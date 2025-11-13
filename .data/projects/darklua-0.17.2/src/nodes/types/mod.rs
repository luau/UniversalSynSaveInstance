mod array;
mod expression_type;
mod function;
mod function_variadic_type;
mod generics;
mod intersection;
mod optional;
mod parenthese;
mod string_type;
mod table;
mod type_field;
mod type_name;
mod type_pack;
mod union;
mod variadic_type_pack;

pub use array::*;
pub use expression_type::*;
pub use function::*;
pub use function_variadic_type::*;
pub use generics::*;
pub use intersection::*;
pub use optional::*;
pub use parenthese::*;
pub use string_type::*;
pub use table::*;
pub use type_field::*;
pub use type_name::*;
pub use type_pack::*;
pub use union::*;
pub use variadic_type_pack::*;

use crate::nodes::Token;

use super::impl_token_fns;

/// Represents a type annotation in Luau.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Type {
    /// A named type, such as `string` or a user-defined type.
    Name(TypeName),
    /// A field access on a type, such as `Module.Type`.
    Field(Box<TypeField>),
    /// The boolean literal type `true`.
    True(Option<Token>),
    /// The boolean literal type `false`.
    False(Option<Token>),
    /// The `nil` type.
    Nil(Option<Token>),
    /// A string literal type, such as `"hello"`.
    String(StringType),
    /// An array type, such as `{ string }`.
    Array(ArrayType),
    /// A table type, such as `{ field: Type }`.
    Table(TableType),
    /// A `typeof(expression)` type.
    TypeOf(ExpressionType),
    /// A type in parentheses, such as `(string | number)`.
    Parenthese(ParentheseType),
    /// A function type, such as `(number) -> string`.
    Function(Box<FunctionType>),
    /// An optional type, such as `string?`.
    Optional(OptionalType),
    /// An intersection type, such as `string & Serializable`.
    Intersection(IntersectionType),
    /// A union type, such as `string | number`.
    Union(UnionType),
}

impl Type {
    /// Creates a new `nil` type.
    pub fn nil() -> Self {
        Self::Nil(None)
    }

    /// Wraps this type in parentheses.
    pub fn in_parentheses(self) -> Type {
        Self::Parenthese(ParentheseType::new(self))
    }

    /// Returns a mutable reference to the last token for this type,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        match self {
            Self::Name(type_name) => type_name.mutate_last_token(),
            Self::Field(type_field) => type_field.mutate_last_token(),
            Self::True(token) => {
                if token.is_none() {
                    *token = Some(Token::from_content("true"));
                }
                token.as_mut().unwrap()
            }
            Self::False(token) => {
                if token.is_none() {
                    *token = Some(Token::from_content("false"));
                }
                token.as_mut().unwrap()
            }
            Self::Nil(token) => {
                if token.is_none() {
                    *token = Some(Token::from_content("nil"));
                }
                token.as_mut().unwrap()
            }
            Self::String(string_type) => string_type.mutate_or_insert_token(),
            Self::Array(array_type) => array_type.mutate_last_token(),
            Self::Table(table_type) => table_type.mutate_last_token(),
            Self::TypeOf(expression_type) => expression_type.mutate_last_token(),
            Self::Parenthese(parenthese_type) => parenthese_type.mutate_last_token(),
            Self::Function(function_type) => function_type.mutate_last_token(),
            Self::Optional(optional_type) => optional_type.mutate_last_token(),
            Self::Intersection(intersection_type) => intersection_type.mutate_last_token(),
            Self::Union(union_type) => union_type.mutate_last_token(),
        }
    }
}

impl From<bool> for Type {
    fn from(value: bool) -> Self {
        match value {
            true => Self::True(None),
            false => Self::False(None),
        }
    }
}

impl<T: Into<Type>> From<Option<T>> for Type {
    fn from(value: Option<T>) -> Self {
        match value {
            None => Self::nil(),
            Some(value) => value.into(),
        }
    }
}

impl From<TypeName> for Type {
    fn from(name: TypeName) -> Self {
        Self::Name(name)
    }
}

impl From<TypeField> for Type {
    fn from(type_field: TypeField) -> Self {
        Self::Field(Box::new(type_field))
    }
}

impl From<FunctionType> for Type {
    fn from(function: FunctionType) -> Self {
        Self::Function(Box::new(function))
    }
}

impl From<ArrayType> for Type {
    fn from(array: ArrayType) -> Self {
        Self::Array(array)
    }
}

impl From<TableType> for Type {
    fn from(table: TableType) -> Self {
        Self::Table(table)
    }
}

impl From<ExpressionType> for Type {
    fn from(type_of: ExpressionType) -> Self {
        Self::TypeOf(type_of)
    }
}

impl From<ParentheseType> for Type {
    fn from(parenthese_type: ParentheseType) -> Self {
        Self::Parenthese(parenthese_type)
    }
}

impl From<StringType> for Type {
    fn from(string_type: StringType) -> Self {
        Self::String(string_type)
    }
}

impl From<OptionalType> for Type {
    fn from(optional_type: OptionalType) -> Self {
        Self::Optional(optional_type)
    }
}

impl From<IntersectionType> for Type {
    fn from(intersection: IntersectionType) -> Self {
        Self::Intersection(intersection)
    }
}

impl From<UnionType> for Type {
    fn from(string_type: UnionType) -> Self {
        Self::Union(string_type)
    }
}
