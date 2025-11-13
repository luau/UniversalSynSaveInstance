use crate::nodes::{Expression, FunctionReturnType, Token, Type};

/// Represents binary operators used in a binary expression.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum BinaryOperator {
    /// Logical AND operator (`and`)
    And,
    /// Logical OR operator (`or`)
    Or,
    /// Equality operator (`==`)
    Equal,
    /// Inequality operator (`~=`)
    NotEqual,
    /// Less than operator (`<`)
    LowerThan,
    /// Less than or equal operator (`<=`)
    LowerOrEqualThan,
    /// Greater than operator (`>`)
    GreaterThan,
    /// Greater than or equal operator (`>=`)
    GreaterOrEqualThan,
    /// Addition operator (`+`)
    Plus,
    /// Subtraction operator (`-`)
    Minus,
    /// Multiplication operator (`*`)
    Asterisk,
    /// Division operator (`/`)
    Slash,
    /// Integer division operator (`//`)
    DoubleSlash,
    /// Modulo operator (`%`)
    Percent,
    /// Exponentiation operator (`^`)
    Caret,
    /// String concatenation operator (`..`)
    Concat,
}

#[inline]
fn ends_with_if_expression(expression: &Expression) -> bool {
    let mut current = expression;

    loop {
        match current {
            Expression::If(_) => break true,
            Expression::Binary(binary) => current = binary.right(),
            Expression::Unary(unary) => current = unary.get_expression(),
            Expression::Call(_)
            | Expression::False(_)
            | Expression::Field(_)
            | Expression::Function(_)
            | Expression::Identifier(_)
            | Expression::Index(_)
            | Expression::Nil(_)
            | Expression::Number(_)
            | Expression::Parenthese(_)
            | Expression::String(_)
            | Expression::InterpolatedString(_)
            | Expression::Table(_)
            | Expression::True(_)
            | Expression::VariableArguments(_)
            | Expression::TypeCast(_) => break false,
        }
    }
}

