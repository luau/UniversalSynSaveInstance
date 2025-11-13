use crate::nodes::*;
use crate::process::processors::FindUsage;
use crate::process::{DefaultVisitor, Evaluator, NodeProcessor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};
use crate::utils::expressions_as_statement;

use super::verify_no_rule_properties;

#[derive(Default)]
struct RemoveUnusedVariableProcessor {
    evaluator: Evaluator,
    mutated: bool,
}

impl RemoveUnusedVariableProcessor {
    fn has_mutated(&self) -> bool {
        self.mutated
    }
}

impl NodeProcessor for RemoveUnusedVariableProcessor {
    fn process_scope(&mut self, block: &mut Block, extra: Option<&mut Expression>) {
        let length = block.statements_len();

        let assignments = block
            .reverse_iter_statements()
            .enumerate()
            .filter_map(|(i, statement)| match statement {
                Statement::LocalAssign(assignment) => {
                    let identifiers = assignment
                        .get_variables()
                        .iter()
                        .map(TypedIdentifier::get_identifier)
                        .map(Identifier::get_name)
                        .map(ToOwned::to_owned)
                        .collect::<Vec<_>>();

                    Some((length - i - 1, identifiers))
                }
                Statement::LocalFunction(function) => {
                    Some((length - i - 1, vec![function.get_name().to_owned()]))
                }
                _ => None,
            })
            .collect::<Vec<_>>();

        let usages_in_extra = if let Some(expression) = extra {
            let mut found_identifiers = Vec::new();
            for (_, identifiers) in assignments.iter() {
                for identifier in identifiers {
                    let mut find_usage = FindUsage::new(identifier);
                    ScopeVisitor::visit_expression(expression, &mut find_usage);
                    if find_usage.has_found_usage() {
                        found_identifiers.push(identifier.to_owned());
                    }
                }
            }
            found_identifiers
        } else {
            Vec::new()
        };

        let usages = assignments
            .into_iter()
            .map(|(index, identifiers)| {
                let usages = identifiers
                    .into_iter()
                    .map(|identifier| {
                        let mut find_usage = FindUsage::new(&identifier);

                        block
                            .iter_mut_statements()
                            .skip(index + 1)
                            .any(|next_statement| {
                                ScopeVisitor::visit_statement(next_statement, &mut find_usage);
                                find_usage.has_found_usage()
                            })
                            || block
                                .mutate_last_statement()
                                .into_iter()
                                .any(|last_statement| {
                                    ScopeVisitor::visit_last_statement(
                                        last_statement,
                                        &mut find_usage,
                                    );
                                    find_usage.has_found_usage()
                                })
                            || usages_in_extra.contains(&identifier)
                    })
                    .collect::<Vec<_>>();

                (index, usages)
            })
            .collect::<Vec<_>>();

        let mut usages_iter = usages.into_iter().rev();

        if let Some((mut find_next_index, mut usages)) = usages_iter.next() {
            let mut i = 0;
            let mut should_find_next = true;

            block.filter_mut_statements(|statement| {
                let found = should_find_next && i == find_next_index;
                i += 1;

                if found {
                    let keep_statement = if let Statement::LocalAssign(assign) = statement {
                        if usages.iter().all(|used| !used) {
                            let values = assign
                                .iter_values()
                                .filter(|value| self.evaluator.has_side_effects(value))
                                .cloned()
                                .collect::<Vec<_>>();

                            if values.is_empty() {
                                false
                            } else {
                                *statement = expressions_as_statement(values);
                                true
                            }
                        } else if usages.iter().any(|used| !used) {
                            let mut assignments: Vec<_> = assign
                                .iter_variables()
                                .zip(usages.iter())
                                .map(|identifier| vec![identifier])
                                .zip(assign.iter_values())
                                .collect();

                            let length = assignments.len();
                            let mut remaining_unassigned_variables = Vec::new();

                            if let Some((last, value)) = assignments.last_mut() {
                                let remaining =
                                    assign.iter_variables().zip(usages.iter()).skip(length);
                                if self.evaluator.can_return_multiple_values(value) {
                                    last.extend(remaining);
                                } else {
                                    remaining_unassigned_variables.extend(
                                        remaining
                                            .filter(|(_, used)| **used)
                                            .map(|(identifier, _)| identifier.clone()),
                                    );
                                }
                            }

                            let mut values: Vec<_> = remaining_unassigned_variables
                                .iter()
                                .map(|_| Expression::nil())
                                .collect();
                            let mut variables = remaining_unassigned_variables;

                            for (mut identifiers, value) in assignments {
                                let mut last_popped = None;

                                while identifiers.last().filter(|(_, used)| !*used).is_some() {
                                    last_popped = identifiers.pop();
                                }

                                if !identifiers.is_empty() {
                                    variables.extend(
                                        identifiers
                                            .into_iter()
                                            .map(|(identifier, _)| identifier.clone()),
                                    );
                                    values.push(value.clone());
                                } else if self.evaluator.has_side_effects(value) {
                                    if let Some((last_identifier, _)) = last_popped {
                                        variables.push(last_identifier.clone());
                                        values.push(value.clone());
                                    }
                                }
                            }

                            if variables.is_empty() {
                                let extra_values: Vec<_> =
                                    assign.iter_values().skip(length).cloned().collect();
                                if extra_values.is_empty() {
                                    false
                                } else {
                                    *statement = expressions_as_statement(extra_values);
                                    true
                                }
                            } else {
                                values.extend(assign.iter_values().skip(length).cloned());
                                *statement = LocalAssignStatement::new(variables, values).into();
                                true
                            }
                        } else {
                            true
                        }
                    } else {
                        usages.iter().any(|used| *used)
                    };

                    if let Some((next_index, next_usages)) = usages_iter.next() {
                        find_next_index = next_index;
                        usages = next_usages;
                    } else {
                        should_find_next = false;
                    }

                    if !(self.mutated || keep_statement) {
                        self.mutated = true;
                    }

                    keep_statement
                } else {
                    true
                }
            });
        }
    }
}

pub const REMOVE_UNUSED_VARIABLE_RULE_NAME: &str = "remove_unused_variable";

/// A rule that removes unused variables.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveUnusedVariable {}

impl FlawlessRule for RemoveUnusedVariable {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        loop {
            let mut processor = RemoveUnusedVariableProcessor::default();
            processor.process_scope(block, None);
            DefaultVisitor::visit_block(block, &mut processor);
            if !processor.has_mutated() {
                break;
            }
        }
    }
}

impl RuleConfiguration for RemoveUnusedVariable {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_UNUSED_VARIABLE_RULE_NAME
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

    fn new_rule() -> RemoveUnusedVariable {
        RemoveUnusedVariable::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_unused_variable", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_unused_variable',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
