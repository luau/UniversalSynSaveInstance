use crate::nodes::{Expression, Token, Variable};

/// Tokens associated with an assignment statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AssignTokens {
    pub equal: Token,
    pub variable_commas: Vec<Token>,
    pub value_commas: Vec<Token>,
}

impl AssignTokens {
    super::impl_token_fns!(
        target = [equal]
        iter = [variable_commas, value_commas]
    );
}

/// Represents a variable assignment statement (e.g., `a, b = 1, 2`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AssignStatement {
    variables: Vec<Variable>,
    values: Vec<Expression>,
    tokens: Option<AssignTokens>,
}

impl AssignStatement {
    /// Creates a new assignment statement with the given variables and values.
    pub fn new(variables: Vec<Variable>, values: Vec<Expression>) -> Self {
        Self {
            variables,
            values,
            tokens: None,
        }
    }

    /// Creates a new assignment statement with a single variable and value.
    pub fn from_variable<V: Into<Variable>, E: Into<Expression>>(variable: V, value: E) -> Self {
        Self {
            variables: vec![variable.into()],
            values: vec![value.into()],
            tokens: None,
        }
    }

    /// Returns the number of variables in the assignment.
    #[inline]
    pub fn variables_len(&self) -> usize {
        self.variables.len()
    }

    /// Returns the number of values in the assignment.
    #[inline]
    pub fn values_len(&self) -> usize {
        self.values.len()
    }

    /// Returns the list of variables.
    #[inline]
    pub fn get_variables(&self) -> &Vec<Variable> {
        &self.variables
    }

    /// Returns an iterator over the variables.
    #[inline]
    pub fn iter_variables(&self) -> impl Iterator<Item = &Variable> {
        self.variables.iter()
    }

    /// Returns a mutable iterator over the variables.
    #[inline]
    pub fn iter_mut_variables(&mut self) -> impl Iterator<Item = &mut Variable> {
        self.variables.iter_mut()
    }

    /// Returns the last value in the assignment, if any.
    #[inline]
    pub fn last_value(&self) -> Option<&Expression> {
        self.values.last()
    }

    /// Returns an iterator over the values.
    #[inline]
    pub fn iter_values(&self) -> impl Iterator<Item = &Expression> {
        self.values.iter()
    }

    /// Returns a mutable iterator over the values.
    #[inline]
    pub fn iter_mut_values(&mut self) -> impl Iterator<Item = &mut Expression> {
        self.values.iter_mut()
    }

    /// Returns a mutable reference to the variables vector.
    #[inline]
    pub fn mutate_variables(&mut self) -> &mut Vec<Variable> {
        &mut self.variables
    }

    /// Adds a new variable and value to the assignment.
    pub fn append_assignment<V: Into<Variable>, E: Into<Expression>>(
        mut self,
        variable: V,
        value: E,
    ) -> Self {
        self.variables.push(variable.into());
        self.values.push(value.into());
        self
    }

    /// Sets the tokens for this assignment statement.
    pub fn with_tokens(mut self, tokens: AssignTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this assignment statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: AssignTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this assignment statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&AssignTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the first token for this assignment statement,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.variables
            .iter_mut()
            .next()
            .expect("an assign statement must have at least one variable")
            .mutate_first_token()
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.values
            .last_mut()
            .expect("an assign statement must have at least one value")
            .mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens]);
}
