use crate::nodes::{Block, Expression, Token, TypedIdentifier};

/// Tokens associated with a generic for statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericForTokens {
    pub r#for: Token,
    pub r#in: Token,
    pub r#do: Token,
    pub end: Token,
    /// The tokens for the commas between identifiers.
    pub identifier_commas: Vec<Token>,
    /// The tokens for the commas between values.
    pub value_commas: Vec<Token>,
}

impl GenericForTokens {
    super::impl_token_fns!(
        target = [r#for, r#in, r#do, end]
        iter = [identifier_commas, value_commas]
    );
}

/// Represents a generic for loop statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GenericForStatement {
    identifiers: Vec<TypedIdentifier>,
    expressions: Vec<Expression>,
    block: Block,
    tokens: Option<GenericForTokens>,
}

impl GenericForStatement {
    /// Creates a new generic for statement.
    pub fn new<B: Into<Block>>(
        identifiers: Vec<TypedIdentifier>,
        expressions: Vec<Expression>,
        block: B,
    ) -> Self {
        Self {
            identifiers,
            expressions,
            block: block.into(),
            tokens: None,
        }
    }

    /// Sets the tokens for this generic for statement.
    pub fn with_tokens(mut self, tokens: GenericForTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this generic for statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: GenericForTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this generic for statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&GenericForTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut GenericForTokens> {
        self.tokens.as_mut()
    }

    /// Returns the loop's block.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns the list of identifiers that receive iterator values.
    #[inline]
    pub fn get_identifiers(&self) -> &Vec<TypedIdentifier> {
        &self.identifiers
    }

    /// Returns an iterator over the identifiers.
    #[inline]
    pub fn iter_identifiers(&self) -> impl Iterator<Item = &TypedIdentifier> {
        self.identifiers.iter()
    }

    /// Returns the list of expressions that produce the iterator values.
    #[inline]
    pub fn get_expressions(&self) -> &Vec<Expression> {
        &self.expressions
    }

    /// Returns an iterator over the expressions.
    #[inline]
    pub fn iter_expressions(&self) -> impl Iterator<Item = &Expression> {
        self.expressions.iter()
    }

    /// Returns a mutable iterator over the identifiers.
    #[inline]
    pub fn iter_mut_identifiers(&mut self) -> impl Iterator<Item = &mut TypedIdentifier> {
        self.identifiers.iter_mut()
    }

    /// Returns a mutable iterator over the expressions.
    #[inline]
    pub fn iter_mut_expressions(&mut self) -> impl Iterator<Item = &mut Expression> {
        self.expressions.iter_mut()
    }

    /// Returns a mutable reference to the expressions vector.
    #[inline]
    pub fn mutate_expressions(&mut self) -> &mut Vec<Expression> {
        &mut self.expressions
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns the number of identifiers.
    #[inline]
    pub fn identifiers_len(&self) -> usize {
        self.identifiers.len()
    }

    /// Returns the number of expressions.
    #[inline]
    pub fn expressions_len(&self) -> usize {
        self.expressions.len()
    }

    /// Removes type annotations from all identifiers.
    pub fn clear_types(&mut self) {
        for identifier in &mut self.identifiers {
            identifier.remove_type();
        }
    }

    super::impl_token_fns!(iter = [tokens, identifiers]);

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
            self.tokens = Some(GenericForTokens {
                r#for: Token::from_content("for"),
                r#in: Token::from_content("in"),
                r#do: Token::from_content("do"),
                end: Token::from_content("end"),
                identifier_commas: Vec::new(),
                value_commas: Vec::new(),
            });
        }
    }
}
