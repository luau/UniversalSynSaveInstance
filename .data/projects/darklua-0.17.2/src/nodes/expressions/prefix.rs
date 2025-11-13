use crate::nodes::{
    Expression, FieldExpression, FunctionCall, Identifier, IndexExpression, ParentheseExpression,
    Token,
};

/// Represents a prefix expression.
///
/// Prefix expressions form the base for more complex expressions like method calls
/// and property access chains.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Prefix {
    /// A function call expression (e.g., `func()`)
    Call(Box<FunctionCall>),
    /// A field access expression (e.g., `object.field`)
    Field(Box<FieldExpression>),
    /// A simple name/variable (e.g., `variable_name`)
    Identifier(Identifier),
    /// An indexed access expression (e.g., `table[key]`)
    Index(Box<IndexExpression>),
    /// A parenthesized expression (e.g., `(expression)`)
    Parenthese(Box<ParentheseExpression>),
}

impl Prefix {
    /// Creates a new prefix from a name/identifier.
    pub fn from_name<S: Into<Identifier>>(name: S) -> Self {
        Self::Identifier(name.into())
    }

    /// Returns a mutable reference to the first token for this prefix chain,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        let mut current = self;
        loop {
            match current {
                Prefix::Call(call) => {
                    current = call.mutate_prefix();
                }
                Prefix::Field(field_expression) => {
                    current = field_expression.mutate_prefix();
                }
                Prefix::Index(index_expression) => {
                    current = index_expression.mutate_prefix();
                }
                Prefix::Identifier(identifier) => {
                    break identifier.mutate_or_insert_token();
                }
                Prefix::Parenthese(parenthese_expression) => {
                    break parenthese_expression.mutate_first_token();
                }
            }
        }
    }

    /// Returns a mutable reference to the last token for this prefix chain,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        match self {
            Prefix::Call(call) => call.mutate_last_token(),
            Prefix::Field(field_expression) => field_expression.mutate_last_token(),
            Prefix::Identifier(identifier) => identifier.mutate_or_insert_token(),
            Prefix::Index(index_expression) => index_expression.mutate_last_token(),
            Prefix::Parenthese(parenthese_expression) => parenthese_expression.mutate_last_token(),
        }
    }
}

impl From<Expression> for Prefix {
    fn from(expression: Expression) -> Self {
        match expression {
            Expression::Call(call) => Prefix::Call(call),
            Expression::Field(field) => Prefix::Field(field),
            Expression::Identifier(identifier) => Prefix::Identifier(identifier),
            Expression::Index(index) => Prefix::Index(index),
            Expression::Parenthese(parenthese) => Prefix::Parenthese(parenthese),
            Expression::Binary(_)
            | Expression::False(_)
            | Expression::Function(_)
            | Expression::If(_)
            | Expression::Nil(_)
            | Expression::Number(_)
            | Expression::String(_)
            | Expression::InterpolatedString(_)
            | Expression::Table(_)
            | Expression::True(_)
            | Expression::TypeCast(_)
            | Expression::Unary(_)
            | Expression::VariableArguments(_) => {
                Prefix::Parenthese(Box::new(ParentheseExpression::new(expression)))
            }
        }
    }
}

impl From<FunctionCall> for Prefix {
    fn from(call: FunctionCall) -> Self {
        Self::Call(Box::new(call))
    }
}

impl From<FieldExpression> for Prefix {
    fn from(field: FieldExpression) -> Self {
        Self::Field(field.into())
    }
}

impl From<Box<FieldExpression>> for Prefix {
    fn from(field: Box<FieldExpression>) -> Self {
        Self::Field(field)
    }
}

impl From<Identifier> for Prefix {
    fn from(identifier: Identifier) -> Self {
        Self::Identifier(identifier)
    }
}

impl From<IndexExpression> for Prefix {
    fn from(index: IndexExpression) -> Self {
        Self::Index(index.into())
    }
}

impl From<Box<IndexExpression>> for Prefix {
    fn from(index: Box<IndexExpression>) -> Self {
        Self::Index(index)
    }
}

impl From<ParentheseExpression> for Prefix {
    fn from(expression: ParentheseExpression) -> Self {
        Self::Parenthese(Box::new(expression))
    }
}
