use crate::nodes::{Block, Expression, LocalAssignStatement};
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Default)]
struct Processor {
    evaluator: Evaluator,
}

impl NodeProcessor for Processor {
    fn process_local_assign_statement(&mut self, assignment: &mut LocalAssignStatement) {
        {
            let mut pop_extra_value_at = Vec::new();
            for (index, extra_value) in assignment
                .iter_values()
                .enumerate()
                .skip(assignment.variables_len())
            {
                if !self.evaluator.has_side_effects(extra_value) {
                    pop_extra_value_at.push(index);
                }
            }

            for index in pop_extra_value_at.into_iter().rev() {
                assignment.remove_value(index);
            }
        }

        if assignment.values_len() > assignment.variables_len() {
            return;
        }

        let has_nil_value = assignment
            .iter_values()
            .any(|value| matches!(value, Expression::Nil(_)));

        if !has_nil_value {
            return;
        }

        if assignment.variables_len() > assignment.values_len()
            && assignment
                .last_value()
                .filter(|last_value| self.evaluator.can_return_multiple_values(last_value))
                .is_some()
        {
            return;
        }

        let mut remove_values_at = Vec::new();
        for (index, value) in assignment.iter_values().enumerate() {
            if matches!(value, Expression::Nil(_)) {
                remove_values_at.push(index);
            }
        }

        let insert_variables: Vec<_> = remove_values_at
            .into_iter()
            .rev()
            .filter_map(|index| {
                assignment.remove_value(index);
                assignment.remove_variable(index)
            })
            .collect();

        for variable in insert_variables.into_iter().rev() {
            assignment.push_variable(variable);
        }

        if let Some(last_value) = assignment.last_value() {
            if self.evaluator.can_return_multiple_values(last_value) {
                let new_value = assignment.pop_value().unwrap().in_parentheses();
                assignment.push_value(new_value);
            }
        }
    }
}

pub const REMOVE_NIL_DECLARATION_RULE_NAME: &str = "remove_nil_declaration";

/// A rule that removes trailing `nil` in local assignments.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveNilDeclaration {}

impl FlawlessRule for RemoveNilDeclaration {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveNilDeclaration {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_NIL_DECLARATION_RULE_NAME
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

    fn new_rule() -> RemoveNilDeclaration {
        RemoveNilDeclaration::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_nil_declaration", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_nil_declaration',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
