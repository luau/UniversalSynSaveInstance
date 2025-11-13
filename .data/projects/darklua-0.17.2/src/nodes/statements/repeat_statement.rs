use crate::nodes::{Block, Expression, Token};

/// Tokens associated with a repeat statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RepeatTokens {
    pub repeat: Token,
    pub until: Token,
}

impl RepeatTokens {
    super::impl_token_fns!(target = [repeat, until]);
}

/// Represents a repeat loop statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RepeatStatement {
    block: Block,
    condition: Expression,
    tokens: Option<RepeatTokens>,
}

impl RepeatStatement {
    /// Creates a new repeat statement with the given block and condition.
    pub fn new<B: Into<Block>, E: Into<Expression>>(block: B, condition: E) -> Self {
        Self {
            block: block.into(),
            condition: condition.into(),
            tokens: None,
        }
    }

    /// Returns the loop's block.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns the until condition for this repeat loop.
    #[inline]
    pub fn get_condition(&self) -> &Expression {
        &self.condition
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns a mutable reference to the condition.
    #[inline]
    pub fn mutate_condition(&mut self) -> &mut Expression {
        &mut self.condition
    }

    /// Returns mutable references to both the block and condition.
    #[inline]
    pub(crate) fn mutate_block_and_condition(&mut self) -> (&mut Block, &mut Expression) {
        (&mut self.block, &mut self.condition)
    }

    /// Sets the tokens for this repeat statement.
    pub fn with_tokens(mut self, tokens: RepeatTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this repeat statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: RepeatTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this repeat statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&RepeatTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut RepeatTokens> {
        self.tokens.as_mut()
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(RepeatTokens {
                repeat: Token::from_content("repeat"),
                until: Token::from_content("until"),
            });
        }
        &mut self.tokens.as_mut().unwrap().repeat
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.condition.mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens]);
}
