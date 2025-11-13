use crate::nodes::Token;

use super::Type;

/// Represents a variadic type pack in Luau.
///
/// Variadic type packs represent an arbitrary number of values of the same type,
/// written with a leading `...` and a type.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct VariadicTypePack {
    // ... type
    inner_type: Box<Type>,
    token: Option<Token>,
}

impl VariadicTypePack {
    /// Creates a new variadic type pack with the specified element type.
    pub fn new(r#type: impl Into<Type>) -> Self {
        Self {
            inner_type: Box::new(r#type.into()),
            token: None,
        }
    }

    /// Returns the element type of this variadic type pack.
    #[inline]
    pub fn get_type(&self) -> &Type {
        &self.inner_type
    }

    /// Returns a mutable reference to the element type of this variadic type pack.
    #[inline]
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.inner_type
    }

    /// Associates a token with this variadic type pack.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the `...` token preceding this variadic type pack.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the `...` token preceding this variadic type pack, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the `...` token preceding this variadic type pack, if any.
    #[inline]
    pub fn mutate_token(&mut self) -> Option<&mut Token> {
        self.token.as_mut()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.inner_type.mutate_last_token()
    }

    super::impl_token_fns!(iter = [token]);
}
