use std::marker::PhantomData;

use crate::nodes::{Identifier, Token, TypePack, VariadicTypePack};

use super::Type;

/// Represents a generic type pack.
///
/// Generic type packs represent a pack of types that can be specified later,
/// written as `T...` where T is a type pack parameter name.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericTypePack {
    // name ...
    name: Identifier,
    token: Option<Token>,
}

impl GenericTypePack {
    /// Creates a new generic type pack with the specified name.
    pub fn new(name: impl Into<Identifier>) -> Self {
        Self {
            name: name.into(),
            token: None,
        }
    }

    /// Returns the name of this generic type pack.
    #[inline]
    pub fn get_name(&self) -> &Identifier {
        &self.name
    }

    /// Returns a mutable reference to the name of this generic type pack.
    #[inline]
    pub fn mutate_name(&mut self) -> &mut Identifier {
        &mut self.name
    }

    /// Associates a token with this generic type pack and returns the modified pack.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token associated with this generic type pack.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this generic type pack, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the last token for this generic type pack,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.token.is_none() {
            self.token = Some(Token::from_content("..."));
        }
        self.token.as_mut().unwrap()
    }

    super::impl_token_fns!(
        target = [name]
        iter = [token]
    );
}

/// Represents generic parameters in a function or type declaration.
///
/// Generic parameters allow type signatures to be parameterized,
/// written as `<T, U...>` in Luau type annotations.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericParameters {
    // generic type list
    type_variables: Vec<Identifier>,
    generic_type_packs: Vec<GenericTypePack>,
    tokens: Option<GenericParametersTokens>,
}

impl GenericParameters {
    /// Creates new generic parameters with a single type variable.
    pub fn from_type_variable(name: impl Into<Identifier>) -> Self {
        Self {
            type_variables: vec![name.into()],
            generic_type_packs: Vec::new(),
            tokens: None,
        }
    }

    /// Creates new generic parameters with a single generic type pack.
    pub fn from_generic_type_pack(generic_type_pack: impl Into<GenericTypePack>) -> Self {
        Self {
            type_variables: Vec::new(),
            generic_type_packs: vec![generic_type_pack.into()],
            tokens: None,
        }
    }

    /// Adds a type variable to these generic parameters.
    pub fn with_type_variable(mut self, type_variable: impl Into<Identifier>) -> Self {
        self.type_variables.push(type_variable.into());
        self
    }

    /// Adds a type variable to these generic parameters.
    pub fn push_type_variable(&mut self, type_variable: impl Into<Identifier>) {
        self.type_variables.push(type_variable.into());
    }

    /// Adds a generic type pack to these generic parameters.
    pub fn push_generic_type_pack(&mut self, generic_pack: GenericTypePack) {
        self.generic_type_packs.push(generic_pack);
    }

    /// Returns the total number of generic parameters.
    #[inline]
    pub fn len(&self) -> usize {
        self.type_variables.len() + self.generic_type_packs.len()
    }

    /// Returns whether there are no generic parameters.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.type_variables.is_empty() && self.generic_type_packs.is_empty()
    }

    /// Returns the number of type variables in these generic parameters.
    #[inline]
    pub fn type_variables_len(&self) -> usize {
        self.type_variables.len()
    }

    /// Returns the number of generic type packs in these generic parameters.
    #[inline]
    pub fn generic_type_packs_len(&self) -> usize {
        self.generic_type_packs.len()
    }

    /// Returns an iterator over the type variables in these generic parameters.
    pub fn iter_type_variable(&self) -> impl Iterator<Item = &Identifier> {
        self.type_variables.iter()
    }

    /// Returns a mutable iterator over the type variables in these generic parameters.
    pub fn iter_mut_type_variable(&mut self) -> impl Iterator<Item = &mut Identifier> {
        self.type_variables.iter_mut()
    }

    /// Returns an iterator over the generic type packs in these generic parameters.
    pub fn iter_generic_type_pack(&self) -> impl Iterator<Item = &GenericTypePack> {
        self.generic_type_packs.iter()
    }

    /// Returns a mutable iterator over the generic type packs in these generic parameters.
    pub fn iter_mut_generic_type_pack(&mut self) -> impl Iterator<Item = &mut GenericTypePack> {
        self.generic_type_packs.iter_mut()
    }

    /// Associates tokens with these generic parameters.
    pub fn with_tokens(mut self, tokens: GenericParametersTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with these generic parameters.
    #[inline]
    pub fn set_tokens(&mut self, tokens: GenericParametersTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with these generic parameters, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&GenericParametersTokens> {
        self.tokens.as_ref()
    }

    super::impl_token_fns!(iter = [type_variables, generic_type_packs, tokens]);
}

/// Contains the tokens that define the generic parameters syntax.
///
/// These tokens represent the angle brackets and commas in generic parameters.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericParametersTokens {
    /// The opening angle bracket token.
    pub opening_list: Token,
    /// The closing angle bracket token.
    pub closing_list: Token,
    /// The comma tokens separating the parameters.
    pub commas: Vec<Token>,
}

