use crate::nodes::{Expression, Token};

/// Represents a `typeof(expression)` type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ExpressionType {
    expression: Box<Expression>,
    tokens: Option<ExpressionTypeTokens>,
}

impl ExpressionType {
    /// Creates a new `typeof` type with the given expression.
    pub fn new(expression: impl Into<Expression>) -> Self {
        Self {
            expression: Box::new(expression.into()),
            tokens: None,
        }
    }

    /// Returns the expression whose type is being referenced.
    #[inline]
    pub fn get_expression(&self) -> &Expression {
        &self.expression
    }

    /// Returns a mutable reference to the expression whose type is being referenced.
    #[inline]
    pub fn mutate_expression(&mut self) -> &mut Expression {
        &mut self.expression
    }

    /// Associates tokens with this expression type and returns the modified type.
    pub fn with_tokens(mut self, tokens: ExpressionTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this expression type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: ExpressionTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this expression type, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&ExpressionTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the last token for this expression type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(ExpressionTypeTokens {
                r#typeof: Token::from_content("typeof"),
                opening_parenthese: Token::from_content("("),
                closing_parenthese: Token::from_content(")"),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_parenthese
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains the tokens that define the `typeof` expression syntax.
///
/// These tokens represent the `typeof` keyword and the parentheses around the expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ExpressionTypeTokens {
    /// The `typeof` keyword token.
    pub r#typeof: Token,
    /// The opening parenthesis token.
    pub opening_parenthese: Token,
    /// The closing parenthesis token.
    pub closing_parenthese: Token,
}

impl ExpressionTypeTokens {
    super::impl_token_fns!(target = [r#typeof, opening_parenthese, closing_parenthese]);
}
