use crate::nodes::{Identifier, Token};

use super::{GenericParameters, GenericTypePack, Type, TypePack, VariadicTypePack};

/// Represents a single argument in a function type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionArgumentType {
    argument_type: Type,
    name: Option<Identifier>,
    token: Option<Token>,
}

impl<T: Into<Type>> From<T> for FunctionArgumentType {
    fn from(value: T) -> Self {
        Self::new(value.into())
    }
}

impl FunctionArgumentType {
    /// Creates a new function argument with the specified type.
    pub fn new(argument_type: impl Into<Type>) -> Self {
        Self {
            argument_type: argument_type.into(),
            name: None,
            token: None,
        }
    }

    /// Associates a name with this argument.
    pub fn with_name(mut self, name: impl Into<Identifier>) -> Self {
        self.name = Some(name.into());
        self
    }

    /// Sets the name of this argument.
    pub fn set_name(&mut self, name: impl Into<Identifier>) {
        self.name = Some(name.into());
    }

    /// Returns the type of this argument.
    #[inline]
    pub fn get_type(&self) -> &Type {
        &self.argument_type
    }

    /// Returns a mutable reference to the type of this argument.
    #[inline]
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.argument_type
    }

    /// Returns the name of this argument, if any.
    #[inline]
    pub fn get_name(&self) -> Option<&Identifier> {
        self.name.as_ref()
    }

    /// Returns a mutable reference to the name of this argument, if any.
    #[inline]
    pub fn mutate_name(&mut self) -> Option<&mut Identifier> {
        self.name.as_mut()
    }

    /// Associates a token with this argument.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token associated with this argument.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this argument, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    super::impl_token_fns!(iter = [name, token]);
}

/// Represents the return type of a function type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum FunctionReturnType {
    /// A single type return value.
    Type(Box<Type>),
    /// A pack of types as return values.
    TypePack(Box<TypePack>),
    /// A generic type pack as return values.
    GenericTypePack(Box<GenericTypePack>),
    /// A variadic type pack as return values.
    VariadicTypePack(VariadicTypePack),
}

impl FunctionReturnType {
    /// Returns a mutable reference to the last token for this function return type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        match self {
            Self::Type(r#type) => r#type.mutate_last_token(),
            Self::TypePack(type_pack) => type_pack.mutate_last_token(),
            Self::GenericTypePack(generic_type_pack) => generic_type_pack.mutate_last_token(),
            Self::VariadicTypePack(variadic_type_pack) => variadic_type_pack.mutate_last_token(),
        }
    }
}

impl<T: Into<Type>> From<T> for FunctionReturnType {
    fn from(r#type: T) -> Self {
        match r#type.into() {
            Type::Parenthese(parenthese) => Self::TypePack(Box::new(
                TypePack::default().with_type(parenthese.into_inner_type()),
            )),
            other => Self::Type(Box::new(other)),
        }
    }
}

impl From<TypePack> for FunctionReturnType {
    fn from(type_pack: TypePack) -> Self {
        Self::TypePack(Box::new(type_pack))
    }
}

impl From<GenericTypePack> for FunctionReturnType {
    fn from(generic_type_pack: GenericTypePack) -> Self {
        Self::GenericTypePack(Box::new(generic_type_pack))
    }
}

impl From<VariadicTypePack> for FunctionReturnType {
    fn from(variadic_type_pack: VariadicTypePack) -> Self {
        Self::VariadicTypePack(variadic_type_pack)
    }
}

/// Represents a variadic argument type in a function annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum VariadicArgumentType {
    /// A generic type pack used as a variadic argument.
    GenericTypePack(GenericTypePack),
    /// A variadic type pack used as a variadic argument.
    VariadicTypePack(VariadicTypePack),
}

impl From<GenericTypePack> for VariadicArgumentType {
    fn from(generic_type_pack: GenericTypePack) -> Self {
        Self::GenericTypePack(generic_type_pack)
    }
}

impl From<VariadicTypePack> for VariadicArgumentType {
    fn from(variadic_type_pack: VariadicTypePack) -> Self {
        Self::VariadicTypePack(variadic_type_pack)
    }
}

/// Represents a function type annotation in Luau.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionType {
    arguments: Vec<FunctionArgumentType>,
    variadic_argument_type: Option<VariadicArgumentType>,
    return_type: FunctionReturnType,
    generic_parameters: Option<GenericParameters>,
    tokens: Option<FunctionTypeTokens>,
}

