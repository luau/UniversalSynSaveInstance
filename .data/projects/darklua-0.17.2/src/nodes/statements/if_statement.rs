use std::mem;

use crate::nodes::{Block, Expression, Token};

/// Tokens associated with an if branch.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfBranchTokens {
    pub elseif: Token,
    pub then: Token,
}

impl IfBranchTokens {
    super::impl_token_fns!(target = [elseif, then]);
}

/// Represents a conditional branch in an if statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfBranch {
    condition: Expression,
    block: Block,
    tokens: Option<IfBranchTokens>,
}

impl IfBranch {
    /// Creates a new if branch with the given condition and block.
    pub fn new<E: Into<Expression>, B: Into<Block>>(condition: E, block: B) -> Self {
        Self {
            condition: condition.into(),
            block: block.into(),
            tokens: None,
        }
    }

    /// Creates a new if branch with the given condition and an empty block.
    pub fn empty<E: Into<Expression>>(condition: E) -> Self {
        Self {
            condition: condition.into(),
            block: Block::default(),
            tokens: None,
        }
    }

    /// Sets the tokens for this if branch.
    pub fn with_tokens(mut self, tokens: IfBranchTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this if branch.
    #[inline]
    pub fn set_tokens(&mut self, tokens: IfBranchTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this if branch, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&IfBranchTokens> {
        self.tokens.as_ref()
    }

    /// Returns the block of code for this branch.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns the condition for this branch.
    #[inline]
    pub fn get_condition(&self) -> &Expression {
        &self.condition
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Takes ownership of the block, leaving an empty block in its place.
    #[inline]
    pub fn take_block(&mut self) -> Block {
        mem::take(&mut self.block)
    }

    /// Returns a mutable reference to the condition.
    #[inline]
    pub fn mutate_condition(&mut self) -> &mut Expression {
        &mut self.condition
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Tokens associated with an if statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfStatementTokens {
    pub r#if: Token,
    pub then: Token,
    pub end: Token,
    pub r#else: Option<Token>,
}

impl IfStatementTokens {
    super::impl_token_fns!(
        target = [r#if, then, end]
        iter = [r#else]
    );
}

/// Represents an if statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfStatement {
    branches: Vec<IfBranch>,
    else_block: Option<Block>,
    tokens: Option<IfStatementTokens>,
}

impl IfStatement {
    /// Creates a new if statement with the given branches and optional else block.
    pub fn new(branches: Vec<IfBranch>, else_block: Option<Block>) -> Self {
        Self {
            branches,
            else_block,
            tokens: None,
        }
    }

    /// Creates a new if statement with a single condition and block.
    pub fn create(condition: impl Into<Expression>, block: impl Into<Block>) -> Self {
        Self {
            branches: vec![IfBranch::new(condition, block)],
            else_block: None,
            tokens: None,
        }
    }

    /// Sets the tokens for this if statement.
    pub fn with_tokens(mut self, tokens: IfStatementTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this if statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: IfStatementTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this if statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&IfStatementTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut IfStatementTokens> {
        self.tokens.as_mut()
    }

    /// Adds a branch to this if statement.
    pub fn with_branch(mut self, branch: IfBranch) -> Self {
        self.branches.push(branch);
        self
    }

    /// Adds a new branch with the given condition and block.
    pub fn with_new_branch(
        mut self,
        condition: impl Into<Expression>,
        block: impl Into<Block>,
    ) -> Self {
        self.branches.push(IfBranch::new(condition, block));
        self
    }

    /// Adds an else block to this if statement.
    pub fn with_else_block<B: Into<Block>>(mut self, block: B) -> Self {
        self.else_block.replace(block.into());
        self
    }

    /// Returns mutable references to all blocks in this if statement.
    pub fn mutate_all_blocks(&mut self) -> Vec<&mut Block> {
        let mut blocks: Vec<&mut Block> = self
            .branches
            .iter_mut()
            .map(|branch| branch.mutate_block())
            .collect();

        if let Some(else_block) = &mut self.else_block {
            blocks.push(else_block);
        };

        blocks
    }

    /// Returns the branches of this if statement.
    #[inline]
    pub fn get_branches(&self) -> &Vec<IfBranch> {
        &self.branches
    }

    /// Returns an iterator over the branches.
    #[inline]
    pub fn iter_branches(&self) -> impl Iterator<Item = &IfBranch> {
        self.branches.iter()
    }

    /// Returns the number of branches.
    #[inline]
    pub fn branch_count(&self) -> usize {
        self.branches.len()
    }

    /// Returns a mutable reference to the branches.
    #[inline]
    pub fn mutate_branches(&mut self) -> &mut Vec<IfBranch> {
        &mut self.branches
    }

    /// Adds a new branch with the given condition and block.
    #[inline]
    pub fn push_new_branch(&mut self, condition: impl Into<Expression>, block: impl Into<Block>) {
        self.branches
            .push(IfBranch::new(condition.into(), block.into()));
    }

    /// Adds a branch to this if statement.
    #[inline]
    pub fn push_branch(&mut self, branch: IfBranch) {
        self.branches.push(branch);
    }

    /// Returns the else block, if any.
    #[inline]
    pub fn get_else_block(&self) -> Option<&Block> {
        self.else_block.as_ref()
    }

    /// Returns a mutable reference to the else block option.
    #[inline]
    pub fn mutate_else_block(&mut self) -> &mut Option<Block> {
        &mut self.else_block
    }

    /// Sets the else block.
    #[inline]
    pub fn set_else_block(&mut self, block: impl Into<Block>) {
        self.else_block = Some(block.into());
    }

    /// Removes the else block, if any.
    #[inline]
    pub fn take_else_block(&mut self) -> Option<Block> {
        self.else_block.take()
    }

    /// Filters branches in-place, ensuring at least one branch remains.
    pub fn retain_branches_mut(&mut self, filter: impl FnMut(&mut IfBranch) -> bool) -> bool {
        self.branches.retain_mut(filter);
        if self.branches.is_empty() {
            // an if statement requires at least one branch
            self.branches.push(IfBranch::new(false, Block::default()));
            true
        } else {
            false
        }
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().r#if
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().end
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.tokens = Some(IfStatementTokens {
                r#if: Token::from_content("if"),
                then: Token::from_content("then"),
                end: Token::from_content("end"),
                r#else: None,
            });
        }
    }

    super::impl_token_fns!(iter = [tokens, branches]);
}
