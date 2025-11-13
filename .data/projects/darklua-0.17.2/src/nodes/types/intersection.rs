use std::iter;

use crate::nodes::Token;

use super::Type;

/// Represents an intersection type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IntersectionType {
    types: Vec<Type>,
    leading_operator: bool,
    tokens: Option<IntersectionTypeTokens>,
}

impl IntersectionType {
    /// Creates a new intersection type with two component types.
    pub fn new(left_type: impl Into<Type>, right_type: impl Into<Type>) -> Self {
        Self {
            types: vec![left_type.into(), right_type.into()],
            leading_operator: false,
            tokens: None,
        }
    }

    /// Adds another type to this intersection.
    pub fn with_type(mut self, r#type: impl Into<Type>) -> Self {
        self.types.push(r#type.into());
        self
    }

    /// Associates tokens with this intersection type.
    pub fn with_tokens(mut self, tokens: IntersectionTypeTokens) -> Self {
        self.set_tokens(tokens);
        self
    }

    /// Sets the tokens associated with this intersection type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: IntersectionTypeTokens) {
        if tokens.leading_token.is_some() {
            self.leading_operator = true;
        }
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this intersection type, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&IntersectionTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns the number of component types in this intersection.
    #[inline]
    pub(crate) fn len(&self) -> usize {
        self.types.len()
    }

    /// Returns an iterator over the component types in this intersection.
    #[inline]
    pub fn iter_types(&self) -> impl Iterator<Item = &Type> {
        self.types.iter()
    }

    /// Returns a mutable iterator over the component types in this intersection.
    #[inline]
    pub fn iter_mut_types(&mut self) -> impl Iterator<Item = &mut Type> {
        self.types.iter_mut()
    }

    /// Returns the first component type in this intersection.
    #[inline]
    pub fn first_type(&self) -> &Type {
        self.types.first().unwrap()
    }

    /// Returns the last component type in this intersection.
    #[inline]
    pub fn last_type(&self) -> &Type {
        self.types.last().unwrap()
    }

    /// Returns whether this intersection type has a leading token.
    pub fn has_leading_token(&self) -> bool {
        self.leading_operator
            || self.types.len() < 2
            || self
                .tokens
                .as_ref()
                .map(|tokens| tokens.leading_token.is_some())
                .unwrap_or_default()
    }

    /// Marks this intersection type as having a leading token and returns the modified type.
    pub fn with_leading_token(mut self) -> Self {
        self.put_leading_token();
        self
    }

    /// Marks this intersection type as having a leading token.
    pub fn put_leading_token(&mut self) {
        self.leading_operator = true;
    }

    /// Removes the leading token from this intersection type.
    pub fn remove_leading_token(&mut self) {
        self.leading_operator = false;
        if let Some(tokens) = &mut self.tokens {
            tokens.leading_token.take();
        }
    }

    /// Determines if a type needs parentheses when used within an intersection type.
    pub fn intermediate_needs_parentheses(r#type: &Type) -> bool {
        matches!(
            r#type,
            Type::Optional(_) | Type::Union(_) | Type::Function(_) | Type::Intersection(_)
        )
    }

    /// Determines if the last type in an intersection needs parentheses.
    pub fn last_needs_parentheses(r#type: &Type) -> bool {
        matches!(
            r#type,
            Type::Optional(_) | Type::Union(_) | Type::Function(_) | Type::Intersection(_)
        )
    }

    /// Returns a mutable reference to the last token for this intersection type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.types
            .last_mut()
            .expect("intersection types cannot be empty")
            .mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl From<Vec<Type>> for IntersectionType {
    fn from(types: Vec<Type>) -> Self {
        assert!(!types.is_empty(), "union types cannot be empty");
        Self {
            types,
            leading_operator: false,
            tokens: None,
        }
    }
}

impl iter::FromIterator<Type> for IntersectionType {
    fn from_iter<I: IntoIterator<Item = Type>>(iter: I) -> Self {
        Self {
            types: iter.into_iter().collect(),
            leading_operator: false,
            tokens: None,
        }
    }
}

/// Contains the tokens that define the intersection type syntax.
///
/// These tokens represent the `&` operators that separate type components.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IntersectionTypeTokens {
    /// Optional leading `&` token before the first type.
    pub leading_token: Option<Token>,
    /// The `&` tokens separating the type components.
    pub separators: Vec<Token>,
}

impl IntersectionTypeTokens {
    super::impl_token_fns!(iter = [leading_token, separators]);
}