#[inline]
fn ends_with_type_cast_to_type_name_without_type_parameters(expression: &Expression) -> bool {
    let mut current = expression;

    loop {
        match current {
            Expression::If(if_statement) => current = if_statement.get_else_result(),
            Expression::Binary(binary) => current = binary.right(),
            Expression::Unary(unary) => current = unary.get_expression(),
            Expression::TypeCast(type_cast) => {
                let mut current_type = type_cast.get_type();

                break loop {
                    match current_type {
                        Type::Name(name) => break !name.has_type_parameters(),
                        Type::Field(field) => break !field.get_type_name().has_type_parameters(),
                        Type::Function(function) => {
                            current_type = match function.get_return_type() {
                                FunctionReturnType::Type(r#type) => r#type,
                                FunctionReturnType::TypePack(_)
                                | FunctionReturnType::GenericTypePack(_) => break false,
                                FunctionReturnType::VariadicTypePack(variadic_type) => {
                                    variadic_type.get_type()
                                }
                            }
                        }
                        Type::Intersection(intersection) => {
                            current_type = intersection.last_type();
                        }
                        Type::Union(union_type) => {
                            current_type = union_type.last_type();
                        }
                        Type::True(_)
                        | Type::False(_)
                        | Type::Nil(_)
                        | Type::String(_)
                        | Type::Array(_)
                        | Type::Table(_)
                        | Type::TypeOf(_)
                        | Type::Parenthese(_)
                        | Type::Optional(_) => break false,
                    }
                };
            }
            Expression::Call(_)
            | Expression::False(_)
            | Expression::Field(_)
            | Expression::Function(_)
            | Expression::Identifier(_)
            | Expression::Index(_)
            | Expression::Nil(_)
            | Expression::Number(_)
            | Expression::Parenthese(_)
            | Expression::String(_)
            | Expression::InterpolatedString(_)
            | Expression::Table(_)
            | Expression::True(_)
            | Expression::VariableArguments(_) => break false,
        }
    }
}

impl BinaryOperator {
    /// Checks if this operator has higher precedence than another operator.
    #[inline]
    pub fn precedes(&self, other: Self) -> bool {
        self.get_precedence() > other.get_precedence()
    }

    /// Checks if this operator has higher precedence than unary expressions.
    ///
    /// Currently only the exponentiation operator (`^`) has this property.
    #[inline]
    pub fn precedes_unary_expression(&self) -> bool {
        matches!(self, Self::Caret)
    }

    /// Determines if this operator is left associative.
    ///
    /// Left associative operators like `+` evaluate expressions from left to right:
    /// `a + b + c` is evaluated as `(a + b) + c`.
    #[inline]
    pub fn is_left_associative(&self) -> bool {
        !matches!(self, Self::Caret | Self::Concat)
    }

    /// Determines if this operator is right associative.
    ///
    /// Right associative operators like `^` evaluate expressions from right to left:
    /// `a ^ b ^ c` is evaluated as `a ^ (b ^ c)`.
    #[inline]
    pub fn is_right_associative(&self) -> bool {
        matches!(self, Self::Caret | Self::Concat)
    }

    /// Determines if the left operand needs parentheses when generating code.
    pub fn left_needs_parentheses(&self, left: &Expression) -> bool {
        let needs_parentheses = match left {
            Expression::Binary(left) => {
                if self.is_left_associative() {
                    self.precedes(left.operator())
                } else {
                    !left.operator().precedes(*self)
                }
            }
            Expression::Unary(_) => self.precedes_unary_expression(),
            Expression::If(_) => true,
            _ => false,
        };
        needs_parentheses
            || ends_with_if_expression(left)
            || (matches!(self, BinaryOperator::LowerThan)
                && ends_with_type_cast_to_type_name_without_type_parameters(left))
    }

    /// Determines if the right operand needs parentheses when generating code.
    pub fn right_needs_parentheses(&self, right: &Expression) -> bool {
        match right {
            Expression::Binary(right) => {
                if self.is_right_associative() {
                    self.precedes(right.operator())
                } else {
                    !right.operator().precedes(*self)
                }
            }
            Expression::Unary(_) => false,
            _ => false,
        }
    }

    /// Returns the string representation of this operator.
    pub fn to_str(&self) -> &'static str {
        match self {
            Self::And => "and",
            Self::Or => "or",
            Self::Equal => "==",
            Self::NotEqual => "~=",
            Self::LowerThan => "<",
            Self::LowerOrEqualThan => "<=",
            Self::GreaterThan => ">",
            Self::GreaterOrEqualThan => ">=",
            Self::Plus => "+",
            Self::Minus => "-",
            Self::Asterisk => "*",
            Self::Slash => "/",
            Self::DoubleSlash => "//",
            Self::Percent => "%",
            Self::Caret => "^",
            Self::Concat => "..",
        }
    }

    /// Returns the precedence level of this operator (higher value = higher precedence).
    fn get_precedence(&self) -> u8 {
        match self {
            Self::Or => 0,
            Self::And => 1,
            Self::Equal
            | Self::NotEqual
            | Self::LowerThan
            | Self::LowerOrEqualThan
            | Self::GreaterThan
            | Self::GreaterOrEqualThan => 2,
            Self::Concat => 3,
            Self::Plus | Self::Minus => 4,
            Self::Asterisk | Self::Slash | Self::DoubleSlash | Self::Percent => 5,
            Self::Caret => 7,
        }
    }
}

/// Represents a binary operation in expressions.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BinaryExpression {
    operator: BinaryOperator,
    left: Expression,
    right: Expression,
    token: Option<Token>,
}

impl BinaryExpression {
    /// Creates a new binary expression with the given operator and operands.
    pub fn new<T: Into<Expression>, U: Into<Expression>>(
        operator: BinaryOperator,
        left: T,
        right: U,
    ) -> Self {
        Self {
            operator,
            left: left.into(),
            right: right.into(),
            token: None,
        }
    }

    /// Associates a token with this expression.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Associates a token with this expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the left operand.
    #[inline]
    pub fn mutate_left(&mut self) -> &mut Expression {
        &mut self.left
    }

    /// Returns a mutable reference to the right operand.
    #[inline]
    pub fn mutate_right(&mut self) -> &mut Expression {
        &mut self.right
    }

