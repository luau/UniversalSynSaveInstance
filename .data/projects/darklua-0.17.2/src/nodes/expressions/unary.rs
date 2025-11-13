use crate::nodes::{Expression, Token};

/// Represents the type of operator in a unary expression.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum UnaryOperator {
    /// The length operator (`#`)
    Length,
    /// The minus operator (`-`)
    Minus,
    /// The not operator (`not`)
    Not,
}

impl UnaryOperator {
    /// Returns the string representation of this operator.
    pub fn to_str(&self) -> &'static str {
        match self {
            Self::Length => "#",
            Self::Minus => "-",
            Self::Not => "not",
        }
    }
}

/// Represents a unary operation applied to an expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct UnaryExpression {
    operator: UnaryOperator,
    expression: Expression,
    token: Option<Token>,
}

impl UnaryExpression {
    /// Creates a new unary expression with the given operator and expression.
    pub fn new<E: Into<Expression>>(operator: UnaryOperator, expression: E) -> Self {
        Self {
            operator,
            expression: expression.into(),
            token: None,
        }
    }

    /// Attaches a token to this unary expression.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for this unary expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this unary expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns the expression being operated on.
    #[inline]
    pub fn get_expression(&self) -> &Expression {
        &self.expression
    }

    /// Returns a mutable reference to the expression being operated on.
    #[inline]
    pub fn mutate_expression(&mut self) -> &mut Expression {
        &mut self.expression
    }

    /// Returns the operator of this unary expression.
    #[inline]
    pub fn operator(&self) -> UnaryOperator {
        self.operator
    }

    /// Returns a mutable reference to the last token for this unary expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.expression.mutate_last_token()
    }

    super::impl_token_fns!(iter = [token]);
}
