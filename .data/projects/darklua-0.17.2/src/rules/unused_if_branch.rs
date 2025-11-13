use crate::nodes::{Block, DoStatement, Expression, IfExpression, IfStatement, Statement};
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

enum FilterResult {
    Keep,
    Remove,
    Replace(Box<Statement>),
}

#[derive(Debug, Clone, Default)]
struct IfFilter {
    evaluator: Evaluator,
}

impl IfFilter {
    fn simplify_if_statement(&self, if_statement: &mut IfStatement) -> FilterResult {
        if let Some(else_block) = if_statement.get_else_block() {
            if else_block.is_empty() {
                if_statement.take_else_block();
            }
        }

        let mut keep_next_branches = true;
        let mut replace_else_with = None;

        let is_empty = if_statement.retain_branches_mut(|branch| {
            keep_next_branches && {
                let branch_condition_value = self.evaluator.evaluate(branch.get_condition());
                match branch_condition_value.is_truthy() {
                    Some(true) => {
                        keep_next_branches = false;

                        if self.evaluator.has_side_effects(branch.get_condition()) {
                            true
                        } else {
                            replace_else_with = Some(branch.take_block());
                            false
                        }
                    }
                    Some(false) => {
                        if self.evaluator.has_side_effects(branch.get_condition()) {
                            branch.take_block();
                            true
                        } else {
                            false
                        }
                    }
                    None => true,
                }
            }
        });

        if is_empty {
            if let Some(block_replacer) = replace_else_with {
                if block_replacer.is_empty() {
                    FilterResult::Remove
                } else {
                    FilterResult::Replace(Box::new(DoStatement::new(block_replacer).into()))
                }
            } else if let Some(else_block) = if_statement.take_else_block() {
                if else_block.is_empty() {
                    FilterResult::Remove
                } else {
                    FilterResult::Replace(Box::new(DoStatement::new(else_block).into()))
                }
            } else {
                FilterResult::Remove
            }
        } else {
            if !keep_next_branches {
                if let Some(block_replacer) = replace_else_with {
                    if_statement.set_else_block(block_replacer);
                } else {
                    if_statement.take_else_block();
                }
            }
            FilterResult::Keep
        }
    }

    fn simplify_if(&self, if_expression: &mut IfExpression) -> Option<Expression> {
        let condition_value = self.evaluator.evaluate(if_expression.get_condition());
        match condition_value.is_truthy() {
            Some(true) => {
                if self
                    .evaluator
                    .has_side_effects(if_expression.get_condition())
                {
                    if_expression.clear_elseif_branches();
                    *if_expression.mutate_else_result() = Self::result_placeholder();
                    None
                } else {
                    let result = if_expression.get_result().clone();

                    Some(if self.evaluator.can_return_multiple_values(&result) {
                        result.in_parentheses()
                    } else {
                        result
                    })
                }
            }
            Some(false) => {
                if self
                    .evaluator
                    .has_side_effects(if_expression.get_condition())
                {
                    *if_expression.mutate_result() = Self::result_placeholder();
                    None
                } else if let Some(branch) = if_expression.remove_branch(0) {
                    let (new_condition, new_result) = branch.into_expressions();
                    *if_expression.mutate_condition() = new_condition;
                    *if_expression.mutate_result() = new_result;
                    self.simplify_if(if_expression)
                } else {
                    let result = if_expression.get_else_result().clone();

                    Some(if self.evaluator.can_return_multiple_values(&result) {
                        result.in_parentheses()
                    } else {
                        result
                    })
                }
            }
            None => {
                let mut keep_next_branches = true;
                let mut replace_else_with = None;

                if_expression.retain_elseif_branches_mut(|branch| {
                    keep_next_branches && {
                        let branch_condition_value =
                            self.evaluator.evaluate(branch.get_condition());
                        match branch_condition_value.is_truthy() {
                            Some(true) => {
                                keep_next_branches = false;

                                if self.evaluator.has_side_effects(branch.get_condition()) {
                                    true
                                } else {
                                    replace_else_with = Some(branch.get_result().clone());
                                    false
                                }
                            }
                            Some(false) => {
                                if self.evaluator.has_side_effects(branch.get_condition()) {
                                    *branch.mutate_result() = Self::result_placeholder();
                                    true
                                } else {
                                    false
                                }
                            }
                            None => true,
                        }
                    }
                });

                if !keep_next_branches {
                    *if_expression.mutate_else_result() =
                        replace_else_with.unwrap_or_else(Self::result_placeholder);
                }
                None
            }
        }
    }

    fn result_placeholder() -> Expression {
        Expression::nil()
    }
}

impl NodeProcessor for IfFilter {
    fn process_block(&mut self, block: &mut Block) {
        block.filter_mut_statements(|statement| {
            if let Statement::If(if_statement) = statement {
                match self.simplify_if_statement(if_statement) {
                    FilterResult::Keep => true,
                    FilterResult::Remove => false,
                    FilterResult::Replace(new_statement) => {
                        *statement = *new_statement;
                        true
                    }
                }
            } else {
                true
            }
        });
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::If(if_expression) = expression {
            if let Some(replace_with) = self.simplify_if(if_expression) {
                *expression = replace_with;
            }
        }
    }
}

pub const REMOVE_UNUSED_IF_BRANCH_RULE_NAME: &str = "remove_unused_if_branch";

/// A rule that removes unused if branches. It can also turn a if statement into a do block
/// statement.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveUnusedIfBranch {}

impl FlawlessRule for RemoveUnusedIfBranch {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = IfFilter::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveUnusedIfBranch {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_UNUSED_IF_BRANCH_RULE_NAME
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

    fn new_rule() -> RemoveUnusedIfBranch {
        RemoveUnusedIfBranch::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_unused_if_branch", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_unused_if_branch',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
