use std::collections::HashMap;
use std::{iter, ops};

use crate::nodes::{
    DoStatement, Expression, FunctionCall, Identifier, LocalAssignStatement, Prefix, Statement,
    TypedIdentifier,
};
use crate::process::{Evaluator, IdentifierTracker, NodeProcessor};
use crate::utils::{
    expressions_as_expression, expressions_as_statement, preserve_arguments_side_effects,
};

pub(crate) trait CallMatch<T> {
    fn matches(&self, identifiers: &IdentifierTracker, prefix: &Prefix) -> bool;

    fn compute_result(
        &self,
        _call: &FunctionCall,
        _mappings: &HashMap<&'static str, String>,
    ) -> Option<Expression> {
        None
    }

    fn reserve_globals(&self) -> impl Iterator<Item = &'static str> {
        iter::empty()
    }
}

#[derive(Default)]
pub(crate) struct RemoveFunctionCallProcessor<Args, T: CallMatch<Args>> {
    identifier_tracker: IdentifierTracker,
    global_mappings: HashMap<&'static str, String>,
    global_counter: u32,
    evaluator: Evaluator,
    preserve_args_side_effects: bool,
    matcher: T,
    _phantom: std::marker::PhantomData<Args>,
}

impl<F> CallMatch<(&IdentifierTracker, &Prefix)> for F
where
    F: Fn(&IdentifierTracker, &Prefix) -> bool,
{
    fn matches(&self, identifiers: &IdentifierTracker, prefix: &Prefix) -> bool {
        (self)(identifiers, prefix)
    }
}

impl<F> CallMatch<&Prefix> for F
where
    F: Fn(&Prefix) -> bool,
{
    fn matches(&self, _identifiers: &IdentifierTracker, prefix: &Prefix) -> bool {
        (self)(prefix)
    }
}

impl<Args, T: CallMatch<Args>> RemoveFunctionCallProcessor<Args, T> {
    pub(crate) fn new(preserve_args_side_effects: bool, matcher: T) -> Self {
        Self {
            identifier_tracker: Default::default(),
            global_mappings: Default::default(),
            global_counter: 0,
            evaluator: Default::default(),
            preserve_args_side_effects,
            matcher,
            _phantom: Default::default(),
        }
    }

    pub(crate) fn extract_reserved_globals(&mut self) -> Option<Statement> {
        let (variables, values) = self.global_mappings.drain().fold(
            (Vec::new(), Vec::new()),
            |(mut variables, mut values), (global, reserved_name)| {
                variables.push(TypedIdentifier::new(reserved_name));
                values.push(Identifier::new(global).into());
                (variables, values)
            },
        );

        if variables.is_empty() {
            None
        } else {
            Some(LocalAssignStatement::new(variables, values).into())
        }
    }

    fn get_reserved_global(&mut self) -> String {
        self.global_counter += 1;
        format!("__DARKLUA_REMOVE_CALL_RESERVED_{}", self.global_counter)
    }
}

impl<Args, T: CallMatch<Args>> ops::Deref for RemoveFunctionCallProcessor<Args, T> {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl<Args, T: CallMatch<Args>> ops::DerefMut for RemoveFunctionCallProcessor<Args, T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

impl<Args, T: CallMatch<Args>> NodeProcessor for RemoveFunctionCallProcessor<Args, T> {
    fn process_statement(&mut self, statement: &mut Statement) {
        if let Statement::Call(call) = statement {
            if call.get_method().is_none()
                && self
                    .matcher
                    .matches(&self.identifier_tracker, call.get_prefix())
            {
                *statement = if self.preserve_args_side_effects {
                    expressions_as_statement(preserve_arguments_side_effects(
                        &self.evaluator,
                        call.get_arguments(),
                    ))
                } else {
                    DoStatement::default().into()
                };
            }
        }
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::Call(call) = expression {
            if call.get_method().is_none()
                && self
                    .matcher
                    .matches(&self.identifier_tracker, call.get_prefix())
            {
                let insert_globals = self
                    .matcher
                    .reserve_globals()
                    .filter(|global| {
                        self.is_identifier_used(global)
                            && !self.global_mappings.contains_key(global)
                    })
                    .collect::<Vec<_>>();

                for global in insert_globals {
                    let new_reserved_name = self.get_reserved_global();
                    self.global_mappings.insert(global, new_reserved_name);
                }

                if let Some(result) = self.matcher.compute_result(call, &self.global_mappings) {
                    *expression = result;
                } else {
                    *expression = if self.preserve_args_side_effects {
                        expressions_as_expression(preserve_arguments_side_effects(
                            &self.evaluator,
                            call.get_arguments(),
                        ))
                    } else {
                        Expression::nil()
                    };
                }
            }
        }
    }
}
