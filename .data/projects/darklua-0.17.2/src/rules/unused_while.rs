use crate::nodes::{Block, Statement};
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Clone, Default)]
struct WhileFilter {
    evaluator: Evaluator,
}

impl NodeProcessor for WhileFilter {
    fn process_block(&mut self, block: &mut Block) {
        block.filter_statements(|statement| match statement {
            Statement::While(while_statement) => {
                let condition = while_statement.get_condition();

                self.evaluator.has_side_effects(condition)
                    || self
                        .evaluator
                        .evaluate(condition)
                        .is_truthy()
                        .unwrap_or(true)
            }
            _ => true,
        });
    }
}

pub const REMOVE_UNUSED_WHILE_RULE_NAME: &str = "remove_unused_while";

/// A rule that removes while statements with a known false condition.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveUnusedWhile {}

impl FlawlessRule for RemoveUnusedWhile {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = WhileFilter::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveUnusedWhile {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_UNUSED_WHILE_RULE_NAME
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

    fn new_rule() -> RemoveUnusedWhile {
        RemoveUnusedWhile::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_unused_while", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_unused_while',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
