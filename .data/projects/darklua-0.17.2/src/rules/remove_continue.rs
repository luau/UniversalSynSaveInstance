use std::fmt::Debug;
use std::mem;

use crate::nodes::{
    AssignStatement, Block, GenericForStatement, Identifier, IfStatement, LastStatement,
    LocalAssignStatement, NumericForStatement, RepeatStatement, UnaryExpression, UnaryOperator,
    WhileStatement,
};
use crate::process::{DefaultPostVisitor, NodePostProcessor, NodePostVisitor, NodeProcessor};
use crate::rules::{Context, RuleConfiguration, RuleConfigurationError, RuleProperties};

use super::{verify_no_rule_properties, FlawlessRule};

#[derive(Default)]
struct Processor {
    loop_stack: Vec<Option<LoopData>>,
    loop_identifier_count: u16,
}

struct LoopData {
    has_continue_statement: bool,
    loop_break_id: u16,
}

impl LoopData {
    fn new(loop_break_id: u16) -> Self {
        Self {
            has_continue_statement: false,
            loop_break_id,
        }
    }

    fn get_identifier(&self) -> Identifier {
        Identifier::new(format!("__DARKLUA_CONTINUE_{}", self.loop_break_id))
    }
}

impl Processor {
    fn push_loop(&mut self) {
        self.loop_identifier_count += 1;
        self.loop_stack
            .push(Some(LoopData::new(self.loop_identifier_count)));
    }

    fn push_no_loop(&mut self) {
        self.loop_stack.push(None);
    }

    fn wrap_loop_block_if_needed(&mut self, block: &mut Block) {
        if let Some(loop_data) = self.loop_stack.pop().flatten() {
            if !loop_data.has_continue_statement {
                return;
            }
            let mut current_loop_block = mem::take(block);

            if current_loop_block.get_last_statement().is_none() {
                current_loop_block.push_statement(AssignStatement::from_variable(
                    loop_data.get_identifier(),
                    true,
                ));
            }

            let new_block = Block::default()
                .with_statement(
                    LocalAssignStatement::from_variable(loop_data.get_identifier())
                        .with_value(false),
                )
                .with_statement(RepeatStatement::new(current_loop_block, true))
                .with_statement(IfStatement::create(
                    UnaryExpression::new(UnaryOperator::Not, loop_data.get_identifier()),
                    LastStatement::Break(None),
                ));

            *block = new_block;
        }
    }
}

impl NodeProcessor for Processor {
    fn process_generic_for_statement(&mut self, _: &mut GenericForStatement) {
        self.push_loop();
    }

    fn process_numeric_for_statement(&mut self, _: &mut NumericForStatement) {
        self.push_loop();
    }

    fn process_repeat_statement(&mut self, _: &mut RepeatStatement) {
        self.push_loop();
    }

    fn process_while_statement(&mut self, _: &mut WhileStatement) {
        self.push_loop();
    }

    fn process_function_statement(&mut self, _: &mut crate::nodes::FunctionStatement) {
        self.push_no_loop();
    }

    fn process_function_expression(&mut self, _: &mut crate::nodes::FunctionExpression) {
        self.push_no_loop();
    }

    fn process_block(&mut self, block: &mut Block) {
        let new_statement =
            block
                .mutate_last_statement()
                .and_then(|last_statement| match last_statement {
                    LastStatement::Continue(continue_token) => {
                        if let Some(Some(loop_data)) = self.loop_stack.last_mut() {
                            if !loop_data.has_continue_statement {
                                loop_data.has_continue_statement = true;
                            }

                            *last_statement = LastStatement::Break(continue_token.take().map(
                                |mut continue_token| {
                                    continue_token.replace_with_content("break");
                                    continue_token
                                },
                            ));

                            Some(AssignStatement::from_variable(
                                loop_data.get_identifier(),
                                true,
                            ))
                        } else {
                            None
                        }
                    }
                    _ => None,
                });

        if let Some(statement) = new_statement {
            block.push_statement(statement);
        }
    }
}

impl NodePostProcessor for Processor {
    fn process_after_generic_for_statement(&mut self, statement: &mut GenericForStatement) {
        self.wrap_loop_block_if_needed(statement.mutate_block());
    }

    fn process_after_numeric_for_statement(&mut self, statement: &mut NumericForStatement) {
        self.wrap_loop_block_if_needed(statement.mutate_block());
    }

    fn process_after_repeat_statement(&mut self, statement: &mut RepeatStatement) {
        self.wrap_loop_block_if_needed(statement.mutate_block());
    }

    fn process_after_while_statement(&mut self, statement: &mut WhileStatement) {
        self.wrap_loop_block_if_needed(statement.mutate_block());
    }

    fn process_after_function_statement(&mut self, _: &mut crate::nodes::FunctionStatement) {
        self.loop_stack.pop();
    }

    fn process_after_function_expression(&mut self, _: &mut crate::nodes::FunctionExpression) {
        self.loop_stack.pop();
    }
}

pub const REMOVE_CONTINUE_RULE_NAME: &str = "remove_continue";

/// A rule that removes continue statements and converts them into break statements.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveContinue {}

impl FlawlessRule for RemoveContinue {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::default();
        DefaultPostVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveContinue {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_CONTINUE_RULE_NAME
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

    fn new_rule() -> RemoveContinue {
        RemoveContinue::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_continue", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_continue',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
