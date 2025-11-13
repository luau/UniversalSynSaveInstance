use std::iter::FromIterator;

use crate::nodes::Token;

use super::{Type, VariadicArgumentType};

/// Represents a pack of types.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct TypePack {
    types: Vec<Type>,
    variadic_type: Option<VariadicArgumentType>,
    tokens: Option<TypePackTokens>,
}

impl TypePack {
    /// Adds a type to this type pack and returns the modified pack.
    pub fn with_type(mut self, r#type: impl Into<Type>) -> Self {
        self.types.push(r#type.into());
        self
    }

    /// Adds a type to this type pack.
    pub fn push_type(&mut self, r#type: impl Into<Type>) {
        self.types.push(r#type.into());
    }

    /// Sets this type pack to include a variadic type and returns the modified pack.
    pub fn with_variadic_type(mut self, variadic_type: impl Into<VariadicArgumentType>) -> Self {
        self.variadic_type = Some(variadic_type.into());
        self
    }

    /// Sets the variadic type of this type pack.
    pub fn set_variadic_type(&mut self, variadic_type: impl Into<VariadicArgumentType>) {
        self.variadic_type = Some(variadic_type.into());
    }

    /// Returns the variadic type of this type pack, if any.
    #[inline]
    pub fn get_variadic_type(&self) -> Option<&VariadicArgumentType> {
        self.variadic_type.as_ref()
    }

    /// Returns whether this type pack has a variadic type.
    #[inline]
    pub fn has_variadic_type(&self) -> bool {
        self.variadic_type.is_some()
    }

    /// Returns a mutable reference to the variadic type of this type pack, if any.
    #[inline]
    pub fn mutate_variadic_type(&mut self) -> Option<&mut VariadicArgumentType> {
        self.variadic_type.as_mut()
    }

    /// Returns the number of types in this type pack, excluding any variadic type.
    #[inline]
    pub fn len(&self) -> usize {
        self.types.len()
    }

    /// Returns whether this type pack contains no types, excluding any variadic type.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.types.is_empty()
    }

    /// Returns an iterator over the types in this type pack.
    #[inline]
    pub fn iter(&self) -> impl Iterator<Item = &Type> {
        self.types.iter()
    }

    /// Returns a mutable iterator over the types in this type pack.
    #[inline]
    pub fn iter_mut(&mut self) -> impl Iterator<Item = &mut Type> {
        self.types.iter_mut()
    }

    /// Associates tokens with this type pack and returns the modified pack.
    pub fn with_tokens(mut self, tokens: TypePackTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this type pack.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TypePackTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this type pack, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TypePackTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens of this type pack, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut TypePackTokens> {
        self.tokens.as_mut()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(TypePackTokens {
                left_parenthese: Token::from_content("("),
                right_parenthese: Token::from_content(")"),
                commas: Vec::new(),
            });
        }
        &mut self.tokens.as_mut().unwrap().right_parenthese
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl FromIterator<Type> for TypePack {
    fn from_iter<T: IntoIterator<Item = Type>>(iter: T) -> Self {
        Self {
            types: iter.into_iter().collect(),
            variadic_type: None,
            tokens: None,
        }
    }
}

impl IntoIterator for TypePack {
    type Item = Type;
    type IntoIter = std::vec::IntoIter<Self::Item>;

    fn into_iter(self) -> Self::IntoIter {
        self.types.into_iter()
    }
}

impl<'a> IntoIterator for &'a mut TypePack {
    type Item = &'a mut Type;
    type IntoIter = std::slice::IterMut<'a, Type>;

    fn into_iter(self) -> Self::IntoIter {
        self.types.iter_mut()
    }
}

impl<'a> IntoIterator for &'a TypePack {
    type Item = &'a Type;
    type IntoIter = std::slice::Iter<'a, Type>;

    fn into_iter(self) -> Self::IntoIter {
        self.types.iter()
    }
}

/// Contains the tokens that define the type pack syntax.
///
/// These tokens represent the parentheses and commas in a type pack.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypePackTokens {
    /// The left parenthesis token.
    pub left_parenthese: Token,
    /// The right parenthesis token.
    pub right_parenthese: Token,
    /// The comma tokens separating the types.
    pub commas: Vec<Token>,
}

impl TypePackTokens {
    super::impl_token_fns!(
        target = [left_parenthese, right_parenthese]
        iter = [commas]
    );
}
