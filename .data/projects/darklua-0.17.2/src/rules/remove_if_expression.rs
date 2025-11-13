use crate::nodes::{
    BinaryExpression, BinaryOperator, Block, Expression, IndexExpression, TableEntry,
    TableExpression,
};
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Default)]
struct Processor {
    evaluator: Evaluator,
}

impl Processor {
    fn wrap_in_table(&self, expression: Expression) -> Expression {
        TableExpression::new(vec![TableEntry::from_value({
            if self.evaluator.can_return_multiple_values(&expression) {
                expression.in_parentheses()
            } else {
                expression
            }
        })])
        .into()
    }

    fn convert_if_branch(
        &self,
        condition: Expression,
        result: Expression,
        else_result: Expression,
    ) -> Expression {
        if self
            .evaluator
            .evaluate(&result)
            .is_truthy()
            .unwrap_or_default()
        {
            BinaryExpression::new(
                BinaryOperator::Or,
                BinaryExpression::new(BinaryOperator::And, condition, result),
                else_result,
            )
            .into()
        } else {
            IndexExpression::new(
                Expression::from(BinaryExpression::new(
                    BinaryOperator::Or,
                    BinaryExpression::new(
                        BinaryOperator::And,
                        condition,
                        self.wrap_in_table(result),
                    ),
                    self.wrap_in_table(else_result),
                )),
                Expression::from(1),
            )
            .into()
        }
    }
}

impl NodeProcessor for Processor {
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::If(if_expression) = expression {
            let else_result = if_expression.iter_branches().fold(
                if_expression.get_else_result().clone(),
                |else_result, branch| {
                    self.convert_if_branch(
                        branch.get_condition().clone(),
                        branch.get_result().clone(),
                        else_result,
                    )
                },
            );

            *expression = self.convert_if_branch(
                if_expression.get_condition().clone(),
                if_expression.get_result().clone(),
                else_result,
            );
        }
    }
}

pub const REMOVE_IF_EXPRESSION_RULE_NAME: &str = "remove_if_expression";

/// A rule that removes trailing `nil` in local assignments.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveIfExpression {}

impl FlawlessRule for RemoveIfExpression {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveIfExpression {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_IF_EXPRESSION_RULE_NAME
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

    fn new_rule() -> RemoveIfExpression {
        RemoveIfExpression::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_if_expression", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_if_expression',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
