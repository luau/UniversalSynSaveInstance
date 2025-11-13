use std::iter;

use crate::nodes::Token;

use super::Type;

/// Represents a union type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct UnionType {
    types: Vec<Type>,
    leading_operator: bool,
    tokens: Option<UnionTypeTokens>,
}

impl UnionType {
    /// Creates a new union type with two alternative types.
    pub fn new(left_type: impl Into<Type>, right_type: impl Into<Type>) -> Self {
        Self {
            types: vec![left_type.into(), right_type.into()],
            leading_operator: false,
            tokens: None,
        }
    }

    /// Associates tokens with this union type and returns the modified type.
    pub fn with_tokens(mut self, tokens: UnionTypeTokens) -> Self {
        self.set_tokens(tokens);
        self
    }

    /// Sets the tokens associated with this union type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: UnionTypeTokens) {
        if tokens.leading_token.is_some() {
            self.leading_operator = true;
        }
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this union type, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&UnionTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns the number of type alternatives in this union.
    #[inline]
    pub(crate) fn len(&self) -> usize {
        self.types.len()
    }

    /// Returns an iterator over the type alternatives in this union.
    #[inline]
    pub fn iter_types(&self) -> impl Iterator<Item = &Type> {
        self.types.iter()
    }

    /// Returns the first type alternative in this union.
    #[inline]
    pub fn first_type(&self) -> &Type {
        self.types.first().unwrap()
    }

    /// Returns the last type alternative in this union.
    #[inline]
    pub fn last_type(&self) -> &Type {
        self.types.last().unwrap()
    }

    /// Returns a mutable iterator over the type alternatives in this union.
    #[inline]
    pub fn iter_mut_types(&mut self) -> impl Iterator<Item = &mut Type> {
        self.types.iter_mut()
    }

    /// Returns whether this union type has a leading token.
    pub fn has_leading_token(&self) -> bool {
        self.leading_operator
            || self.types.len() < 2
            || self
                .tokens
                .as_ref()
                .map(|tokens| tokens.leading_token.is_some())
                .unwrap_or_default()
    }

    /// Marks this union type as having a leading token and returns the modified type.
    pub fn with_leading_token(mut self) -> Self {
        self.put_leading_token();
        self
    }

    /// Marks this union type as having a leading token.
    pub fn put_leading_token(&mut self) {
        self.leading_operator = true;
    }

    /// Removes the leading token from this union type.
    pub fn remove_leading_token(&mut self) {
        self.leading_operator = false;
        if let Some(tokens) = &mut self.tokens {
            tokens.leading_token.take();
        }
    }

    /// Determines if a type needs parentheses when used within a union type.
    pub fn intermediate_needs_parentheses(r#type: &Type) -> bool {
        matches!(
            r#type,
            Type::Optional(_) | Type::Intersection(_) | Type::Function(_) | Type::Union(_)
        )
    }

    /// Determines if the last type in a union needs parentheses.
    pub fn last_needs_parentheses(r#type: &Type) -> bool {
        matches!(
            r#type,
            Type::Intersection(_) | Type::Function(_) | Type::Union(_)
        )
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.types
            .last_mut()
            .expect("union types cannot be empty")
            .mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl From<Vec<Type>> for UnionType {
    fn from(types: Vec<Type>) -> Self {
        assert!(!types.is_empty(), "union types cannot be empty");
        Self {
            types,
            leading_operator: false,
            tokens: None,
        }
    }
}

impl iter::FromIterator<Type> for UnionType {
    fn from_iter<I: IntoIterator<Item = Type>>(iter: I) -> Self {
        Self {
            types: iter.into_iter().collect(),
            leading_operator: false,
            tokens: None,
        }
    }
}

/// Contains the tokens that define the union type syntax.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct UnionTypeTokens {
    /// Optional leading `|` token before the first type.
    pub leading_token: Option<Token>,
    /// The `|` tokens separating the type alternatives.
    pub separators: Vec<Token>,
}

impl UnionTypeTokens {
    super::impl_token_fns!(iter = [leading_token, separators]);
}
