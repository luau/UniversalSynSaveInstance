use crate::nodes::{Block, LastStatement, Statement};
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Clone, Default)]
struct Processor {}

impl Processor {
    fn search_remove_after(block: &Block) -> Option<usize> {
        block
            .iter_statements()
            .enumerate()
            .find_map(|(i, statement)| match statement {
                Statement::Do(do_statement) => {
                    let inner_block = do_statement.get_block();
                    if let Some(last_statement) = inner_block.get_last_statement() {
                        match last_statement {
                            LastStatement::Break(_) => None,
                            LastStatement::Continue(_) => None,
                            LastStatement::Return(_) => Some(i),
                        }
                    } else {
                        Self::search_remove_after(inner_block).map(|_| i)
                    }
                }
                Statement::Assign(_)
                | Statement::Call(_)
                | Statement::CompoundAssign(_)
                | Statement::Function(_)
                | Statement::GenericFor(_)
                | Statement::If(_)
                | Statement::LocalAssign(_)
                | Statement::LocalFunction(_)
                | Statement::NumericFor(_)
                | Statement::Repeat(_)
                | Statement::While(_)
                | Statement::TypeDeclaration(_) => None,
            })
    }
}

impl NodeProcessor for Processor {
    fn process_block(&mut self, block: &mut Block) {
        if let Some(remove_after) = Self::search_remove_after(block) {
            block.take_last_statement();
            block.truncate(remove_after + 1);
        }
    }
}

pub const FILTER_AFTER_EARLY_RETURN_RULE_NAME: &str = "filter_after_early_return";

/// A rule that removes statements that will never be executed because of an earlier
/// `return` statement.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct FilterAfterEarlyReturn {}

impl FlawlessRule for FilterAfterEarlyReturn {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::default();

        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for FilterAfterEarlyReturn {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)
    }

    fn get_name(&self) -> &'static str {
        FILTER_AFTER_EARLY_RETURN_RULE_NAME
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

    fn new_rule() -> FilterAfterEarlyReturn {
        FilterAfterEarlyReturn::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_filter_after_early_return", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'filter_after_early_return',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
