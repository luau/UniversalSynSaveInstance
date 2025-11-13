use std::iter::FromIterator;

use crate::nodes::{Identifier, Token};

use super::{GenericTypePack, Type, TypePack, VariadicTypePack};

/// Represents a named type.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeName {
    type_name: Identifier,
    type_parameters: Option<Box<TypeParameters>>,
}

impl TypeName {
    /// Creates a new type name with the specified identifier.
    pub fn new(type_name: impl Into<Identifier>) -> Self {
        Self {
            type_name: type_name.into(),
            type_parameters: None,
        }
    }

    /// Associates type parameters with this type name.
    pub fn with_type_parameters(mut self, type_parameters: TypeParameters) -> Self {
        self.type_parameters = Some(Box::new(type_parameters));
        self
    }

    /// Adds a type parameter to this type name.
    pub fn with_type_parameter(mut self, parameter: impl Into<TypeParameter>) -> Self {
        self.push_type_parameter(parameter.into());
        self
    }

    /// Adds a type parameter to this type name.
    pub fn push_type_parameter(&mut self, parameter: impl Into<TypeParameter>) {
        if let Some(parameters) = &mut self.type_parameters {
            parameters.push_parameter(parameter.into());
        } else {
            self.type_parameters = Some(Box::new(TypeParameters {
                parameters: vec![parameter.into()],
                tokens: None,
            }))
        }
    }

    /// Returns the identifier of this type name.
    #[inline]
    pub fn get_type_name(&self) -> &Identifier {
        &self.type_name
    }

    /// Returns a mutable reference to the identifier of this type name.
    #[inline]
    pub fn mutate_type_name(&mut self) -> &mut Identifier {
        &mut self.type_name
    }

    /// Returns the type parameters of this type name, if any.
    #[inline]
    pub fn get_type_parameters(&self) -> Option<&TypeParameters> {
        self.type_parameters.as_deref()
    }

    /// Returns whether this type name has type parameters.
    #[inline]
    pub fn has_type_parameters(&self) -> bool {
        self.type_parameters.is_some()
    }

    /// Returns a mutable reference to the type parameters of this type name, if any.
    #[inline]
    pub fn mutate_type_parameters(&mut self) -> Option<&mut TypeParameters> {
        self.type_parameters.as_deref_mut()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if let Some(parameters) = &mut self.type_parameters {
            parameters.mutate_last_token()
        } else {
            self.type_name.mutate_or_insert_token()
        }
    }

    super::impl_token_fns!(target = [type_name] iter = [type_parameters]);
}

/// Represents a collection of type parameters in a generic type.
///
/// Type parameters are used in generic types, written as `Array<T>`
/// or `Map<K, V>` in type annotations.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeParameters {
    parameters: Vec<TypeParameter>,
    tokens: Option<TypeParametersTokens>,
}

impl TypeParameters {
    /// Creates new type parameters with a single initial parameter.
    pub fn new(parameter: impl Into<TypeParameter>) -> Self {
        Self {
            parameters: vec![parameter.into()],
            tokens: None,
        }
    }

    /// Adds a type parameter and returns the modified parameters.
    pub fn with_parameter(mut self, parameter: impl Into<TypeParameter>) -> Self {
        self.parameters.push(parameter.into());
        self
    }

    /// Adds a type parameter.
    pub fn push_parameter(&mut self, parameter: impl Into<TypeParameter>) {
        self.parameters.push(parameter.into());
    }

    /// Associates tokens with these type parameters.
    pub fn with_tokens(mut self, tokens: TypeParametersTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Returns an iterator over the type parameters.
    #[inline]
    pub fn iter(&self) -> impl Iterator<Item = &TypeParameter> {
        self.parameters.iter()
    }

    /// Returns a mutable iterator over the type parameters.
    #[inline]
    pub fn iter_mut(&mut self) -> impl Iterator<Item = &mut TypeParameter> {
        self.parameters.iter_mut()
    }

    /// Returns the number of type parameters.
    #[inline]
    pub fn len(&self) -> usize {
        self.parameters.len()
    }

    /// Returns whether there are no type parameters.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.parameters.is_empty()
    }

    /// Sets the tokens associated with these type parameters.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TypeParametersTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with these type parameters, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TypeParametersTokens> {
        self.tokens.as_ref()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(TypeParametersTokens {
                opening_list: Token::from_content("<"),
                closing_list: Token::from_content(">"),
                commas: Vec::new(),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_list
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl FromIterator<TypeParameter> for TypeParameters {
    fn from_iter<T: IntoIterator<Item = TypeParameter>>(iter: T) -> Self {
        Self {
            parameters: iter.into_iter().collect(),
            tokens: None,
        }
    }
}

impl IntoIterator for TypeParameters {
    type Item = TypeParameter;
    type IntoIter = std::vec::IntoIter<Self::Item>;

    fn into_iter(self) -> Self::IntoIter {
        self.parameters.into_iter()
    }
}

impl<'a> IntoIterator for &'a mut TypeParameters {
    type Item = &'a mut TypeParameter;
    type IntoIter = std::slice::IterMut<'a, TypeParameter>;

    fn into_iter(self) -> Self::IntoIter {
        self.parameters.iter_mut()
    }
}

impl<'a> IntoIterator for &'a TypeParameters {
    type Item = &'a TypeParameter;
    type IntoIter = std::slice::Iter<'a, TypeParameter>;

    fn into_iter(self) -> Self::IntoIter {
        self.parameters.iter()
    }
}

/// Represents a type parameter in a generic type.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TypeParameter {
    /// A single type parameter.
    Type(Type),
    /// A type pack parameter.
    TypePack(TypePack),
    /// A variadic type pack parameter.
    VariadicTypePack(VariadicTypePack),
    /// A generic type pack parameter.
    GenericTypePack(GenericTypePack),
}

impl<T: Into<Type>> From<T> for TypeParameter {
    fn from(value: T) -> Self {
        match value.into() {
            Type::Parenthese(parenthese) => {
                Self::TypePack(TypePack::default().with_type(parenthese.into_inner_type()))
            }
            other => Self::Type(other),
        }
    }
}

impl From<TypePack> for TypeParameter {
    fn from(value: TypePack) -> Self {
        Self::TypePack(value)
    }
}

impl From<VariadicTypePack> for TypeParameter {
    fn from(value: VariadicTypePack) -> Self {
        Self::VariadicTypePack(value)
    }
}

impl From<GenericTypePack> for TypeParameter {
    fn from(value: GenericTypePack) -> Self {
        Self::GenericTypePack(value)
    }
}

/// Contains the tokens that define the type parameters syntax.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeParametersTokens {
    /// The opening angle bracket token.
    pub opening_list: Token,
    /// The closing angle bracket token.
    pub closing_list: Token,
    /// The comma tokens separating the parameters.
    pub commas: Vec<Token>,
}

impl TypeParametersTokens {
    super::impl_token_fns!(
        target = [opening_list, closing_list]
        iter = [commas]
    );
}