    /// Returns a reference to the left operand.
    #[inline]
    pub fn left(&self) -> &Expression {
        &self.left
    }

    /// Returns a reference to the right operand.
    #[inline]
    pub fn right(&self) -> &Expression {
        &self.right
    }

    /// Returns the binary operator.
    #[inline]
    pub fn operator(&self) -> BinaryOperator {
        self.operator
    }

    /// Changes the operator and updates the associated token's content if present.
    #[inline]
    pub fn set_operator(&mut self, operator: BinaryOperator) {
        if self.operator == operator {
            return;
        }
        self.operator = operator;
        if let Some(token) = self.token.as_mut() {
            token.replace_with_content(operator.to_str());
        }
    }

    /// Returns a mutable reference to the last token for this binary expression.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.right.mutate_last_token()
    }

    super::impl_token_fns!(iter = [token]);
}

#[cfg(test)]
mod test {
    use super::*;

    mod precedence {
        use super::*;

        use BinaryOperator::*;

        #[test]
        fn caret() {
            assert!(Caret.precedes(And));
            assert!(Caret.precedes(Or));
            assert!(Caret.precedes(Equal));
            assert!(Caret.precedes(NotEqual));
            assert!(Caret.precedes(LowerThan));
            assert!(Caret.precedes(LowerOrEqualThan));
            assert!(Caret.precedes(GreaterThan));
            assert!(Caret.precedes(GreaterOrEqualThan));
            assert!(Caret.precedes(Plus));
            assert!(Caret.precedes(Minus));
            assert!(Caret.precedes(Asterisk));
            assert!(Caret.precedes(Slash));
            assert!(Caret.precedes(DoubleSlash));
            assert!(Caret.precedes(Percent));
            assert!(Caret.precedes(Concat));
            assert!(!Caret.precedes(Caret));
            assert!(Caret.precedes_unary_expression());
        }

        #[test]
        fn asterisk() {
            assert!(Asterisk.precedes(And));
            assert!(Asterisk.precedes(Or));
            assert!(Asterisk.precedes(Equal));
            assert!(Asterisk.precedes(NotEqual));
            assert!(Asterisk.precedes(LowerThan));
            assert!(Asterisk.precedes(LowerOrEqualThan));
            assert!(Asterisk.precedes(GreaterThan));
            assert!(Asterisk.precedes(GreaterOrEqualThan));
            assert!(Asterisk.precedes(Plus));
            assert!(Asterisk.precedes(Minus));
            assert!(!Asterisk.precedes(Asterisk));
            assert!(!Asterisk.precedes(Slash));
            assert!(!Asterisk.precedes(DoubleSlash));
            assert!(!Asterisk.precedes(Percent));
            assert!(Asterisk.precedes(Concat));
            assert!(!Asterisk.precedes(Caret));
            assert!(!Asterisk.precedes_unary_expression());
        }

        #[test]
        fn slash() {
            assert!(Slash.precedes(And));
            assert!(Slash.precedes(Or));
            assert!(Slash.precedes(Equal));
            assert!(Slash.precedes(NotEqual));
            assert!(Slash.precedes(LowerThan));
            assert!(Slash.precedes(LowerOrEqualThan));
            assert!(Slash.precedes(GreaterThan));
            assert!(Slash.precedes(GreaterOrEqualThan));
            assert!(Slash.precedes(Plus));
            assert!(Slash.precedes(Minus));
            assert!(!Slash.precedes(Asterisk));
            assert!(!Slash.precedes(Slash));
            assert!(!Slash.precedes(DoubleSlash));
            assert!(!Slash.precedes(Percent));
            assert!(Slash.precedes(Concat));
            assert!(!Slash.precedes(Caret));
            assert!(!Slash.precedes_unary_expression());
        }

