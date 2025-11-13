use crate::nodes::{BinaryOperator, Block, Expression};
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Clone, Default)]
struct Computer {
    evaluator: Evaluator,
}

impl Computer {
    fn replace_with(&mut self, expression: &Expression) -> Option<Expression> {
        match expression {
            Expression::Unary(_) => {
                if !self.evaluator.has_side_effects(expression) {
                    self.evaluator.evaluate(expression).to_expression()
                } else {
                    None
                }
            }
            Expression::Binary(binary) => {
                if !self.evaluator.has_side_effects(expression) {
                    self.evaluator
                        .evaluate(expression)
                        .to_expression()
                        .or_else(|| {
                            match binary.operator() {
                                BinaryOperator::And => {
                                    self.evaluator.evaluate(binary.left()).is_truthy().map(
                                        |is_truthy| {
                                            if is_truthy {
                                                binary.right().clone()
                                            } else {
                                                binary.left().clone()
                                            }
                                        },
                                    )
                                }
                                BinaryOperator::Or => {
                                    self.evaluator.evaluate(binary.left()).is_truthy().map(
                                        |is_truthy| {
                                            if is_truthy {
                                                binary.left().clone()
                                            } else {
                                                binary.right().clone()
                                            }
                                        },
                                    )
                                }
                                _ => None,
                            }
                            .map(|mut expression| {
                                self.process_expression(&mut expression);
                                expression
                            })
                        })
                } else {
                    match binary.operator() {
                        BinaryOperator::And => {
                            if !self.evaluator.has_side_effects(binary.left()) {
                                self.evaluator.evaluate(binary.left()).is_truthy().map(
                                    |is_truthy| {
                                        if is_truthy {
                                            binary.right().clone()
                                        } else {
                                            binary.left().clone()
                                        }
                                    },
                                )
                            } else {
                                None
                            }
                        }
                        BinaryOperator::Or => {
                            if !self.evaluator.has_side_effects(binary.left()) {
                                self.evaluator.evaluate(binary.left()).is_truthy().map(
                                    |is_truthy| {
                                        if is_truthy {
                                            binary.left().clone()
                                        } else {
                                            binary.right().clone()
                                        }
                                    },
                                )
                            } else {
                                None
                            }
                        }
                        _ => None,
                    }
                }
            }
            Expression::If(_) => {
                if !self.evaluator.has_side_effects(expression) {
                    self.evaluator.evaluate(expression).to_expression()
                } else {
                    None
                }
            }
            _ => None,
        }
    }
}

impl NodeProcessor for Computer {
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Some(replace_with) = self.replace_with(expression) {
            *expression = replace_with;
        }
    }
}

pub const COMPUTE_EXPRESSIONS_RULE_NAME: &str = "compute_expression";

/// A rule that compute expressions that do not have any side-effects.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct ComputeExpression {}

impl FlawlessRule for ComputeExpression {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Computer::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ComputeExpression {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        COMPUTE_EXPRESSIONS_RULE_NAME
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

    fn new_rule() -> ComputeExpression {
        ComputeExpression::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_compute_expression", rule);
    }
}
