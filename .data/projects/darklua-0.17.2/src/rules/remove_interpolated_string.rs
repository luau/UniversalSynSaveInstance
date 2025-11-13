use std::{iter, ops};

use bstr::ByteSlice;

use crate::nodes::{
    Block, Expression, FieldExpression, FunctionCall, Identifier, InterpolatedStringExpression,
    InterpolationSegment, LocalAssignStatement, Prefix, StringExpression, TupleArguments,
    TypedIdentifier,
};
use crate::process::{IdentifierTracker, NodeProcessor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ReplacementStrategy {
    StringSpecifier,
    ToStringSpecifier,
}

impl Default for ReplacementStrategy {
    fn default() -> Self {
        Self::StringSpecifier
    }
}

struct RemoveInterpolatedStringProcessor {
    string_format_identifier: String,
    tostring_identifier: String,
    define_string_format: bool,
    define_tostring: bool,
    identifier_tracker: IdentifierTracker,
    strategy: ReplacementStrategy,
}

impl ops::Deref for RemoveInterpolatedStringProcessor {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl ops::DerefMut for RemoveInterpolatedStringProcessor {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

const DEFAULT_TOSTRING_IDENTIFIER: &str = "tostring";
const DEFAULT_STRING_LIBRARY: &str = "string";
const DEFAULT_STRING_FORMAT_NAME: &str = "format";

impl RemoveInterpolatedStringProcessor {
    fn new(
        strategy: ReplacementStrategy,
        string_format_identifier: impl Into<String>,
        tostring_identifier: impl Into<String>,
    ) -> Self {
        Self {
            string_format_identifier: string_format_identifier.into(),
            tostring_identifier: tostring_identifier.into(),
            define_string_format: false,
            define_tostring: false,
            identifier_tracker: Default::default(),
            strategy,
        }
    }

    fn replace_with(&mut self, string: &InterpolatedStringExpression) -> Expression {
        if string.is_empty() {
            StringExpression::from_value("").into()
        } else if string.len() == 1 {
            match string.iter_segments().next().unwrap() {
                InterpolationSegment::String(string_segment) => {
                    StringExpression::from_value(string_segment.get_value()).into()
                }
                InterpolationSegment::Value(value_segment) => FunctionCall::from_name(
                    if self.is_identifier_used(DEFAULT_TOSTRING_IDENTIFIER) {
                        self.define_tostring = true;
                        &self.tostring_identifier
                    } else {
                        DEFAULT_TOSTRING_IDENTIFIER
                    },
                )
                .with_argument(value_segment.get_expression().clone())
                .into(),
            }
        } else {
            let arguments = iter::once(
                StringExpression::from_value(string.iter_segments().fold(
                    Vec::new(),
                    |mut format_string, segment| {
                        match segment {
                            InterpolationSegment::String(string_segment) => {
                                format_string.extend_from_slice(
                                    &string_segment.get_value().replace(b"%", b"%%"),
                                );
                            }
                            InterpolationSegment::Value(_) => {
                                format_string.extend_from_slice(match self.strategy {
                                    ReplacementStrategy::StringSpecifier => b"%s",
                                    ReplacementStrategy::ToStringSpecifier => b"%*",
                                });
                            }
                        }
                        format_string
                    },
                ))
                .into(),
            )
            .chain(
                string
                    .iter_segments()
                    .filter_map(|segment| match segment {
                        InterpolationSegment::Value(segment) => {
                            Some(segment.get_expression().clone())
                        }
                        InterpolationSegment::String(_) => None,
                    })
                    .map(|value| match self.strategy {
                        ReplacementStrategy::ToStringSpecifier => value,
                        ReplacementStrategy::StringSpecifier => FunctionCall::from_name(
                            if self.is_identifier_used(DEFAULT_TOSTRING_IDENTIFIER) {
                                self.define_tostring = true;
                                &self.tostring_identifier
                            } else {
                                DEFAULT_TOSTRING_IDENTIFIER
                            },
                        )
                        .with_argument(value)
                        .into(),
                    }),
            )
            .collect::<TupleArguments>();

            FunctionCall::from_prefix(if self.is_identifier_used(DEFAULT_STRING_LIBRARY) {
                self.define_string_format = true;
                Prefix::from_name(&self.string_format_identifier)
            } else {
                FieldExpression::new(
                    Prefix::from_name(DEFAULT_STRING_LIBRARY),
                    DEFAULT_STRING_FORMAT_NAME,
                )
                .into()
            })
            .with_arguments(arguments)
            .into()
        }
    }
}

impl NodeProcessor for RemoveInterpolatedStringProcessor {
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::InterpolatedString(string) = expression {
            *expression = self.replace_with(string);
        }
    }
}

pub const REMOVE_INTERPOLATED_STRING_RULE_NAME: &str = "remove_interpolated_string";

/// A rule that removes interpolated strings.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveInterpolatedString {
    strategy: ReplacementStrategy,
}

impl FlawlessRule for RemoveInterpolatedString {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        const STRING_FORMAT_IDENTIFIER: &str = "__DARKLUA_STR_FMT";
        const TOSTRING_IDENTIFIER: &str = "__DARKLUA_TO_STR";

        let mut processor = RemoveInterpolatedStringProcessor::new(
            self.strategy,
            STRING_FORMAT_IDENTIFIER,
            TOSTRING_IDENTIFIER,
        );
        ScopeVisitor::visit_block(block, &mut processor);

        if processor.define_string_format || processor.define_tostring {
            let mut variables = Vec::new();
            let mut values = Vec::new();

            if processor.define_string_format {
                variables.push(TypedIdentifier::new(STRING_FORMAT_IDENTIFIER));
                values.push(
                    FieldExpression::new(
                        Prefix::from_name(DEFAULT_STRING_LIBRARY),
                        DEFAULT_STRING_FORMAT_NAME,
                    )
                    .into(),
                );
            }

            if processor.define_tostring {
                variables.push(TypedIdentifier::new(TOSTRING_IDENTIFIER));
                values.push(Identifier::new(DEFAULT_TOSTRING_IDENTIFIER).into());
            }

            block.insert_statement(0, LocalAssignStatement::new(variables, values));
        }
    }
}

impl RuleConfiguration for RemoveInterpolatedString {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        for (key, value) in properties {
            match key.as_str() {
                "strategy" => {
                    self.strategy = match value.expect_string(&key)?.as_str() {
                        "string" => ReplacementStrategy::StringSpecifier,
                        "tostring" => ReplacementStrategy::ToStringSpecifier,
                        unexpected => {
                            return Err(RuleConfigurationError::UnexpectedValue {
                                property: "strategy".to_owned(),
                                message: format!(
                                    "invalid value `{}` (must be `string` or `tostring`)",
                                    unexpected
                                ),
                            })
                        }
                    };
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_INTERPOLATED_STRING_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        let mut properties = RuleProperties::new();

        match self.strategy {
            ReplacementStrategy::StringSpecifier => {}
            ReplacementStrategy::ToStringSpecifier => {
                properties.insert("strategy".to_owned(), "tostring".into());
            }
        }

        properties
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveInterpolatedString {
        RemoveInterpolatedString::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_interpolated_string", rule);
    }

    #[test]
    fn serialize_rule_with_tostring_strategy() {
        let rule: Box<dyn Rule> = Box::new(RemoveInterpolatedString {
            strategy: ReplacementStrategy::ToStringSpecifier,
        });

        assert_json_snapshot!("remove_interpolated_string_tostring_strategy", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_interpolated_string',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
