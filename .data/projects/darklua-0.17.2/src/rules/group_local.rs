use crate::nodes::{Block, Expression, LocalAssignStatement, Statement};
use crate::process::processors::FindVariables;
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use std::iter;

use super::verify_no_rule_properties;

#[derive(Debug, Clone, Default)]
struct GroupLocalProcessor {}

impl GroupLocalProcessor {
    fn filter_statements(&self, block: &mut Block) -> Vec<Statement> {
        let mut statements = block.take_statements();
        let mut filter_statements = Vec::new();
        let mut iter = statements.drain(..);
        let mut previous_statement = iter.next();
        let mut current_statement = iter.next();

        while let Some(current) = current_statement {
            previous_statement = if let Some(previous) = previous_statement {
                use Statement::LocalAssign;

                match (previous, current) {
                    (LocalAssign(mut previous), LocalAssign(mut current)) => {
                        if self.should_merge(&previous, &mut current) {
                            self.merge(&mut previous, current);

                            Some(LocalAssign(previous))
                        } else {
                            filter_statements.push(LocalAssign(previous));
                            Some(LocalAssign(current))
                        }
                    }
                    (previous, current) => {
                        filter_statements.push(previous);
                        Some(current)
                    }
                }
            } else {
                None
            };

            current_statement = iter.next();
        }

        if let Some(previous) = previous_statement {
            filter_statements.push(previous);
        }

        filter_statements
    }

    fn should_merge(&self, first: &LocalAssignStatement, next: &mut LocalAssignStatement) -> bool {
        let first_value_count = first.values_len();

        if first.variables_len() > first_value_count && first_value_count != 0 {
            return false;
        }

        let mut find_variables: FindVariables = first
            .iter_variables()
            .map(|variable| variable.get_name().as_str())
            .collect();

        next.iter_mut_values().all(|expression| {
            DefaultVisitor::visit_expression(expression, &mut find_variables);
            !find_variables.has_found_usage()
        })
    }

    fn merge(&self, first: &mut LocalAssignStatement, mut other: LocalAssignStatement) {
        if first.values_len() == 0 && other.values_len() != 0 {
            let variable_count = first.variables_len();
            first.extend_values(iter::repeat_n(Expression::nil(), variable_count));
        }

        if other.values_len() == 0 && first.values_len() != 0 {
            let variable_count = other.variables_len();
            other.extend_values(iter::repeat_n(Expression::nil(), variable_count));
        }

        let (mut variables, mut values) = other.into_assignments();
        first.append_variables(&mut variables);
        first.append_values(&mut values);
    }
}

impl NodeProcessor for GroupLocalProcessor {
    fn process_block(&mut self, block: &mut Block) {
        let filter_statements = self.filter_statements(block);

        block.set_statements(filter_statements);
    }
}

pub const GROUP_LOCAL_ASSIGNMENT_RULE_NAME: &str = "group_local_assignment";

/// Group local assign statements into one statement.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct GroupLocalAssignment {}

impl FlawlessRule for GroupLocalAssignment {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = GroupLocalProcessor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for GroupLocalAssignment {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        GROUP_LOCAL_ASSIGNMENT_RULE_NAME
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

    fn new_rule() -> GroupLocalAssignment {
        GroupLocalAssignment::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_group_local_assignment", rule);
    }
}