impl GenericParametersTokens {
    super::impl_token_fns!(
        target = [opening_list, closing_list]
        iter = [commas]
    );
}

/// Represents the default value for a generic type pack.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum GenericTypePackDefault {
    /// A type pack default.
    TypePack(Box<TypePack>),
    /// A variadic type pack default.
    VariadicTypePack(VariadicTypePack),
    /// A generic type pack default.
    GenericTypePack(GenericTypePack),
}

impl From<TypePack> for GenericTypePackDefault {
    fn from(type_pack: TypePack) -> Self {
        Self::TypePack(Box::new(type_pack))
    }
}

impl From<VariadicTypePack> for GenericTypePackDefault {
    fn from(variadic_type_pack: VariadicTypePack) -> Self {
        Self::VariadicTypePack(variadic_type_pack)
    }
}

impl From<GenericTypePack> for GenericTypePackDefault {
    fn from(generic_type_pack: GenericTypePack) -> Self {
        Self::GenericTypePack(generic_type_pack)
    }
}

/// Represents a generic type pack with a default value.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericTypePackWithDefault {
    generic_type_pack: GenericTypePack,
    default: GenericTypePackDefault,
    // equal sign token
    token: Option<Token>,
}

impl GenericTypePackWithDefault {
    /// Creates a new generic type pack with the specified default value.
    pub fn new(
        generic_type_pack: impl Into<GenericTypePack>,
        default: impl Into<GenericTypePackDefault>,
    ) -> Self {
        Self {
            generic_type_pack: generic_type_pack.into(),
            default: default.into(),
            token: None,
        }
    }

    /// Returns the generic type pack.
    #[inline]
    pub fn get_generic_type_pack(&self) -> &GenericTypePack {
        &self.generic_type_pack
    }

    /// Returns a mutable reference to the generic type pack.
    #[inline]
    pub fn mutate_generic_type_pack(&mut self) -> &mut GenericTypePack {
        &mut self.generic_type_pack
    }

    /// Returns the default type of this generic type pack.
    #[inline]
    pub fn get_default_type(&self) -> &GenericTypePackDefault {
        &self.default
    }

    /// Returns a mutable reference to the default type of this generic type pack.
    #[inline]
    pub fn mutate_default_type(&mut self) -> &mut GenericTypePackDefault {
        &mut self.default
    }

    /// Associates a token with this generic type pack and returns the modified pack.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token associated with this generic type pack.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this generic type pack, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    super::impl_token_fns!(iter = [token]);
}

/// Represents a type variable with a default value.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeVariableWithDefault {
    variable: Identifier,
    default: Type,
    // equal sign token
    token: Option<Token>,
}

impl TypeVariableWithDefault {
    /// Creates a new type variable with the specified default type.
    pub fn new(identifier: impl Into<Identifier>, r#type: impl Into<Type>) -> Self {
        Self {
            variable: identifier.into(),
            default: r#type.into(),
            token: None,
        }
    }

    /// Returns the type variable identifier.
    #[inline]
    pub fn get_type_variable(&self) -> &Identifier {
        &self.variable
    }

    /// Returns a mutable reference to the type variable identifier.
    #[inline]
    pub fn mutate_type_variable(&mut self) -> &mut Identifier {
        &mut self.variable
    }

    /// Returns the default type of this type variable.
    #[inline]
    pub fn get_default_type(&self) -> &Type {
        &self.default
    }

    /// Returns a mutable reference to the default type of this type variable.
    #[inline]
    pub fn mutate_default_type(&mut self) -> &mut Type {
        &mut self.default
    }

    /// Associates a token for the `=` operator with this type variable and returns the modified variable.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for the `=` operator associated with this type variable.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token for the `=` operator associated with this type variable, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    super::impl_token_fns!(
        target = [variable]
        iter = [token]
    );
}

