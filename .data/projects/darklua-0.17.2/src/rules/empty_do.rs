use crate::nodes::{Block, Statement};
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Default)]
struct EmptyDoFilter {
    mutated: bool,
}

impl EmptyDoFilter {
    pub fn has_mutated(&self) -> bool {
        self.mutated
    }
}

impl NodeProcessor for EmptyDoFilter {
    fn process_block(&mut self, block: &mut Block) {
        block.filter_statements(|statement| match statement {
            Statement::Do(do_statement) => {
                self.mutated = do_statement.get_block().is_empty();
                !self.mutated
            }
            _ => true,
        });
    }
}

pub const REMOVE_EMPTY_DO_RULE_NAME: &str = "remove_empty_do";

/// A rule that removes empty do statements.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveEmptyDo {}

impl FlawlessRule for RemoveEmptyDo {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        loop {
            let mut processor = EmptyDoFilter::default();
            DefaultVisitor::visit_block(block, &mut processor);
            if !processor.has_mutated() {
                break;
            }
        }
    }
}

impl RuleConfiguration for RemoveEmptyDo {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_EMPTY_DO_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::nodes::DoStatement;
    use crate::rules::{ContextBuilder, Rule};
    use crate::Resources;

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveEmptyDo {
        RemoveEmptyDo::default()
    }

    #[test]
    fn remove_empty_do_statement() {
        let rule = new_rule();

        let mut block = Block::default().with_statement(DoStatement::new(Block::default()));

        rule.process(
            &mut block,
            &ContextBuilder::new(".", &Resources::from_memory(), "").build(),
        )
        .expect("rule should succeed");

        assert_eq!(block, Block::default());
    }

    #[test]
    fn remove_nested_empty_do_statement() {
        let rule = new_rule();

        let block_with_do_statement = Block::default().with_statement(DoStatement::default());
        let mut block = Block::default().with_statement(DoStatement::new(block_with_do_statement));

        rule.process(
            &mut block,
            &ContextBuilder::new(".", &Resources::from_memory(), "").build(),
        )
        .expect("rule should succeed");

        assert_eq!(block, Block::default());
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_empty_do", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_empty_do',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
