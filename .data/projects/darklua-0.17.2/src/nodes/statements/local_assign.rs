use crate::nodes::{Expression, Token, TypedIdentifier};

/// Tokens associated with a local variable assignment statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LocalAssignTokens {
    pub local: Token,
    /// The token for the equal sign, if any.
    pub equal: Option<Token>,
    /// The tokens for the commas between variables.
    pub variable_commas: Vec<Token>,
    /// The tokens for the commas between values.
    pub value_commas: Vec<Token>,
}

impl LocalAssignTokens {
    super::impl_token_fns!(
        target = [local]
        iter = [variable_commas, value_commas, equal]
    );
}

/// Represents a local variable assignment statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LocalAssignStatement {
    variables: Vec<TypedIdentifier>,
    values: Vec<Expression>,
    tokens: Option<LocalAssignTokens>,
}

impl LocalAssignStatement {
    /// Creates a new local assignment statement with the given variables and values.
    pub fn new(variables: Vec<TypedIdentifier>, values: Vec<Expression>) -> Self {
        Self {
            variables,
            values,
            tokens: None,
        }
    }

    /// Creates a new local assignment statement with a single variable and no values.
    pub fn from_variable<S: Into<TypedIdentifier>>(variable: S) -> Self {
        Self {
            variables: vec![variable.into()],
            values: Vec::new(),
            tokens: None,
        }
    }