/// Represents a collection of generic parameters that may include default values.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericParametersWithDefaults {
    type_variables: Vec<Identifier>,
    middle: GenericParametersWithDefaultsMiddle,
    generic_type_packs_with_default: Vec<GenericTypePackWithDefault>,
    tokens: Option<GenericParametersTokens>,
}

impl GenericParametersWithDefaults {
    /// Creates new generic parameters with a single type variable.
    pub fn from_type_variable(identifier: impl Into<Identifier>) -> Self {
        Self {
            type_variables: vec![identifier.into()],
            middle: GenericParametersWithDefaultsMiddle::Empty,
            generic_type_packs_with_default: Vec::new(),
            tokens: None,
        }
    }

    /// Creates new generic parameters with a single type variable that has a default value.
    pub fn from_type_variable_with_default(
        type_variable_with_default: TypeVariableWithDefault,
    ) -> Self {
        Self {
            type_variables: Vec::new(),
            middle: GenericParametersWithDefaultsMiddle::TypeVariableDefaults(vec![
                type_variable_with_default,
            ]),
            generic_type_packs_with_default: Vec::new(),
            tokens: None,
        }
    }

    /// Creates new generic parameters with a single generic type pack.
    pub fn from_generic_type_pack(generic_type_pack: GenericTypePack) -> Self {
        Self {
            type_variables: Vec::new(),
            middle: GenericParametersWithDefaultsMiddle::GenericTypePacks(vec![generic_type_pack]),
            generic_type_packs_with_default: Vec::new(),
            tokens: None,
        }
    }

    /// Creates new generic parameters with a single generic type pack that has a default value.
    pub fn from_generic_type_pack_with_default(
        generic_type_pack_with_default: GenericTypePackWithDefault,
    ) -> Self {
        Self {
            type_variables: Vec::new(),
            middle: GenericParametersWithDefaultsMiddle::Empty,
            generic_type_packs_with_default: vec![generic_type_pack_with_default],
            tokens: None,
        }
    }

    /// Adds a type variable to these generic parameters.
    pub fn with_type_variable(mut self, identifier: impl Into<Identifier>) -> Self {
        self.type_variables.push(identifier.into());
        self
    }

    /// Adds a type variable to these generic parameters.
    pub fn push_type_variable(&mut self, type_variable: impl Into<Identifier>) {
        self.type_variables.push(type_variable.into());
    }

    /// Adds a type variable with a default value to these generic parameters.
    ///
    /// Returns `None` if the operation would mix type variables with default values and generic type packs.
    pub fn with_type_variable_with_default(
        mut self,
        type_variable_with_default: TypeVariableWithDefault,
    ) -> Option<Self> {
        if self.push_type_variable_with_default(type_variable_with_default) {
            Some(self)
        } else {
            None
        }
    }

    /// Adds a type variable with a default value to these generic parameters.
    ///
    /// Returns `false` if the operation would mix type variables with default values and generic type packs.
    pub fn push_type_variable_with_default(
        &mut self,
        type_variable_with_default: TypeVariableWithDefault,
    ) -> bool {
        match &mut self.middle {
            GenericParametersWithDefaultsMiddle::Empty => {
                self.middle = GenericParametersWithDefaultsMiddle::TypeVariableDefaults(vec![
                    type_variable_with_default,
                ]);
                true
            }
            GenericParametersWithDefaultsMiddle::TypeVariableDefaults(types) => {
                types.push(type_variable_with_default);
                true
            }
            GenericParametersWithDefaultsMiddle::GenericTypePacks(_) => false,
        }
    }

    /// Adds a generic type pack to these generic parameters.
    ///
    /// Returns `None` if the operation would mix generic type packs and type variables with default values.
    pub fn with_generic_type_pack(mut self, generic_type_pack: GenericTypePack) -> Option<Self> {
        if self.push_generic_type_pack(generic_type_pack) {
            Some(self)
        } else {
            None
        }
    }

    /// Adds a generic type pack to these generic parameters.
    ///
    /// Returns `false` if the operation would mix generic type packs and type variables with default values.
    pub fn push_generic_type_pack(&mut self, generic_type_pack: GenericTypePack) -> bool {
        match &mut self.middle {
            GenericParametersWithDefaultsMiddle::Empty => {
                self.middle =
                    GenericParametersWithDefaultsMiddle::GenericTypePacks(vec![generic_type_pack]);
                true
            }
            GenericParametersWithDefaultsMiddle::GenericTypePacks(type_packs) => {
                type_packs.push(generic_type_pack);
                true
            }
            GenericParametersWithDefaultsMiddle::TypeVariableDefaults(_) => false,
        }
    }

