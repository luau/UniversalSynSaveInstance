use crate::nodes::*;
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Default)]
struct RemoveTypesProcessor {
    evaluator: Evaluator,
}

impl NodeProcessor for RemoveTypesProcessor {
    fn process_block(&mut self, block: &mut Block) {
        block.filter_statements(|statement| !matches!(statement, Statement::TypeDeclaration(_)));
    }

    fn process_local_assign_statement(&mut self, local_assign: &mut LocalAssignStatement) {
        local_assign.clear_types();
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.clear_types();
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.clear_types();
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.clear_types();
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.clear_types();
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.clear_types();
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::TypeCast(type_cast) => {
                let value = type_cast.get_expression();
                if self.evaluator.can_return_multiple_values(value) {
                    *expression = value.clone().in_parentheses();
                } else {
                    *expression = value.clone();
                }
            }
            Expression::Function(function) => {
                function.clear_types();
            }
            _ => {}
        }
    }
}

pub const REMOVE_TYPES_RULE_NAME: &str = "remove_types";

/// A rule that removes Luau types from all AST nodes.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveTypes {}

impl FlawlessRule for RemoveTypes {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = RemoveTypesProcessor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveTypes {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_TYPES_RULE_NAME
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

    fn new_rule() -> RemoveTypes {
        RemoveTypes::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_types", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_types',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
