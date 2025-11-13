use crate::nodes::Token;

use super::Type;

/// Represents a parenthesized type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ParentheseType {
    inner_type: Box<Type>,
    tokens: Option<ParentheseTypeTokens>,
}

impl ParentheseType {
    /// Creates a new parenthesized type wrapping the specified type.
    pub fn new(r#type: impl Into<Type>) -> Self {
        Self {
            inner_type: Box::new(r#type.into()),
            tokens: None,
        }
    }

    /// Returns the inner type wrapped by these parentheses.
    #[inline]
    pub fn get_inner_type(&self) -> &Type {
        &self.inner_type
    }

    /// Consumes this parenthesized type and returns the inner type.
    #[inline]
    pub fn into_inner_type(self) -> Type {
        *self.inner_type
    }

    /// Returns a mutable reference to the inner type wrapped by these parentheses.
    #[inline]
    pub fn mutate_inner_type(&mut self) -> &mut Type {
        &mut self.inner_type
    }

    /// Associates tokens with this parenthesized type.
    pub fn with_tokens(mut self, tokens: ParentheseTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this parenthesized type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: ParentheseTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this parenthesized type, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&ParentheseTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens of this parenthesized type, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut ParentheseTypeTokens> {
        self.tokens.as_mut()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(ParentheseTypeTokens {
                left_parenthese: Token::from_content("("),
                right_parenthese: Token::from_content(")"),
            });
        }
        &mut self.tokens.as_mut().unwrap().right_parenthese
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains the tokens that define the parenthesized type syntax.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ParentheseTypeTokens {
    /// The left parenthesis token.
    pub left_parenthese: Token,
    /// The right parenthesis token.
    pub right_parenthese: Token,
}

impl ParentheseTypeTokens {
    super::impl_token_fns!(target = [left_parenthese, right_parenthese]);
}
