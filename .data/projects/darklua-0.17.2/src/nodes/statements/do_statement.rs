use crate::nodes::{Block, Token};

/// Tokens associated with a do statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DoTokens {
    pub r#do: Token,
    pub end: Token,
}

impl DoTokens {
    super::impl_token_fns!(target = [r#do, end]);
}

/// Represents a do statement (e.g., `do ... end`).
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct DoStatement {
    block: Block,
    tokens: Option<DoTokens>,
}

impl DoStatement {
    /// Creates a new do statement with the given block.
    pub fn new(block: Block) -> Self {
        Self {
            block,
            tokens: None,
        }
    }

    /// Returns the block contained within the do statement.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Sets the tokens for this do statement.
    pub fn with_tokens(mut self, tokens: DoTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this do statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: DoTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this do statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&DoTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut DoTokens> {
        self.tokens.as_mut()
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().r#do
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().end
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.tokens = Some(DoTokens {
                r#do: Token::from_content("do"),
                end: Token::from_content("end"),
            });
        }
    }

    super::impl_token_fns!(iter = [tokens]);
}
