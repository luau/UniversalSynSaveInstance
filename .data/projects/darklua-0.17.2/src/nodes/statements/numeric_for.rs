use crate::nodes::{Block, Expression, Token, TypedIdentifier};

/// Tokens associated with a numeric for statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NumericForTokens {
    pub r#for: Token,
    pub equal: Token,
    pub r#do: Token,
    pub end: Token,
    /// The token for the comma between the start and end values.
    pub end_comma: Token,
    /// The token for the comma between the end and step values.
    pub step_comma: Option<Token>,
}

impl NumericForTokens {
    super::impl_token_fns!(
        target = [r#for, equal, r#do, end, end_comma]
        iter = [step_comma]
    );
}

/// Represents a numeric for loop statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NumericForStatement {
    identifier: TypedIdentifier,
    start: Expression,
    end: Expression,
    step: Option<Expression>,
    block: Block,
    tokens: Option<NumericForTokens>,
}

impl NumericForStatement {
    /// Creates a new numeric for statement.
    pub fn new<
        S: Into<TypedIdentifier>,
        E1: Into<Expression>,
        E2: Into<Expression>,
        B: Into<Block>,
    >(
        identifier: S,
        start: E1,
        end: E2,
        step: Option<Expression>,
        block: B,
    ) -> Self {
        Self {
            identifier: identifier.into(),
            start: start.into(),
            end: end.into(),
            step,
            block: block.into(),
            tokens: None,
        }
    }

    /// Sets the tokens for this numeric for statement.
    pub fn with_tokens(mut self, tokens: NumericForTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this numeric for statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: NumericForTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this numeric for statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&NumericForTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut NumericForTokens> {
        self.tokens.as_mut()
    }

    /// Returns the loop's block.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns the start expression for the range.
    #[inline]
    pub fn get_start(&self) -> &Expression {
        &self.start
    }

    /// Returns a mutable reference to the start expression.
    #[inline]
    pub fn mutate_start(&mut self) -> &mut Expression {
        &mut self.start
    }

    /// Returns the end expression for the range.
    #[inline]
    pub fn get_end(&self) -> &Expression {
        &self.end
    }

    /// Returns a mutable reference to the end expression.
    #[inline]
    pub fn mutate_end(&mut self) -> &mut Expression {
        &mut self.end
    }

    /// Returns the step expression for the range, if any.
    #[inline]
    pub fn get_step(&self) -> Option<&Expression> {
        self.step.as_ref()
    }

    /// Returns a mutable reference to the step expression option.
    #[inline]
    pub fn mutate_step(&mut self) -> &mut Option<Expression> {
        &mut self.step
    }

    /// Returns the loop variable identifier.
    #[inline]
    pub fn get_identifier(&self) -> &TypedIdentifier {
        &self.identifier
    }

    /// Returns a mutable reference to the loop variable identifier.
    #[inline]
    pub fn mutate_identifier(&mut self) -> &mut TypedIdentifier {
        &mut self.identifier
    }

    /// Sets the loop variable identifier.
    #[inline]
    pub fn set_identifier<S: Into<TypedIdentifier>>(&mut self, identifier: S) {
        self.identifier = identifier.into();
    }

    /// Removes type annotations from the loop variable.
    pub fn clear_types(&mut self) {
        self.identifier.remove_type();
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().r#for
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().end
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.tokens = Some(NumericForTokens {
                r#for: Token::from_content("for"),
                equal: Token::from_content("="),
                r#do: Token::from_content("do"),
                end: Token::from_content("end"),
                end_comma: Token::from_content(","),
                step_comma: None,
            });
        }
    }

    super::impl_token_fns!(target = [identifier] iter = [tokens]);
}
