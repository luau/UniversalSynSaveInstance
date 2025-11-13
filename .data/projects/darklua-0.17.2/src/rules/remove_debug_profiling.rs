use crate::nodes::{Block, Prefix};
use crate::process::{IdentifierTracker, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::remove_call_match::RemoveFunctionCallProcessor;

const DEBUG_LIBRARY_NAME: &str = "debug";
const START_PROFILE_FUNFCTION: &str = "profilebegin";
const STOP_PROFILE_FUNCTION: &str = "profileend";

pub const REMOVE_DEBUG_PROFILING_RULE_NAME: &str = "remove_debug_profiling";

/// A rule that removes `debug.profilebegin` and `debug.profileend` calls.
#[derive(Debug, PartialEq, Eq)]
pub struct RemoveDebugProfiling {
    preserve_args_side_effects: bool,
}

impl Default for RemoveDebugProfiling {
    fn default() -> Self {
        Self {
            preserve_args_side_effects: true,
        }
    }
}

fn should_remove_call(identifiers: &IdentifierTracker, prefix: &Prefix) -> bool {
    if identifiers.is_identifier_used(DEBUG_LIBRARY_NAME) {
        return false;
    }

    match prefix {
        Prefix::Field(field_expression)
            if field_expression.get_field().get_name() == START_PROFILE_FUNFCTION
                || field_expression.get_field().get_name() == STOP_PROFILE_FUNCTION =>
        {
            matches!(field_expression.get_prefix(), Prefix::Identifier(identifier) if identifier.get_name() == DEBUG_LIBRARY_NAME)
        }
        _ => false,
    }
}

impl FlawlessRule for RemoveDebugProfiling {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor =
            RemoveFunctionCallProcessor::new(self.preserve_args_side_effects, should_remove_call);
        ScopeVisitor::visit_block(block, &mut processor);

        if let Some(statement) = processor.extract_reserved_globals() {
            block.insert_statement(0, statement);
        }
    }
}

impl RuleConfiguration for RemoveDebugProfiling {
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
        REMOVE_DEBUG_PROFILING_RULE_NAME
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

    fn new_rule() -> RemoveDebugProfiling {
        RemoveDebugProfiling::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_debug_profiling", rule);
    }

    #[test]
    fn serialize_rule_without_side_effects() {
        let rule: Box<dyn Rule> = Box::new(RemoveDebugProfiling {
            preserve_args_side_effects: false,
        });

        assert_json_snapshot!("remove_debug_profiling_without_side_effects", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_debug_profiling',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
