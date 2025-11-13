use std::collections::HashSet;
use std::ops::DerefMut;

use crate::nodes::*;
use crate::process::utils::is_valid_identifier;
use crate::process::{NodeProcessor, NodeVisitor};

use super::utils::{identifier_permutator, Permutator};
use super::{NodePostProcessor, NodePostVisitor};

/// Defines methods to interact with the concept of lexical scoping. The struct implementing this
/// trait should be able to keep track of identifiers when used along the ScopeVisitor.
pub trait Scope {
    /// This method is called when a new block is entered.
    fn push(&mut self);
    /// When a block is left, this method should should free all identifiers inserted in the
    /// previous block.
    fn pop(&mut self);
    /// Called when entering a function block (with each parameters of the function), with the
    /// identifiers from a generic for statement or the identifier from a numeric for loop.
    fn insert(&mut self, identifier: &mut String);
    /// Called when entering a function defined with a method
    fn insert_self(&mut self);
    /// Called when a new local variable is initialized.
    fn insert_local(&mut self, identifier: &mut String, value: Option<&mut Expression>);
    /// Called when a new local function is initialized.
    fn insert_local_function(&mut self, function: &mut LocalFunctionStatement);
}

/// A visitor that can be used only with a NodeProcessor that also implements the Scope trait.
pub struct ScopeVisitor;

impl ScopeVisitor {
    fn visit_block_without_push<T: NodeProcessor + Scope>(block: &mut Block, scope: &mut T) {
        scope.process_block(block);

        block
            .iter_mut_statements()
            .for_each(|statement| Self::visit_statement(statement, scope));

        if let Some(last_statement) = block.mutate_last_statement() {
            Self::visit_last_statement(last_statement, scope);
        };
    }
}

impl<T: NodeProcessor + Scope> NodeVisitor<T> for ScopeVisitor {
    fn visit_block(block: &mut Block, scope: &mut T) {
        scope.push();
        Self::visit_block_without_push(block, scope);
        scope.pop();
    }

    fn visit_local_assign(statement: &mut LocalAssignStatement, scope: &mut T) {
        scope.process_local_assign_statement(statement);

        statement
            .iter_mut_values()
            .for_each(|value| Self::visit_expression(value, scope));

        for r#type in statement
            .iter_mut_variables()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        statement.for_each_assignment(|variable, expression| {
            scope.insert_local(variable.mutate_name(), expression)
        });
    }

    fn visit_function_expression(function: &mut FunctionExpression, scope: &mut T) {
        scope.process_function_expression(function);

        for r#type in function
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = function.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = function.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        function
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(function.mutate_block(), None);

        Self::visit_block(function.mutate_block(), scope);
        scope.pop();
    }

    fn visit_function_statement(statement: &mut FunctionStatement, scope: &mut T) {
        scope.process_function_statement(statement);
        scope.process_variable_expression(statement.mutate_function_name().mutate_identifier());

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        if statement.get_name().has_method() {
            scope.insert_self();
        }
        statement
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();
    }

    fn visit_local_function(statement: &mut LocalFunctionStatement, scope: &mut T) {
        scope.process_local_function_statement(statement);

        scope.insert_local_function(statement);

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        statement
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();
    }

    fn visit_generic_for(statement: &mut GenericForStatement, scope: &mut T) {
        scope.process_generic_for_statement(statement);

        statement
            .iter_mut_expressions()
            .for_each(|expression| Self::visit_expression(expression, scope));

        scope.push();
        statement
            .iter_mut_identifiers()
            .for_each(|identifier| scope.insert(identifier.mutate_name()));

        for r#type in statement
            .iter_mut_identifiers()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();
    }

