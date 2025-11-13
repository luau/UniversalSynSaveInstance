use darklua_core::nodes::{BinaryOperator, UnaryOperator};

#[allow(dead_code)]
pub fn binary_operators() -> impl Iterator<Item = BinaryOperator> {
    [
        BinaryOperator::And,
        BinaryOperator::Or,
        BinaryOperator::Equal,
        BinaryOperator::NotEqual,
        BinaryOperator::LowerThan,
        BinaryOperator::LowerOrEqualThan,
        BinaryOperator::GreaterThan,
        BinaryOperator::GreaterOrEqualThan,
        BinaryOperator::Plus,
        BinaryOperator::Minus,
        BinaryOperator::Asterisk,
        BinaryOperator::Slash,
        BinaryOperator::DoubleSlash,
        BinaryOperator::Percent,
        BinaryOperator::Caret,
        BinaryOperator::Concat,
    ]
    .iter()
    .cloned()
}

#[allow(dead_code)]
pub fn unary_operators() -> impl Iterator<Item = UnaryOperator> {
    [
        UnaryOperator::Length,
        UnaryOperator::Minus,
        UnaryOperator::Not,
    ]
    .iter()
    .cloned()
}
