use super::{GenericTypePack, Type};

/// Represents a variadic type in a function signature.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum FunctionVariadicType {
    /// A specific type for variadic arguments.
    Type(Box<Type>),
    /// A generic type pack for variadic arguments.
    GenericTypePack(GenericTypePack),
}

impl From<GenericTypePack> for FunctionVariadicType {
    fn from(value: GenericTypePack) -> Self {
        Self::GenericTypePack(value)
    }
}

impl<T: Into<Type>> From<T> for FunctionVariadicType {
    fn from(value: T) -> Self {
        Self::Type(Box::new(value.into()))
    }
}
