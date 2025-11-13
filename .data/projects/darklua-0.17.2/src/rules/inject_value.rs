use num_traits::ToPrimitive;

use crate::nodes::{Block, Expression, ParentheseExpression, Prefix, StringExpression};
use crate::process::{to_expression, IdentifierTracker, NodeProcessor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
    RulePropertyValue,
};

use std::{env, ops};

use super::{verify_property_collisions, verify_required_properties};

#[derive(Debug, Clone)]
struct ValueInjection {
    identifier: String,
    expression: Expression,
    identifier_tracker: IdentifierTracker,
}

impl ValueInjection {
    pub fn new<S: Into<String>, E: Into<Expression>>(identifier: S, expression: E) -> Self {
        Self {
            identifier: identifier.into(),
            expression: expression.into(),
            identifier_tracker: IdentifierTracker::default(),
        }
    }
}

impl ops::Deref for ValueInjection {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl ops::DerefMut for ValueInjection {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

impl NodeProcessor for ValueInjection {
    fn process_expression(&mut self, expression: &mut Expression) {
        let replace = match expression {
            Expression::Identifier(identifier) => {
                &self.identifier == identifier.get_name()
                    && !self.is_identifier_used(&self.identifier)
            }
            Expression::Field(field) => {
                &self.identifier == field.get_field().get_name()
                    && !self.is_identifier_used("_G")
                    && matches!(field.get_prefix(), Prefix::Identifier(prefix) if prefix.get_name() == "_G")
            }
            Expression::Index(index) => {
                !self.is_identifier_used("_G")
                    && matches!(index.get_index(), Expression::String(string) if string.get_string_value() == Some(&self.identifier))
                    && matches!(index.get_prefix(), Prefix::Identifier(prefix) if prefix.get_name() == "_G")
            }
            _ => false,
        };

        if replace {
            let new_expression = self.expression.clone();
            *expression = new_expression;
        }
    }

    fn process_prefix_expression(&mut self, prefix: &mut Prefix) {
        let replace = match prefix {
            Prefix::Identifier(identifier) => &self.identifier == identifier.get_name(),
            _ => false,
        };

        if replace {
            let new_prefix = ParentheseExpression::new(self.expression.clone()).into();
            *prefix = new_prefix;
        }
    }
}

pub const INJECT_GLOBAL_VALUE_RULE_NAME: &str = "inject_global_value";

/// A rule to replace global variables with values.
#[derive(Debug, PartialEq)]
pub struct InjectGlobalValue {
    identifier: String,
    value: Expression,
    original_properties: RuleProperties,
}

fn properties_with_value(value: impl Into<RulePropertyValue>) -> RuleProperties {
    let mut properties = RuleProperties::new();
    properties.insert("value".to_owned(), value.into());
    properties
}

impl InjectGlobalValue {
    pub fn nil(identifier: impl Into<String>) -> Self {
        Self {
            identifier: identifier.into(),
            value: Expression::nil(),
            original_properties: properties_with_value(RulePropertyValue::None),
        }
    }

    pub fn boolean(identifier: impl Into<String>, value: bool) -> Self {
        Self {
            identifier: identifier.into(),
            value: Expression::from(value),
            original_properties: properties_with_value(value),
        }
    }

    pub fn string(identifier: impl Into<String>, value: impl Into<String>) -> Self {
        let value = value.into();
        let original_properties = properties_with_value(&value);
        Self {
            identifier: identifier.into(),
            value: StringExpression::from_value(value).into(),
            original_properties,
        }
    }