        #[test]
        fn percent() {
            assert!(Percent.precedes(And));
            assert!(Percent.precedes(Or));
            assert!(Percent.precedes(Equal));
            assert!(Percent.precedes(NotEqual));
            assert!(Percent.precedes(LowerThan));
            assert!(Percent.precedes(LowerOrEqualThan));
            assert!(Percent.precedes(GreaterThan));
            assert!(Percent.precedes(GreaterOrEqualThan));
            assert!(Percent.precedes(Plus));
            assert!(Percent.precedes(Minus));
            assert!(!Percent.precedes(Asterisk));
            assert!(!Percent.precedes(Slash));
            assert!(!Percent.precedes(DoubleSlash));
            assert!(!Percent.precedes(Percent));
            assert!(Percent.precedes(Concat));
            assert!(!Percent.precedes(Caret));
            assert!(!Percent.precedes_unary_expression());
        }

        #[test]
        fn plus() {
            assert!(Plus.precedes(And));
            assert!(Plus.precedes(Or));
            assert!(Plus.precedes(Equal));
            assert!(Plus.precedes(NotEqual));
            assert!(Plus.precedes(LowerThan));
            assert!(Plus.precedes(LowerOrEqualThan));
            assert!(Plus.precedes(GreaterThan));
            assert!(Plus.precedes(GreaterOrEqualThan));
            assert!(!Plus.precedes(Plus));
            assert!(!Plus.precedes(Minus));
            assert!(!Plus.precedes(Asterisk));
            assert!(!Plus.precedes(Slash));
            assert!(!Plus.precedes(DoubleSlash));
            assert!(!Plus.precedes(Percent));
            assert!(Plus.precedes(Concat));
            assert!(!Plus.precedes(Caret));
            assert!(!Plus.precedes_unary_expression());
        }

        #[test]
        fn minus() {
            assert!(Minus.precedes(And));
            assert!(Minus.precedes(Or));
            assert!(Minus.precedes(Equal));
            assert!(Minus.precedes(NotEqual));
            assert!(Minus.precedes(LowerThan));
            assert!(Minus.precedes(LowerOrEqualThan));
            assert!(Minus.precedes(GreaterThan));
            assert!(Minus.precedes(GreaterOrEqualThan));
            assert!(!Minus.precedes(Plus));
            assert!(!Minus.precedes(Minus));
            assert!(!Minus.precedes(Asterisk));
            assert!(!Minus.precedes(Slash));
            assert!(!Minus.precedes(DoubleSlash));
            assert!(!Minus.precedes(Percent));
            assert!(Minus.precedes(Concat));
            assert!(!Minus.precedes(Caret));
            assert!(!Minus.precedes_unary_expression());
        }

        #[test]
        fn concat() {
            assert!(Concat.precedes(And));
            assert!(Concat.precedes(Or));
            assert!(Concat.precedes(Equal));
            assert!(Concat.precedes(NotEqual));
            assert!(Concat.precedes(LowerThan));
            assert!(Concat.precedes(LowerOrEqualThan));
            assert!(Concat.precedes(GreaterThan));
            assert!(Concat.precedes(GreaterOrEqualThan));
            assert!(!Concat.precedes(Plus));
            assert!(!Concat.precedes(Minus));
            assert!(!Concat.precedes(Asterisk));
            assert!(!Concat.precedes(Slash));
            assert!(!Concat.precedes(DoubleSlash));
            assert!(!Concat.precedes(Percent));
            assert!(!Concat.precedes(Concat));
            assert!(!Concat.precedes(Caret));
            assert!(!Concat.precedes_unary_expression());
        }

        #[test]
        fn and() {
            assert!(!And.precedes(And));
            assert!(And.precedes(Or));
            assert!(!And.precedes(Equal));
            assert!(!And.precedes(NotEqual));
            assert!(!And.precedes(LowerThan));
            assert!(!And.precedes(LowerOrEqualThan));
            assert!(!And.precedes(GreaterThan));
            assert!(!And.precedes(GreaterOrEqualThan));
            assert!(!And.precedes(Plus));
            assert!(!And.precedes(Minus));
            assert!(!And.precedes(Asterisk));
            assert!(!And.precedes(Slash));
            assert!(!And.precedes(DoubleSlash));
            assert!(!And.precedes(Percent));
            assert!(!And.precedes(Concat));
            assert!(!And.precedes(Caret));
            assert!(!And.precedes_unary_expression());
        }
    }
}
