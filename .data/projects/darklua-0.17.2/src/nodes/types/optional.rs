use crate::nodes::Token;

use super::Type;

/// Represents an optional type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct OptionalType {
    inner_type: Box<Type>,
    token: Option<Token>,
}

impl OptionalType {
    /// Creates a new optional type with the specified base type.
    pub fn new(r#type: impl Into<Type>) -> Self {
        Self {
            inner_type: Box::new(r#type.into()),
            token: None,
        }
    }

    /// Returns the inner base type of this optional type.
    #[inline]
    pub fn get_inner_type(&self) -> &Type {
        &self.inner_type
    }

    /// Returns a mutable reference to the inner base type of this optional type.
    #[inline]
    pub fn mutate_inner_type(&mut self) -> &mut Type {
        &mut self.inner_type
    }

    /// Associates a token with this optional type.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token associated with this optional type.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this optional type, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Determines if a type needs parentheses when marked as optional.
    pub fn needs_parentheses(r#type: &Type) -> bool {
        matches!(
            r#type,
            Type::Intersection(_) | Type::Union(_) | Type::Function(_)
        )
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.token.is_none() {
            self.token = Some(Token::from_content("?"));
        }
        self.token.as_mut().unwrap()
    }

    super::impl_token_fns!(iter = [token]);
}