    pub fn number(identifier: impl Into<String>, value: f64) -> Self {
        Self {
            identifier: identifier.into(),
            value: Expression::from(value),
            original_properties: if let Some(integer) = value
                .to_usize()
                .filter(|integer| integer.to_f64() == Some(value))
            {
                properties_with_value(integer)
            } else {
                properties_with_value(value)
            },
        }
    }
}

impl Default for InjectGlobalValue {
    fn default() -> Self {
        Self {
            identifier: "".to_owned(),
            value: Expression::nil(),
            original_properties: RuleProperties::new(),
        }
    }
}

impl FlawlessRule for InjectGlobalValue {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = ValueInjection::new(&self.identifier, self.value.clone());
        ScopeVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for InjectGlobalValue {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_required_properties(&properties, &["identifier"])?;
        verify_property_collisions(&properties, &["value", "env", "env_json"])?;
        verify_property_collisions(&properties, &["value", "default_value"])?;

        let mut default_value_expected = None;
        let mut has_default_value = false;

        self.original_properties = properties.clone();

        for (key, value) in properties {
            match key.as_str() {
                "identifier" => {
                    self.identifier = value.expect_string(&key)?;
                }
                "value" => {
                    if let Some(value) = value.into_expression() {
                        self.value = value
                    } else {
                        return Err(RuleConfigurationError::UnexpectedValueType(key));
                    }
                }
                "default_value" => {
                    has_default_value = true;
                    if let Some(value) = value.into_expression() {
                        self.value = value
                    } else {
                        return Err(RuleConfigurationError::UnexpectedValueType(key));
                    }
                }
                "env" | "env_json" => {
                    let variable_name = value.expect_string(&key)?;
                    if let Some(os_value) = env::var_os(&variable_name) {
                        if let Some(value) = os_value.to_str() {
                            self.value = if key.as_str() == "env_json" {
                                let json_value = json5::from_str::<serde_json::Value>(value).map_err(|err| {
                                    RuleConfigurationError::UnexpectedValue {
                                        property: key.clone(),
                                        message: format!(
                                            "invalid json data assigned to the `{}` environment variable: {}",
                                            &variable_name,
                                            err
                                        ),
                                    }
                                })?;

                                to_expression(&json_value).map_err(|err| {
                                    RuleConfigurationError::UnexpectedValue {
                                        property: key,
                                        message: format!(
                                            "unable to convert json data assigned to the `{}` environment variable to a lua expression: {}",
                                            &variable_name,
                                            err
                                        ),
                                    }
                                })?
                            } else {
                                StringExpression::from_value(value).into()
                            };
                        } else {
                            return Err(RuleConfigurationError::UnexpectedValue {
                                property: key,
                                message: format!(
                                    "invalid string assigned to the `{}` environment variable",
                                    &variable_name,
                                ),
                            });
                        }
                    } else {
                        default_value_expected = Some(variable_name);
                    };
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        if !has_default_value {
            if let Some(variable_name) = default_value_expected {
                log::warn!(
                    "environment variable `{}` is not defined. The rule `{}` will use `nil`",
                    &variable_name,
                    INJECT_GLOBAL_VALUE_RULE_NAME,
                );
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        INJECT_GLOBAL_VALUE_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        let mut rules = self.original_properties.clone();

        rules.insert(
            "identifier".to_owned(),
            RulePropertyValue::String(self.identifier.clone()),
        );

        rules
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    #[test]
    fn configure_without_identifier_property_should_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'inject_global_value',
        }"#,
        );

        insta::assert_snapshot!(result.unwrap_err().to_string(), @"missing required field 'identifier'");
    }

    #[test]
    fn configure_with_value_and_env_properties_should_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'inject_global_value',
            identifier: 'DEV',
            value: false,
            env: "VAR",
        }"#,
        );

        insta::assert_snapshot!(result.unwrap_err().to_string(), @"the fields `value` and `env` cannot be defined together");
    }

    #[test]
    fn configure_with_value_and_default_value_properties_should_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'inject_global_value',
            identifier: 'DEV',
            value: false,
            default_value: true,
        }"#,
        );

        insta::assert_snapshot!(result.unwrap_err().to_string(), @"the fields `value` and `default_value` cannot be defined together");
    }

    #[test]
    fn deserialize_from_string_notation_should_error() {
        let result = json5::from_str::<Box<dyn Rule>>("'inject_global_value'");

        insta::assert_snapshot!(result.unwrap_err().to_string(), @"missing required field 'identifier'");
    }

    #[test]
    fn serialize_inject_nil_as_foo() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::nil("foo"));

        assert_json_snapshot!("inject_nil_value_as_foo", rule);
    }

    #[test]
    fn serialize_inject_true_as_foo() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::boolean("foo", true));

        assert_json_snapshot!("inject_true_value_as_foo", rule);
    }

    #[test]
    fn serialize_inject_false_as_foo() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::boolean("foo", false));

        assert_json_snapshot!("inject_false_value_as_foo", rule);
    }

    #[test]
    fn serialize_inject_string_as_var() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::string("VAR", "hello"));

        assert_json_snapshot!("inject_hello_value_as_var", rule);
    }

    #[test]
    fn serialize_inject_integer_as_var() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::number("VAR", 1.0));

        assert_json_snapshot!("inject_integer_value_as_var", rule);
    }

    #[test]
    fn serialize_inject_negative_integer_as_var() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::number("VAR", -100.0));

        assert_json_snapshot!("inject_negative_integer_value_as_var", rule);
    }

    #[test]
    fn serialize_inject_float_as_var() {
        let rule: Box<dyn Rule> = Box::new(InjectGlobalValue::number("VAR", 123.45));

        assert_json_snapshot!("inject_float_value_as_var", rule);
    }

    #[test]
    fn serialization_round_trip_with_mixed_array() {
        let rule: Box<dyn Rule> = json5::from_str(
            r#"{
            rule: 'inject_global_value',
            identifier: 'foo',
            value: ["hello", true, 1, 0.5, -1.35],
        }"#,
        )
        .unwrap();

        assert_json_snapshot!(rule, @r###"
        {
          "rule": "inject_global_value",
          "identifier": "foo",
          "value": [
            "hello",
            true,
            1,
            0.5,
            -1.35
          ]
        }
        "###);
    }

    #[test]
    fn serialization_round_trip_with_object_value() {
        let rule: Box<dyn Rule> = json5::from_str(
            r#"{
            rule: 'inject_global_value',
            identifier: 'foo',
            value: {
                f0: 'world',
                f1: true,
                f2: 1,
                f3: 0.5,
                f4: -1.35,
                f5: [1, 2, 3],
            },
        }"#,
        )
        .unwrap();

        assert_json_snapshot!(rule, @r###"
        {
          "rule": "inject_global_value",
          "identifier": "foo",
          "value": {
            "f0": "world",
            "f1": true,
            "f2": 1,
            "f3": 0.5,
            "f4": -1.35,
            "f5": [
              1,
              2,
              3
            ]
          }
        }
        "###);
    }
}
