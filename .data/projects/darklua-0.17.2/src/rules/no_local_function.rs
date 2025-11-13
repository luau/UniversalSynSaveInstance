use crate::nodes::{
    Block, FunctionExpression, LocalAssignStatement, LocalFunctionStatement, Statement,
};
use crate::process::{processors::FindVariables, DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use serde::ser::{Serialize, Serializer};
use std::mem;

use super::verify_no_rule_properties;

struct Processor;

impl Processor {
    fn convert(&self, local_function: &mut LocalFunctionStatement) -> Statement {
        let mut function_expression = FunctionExpression::default();
        function_expression.set_variadic(local_function.is_variadic());
        mem::swap(
            function_expression.mutate_block(),
            local_function.mutate_block(),
        );
        mem::swap(
            function_expression.mutate_parameters(),
            local_function.mutate_parameters(),
        );

        LocalAssignStatement::from_variable(local_function.get_name())
            .with_value(function_expression)
            .into()
    }
}

impl NodeProcessor for Processor {
    fn process_statement(&mut self, statement: &mut Statement) {
        if let Statement::LocalFunction(local_function) = statement {
            let name = local_function.get_name().to_owned();

            if local_function.has_parameter(&name) {
                let mut assign = self.convert(local_function);
                mem::swap(statement, &mut assign)
            } else {
                let mut find_usage = FindVariables::new(&name);
                DefaultVisitor::visit_block(local_function.mutate_block(), &mut find_usage);

                if !find_usage.has_found_usage() {
                    let mut assign = self.convert(local_function);
                    mem::swap(statement, &mut assign)
                }
            }
        };
    }
}

pub const CONVERT_LOCAL_FUNCTION_TO_ASSIGN_RULE_NAME: &str = "convert_local_function_to_assign";

/// Convert local function statements into local assignements when the function is not recursive.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct ConvertLocalFunctionToAssign {}

impl FlawlessRule for ConvertLocalFunctionToAssign {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor;
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ConvertLocalFunctionToAssign {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        CONVERT_LOCAL_FUNCTION_TO_ASSIGN_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

impl Serialize for ConvertLocalFunctionToAssign {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        serializer.serialize_str(CONVERT_LOCAL_FUNCTION_TO_ASSIGN_RULE_NAME)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> ConvertLocalFunctionToAssign {
        ConvertLocalFunctionToAssign::default()
    }

    #[test]
    fn serialize_default_rule() {
        assert_json_snapshot!("default_convert_local_function_to_assign", new_rule());
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_local_function_to_assign',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
