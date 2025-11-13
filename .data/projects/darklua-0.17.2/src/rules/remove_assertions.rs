use std::collections::HashMap;
use std::iter::{self, FromIterator};

use crate::nodes::{Block, Expression, FunctionCall, Prefix, TupleArguments};
use crate::process::{IdentifierTracker, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::remove_call_match::{CallMatch, RemoveFunctionCallProcessor};

const ASSERT_FUNCTION_NAME: &str = "assert";

pub const REMOVE_ASSERTIONS_RULE_NAME: &str = "remove_assertions";

/// A rule that removes `assert` calls.
#[derive(Debug, PartialEq, Eq)]
pub struct RemoveAssertions {
    preserve_args_side_effects: bool,
}

impl Default for RemoveAssertions {
    fn default() -> Self {
        Self {
            preserve_args_side_effects: true,
        }
    }
}

struct AssertMatcher;

impl CallMatch<()> for AssertMatcher {
    fn matches(&self, identifiers: &IdentifierTracker, prefix: &Prefix) -> bool {
        if identifiers.is_identifier_used(ASSERT_FUNCTION_NAME) {
            return false;
        }

        match prefix {
            Prefix::Identifier(identifier) => identifier.get_name() == ASSERT_FUNCTION_NAME,
            _ => false,
        }
    }

    fn compute_result(
        &self,
        call: &FunctionCall,
        mappings: &HashMap<&'static str, String>,
    ) -> Option<Expression> {
        let expressions = call.get_arguments().clone().to_expressions();

        Some(match expressions.len() {
            0 => Expression::nil(),
            1 => expressions
                .into_iter()
                .next()
                .expect("at least one expression is expected"),
            _ => FunctionCall::from_name(
                mappings
                    .get("select")
                    .cloned()
                    .unwrap_or_else(|| "select".to_owned()),
            )
            .with_arguments(TupleArguments::from_iter(
                iter::once(Expression::from(1)).chain(expressions),
            ))
            .into(),
        })
    }

    fn reserve_globals(&self) -> impl Iterator<Item = &'static str> {
        iter::once("select")
    }
}

impl FlawlessRule for RemoveAssertions {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor =
            RemoveFunctionCallProcessor::new(self.preserve_args_side_effects, AssertMatcher);
        ScopeVisitor::visit_block(block, &mut processor);

        if let Some(statement) = processor.extract_reserved_globals() {
            block.insert_statement(0, statement);
        }
    }
}

impl RuleConfiguration for RemoveAssertions {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        for (key, value) in properties {
            match key.as_str() {
                "preserve_arguments_side_effects" => {
                    self.preserve_args_side_effects = value.expect_bool(&key)?;
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_ASSERTIONS_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        let mut properties = RuleProperties::new();

        if !self.preserve_args_side_effects {
            properties.insert("preserve_arguments_side_effects".to_owned(), false.into());
        }

        properties
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveAssertions {
        RemoveAssertions::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_assertions", rule);
    }

    #[test]
    fn serialize_rule_without_side_effects() {
        let rule: Box<dyn Rule> = Box::new(RemoveAssertions {
            preserve_args_side_effects: false,
        });

        assert_json_snapshot!("remove_assertions_without_side_effects", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_assertions',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