    fn visit_numeric_for(statement: &mut NumericForStatement, scope: &mut T) {
        scope.process_numeric_for_statement(statement);

        Self::visit_expression(statement.mutate_start(), scope);
        Self::visit_expression(statement.mutate_end(), scope);

        if let Some(step) = statement.mutate_step() {
            Self::visit_expression(step, scope);
        };

        if let Some(r#type) = statement.mutate_identifier().mutate_type() {
            Self::visit_type(r#type, scope);
        }

        scope.push();
        scope.insert(statement.mutate_identifier().mutate_name());

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();
    }

    fn visit_repeat_statement(statement: &mut RepeatStatement, scope: &mut T) {
        scope.process_repeat_statement(statement);

        scope.push();

        let (block, condition) = statement.mutate_block_and_condition();
        scope.process_scope(block, Some(condition));

        Self::visit_block_without_push(statement.mutate_block(), scope);
        Self::visit_expression(statement.mutate_condition(), scope);

        scope.pop();
    }
}

/// A visitor that can be used only with a NodeProcessor that also implements the Scope trait.
pub struct ScopePostVisitor;

impl ScopePostVisitor {
    fn visit_block_without_push<T: NodeProcessor + NodePostProcessor + Scope>(
        block: &mut Block,
        scope: &mut T,
    ) {
        scope.process_block(block);

        block
            .iter_mut_statements()
            .for_each(|statement| Self::visit_statement(statement, scope));

        if let Some(last_statement) = block.mutate_last_statement() {
            Self::visit_last_statement(last_statement, scope);
        };
        scope.process_after_block(block);
    }
}

impl<T: NodeProcessor + NodePostProcessor + Scope> NodePostVisitor<T> for ScopePostVisitor {
    fn visit_block(block: &mut Block, scope: &mut T) {
        scope.push();
        Self::visit_block_without_push(block, scope);
        scope.pop();
    }

    fn visit_local_assign(statement: &mut LocalAssignStatement, scope: &mut T) {
        scope.process_local_assign_statement(statement);

        statement
            .iter_mut_values()
            .for_each(|value| Self::visit_expression(value, scope));

        for r#type in statement
            .iter_mut_variables()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        statement.for_each_assignment(|variable, expression| {
            scope.insert_local(variable.mutate_name(), expression)
        });

        scope.process_after_local_assign_statement(statement);
    }

    fn visit_function_expression(function: &mut FunctionExpression, scope: &mut T) {
        scope.process_function_expression(function);

        for r#type in function
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = function.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = function.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        function
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(function.mutate_block(), None);

        Self::visit_block(function.mutate_block(), scope);
        scope.pop();

        scope.process_after_function_expression(function);
    }

    fn visit_function_statement(statement: &mut FunctionStatement, scope: &mut T) {
        scope.process_function_statement(statement);
        scope.process_variable_expression(statement.mutate_function_name().mutate_identifier());

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        if statement.get_name().has_method() {
            scope.insert_self();
        }
        statement
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();

        scope.process_after_function_statement(statement);
    }

    fn visit_local_function(statement: &mut LocalFunctionStatement, scope: &mut T) {
        scope.process_local_function_statement(statement);

        scope.insert_local_function(statement);

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, scope);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, scope);
        }

        scope.push();
        statement
            .mutate_parameters()
            .iter_mut()
            .for_each(|parameter| scope.insert(parameter.mutate_name()));

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();

        scope.process_after_local_function_statement(statement);
    }

    fn visit_generic_for(statement: &mut GenericForStatement, scope: &mut T) {
        scope.process_generic_for_statement(statement);

        statement
            .iter_mut_expressions()
            .for_each(|expression| Self::visit_expression(expression, scope));

        scope.push();
        statement
            .iter_mut_identifiers()
            .for_each(|identifier| scope.insert(identifier.mutate_name()));

        for r#type in statement
            .iter_mut_identifiers()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, scope);
        }

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();

        scope.process_after_generic_for_statement(statement);
    }

    fn visit_numeric_for(statement: &mut NumericForStatement, scope: &mut T) {
        scope.process_numeric_for_statement(statement);

        Self::visit_expression(statement.mutate_start(), scope);
        Self::visit_expression(statement.mutate_end(), scope);

        if let Some(step) = statement.mutate_step() {
            Self::visit_expression(step, scope);
        };

        if let Some(r#type) = statement.mutate_identifier().mutate_type() {
            Self::visit_type(r#type, scope);
        }

        scope.push();
        scope.insert(statement.mutate_identifier().mutate_name());

        scope.process_scope(statement.mutate_block(), None);

        Self::visit_block(statement.mutate_block(), scope);
        scope.pop();

        scope.process_after_numeric_for_statement(statement);
    }

    fn visit_repeat_statement(statement: &mut RepeatStatement, scope: &mut T) {
        scope.process_repeat_statement(statement);

        scope.push();

        let (block, condition) = statement.mutate_block_and_condition();
        scope.process_scope(block, Some(condition));

        Self::visit_block_without_push(statement.mutate_block(), scope);
        Self::visit_expression(statement.mutate_condition(), scope);

        scope.pop();

        scope.process_after_repeat_statement(statement);
    }
}