    /// Adds a generic type pack with a default value to these generic parameters.
    pub fn with_generic_type_pack_with_default(
        mut self,
        generic_type_pack_with_default: GenericTypePackWithDefault,
    ) -> Self {
        self.generic_type_packs_with_default
            .push(generic_type_pack_with_default);
        self
    }

    /// Adds a generic type pack with a default value to these generic parameters.
    pub fn push_generic_type_pack_with_default(
        &mut self,
        generic_type_pack_with_default: GenericTypePackWithDefault,
    ) {
        self.generic_type_packs_with_default
            .push(generic_type_pack_with_default);
    }

    /// Associates tokens with these generic parameters.
    pub fn with_tokens(mut self, tokens: GenericParametersTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with these generic parameters.
    #[inline]
    pub fn set_tokens(&mut self, tokens: GenericParametersTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with these generic parameters, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&GenericParametersTokens> {
        self.tokens.as_ref()
    }

    /// Returns an iterator over references to the generic parameters.
    pub fn iter(&self) -> impl Iterator<Item = GenericParameterRef<'_>> {
        self.into_iter()
    }

    /// Returns a mutable iterator over references to the generic parameters.
    pub fn iter_mut(&mut self) -> impl Iterator<Item = GenericParameterMutRef<'_>> {
        self.into_iter()
    }

    /// Returns the total number of generic parameters.
    pub fn len(&self) -> usize {
        self.type_variables.len() + self.middle.len() + self.generic_type_packs_with_default.len()
    }

    /// Returns whether there are no generic parameters.
    pub fn is_empty(&self) -> bool {
        self.type_variables.is_empty()
            && self.middle.is_empty()
            && self.generic_type_packs_with_default.is_empty()
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Represents a generic parameter in a type or function signature.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum GenericParameter {
    /// A simple type variable like `T`.
    TypeVariable(Identifier),
    /// A type variable with a default value like `T = string`.
    TypeVariableWithDefault(Box<TypeVariableWithDefault>),
    /// A generic type pack like `T...`.
    GenericTypePack(Box<GenericTypePack>),
    /// A generic type pack with a default value like `T... = ...string`.
    GenericTypePackWithDefault(Box<GenericTypePackWithDefault>),
}

impl From<Identifier> for GenericParameter {
    fn from(value: Identifier) -> Self {
        Self::TypeVariable(value)
    }
}

impl From<TypeVariableWithDefault> for GenericParameter {
    fn from(value: TypeVariableWithDefault) -> Self {
        Self::TypeVariableWithDefault(Box::new(value))
    }
}

impl From<GenericTypePack> for GenericParameter {
    fn from(value: GenericTypePack) -> Self {
        Self::GenericTypePack(Box::new(value))
    }
}

impl From<GenericTypePackWithDefault> for GenericParameter {
    fn from(value: GenericTypePackWithDefault) -> Self {
        Self::GenericTypePackWithDefault(Box::new(value))
    }
}

/// A reference to a generic parameter.
pub enum GenericParameterRef<'a> {
    /// A reference to a simple type variable.
    TypeVariable(&'a Identifier),
    /// A reference to a type variable with a default value.
    TypeVariableWithDefault(&'a TypeVariableWithDefault),
    /// A reference to a generic type pack.
    GenericTypePack(&'a GenericTypePack),
    /// A reference to a generic type pack with a default value.
    GenericTypePackWithDefault(&'a GenericTypePackWithDefault),
}

impl<'a> From<&'a Identifier> for GenericParameterRef<'a> {
    fn from(value: &'a Identifier) -> Self {
        Self::TypeVariable(value)
    }
}

impl<'a> From<&'a TypeVariableWithDefault> for GenericParameterRef<'a> {
    fn from(value: &'a TypeVariableWithDefault) -> Self {
        Self::TypeVariableWithDefault(value)
    }
}

impl<'a> From<&'a GenericTypePack> for GenericParameterRef<'a> {
    fn from(value: &'a GenericTypePack) -> Self {
        Self::GenericTypePack(value)
    }
}

impl<'a> From<&'a GenericTypePackWithDefault> for GenericParameterRef<'a> {
    fn from(value: &'a GenericTypePackWithDefault) -> Self {
        Self::GenericTypePackWithDefault(value)
    }
}

/// A mutable reference to a generic parameter.
pub enum GenericParameterMutRef<'a> {
    /// A mutable reference to a simple type variable.
    TypeVariable(&'a mut Identifier),
    /// A mutable reference to a type variable with a default value.
    TypeVariableWithDefault(&'a mut TypeVariableWithDefault),
    /// A mutable reference to a generic type pack.
    GenericTypePack(&'a mut GenericTypePack),
    /// A mutable reference to a generic type pack with a default value.
    GenericTypePackWithDefault(&'a mut GenericTypePackWithDefault),
}

impl<'a> From<&'a mut Identifier> for GenericParameterMutRef<'a> {
    fn from(value: &'a mut Identifier) -> Self {
        Self::TypeVariable(value)
    }
}

impl<'a> From<&'a mut TypeVariableWithDefault> for GenericParameterMutRef<'a> {
    fn from(value: &'a mut TypeVariableWithDefault) -> Self {
        Self::TypeVariableWithDefault(value)
    }
}

impl<'a> From<&'a mut GenericTypePack> for GenericParameterMutRef<'a> {
    fn from(value: &'a mut GenericTypePack) -> Self {
        Self::GenericTypePack(value)
    }
}

impl<'a> From<&'a mut GenericTypePackWithDefault> for GenericParameterMutRef<'a> {
    fn from(value: &'a mut GenericTypePackWithDefault) -> Self {
        Self::GenericTypePackWithDefault(value)
    }
}

