use crate::nodes::{Expression, Prefix, Token};

/// Contains token information for an index expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IndexExpressionTokens {
    /// The opening bracket token
    pub opening_bracket: Token,
    /// The closing bracket token
    pub closing_bracket: Token,
}

impl IndexExpressionTokens {
    super::impl_token_fns!(target = [opening_bracket, closing_bracket]);
}

/// Represents a table index access expression.
///
/// An index expression accesses a value in a table using square bracket notation,
/// such as `table[key]`. It consists of a prefix (the table being accessed)
/// and an index expression that evaluates to the key.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IndexExpression {
    prefix: Prefix,
    index: Expression,
    tokens: Option<IndexExpressionTokens>,
}

impl IndexExpression {
    /// Creates a new index expression with the given prefix and index expression.
    pub fn new<P: Into<Prefix>, E: Into<Expression>>(prefix: P, expression: E) -> Self {
        Self {
            prefix: prefix.into(),
            index: expression.into(),
            tokens: None,
        }
    }

    /// Attaches tokens to this index expression.
    pub fn with_tokens(mut self, tokens: IndexExpressionTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Attaches tokens to this index expression.
    #[inline]
    pub fn set_tokens(&mut self, tokens: IndexExpressionTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns a reference to the tokens attached to this index expression, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&IndexExpressionTokens> {
        self.tokens.as_ref()
    }

    /// Returns a reference to the prefix of this index expression.
    #[inline]
    pub fn get_prefix(&self) -> &Prefix {
        &self.prefix
    }

    /// Returns a reference to the index expression of this index expression.
    #[inline]
    pub fn get_index(&self) -> &Expression {
        &self.index
    }

    /// Returns a mutable reference to the prefix of this index expression.
    #[inline]
    pub fn mutate_prefix(&mut self) -> &mut Prefix {
        &mut self.prefix
    }

    /// Returns a mutable reference to the index expression of this index expression.
    #[inline]
    pub fn mutate_index(&mut self) -> &mut Expression {
        &mut self.index
    }

    /// Returns a mutable reference to the first token of this index expression,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut crate::nodes::Token {
        self.prefix.mutate_first_token()
    }

    /// Returns a mutable reference to the last token of this index expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(IndexExpressionTokens {
                opening_bracket: Token::from_content("["),
                closing_bracket: Token::from_content("]"),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_bracket
    }

    super::impl_token_fns!(iter = [tokens]);
}
