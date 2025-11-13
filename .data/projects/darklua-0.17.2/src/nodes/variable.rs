use crate::nodes::{FieldExpression, Identifier, IndexExpression, Token};

/// Represents a variable reference.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Variable {
    /// A simple named variable (e.g., `x`, `count`, `self`).
    Identifier(Identifier),
    /// A field access on a table or object using dot notation (e.g., `table.field`, `self.name`).
    Field(Box<FieldExpression>),
    /// An index access on a table using bracket notation (e.g., `array[1]`, `table[key]`).
    Index(Box<IndexExpression>),
}

impl Variable {
    /// Creates a new variable from an identifier name.
    pub fn new<S: Into<String>>(name: S) -> Self {
        Self::Identifier(Identifier::new(name))
    }

    /// Returns a mutable reference to the first token for this variable,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        match self {
            Variable::Identifier(identifier) => {
                if identifier.get_token().is_none() {
                    let name = identifier.get_name().to_owned();
                    identifier.set_token(Token::from_content(name));
                }
                identifier.mutate_token().unwrap()
            }
            Variable::Field(field) => field.mutate_first_token(),
            Variable::Index(index) => index.mutate_first_token(),
        }
    }

    /// Returns a mutable reference to the last token for this variable,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        match self {
            Variable::Identifier(identifier) => identifier.mutate_or_insert_token(),
            Variable::Field(field) => field.mutate_last_token(),
            Variable::Index(index) => index.mutate_last_token(),
        }
    }
}

impl From<Identifier> for Variable {
    fn from(identifier: Identifier) -> Self {
        Self::Identifier(identifier)
    }
}

impl From<FieldExpression> for Variable {
    fn from(field: FieldExpression) -> Self {
        Self::Field(field.into())
    }
}

impl From<IndexExpression> for Variable {
    fn from(index: IndexExpression) -> Self {
        Self::Index(index.into())
    }
}