/// A utility struct to create iterators over generic parameters.
pub struct GenericParameterIteratorGeneric<Item, A, B, C, D, IterA, IterB, IterC, IterD>
where
    IterA: Iterator<Item = A>,
    IterB: Iterator<Item = B>,
    IterC: Iterator<Item = C>,
    IterD: Iterator<Item = D>,
{
    type_variables: IterA,
    generic_type_packs: Option<IterB>,
    type_variables_with_default: Option<IterC>,
    generic_type_packs_with_default: IterD,
    _phantom: PhantomData<Item>,
}

impl<Item, A, B, C, D, IterA, IterB, IterC, IterD>
    GenericParameterIteratorGeneric<Item, A, B, C, D, IterA, IterB, IterC, IterD>
where
    IterA: Iterator<Item = A>,
    IterB: Iterator<Item = B>,
    IterC: Iterator<Item = C>,
    IterD: Iterator<Item = D>,
{
    fn new(
        type_variables: impl IntoIterator<Item = A, IntoIter = IterA>,
        generic_type_packs: Option<impl IntoIterator<Item = B, IntoIter = IterB>>,
        type_variables_with_default: Option<impl IntoIterator<Item = C, IntoIter = IterC>>,
        generic_type_packs_with_default: impl IntoIterator<Item = D, IntoIter = IterD>,
    ) -> Self {
        Self {
            type_variables: type_variables.into_iter(),
            generic_type_packs: generic_type_packs.map(IntoIterator::into_iter),
            type_variables_with_default: type_variables_with_default.map(IntoIterator::into_iter),
            generic_type_packs_with_default: generic_type_packs_with_default.into_iter(),
            _phantom: PhantomData,
        }
    }
}

pub type GenericParameterIterator = GenericParameterIteratorGeneric<
    GenericParameter,
    Identifier,
    GenericTypePack,
    TypeVariableWithDefault,
    GenericTypePackWithDefault,
    std::vec::IntoIter<Identifier>,
    std::vec::IntoIter<GenericTypePack>,
    std::vec::IntoIter<TypeVariableWithDefault>,
    std::vec::IntoIter<GenericTypePackWithDefault>,
>;

pub type GenericParameterRefIterator<'a> = GenericParameterIteratorGeneric<
    GenericParameterRef<'a>,
    &'a Identifier,
    &'a GenericTypePack,
    &'a TypeVariableWithDefault,
    &'a GenericTypePackWithDefault,
    std::slice::Iter<'a, Identifier>,
    std::slice::Iter<'a, GenericTypePack>,
    std::slice::Iter<'a, TypeVariableWithDefault>,
    std::slice::Iter<'a, GenericTypePackWithDefault>,
>;

pub type GenericParameterMutRefIterator<'a> = GenericParameterIteratorGeneric<
    GenericParameterMutRef<'a>,
    &'a mut Identifier,
    &'a mut GenericTypePack,
    &'a mut TypeVariableWithDefault,
    &'a mut GenericTypePackWithDefault,
    std::slice::IterMut<'a, Identifier>,
    std::slice::IterMut<'a, GenericTypePack>,
    std::slice::IterMut<'a, TypeVariableWithDefault>,
    std::slice::IterMut<'a, GenericTypePackWithDefault>,
>;

