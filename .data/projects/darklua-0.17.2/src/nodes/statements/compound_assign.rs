use crate::nodes::{BinaryOperator, Expression, Token, Variable};

/// Represents compound assignment operators (e.g., `+=`, `-=`, etc.).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CompoundOperator {
    /// Addition and assignment (`+=`)
    Plus,
    /// Subtraction and assignment (`-=`)
    Minus,
    /// Multiplication and assignment (`*=`)
    Asterisk,
    /// Division and assignment (`/=`)
    Slash,
    /// Floor division and assignment (`//=`)
    DoubleSlash,
    /// Modulo and assignment (`%=`)
    Percent,
    /// Exponentiation and assignment (`^=`)
    Caret,
    /// Concatenation and assignment (`..=`)
    Concat,
}

impl CompoundOperator {
    /// Returns the string representation of the operator.
    pub fn to_str(&self) -> &'static str {
        match self {
            Self::Plus => "+=",
            Self::Minus => "-=",
            Self::Asterisk => "*=",
            Self::Slash => "/=",
            Self::DoubleSlash => "//=",
            Self::Percent => "%=",
            Self::Caret => "^=",
            Self::Concat => "..=",
        }
    }

    /// Converts this compound operator to its corresponding binary operator.
    pub fn to_binary_operator(&self) -> BinaryOperator {
        match self {
            Self::Plus => BinaryOperator::Plus,
            Self::Minus => BinaryOperator::Minus,
            Self::Asterisk => BinaryOperator::Asterisk,
            Self::Slash => BinaryOperator::Slash,
            Self::DoubleSlash => BinaryOperator::DoubleSlash,
            Self::Percent => BinaryOperator::Percent,
            Self::Caret => BinaryOperator::Caret,
            Self::Concat => BinaryOperator::Concat,
        }
    }
}

/// Tokens associated with a compound assignment statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct CompoundAssignTokens {
    /// The operator token for the compound assignment.
    pub operator: Token,
}

impl CompoundAssignTokens {
    super::impl_token_fns!(target = [operator]);
}

/// Represents a compound assignment statement (e.g., `a += 1`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct CompoundAssignStatement {
    operator: CompoundOperator,
    variable: Variable,
    value: Expression,
    tokens: Option<CompoundAssignTokens>,
}

impl CompoundAssignStatement {
    /// Creates a new compound assignment statement.
    pub fn new<V: Into<Variable>, E: Into<Expression>>(
        operator: CompoundOperator,
        variable: V,
        value: E,
    ) -> Self {
        Self {
            operator,
            variable: variable.into(),
            value: value.into(),
            tokens: None,
        }
    }

    /// Sets the tokens for this compound assignment statement.
    pub fn with_tokens(mut self, tokens: CompoundAssignTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this compound assignment statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: CompoundAssignTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this compound assignment statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&CompoundAssignTokens> {
        self.tokens.as_ref()
    }

    /// Returns the compound operator used in this statement.
    #[inline]
    pub fn get_operator(&self) -> CompoundOperator {
        self.operator
    }

    /// Returns the variable being assigned to.
    #[inline]
    pub fn get_variable(&self) -> &Variable {
        &self.variable
    }

    /// Returns the value expression in the assignment.
    #[inline]
    pub fn get_value(&self) -> &Expression {
        &self.value
    }

    /// Extracts the variable and value from this statement.
    #[inline]
    pub fn extract_assignment(self) -> (Variable, Expression) {
        (self.variable, self.value)
    }

    /// Returns a mutable reference to the variable.
    #[inline]
    pub fn mutate_variable(&mut self) -> &mut Variable {
        &mut self.variable
    }

    /// Returns a mutable reference to the value expression.
    #[inline]
    pub fn mutate_value(&mut self) -> &mut Expression {
        &mut self.value
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.variable.mutate_first_token()
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.value.mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens]);
}