    /// Sets the tokens for this local assignment statement.
    pub fn with_tokens(mut self, tokens: LocalAssignTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this local assignment statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: LocalAssignTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this local assignment statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&LocalAssignTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut LocalAssignTokens> {
        self.tokens.as_mut()
    }

    /// Adds a variable to this local assignment statement.
    pub fn with_variable<S: Into<TypedIdentifier>>(mut self, variable: S) -> Self {
        self.variables.push(variable.into());
        self
    }

    /// Adds a value to this local assignment statement.
    pub fn with_value<E: Into<Expression>>(mut self, value: E) -> Self {
        self.values.push(value.into());
        self
    }

    /// Converts this statement into a tuple of variables and values.
    pub fn into_assignments(self) -> (Vec<TypedIdentifier>, Vec<Expression>) {
        (self.variables, self.values)
    }

    /// Adds a new variable-value pair to this local assignment statement.
    pub fn append_assignment<S: Into<TypedIdentifier>>(&mut self, variable: S, value: Expression) {
        self.variables.push(variable.into());
        self.values.push(value);
    }

    /// Applies a function to each variable-value pair.
    pub fn for_each_assignment<F>(&mut self, mut callback: F)
    where
        F: FnMut(&mut TypedIdentifier, Option<&mut Expression>),
    {
        let mut values = self.values.iter_mut();
        self.variables
            .iter_mut()
            .for_each(|variable| callback(variable, values.next()));
    }

    /// Returns the list of variables.
    #[inline]
    pub fn get_variables(&self) -> &Vec<TypedIdentifier> {
        &self.variables
    }

    /// Returns an iterator over the variables.
    #[inline]
    pub fn iter_variables(&self) -> impl Iterator<Item = &TypedIdentifier> {
        self.variables.iter()
    }

    /// Returns a mutable iterator over the variables.
    #[inline]
    pub fn iter_mut_variables(&mut self) -> impl Iterator<Item = &mut TypedIdentifier> {
        self.variables.iter_mut()
    }

    /// Appends variables from another vector.
    #[inline]
    pub fn append_variables(&mut self, variables: &mut Vec<TypedIdentifier>) {
        self.variables.append(variables);
    }

    /// Extends the values with elements from an iterator.
    #[inline]
    pub fn extend_values<T: IntoIterator<Item = Expression>>(&mut self, iter: T) {
        self.values.extend(iter);
    }

    /// Returns a mutable iterator over the values.
    #[inline]
    pub fn iter_mut_values(&mut self) -> impl Iterator<Item = &mut Expression> {
        self.values.iter_mut()
    }

    /// Returns an iterator over the values.
    #[inline]
    pub fn iter_values(&self) -> impl Iterator<Item = &Expression> {
        self.values.iter()
    }

    /// Adds a variable to this local assignment statement.
    #[inline]
    pub fn push_variable(&mut self, variable: impl Into<TypedIdentifier>) {
        self.variables.push(variable.into());
    }

    /// Adds a value to this local assignment statement.
    #[inline]
    pub fn push_value(&mut self, value: impl Into<Expression>) {
        self.values.push(value.into());
    }

    /// Appends values from another vector.
    #[inline]
    pub fn append_values(&mut self, values: &mut Vec<Expression>) {
        self.values.append(values);
    }

    /// Returns the last value, if any.
    #[inline]
    pub fn last_value(&self) -> Option<&Expression> {
        self.values.last()
    }

    /// Removes and returns the last value, adjusting tokens as needed.
    pub fn pop_value(&mut self) -> Option<Expression> {
        let value = self.values.pop();
        if let Some(tokens) = &mut self.tokens {
            let length = self.values.len();
            if length == 0 {
                if !tokens.value_commas.is_empty() {
                    tokens.value_commas.clear();
                }
                if tokens.equal.is_some() {
                    tokens.equal = None;
                }
            } else {
                tokens.value_commas.truncate(length.saturating_sub(1));
            }
        }
        value
    }

    /// Removes and returns the value at the given index, adjusting tokens as needed.
    pub fn remove_value(&mut self, index: usize) -> Option<Expression> {
        if index < self.values.len() {
            let value = self.values.remove(index);

            if let Some(tokens) = &mut self.tokens {
                if index < tokens.value_commas.len() {
                    tokens.value_commas.remove(index);
                }
                if self.values.is_empty() && tokens.equal.is_some() {
                    tokens.equal = None;
                }
            }

            Some(value)
        } else {
            None
        }
    }

    /// Removes and returns the variable at the given index, adjusting tokens as needed.
    ///
    /// Returns None if there is only one variable or if the index is out of bounds.
    pub fn remove_variable(&mut self, index: usize) -> Option<TypedIdentifier> {
        let len = self.variables.len();

        if len > 1 && index < len {
            let variable = self.variables.remove(index);

            if let Some(tokens) = &mut self.tokens {
                if index < tokens.variable_commas.len() {
                    tokens.variable_commas.remove(index);
                }
            }

            Some(variable)
        } else {
            None
        }
    }

    /// Returns the number of values.
    #[inline]
    pub fn values_len(&self) -> usize {
        self.values.len()
    }

    /// Returns the number of variables.
    #[inline]
    pub fn variables_len(&self) -> usize {
        self.variables.len()
    }

    /// Returns whether this statement has any values.
    #[inline]
    pub fn has_values(&self) -> bool {
        !self.values.is_empty()
    }

    /// Removes type annotations from all variables.
    pub fn clear_types(&mut self) {
        for variable in &mut self.variables {
            variable.remove_type();
        }
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(LocalAssignTokens {
                local: Token::from_content("local"),
                equal: (!self.values.is_empty()).then(|| Token::from_content("=")),
                variable_commas: Vec::new(),
                value_commas: Vec::new(),
            });
        }
        &mut self.tokens.as_mut().unwrap().local
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if let Some(last_value) = self.values.last_mut() {
            return last_value.mutate_last_token();
        }
        self.variables
            .last_mut()
            .expect("local assign must have at least one variable")
            .mutate_or_insert_token()
    }

    super::impl_token_fns!(iter = [variables, tokens]);
}

#[cfg(test)]
mod test {
    use super::*;

    mod pop_value {
        use super::*;