impl FunctionType {
    /// Creates a new function type with the specified return type.
    pub fn new(return_type: impl Into<FunctionReturnType>) -> Self {
        Self {
            arguments: Vec::new(),
            variadic_argument_type: None,
            return_type: return_type.into(),
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Associates generic parameters with this function type and returns the modified type.
    pub fn with_generic_parameters(mut self, generic_parameters: GenericParameters) -> Self {
        self.generic_parameters = Some(generic_parameters);
        self
    }

    /// Sets the generic parameters of this function type.
    #[inline]
    pub fn set_generic_parameters(&mut self, generic_parameters: GenericParameters) {
        self.generic_parameters = Some(generic_parameters);
    }

    /// Returns the generic parameters of this function type, if any.
    #[inline]
    pub fn get_generic_parameters(&self) -> Option<&GenericParameters> {
        self.generic_parameters.as_ref()
    }

    /// Adds an argument to this function type and returns the modified type.
    pub fn with_argument(mut self, argument: impl Into<FunctionArgumentType>) -> Self {
        self.arguments.push(argument.into());
        self
    }

    /// Adds a named argument to this function type and returns the modified type.
    pub fn with_named_argument(
        mut self,
        name: impl Into<Identifier>,
        argument: impl Into<Type>,
    ) -> Self {
        self.arguments
            .push(FunctionArgumentType::new(argument.into()).with_name(name.into()));
        self
    }

    /// Adds an argument to this function type.
    pub fn push_argument(&mut self, argument: impl Into<FunctionArgumentType>) {
        self.arguments.push(argument.into());
    }

    /// Sets this function type to accept variadic arguments of the specified type.
    pub fn with_variadic_type(mut self, variadic_type: impl Into<VariadicArgumentType>) -> Self {
        self.variadic_argument_type = Some(variadic_type.into());
        self
    }

    /// Sets the variadic argument type of this function type.
    pub fn set_variadic_type(&mut self, variadic_type: impl Into<VariadicArgumentType>) {
        self.variadic_argument_type = Some(variadic_type.into());
    }

    /// Returns the variadic argument type of this function, if any.
    #[inline]
    pub fn get_variadic_argument_type(&self) -> Option<&VariadicArgumentType> {
        self.variadic_argument_type.as_ref()
    }

    /// Returns whether this function type has a variadic argument type.
    #[inline]
    pub fn has_variadic_argument_type(&self) -> bool {
        self.variadic_argument_type.is_some()
    }

    /// Returns a mutable reference to the variadic argument type of this function, if any.
    #[inline]
    pub fn mutate_variadic_argument_type(&mut self) -> Option<&mut VariadicArgumentType> {
        self.variadic_argument_type.as_mut()
    }

    /// Returns an iterator over the arguments of this function type.
    #[inline]
    pub fn iter_arguments(&self) -> impl Iterator<Item = &FunctionArgumentType> {
        self.arguments.iter()
    }

    /// Returns a mutable iterator over the arguments of this function type.
    #[inline]
    pub fn iter_mut_arguments(&mut self) -> impl Iterator<Item = &mut FunctionArgumentType> {
        self.arguments.iter_mut()
    }

    /// Returns the number of arguments for this function type.
    #[inline]
    pub fn argument_len(&self) -> usize {
        self.arguments.len()
    }

    /// Returns the return type of this function.
    #[inline]
    pub fn get_return_type(&self) -> &FunctionReturnType {
        &self.return_type
    }

    /// Returns a mutable reference to the return type of this function.
    #[inline]
    pub fn mutate_return_type(&mut self) -> &mut FunctionReturnType {
        &mut self.return_type
    }

    /// Associates tokens with this function type and returns the modified type.
    pub fn with_tokens(mut self, tokens: FunctionTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this function type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: FunctionTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this function type, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&FunctionTypeTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the last token for this function type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.return_type.mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens, generic_parameters, arguments]);
}

/// Represents the tokens associated with a function type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionTypeTokens {
    /// The opening parenthesis token.
    pub opening_parenthese: Token,
    /// The closing parenthesis token.
    pub closing_parenthese: Token,
    /// The arrow token (->).
    pub arrow: Token,
    /// The comma tokens between arguments.
    pub commas: Vec<Token>,
}

impl FunctionTypeTokens {
    super::impl_token_fns!(
        target = [opening_parenthese, closing_parenthese, arrow]
        iter = [commas]
    );
}