impl<IterItem, A, B, C, D, IterA, IterB, IterC, IterD> Iterator
    for GenericParameterIteratorGeneric<IterItem, A, B, C, D, IterA, IterB, IterC, IterD>
where
    A: Into<IterItem>,
    B: Into<IterItem>,
    C: Into<IterItem>,
    D: Into<IterItem>,
    IterA: Iterator<Item = A>,
    IterB: Iterator<Item = B>,
    IterC: Iterator<Item = C>,
    IterD: Iterator<Item = D>,
{
    type Item = IterItem;

    fn next(&mut self) -> Option<Self::Item> {
        self.type_variables
            .next()
            .map(Into::into)
            .or_else(|| {
                self.generic_type_packs
                    .as_mut()
                    .and_then(|generic_type_packs| generic_type_packs.next().map(Into::into))
            })
            .or_else(|| {
                self.type_variables_with_default
                    .as_mut()
                    .and_then(|type_variables_with_default| {
                        type_variables_with_default.next().map(Into::into)
                    })
            })
            .or_else(|| self.generic_type_packs_with_default.next().map(Into::into))
    }
}

impl IntoIterator for GenericParametersWithDefaults {
    type Item = GenericParameter;
    type IntoIter = GenericParameterIterator;

    fn into_iter(self) -> Self::IntoIter {
        let (generic_type_packs, type_variables_with_default) = match self.middle {
            GenericParametersWithDefaultsMiddle::Empty => (None, None),
            GenericParametersWithDefaultsMiddle::GenericTypePacks(generic_type_packs) => {
                (Some(generic_type_packs), None)
            }
            GenericParametersWithDefaultsMiddle::TypeVariableDefaults(
                type_variables_with_default,
            ) => (None, Some(type_variables_with_default)),
        };
        GenericParameterIterator::new(
            self.type_variables,
            generic_type_packs,
            type_variables_with_default,
            self.generic_type_packs_with_default,
        )
    }
}

impl<'a> IntoIterator for &'a mut GenericParametersWithDefaults {
    type Item = GenericParameterMutRef<'a>;
    type IntoIter = GenericParameterMutRefIterator<'a>;

    fn into_iter(self) -> Self::IntoIter {
        let (generic_type_packs, type_variables_with_default) = match &mut self.middle {
            GenericParametersWithDefaultsMiddle::Empty => (None, None),
            GenericParametersWithDefaultsMiddle::GenericTypePacks(generic_type_packs) => {
                (Some(generic_type_packs), None)
            }
            GenericParametersWithDefaultsMiddle::TypeVariableDefaults(
                type_variables_with_default,
            ) => (None, Some(type_variables_with_default)),
        };
        GenericParameterMutRefIterator::new(
            &mut self.type_variables,
            generic_type_packs,
            type_variables_with_default,
            &mut self.generic_type_packs_with_default,
        )
    }
}

impl<'a> IntoIterator for &'a GenericParametersWithDefaults {
    type Item = GenericParameterRef<'a>;
    type IntoIter = GenericParameterRefIterator<'a>;

    fn into_iter(self) -> Self::IntoIter {
        let (generic_type_packs, type_variables_with_default) = match &self.middle {
            GenericParametersWithDefaultsMiddle::Empty => (None, None),
            GenericParametersWithDefaultsMiddle::GenericTypePacks(generic_type_packs) => {
                (Some(generic_type_packs), None)
            }
            GenericParametersWithDefaultsMiddle::TypeVariableDefaults(
                type_variables_with_default,
            ) => (None, Some(type_variables_with_default)),
        };
        GenericParameterRefIterator::new(
            &self.type_variables,
            generic_type_packs,
            type_variables_with_default,
            &self.generic_type_packs_with_default,
        )
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
enum GenericParametersWithDefaultsMiddle {
    Empty,
    GenericTypePacks(Vec<GenericTypePack>),
    TypeVariableDefaults(Vec<TypeVariableWithDefault>),
}

impl GenericParametersWithDefaultsMiddle {
    fn len(&self) -> usize {
        match self {
            Self::Empty => 0,
            Self::GenericTypePacks(generic_type_packs) => generic_type_packs.len(),
            Self::TypeVariableDefaults(type_variables) => type_variables.len(),
        }
    }

    fn is_empty(&self) -> bool {
        match self {
            Self::Empty => true,
            Self::GenericTypePacks(generic_type_packs) => generic_type_packs.is_empty(),
            Self::TypeVariableDefaults(type_variables) => type_variables.is_empty(),
        }
    }
}