#[derive(Debug, Clone, Default)]
pub(crate) struct IdentifierTracker {
    identifiers: Vec<HashSet<String>>,
}

impl IdentifierTracker {
    fn insert_identifier(&mut self, identifier: &str) {
        if let Some(set) = self.identifiers.last_mut() {
            set.insert(identifier.to_string());
        } else {
            let mut set = HashSet::new();
            set.insert(identifier.to_string());
            self.identifiers.push(set);
        }
    }

    pub fn new() -> IdentifierTracker {
        Self {
            identifiers: Vec::new(),
        }
    }

    pub fn is_identifier_used(&self, identifier: &str) -> bool {
        self.identifiers.iter().any(|set| set.contains(identifier))
    }

    pub fn generate_identifier(&mut self) -> String {
        let mut permutator = identifier_permutator();

        let identifier = permutator
            .find(|identifier| {
                is_valid_identifier(identifier) && !self.is_identifier_used(identifier)
            })
            .expect("the permutator should always ultimately return a valid identifier");
        self.insert_identifier(&identifier);
        identifier
    }

    pub fn generate_identifier_with_prefix(&mut self, prefix: impl Into<String>) -> String {
        let mut identifier = prefix.into();
        if identifier.is_empty() {
            return self.generate_identifier();
        }
        let initial_length = identifier.len();
        let mut permutator = Permutator::new("012345689".chars());

        while self.is_identifier_used(&identifier) {
            identifier.truncate(initial_length);
            let next_suffix = permutator.next().unwrap_or_else(|| "_".to_owned());
            identifier.push_str(&next_suffix);
        }
        self.insert_identifier(&identifier);
        identifier
    }
}

impl Scope for IdentifierTracker {
    fn push(&mut self) {
        self.identifiers.push(HashSet::new())
    }

    fn pop(&mut self) {
        self.identifiers.pop();
    }

    fn insert(&mut self, identifier: &mut String) {
        self.insert_identifier(identifier);
    }

    fn insert_self(&mut self) {
        self.insert_identifier("self");
    }

    fn insert_local(&mut self, identifier: &mut String, _value: Option<&mut Expression>) {
        self.insert_identifier(identifier);
    }

    fn insert_local_function(&mut self, function: &mut LocalFunctionStatement) {
        self.insert_identifier(function.mutate_identifier().get_name());
    }
}

// implement Scope on anything that can deref into a Scope
impl<T, U> Scope for T
where
    T: DerefMut<Target = U>,
    U: Scope,
{
    #[inline]
    fn push(&mut self) {
        self.deref_mut().push()
    }

    #[inline]
    fn pop(&mut self) {
        self.deref_mut().pop()
    }

    #[inline]
    fn insert(&mut self, identifier: &mut String) {
        self.deref_mut().insert(identifier);
    }

    #[inline]
    fn insert_self(&mut self) {
        self.deref_mut().insert_self();
    }

    #[inline]
    fn insert_local(&mut self, identifier: &mut String, value: Option<&mut Expression>) {
        self.deref_mut().insert_local(identifier, value)
    }

    #[inline]
    fn insert_local_function(&mut self, function: &mut LocalFunctionStatement) {
        self.deref_mut().insert_local_function(function)
    }
}
