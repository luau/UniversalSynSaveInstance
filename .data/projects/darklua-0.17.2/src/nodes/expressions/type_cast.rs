use crate::nodes::{Expression, Token, Type};

/// Represents a type cast expression.
///
/// This corresponds to expressions like: `expression :: type`
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeCastExpression {
    expression: Box<Expression>,
    r#type: Box<Type>,
    token: Option<Token>,
}

impl TypeCastExpression {
    /// Creates a new type cast expression with the given expression and type.
    pub fn new(expression: impl Into<Expression>, r#type: impl Into<Type>) -> Self {
        Self {
            expression: Box::new(expression.into()),
            r#type: Box::new(r#type.into()),
            token: None,
        }
    }

    /// Returns the expression being cast.
    pub fn get_expression(&self) -> &Expression {
        &self.expression
    }

    /// Returns a mutable reference to the expression being cast.
    pub fn mutate_expression(&mut self) -> &mut Expression {
        &mut self.expression
    }

    /// Consumes the type cast expression and returns the inner expression.
    pub fn into_inner_expression(self) -> Expression {
        *self.expression
    }

    /// Returns the type being cast to.
    pub fn get_type(&self) -> &Type {
        &self.r#type
    }

    /// Returns a mutable reference to the type being cast to.
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.r#type
    }

    /// Attaches a token to this type cast expression.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for this type cast expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this type cast expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Determines if the given expression requires parentheses when used as the subject of a type cast.
    ///
    /// Some expressions require parentheses to ensure correct operator precedence when type cast.
    pub fn needs_parentheses(expression: &Expression) -> bool {
        matches!(
            expression,
            Expression::Binary(_)
                | Expression::Unary(_)
                | Expression::TypeCast(_)
                | Expression::If(_)
        )
    }

    /// Returns a mutable reference to the last token for this type cast expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.r#type.mutate_last_token()
    }

    super::impl_token_fns!(iter = [token]);
}

#[cfg(test)]
mod test {
    use crate::nodes::IfExpression;

    use super::*;

    #[test]
    fn if_expression_needs_parentheses() {
        assert!(TypeCastExpression::needs_parentheses(&Expression::from(
            IfExpression::new(true, false, true)
        )));
    }
}
