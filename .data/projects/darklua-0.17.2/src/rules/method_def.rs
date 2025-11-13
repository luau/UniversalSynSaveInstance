use crate::nodes::{Block, FunctionStatement};
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

struct FunctionMutator;

impl NodeProcessor for FunctionMutator {
    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.remove_method();
    }
}

pub const REMOVE_METHOD_DEFINITION_RULE_NAME: &str = "remove_method_definition";

/// Change method functions into regular functions.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveMethodDefinition {}

impl FlawlessRule for RemoveMethodDefinition {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = FunctionMutator;
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveMethodDefinition {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_METHOD_DEFINITION_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveMethodDefinition {
        RemoveMethodDefinition::default()
    }

    fn wrap(rule: RemoveMethodDefinition) -> Box<dyn Rule> {
        Box::new(rule)
    }

    #[test]
    fn serialize_default_rule() {
        assert_json_snapshot!("default_remove_method_definition", wrap(new_rule()));
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_method_definition',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
