use crate::nodes::Token;

use super::Type;

/// Represents an array type annotation (e.g. `{ ElementType }`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ArrayType {
    inner_type: Box<Type>,
    tokens: Option<ArrayTypeTokens>,
}

impl ArrayType {
    /// Creates a new array type with the specified element type.
    pub fn new(element_type: impl Into<Type>) -> Self {
        Self {
            inner_type: Box::new(element_type.into()),
            tokens: None,
        }
    }

    /// Associates tokens with this array type.
    pub fn with_tokens(mut self, tokens: ArrayTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this array type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: ArrayTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this array type, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&ArrayTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns the element type of this array.
    pub fn get_element_type(&self) -> &Type {
        &self.inner_type
    }

    /// Returns a mutable reference to the element type of this array.
    pub fn mutate_element_type(&mut self) -> &mut Type {
        &mut self.inner_type
    }

    /// Returns a mutable reference to the last token for this array type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(ArrayTypeTokens {
                opening_brace: Token::from_content("{"),
                closing_brace: Token::from_content("}"),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_brace
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains the tokens that define the array type syntax.
///
/// These tokens represent the opening and closing braces in an array type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ArrayTypeTokens {
    /// The opening brace token.
    pub opening_brace: Token,
    /// The closing brace token.
    pub closing_brace: Token,
}

impl ArrayTypeTokens {
    super::impl_token_fns!(target = [opening_brace, closing_brace]);
}