        #[test]
        fn removes_the_equal_sign() {
            let mut assign = LocalAssignStatement::from_variable("var")
                .with_value(true)
                .with_tokens(LocalAssignTokens {
                    local: Token::from_content("local"),
                    equal: Some(Token::from_content("=")),
                    variable_commas: Vec::new(),
                    value_commas: Vec::new(),
                });

            assign.pop_value();

            pretty_assertions::assert_eq!(
                assign,
                LocalAssignStatement::from_variable("var").with_tokens(LocalAssignTokens {
                    local: Token::from_content("local"),
                    equal: None,
                    variable_commas: Vec::new(),
                    value_commas: Vec::new(),
                })
            );
        }

        #[test]
        fn removes_the_last_comma_token() {
            let mut assign = LocalAssignStatement::from_variable("var")
                .with_value(true)
                .with_value(false)
                .with_tokens(LocalAssignTokens {
                    local: Token::from_content("local"),
                    equal: Some(Token::from_content("=")),
                    variable_commas: Vec::new(),
                    value_commas: vec![Token::from_content(",")],
                });

            assign.pop_value();

            pretty_assertions::assert_eq!(
                assign,
                LocalAssignStatement::from_variable("var")
                    .with_value(true)
                    .with_tokens(LocalAssignTokens {
                        local: Token::from_content("local"),
                        equal: Some(Token::from_content("=")),
                        variable_commas: Vec::new(),
                        value_commas: Vec::new(),
                    })
            );
        }

        #[test]
        fn removes_one_comma_token() {
            let mut assign = LocalAssignStatement::from_variable("var")
                .with_value(true)
                .with_value(false)
                .with_value(true)
                .with_tokens(LocalAssignTokens {
                    local: Token::from_content("local"),
                    equal: Some(Token::from_content("=")),
                    variable_commas: Vec::new(),
                    value_commas: vec![Token::from_content(","), Token::from_content(",")],
                });

            assign.pop_value();

            pretty_assertions::assert_eq!(
                assign,
                LocalAssignStatement::from_variable("var")
                    .with_value(true)
                    .with_value(false)
                    .with_tokens(LocalAssignTokens {
                        local: Token::from_content("local"),
                        equal: Some(Token::from_content("=")),
                        variable_commas: Vec::new(),
                        value_commas: vec![Token::from_content(",")],
                    })
            );
        }
    }

    mod remove_variable {
        use super::*;

        #[test]
        fn single_variable_returns_none_without_mutating() {
            let mut assign = LocalAssignStatement::from_variable("var").with_value(true);
            let copy = assign.clone();

            assert_eq!(assign.remove_variable(0), None);

            pretty_assertions::assert_eq!(assign, copy);
        }

        #[test]
        fn single_variable_remove_outside_of_bounds() {
            let mut assign = LocalAssignStatement::from_variable("var");
            let copy = assign.clone();

            assert_eq!(assign.remove_variable(1), None);
            pretty_assertions::assert_eq!(assign, copy);

            assert_eq!(assign.remove_variable(3), None);
            pretty_assertions::assert_eq!(assign, copy);
        }

        #[test]
        fn two_variables_remove_first() {
            let mut assign = LocalAssignStatement::from_variable("var")
                .with_variable("var2")
                .with_value(true)
                .with_value(false);

            assert_eq!(assign.remove_variable(0), Some(TypedIdentifier::new("var")));

            pretty_assertions::assert_eq!(
                assign,
                LocalAssignStatement::from_variable("var2")
                    .with_value(true)
                    .with_value(false)
            );
        }

        #[test]
        fn two_variables_remove_second() {
            let mut assign = LocalAssignStatement::from_variable("var")
                .with_variable("var2")
                .with_value(true)
                .with_value(false);

            assert_eq!(
                assign.remove_variable(1),
                Some(TypedIdentifier::new("var2"))
            );

            pretty_assertions::assert_eq!(
                assign,
                LocalAssignStatement::from_variable("var")
                    .with_value(true)
                    .with_value(false)
            );
        }
    }
}
