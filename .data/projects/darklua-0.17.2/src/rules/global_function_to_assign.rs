use crate::nodes::{
    AssignStatement, Block, FieldExpression, FunctionExpression, FunctionStatement, Identifier,
    Statement, Variable,
};
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use serde::ser::{Serialize, Serializer};
use std::mem;

use super::verify_no_rule_properties;

struct Processor;

impl Processor {
    fn convert(&self, function: &mut FunctionStatement) -> Statement {
        let mut function_expression = FunctionExpression::default();
        function_expression.set_variadic(function.is_variadic());
        mem::swap(function_expression.mutate_block(), function.mutate_block());
        mem::swap(
            function_expression.mutate_parameters(),
            function.mutate_parameters(),
        );

        let name = function.get_name();

        let base = name.get_name().clone();

        let fields = name.get_field_names();

        let variable = if fields.is_empty() {
            if let Some(method) = name.get_method() {
                Variable::from(FieldExpression::new(base, method.clone()))
            } else {
                Variable::from(base)
            }
        } else {
            let mut fields_iter = fields.iter().chain(name.get_method()).map(Clone::clone);
            let mut current = FieldExpression::new(base, fields_iter.next().unwrap());
            for field in fields_iter {
                current = FieldExpression::new(current, field.clone());
            }
            Variable::from(current)
        };

        if name.has_method() {
            function_expression
                .mutate_parameters()
                .insert(0, Identifier::new("self").into());
        }

        AssignStatement::from_variable(variable, function_expression).into()
    }
}

impl NodeProcessor for Processor {
    fn process_statement(&mut self, statement: &mut Statement) {
        if let Statement::Function(function) = statement {
            let mut assign = self.convert(function);
            mem::swap(statement, &mut assign)
        };
    }
}

pub const CONVERT_FUNCTION_TO_ASSIGNMENT_RULE_NAME: &str = "convert_function_to_assignment";

/// Convert function statements into regular assignments.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct ConvertFunctionToAssign {}

impl FlawlessRule for ConvertFunctionToAssign {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor;
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ConvertFunctionToAssign {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        CONVERT_FUNCTION_TO_ASSIGNMENT_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

impl Serialize for ConvertFunctionToAssign {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        serializer.serialize_str(CONVERT_FUNCTION_TO_ASSIGNMENT_RULE_NAME)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> ConvertFunctionToAssign {
        ConvertFunctionToAssign::default()
    }

    #[test]
    fn serialize_default_rule() {
        assert_json_snapshot!(new_rule(), @r###""convert_function_to_assignment""###);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_function_to_assignment',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
