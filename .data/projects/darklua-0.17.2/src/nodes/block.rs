use crate::nodes::{LastStatement, ReturnStatement, Statement, Token, Trivia, TriviaKind};

/// Represents the tokens associated with a Lua code block, maintaining
/// syntax information like semicolons that separate statements.
///
/// Fields:
/// - `semicolons`: Optional tokens for semicolons between statements
/// - `last_semicolon`: Optional semicolon after the last statement
/// - `final_token`: Optional token at the end of the block (e.g., `end` or `until`)
///
/// Typically created by the parser to preserve source formatting for roundtrip transformations.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BlockTokens {
    pub semicolons: Vec<Option<Token>>,
    pub last_semicolon: Option<Token>,
    pub final_token: Option<Token>,
}

impl BlockTokens {
    super::impl_token_fns!(
        iter = [last_semicolon, final_token]
        iter_flatten = [semicolons]
    );
}

/// Represents a block, a collection of [`Statement`]s that can end with a [`LastStatement`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Block {
    statements: Vec<Statement>,
    last_statement: Option<LastStatement>,
    tokens: Option<Box<BlockTokens>>,
}

impl Block {
    /// Creates a new Block with the given statements and optional last statement.
    pub fn new(statements: Vec<Statement>, last_statement: Option<LastStatement>) -> Self {
        Self {
            statements,
            last_statement,
            tokens: None,
        }
    }

    /// Attaches token information to this block and returns the updated block.
    pub fn with_tokens(mut self, tokens: BlockTokens) -> Self {
        self.tokens = Some(tokens.into());
        self
    }

    /// Attaches token information to this block.
    #[inline]
    pub fn set_tokens(&mut self, tokens: BlockTokens) {
        self.tokens = Some(tokens.into());
    }

    /// Returns a reference to the token information attached to this block, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&BlockTokens> {
        self.tokens.as_ref().map(|tokens| tokens.as_ref())
    }

    /// Returns a mutable reference to the token information attached to this block, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut BlockTokens> {
        self.tokens.as_mut().map(|tokens| tokens.as_mut())
    }

    /// Adds a statement to the end of the block. Updates token information if present.
    ///
    /// This method maintains consistency between the statements and their token information.
    pub fn push_statement<T: Into<Statement>>(&mut self, statement: T) {
        if let Some(tokens) = &mut self.tokens {
            if self.statements.len() == tokens.semicolons.len() {
                tokens.semicolons.push(None);
            }
        }
        self.statements.push(statement.into());
    }

    /// Removes a statement at the specified index. Updates token information if present.
    ///
    /// Does nothing if the index is out of bounds.
    pub fn remove_statement(&mut self, index: usize) {
        let statements_len = self.statements.len();
        if index < statements_len {
            let mut removed = self.statements.remove(index);

            fn filter_trivia(trivia: Trivia) -> Option<Trivia> {
                if trivia.kind() == TriviaKind::Whitespace {
                    None
                } else {
                    Some(trivia)
                }
            }

            let mut trivia: Vec<_> = removed
                .mutate_first_token()
                .drain_leading_trivia()
                .filter_map(filter_trivia)
                .collect();

            let mut drain_trailing_token = true;

            if let Some(tokens) = &mut self.tokens {
                if tokens.semicolons.len() == statements_len {
                    let removed_semicolon = tokens.semicolons.remove(index);

                    if let Some(mut semicolon) = removed_semicolon {
                        trivia.extend(semicolon.drain_trailing_trivia().filter_map(filter_trivia));
                        drain_trailing_token = false;
                    }
                }
            }

            if drain_trailing_token {
                trivia.extend(
                    removed
                        .mutate_last_token()
                        .drain_trailing_trivia()
                        .filter_map(filter_trivia),
                );
            }

            if !trivia.is_empty() {
                let next_statement = self.statements.get_mut(index);

                let token = if let Some(next_statement) = next_statement {
                    next_statement.mutate_first_token()
                } else if let Some(last) = self.last_statement.as_mut() {
                    last.mutate_first_token()
                } else {
                    self.set_default_tokens();

                    self.tokens.as_mut().unwrap().final_token.as_mut().unwrap()
                };

                let line_numbers: Vec<_> = trivia.iter().map(|t| t.get_line_number()).collect();

                let mut previous = None;
                let mut offset = 0;

                for (index, (trivia, line_number)) in
                    trivia.into_iter().zip(line_numbers).enumerate()
                {
                    if let (Some(previous), Some(next_line)) = (previous, line_number) {
                        let gap = next_line.saturating_sub(previous);
                        if gap != 0 {
                            token.insert_leading_trivia(
                                index + offset,
                                TriviaKind::Whitespace.with_content("\n".repeat(gap)),
                            );
                            offset += gap;
                        }
                    }

                    token.insert_leading_trivia(index + offset, trivia.clone());

                    if line_number.is_some() {
                        previous = line_number;
                    }
                }
            }
        }
    }

    /// Adds a statement to the end of the block and returns the updated block.
    pub fn with_statement<T: Into<Statement>>(mut self, statement: T) -> Self {
        self.statements.push(statement.into());
        self
    }

    /// Inserts a statement at the specified index, appending if the index is beyond the end.
    /// Updates token information if present.
    ///
    /// This method maintains consistency between the statements and their token information.
    pub fn insert_statement(&mut self, index: usize, statement: impl Into<Statement>) {
        if index > self.statements.len() {
            self.push_statement(statement.into());
        } else {
            self.statements.insert(index, statement.into());

            if let Some(tokens) = &mut self.tokens {
                if index <= tokens.semicolons.len() {
                    tokens.semicolons.insert(index, None);
                }
            }
        }
    }

    /// Sets the last statement of the block.
    #[inline]
    pub fn set_last_statement(&mut self, last_statement: impl Into<LastStatement>) {
        self.last_statement = Some(last_statement.into());
    }

    /// Sets the last statement of the block and returns the updated block.
    pub fn with_last_statement(mut self, last_statement: impl Into<LastStatement>) -> Self {
        self.last_statement = Some(last_statement.into());
        self
    }

    /// Checks if the block is empty (contains no statements or last statement).
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.last_statement.is_none() && self.statements.is_empty()
    }

    /// Returns the number of statements in the block.
    #[inline]
    pub fn statements_len(&self) -> usize {
        self.statements.len()
    }

    /// Returns an iterator over references to the statements in the block.
    #[inline]
    pub fn iter_statements(&self) -> impl Iterator<Item = &Statement> {
        self.statements.iter()
    }

    /// Returns an iterator over references to the statements in the block in reverse order.
    #[inline]
    pub fn reverse_iter_statements(&self) -> impl Iterator<Item = &Statement> {
        self.statements.iter().rev()
    }

    /// Returns a reference to the last statement of the block, if any.
    #[inline]
    pub fn get_last_statement(&self) -> Option<&LastStatement> {
        self.last_statement.as_ref()
    }

    /// Filters statements in the block, removing those for which the predicate returns `false`.
    /// Updates token information if present.
    ///
    /// This method ensures token information stays consistent with the statements collection.
    pub fn filter_statements<F>(&mut self, mut f: F)
    where
        F: FnMut(&Statement) -> bool,
    {
        let mut i = 0;

        while i != self.statements.len() {
            if f(&self.statements[i]) {
                i += 1;
            } else {
                self.remove_statement(i);
            }
        }
    }

    /// Filters statements with mutable access, removing those for which the predicate returns `false`.
    /// Updates token information if present.
    ///
    /// This method gives mutable access to statements during filtering.
    pub fn filter_mut_statements<F>(&mut self, mut f: F)
    where
        F: FnMut(&mut Statement) -> bool,
    {
        let mut i = 0;

        while i != self.statements.len() {
            if f(&mut self.statements[i]) {
                i += 1;
            } else {
                self.remove_statement(i);
            }
        }
    }

    /// Truncates the statements to the specified length.
    ///
    /// Updates token information if present.
    pub fn truncate(&mut self, length: usize) {
        self.statements.truncate(length);
        if let Some(tokens) = &mut self.tokens {
            tokens.semicolons.truncate(length);
        }
    }

    /// Returns a mutable iterator over the statements in the block.
    #[inline]
    pub fn iter_mut_statements(&mut self) -> impl Iterator<Item = &mut Statement> {
        self.statements.iter_mut()
    }

    /// Returns a reference to the first statement in the block, if any.
    #[inline]
    pub fn first_statement(&self) -> Option<&Statement> {
        self.statements.first()
    }

    /// Returns a mutable reference to the first statement in the block, if any.
    #[inline]
    pub fn first_mut_statement(&mut self) -> Option<&mut Statement> {
        self.statements.first_mut()
    }

    /// Removes all statements from the block and returns them.
    ///
    /// Clears token information if present.
    pub fn take_statements(&mut self) -> Vec<Statement> {
        if let Some(tokens) = &mut self.tokens {
            tokens.semicolons.clear();
        }
        self.statements.drain(..).collect()
    }

    /// Removes and returns the last statement of the block, if any.
    ///
    /// Clears the last semicolon token if present.
    pub fn take_last_statement(&mut self) -> Option<LastStatement> {
        if let Some(tokens) = &mut self.tokens {
            tokens.last_semicolon.take();
        }
        self.last_statement.take()
    }

    /// Sets the statements of the block.
    ///
    /// Clears any existing semicolon tokens.
    pub fn set_statements(&mut self, statements: Vec<Statement>) {
        self.statements = statements;

        if let Some(tokens) = &mut self.tokens {
            tokens.semicolons.clear();
        }
    }

    /// Returns a mutable reference to the last statement of the block, if any.
    #[inline]
    pub fn mutate_last_statement(&mut self) -> Option<&mut LastStatement> {
        self.last_statement.as_mut()
    }

    /// Replaces the last statement with the given statement and returns the old one, if any.
    #[inline]
    pub fn replace_last_statement<S: Into<LastStatement>>(
        &mut self,
        statement: S,
    ) -> Option<LastStatement> {
        self.last_statement.replace(statement.into())
    }

    /// Clears all statements and the last statement from the block.
    ///
    /// Also clears all token information if present.
    pub fn clear(&mut self) {
        self.statements.clear();
        self.last_statement.take();

        if let Some(tokens) = &mut self.tokens {
            tokens.semicolons.clear();
            tokens.last_semicolon = None;
        }
    }

    /// Returns a mutable reference to the first token in this block, creating
    /// it if it doesn't exist.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        if self.is_empty() {
            self.set_default_tokens();
            return self.tokens.as_mut().unwrap().final_token.as_mut().unwrap();
        }

        if !self.statements.is_empty() {
            return self
                .first_mut_statement()
                .expect("first statement should exist")
                .mutate_first_token();
        }

        match self
            .mutate_last_statement()
            .expect("non-empty block should have a last statement")
        {
            LastStatement::Break(token) => {
                if token.is_none() {
                    *token = Some(Token::from_content("break"));
                }
                token.as_mut().unwrap()
            }
            LastStatement::Continue(token) => {
                if token.is_none() {
                    *token = Some(Token::from_content("continue"));
                }
                token.as_mut().unwrap()
            }
            LastStatement::Return(return_stmt) => return_stmt.mutate_first_token(),
        }
    }

    /// Returns a mutable reference to the last token for this block,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.is_empty() {
            self.set_default_tokens();
            return self.tokens.as_mut().unwrap().final_token.as_mut().unwrap();
        }

        if let Some(last_stmt) = self.last_statement.as_mut() {
            return last_stmt.mutate_last_token();
        }

        self.statements.last_mut().unwrap().mutate_last_token()
    }

    fn set_default_tokens(&mut self) {
        if self.get_tokens().is_none() {
            self.set_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: None,
                final_token: Some(Token::from_content("")),
            });
        } else {
            let tokens = self.tokens.as_mut().unwrap();
            if tokens.final_token.is_none() {
                tokens.final_token = Some(Token::from_content(""));
            }
        }
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl Default for Block {
    fn default() -> Self {
        Self::new(Vec::new(), None)
    }
}

impl<IntoStatement: Into<Statement>> From<IntoStatement> for Block {
    fn from(statement: IntoStatement) -> Block {
        Block::new(vec![statement.into()], None)
    }
}

impl From<LastStatement> for Block {
    fn from(statement: LastStatement) -> Block {
        Block::new(Vec::new(), Some(statement))
    }
}

impl From<ReturnStatement> for Block {
    fn from(statement: ReturnStatement) -> Block {
        Block::new(Vec::new(), Some(statement.into()))
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::{
        generator::{LuaGenerator, TokenBasedLuaGenerator},
        nodes::{DoStatement, RepeatStatement},
        Parser,
    };

    fn parse_block_with_tokens(lua: &str) -> Block {
        let parser = Parser::default().preserve_tokens();
        parser.parse(lua).expect("code should parse")
    }

    fn parse_statement_with_tokens(lua: &str) -> Statement {
        let mut block = parse_block_with_tokens(lua);
        assert!(block.get_last_statement().is_none());
        let statements = block.take_statements();
        assert_eq!(statements.len(), 1);
        statements.into_iter().next().unwrap()
    }

    #[test]
    fn default_block_is_empty() {
        let block = Block::default();

        assert!(block.is_empty());
    }

    #[test]
    fn is_empty_is_true_when_block_has_no_statements_or_last_statement() {
        let block = Block::new(Vec::new(), None);

        assert!(block.is_empty());
    }

    #[test]
    fn is_empty_is_false_when_block_has_a_last_statement() {
        let block = Block::default().with_last_statement(LastStatement::new_break());

        assert!(!block.is_empty());
    }

    #[test]
    fn is_empty_is_false_when_block_a_statement() {
        let block = Block::default().with_statement(DoStatement::default());

        assert!(!block.is_empty());
    }

    #[test]
    fn clear_removes_statements() {
        let mut block = Block::default().with_statement(DoStatement::default());
        block.clear();

        assert!(block.is_empty());
    }

    #[test]
    fn clear_removes_last_statement() {
        let mut block = Block::default().with_last_statement(LastStatement::new_break());
        block.clear();

        assert!(block.is_empty());
        assert_eq!(block.get_last_statement(), None);
    }

    #[test]
    fn set_last_statement() {
        let mut block = Block::default();
        let continue_statement = LastStatement::new_continue();
        block.set_last_statement(continue_statement.clone());

        assert_eq!(block.get_last_statement(), Some(&continue_statement));
    }

    #[test]
    fn insert_statement_at_index_0() {
        let mut block = Block::default().with_statement(DoStatement::default());

        let new_statement = RepeatStatement::new(Block::default(), false);
        block.insert_statement(0, new_statement.clone());

        assert_eq!(
            block,
            Block::default()
                .with_statement(new_statement)
                .with_statement(DoStatement::default())
        );
    }

    #[test]
    fn insert_statement_at_index_0_with_tokens() {
        let mut block = parse_block_with_tokens("do end;");

        block.insert_statement(0, RepeatStatement::new(Block::default(), false));

        insta::assert_debug_snapshot!("insert_statement_at_index_0_with_tokens", block);
    }

    #[test]
    fn insert_statement_at_upper_bound() {
        let mut block = Block::default().with_statement(DoStatement::default());

        let new_statement = RepeatStatement::new(Block::default(), false);
        block.insert_statement(1, new_statement.clone());

        assert_eq!(
            block,
            Block::default()
                .with_statement(DoStatement::default())
                .with_statement(new_statement)
        );
    }

    #[test]
    fn insert_statement_after_statement_upper_bound() {
        let mut block = Block::default().with_statement(DoStatement::default());

        let new_statement = RepeatStatement::new(Block::default(), false);
        block.insert_statement(4, new_statement.clone());

        assert_eq!(
            block,
            Block::default()
                .with_statement(DoStatement::default())
                .with_statement(new_statement)
        );
    }

    #[test]
    fn insert_statement_after_statement_upper_bound_with_tokens() {
        let mut block = parse_block_with_tokens("do end;");

        block.insert_statement(4, RepeatStatement::new(Block::default(), false));

        insta::assert_debug_snapshot!(
            "insert_statement_after_statement_upper_bound_with_tokens",
            block
        );
    }

    #[test]
    fn push_statement_with_tokens() {
        let mut block = parse_block_with_tokens("");

        let new_statement = parse_statement_with_tokens("while true do end");
        block.push_statement(new_statement);

        pretty_assertions::assert_eq!(
            block.get_tokens(),
            Some(&BlockTokens {
                semicolons: vec![None],
                last_semicolon: None,
                final_token: None,
            })
        );
    }

    #[test]
    fn attempt_to_remove_statement_from_empty_block() {
        let mut block = parse_block_with_tokens("");

        block.remove_statement(0);

        assert!(block.is_empty());
    }

    #[test]
    fn remove_first_and_only_statement() {
        let mut block = parse_block_with_tokens("while true do end");

        block.remove_statement(0);

        assert!(block.is_empty());
    }

    #[test]
    fn remove_first_statement() {
        let mut block = parse_block_with_tokens("while true do end ; do end");

        block.remove_statement(0);

        insta::assert_debug_snapshot!("remove_first_statement", block);
    }

    #[test]
    fn attempt_to_remove_statement_out_of_bounds() {
        let mut block = parse_block_with_tokens("while true do end");
        let original = block.clone();

        block.remove_statement(1);
        block.remove_statement(2);

        assert_eq!(block, original);
    }

    #[test]
    fn clear_removes_semicolon_tokens() {
        let mut block = Block::default()
            .with_statement(DoStatement::default())
            .with_tokens(BlockTokens {
                semicolons: vec![Some(Token::from_content(";"))],
                last_semicolon: None,
                final_token: None,
            });
        block.clear();

        assert!(block.get_tokens().unwrap().semicolons.is_empty());
    }

    #[test]
    fn clear_removes_last_semicolon_token() {
        let mut block = Block::default()
            .with_last_statement(LastStatement::new_break())
            .with_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: Some(Token::from_content(";")),
                final_token: None,
            });
        block.clear();

        assert!(block.get_tokens().unwrap().last_semicolon.is_none());
    }

    #[test]
    fn set_statements_clear_semicolon_tokens() {
        let mut block = Block::default()
            .with_statement(DoStatement::default())
            .with_tokens(BlockTokens {
                semicolons: vec![Some(Token::from_content(";"))],
                last_semicolon: None,
                final_token: None,
            });
        block.set_statements(Vec::new());

        assert!(block.get_tokens().unwrap().semicolons.is_empty());
    }

    #[test]
    fn take_last_statement_clear_semicolon_token() {
        let mut block = Block::default()
            .with_last_statement(LastStatement::new_break())
            .with_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: Some(Token::from_content(";")),
                final_token: None,
            });

        assert_eq!(
            block.take_last_statement(),
            Some(LastStatement::new_break())
        );

        assert!(block.get_tokens().unwrap().last_semicolon.is_none());
    }

    #[test]
    fn filter_statements_does_not_panic_when_semicolons_do_not_match() {
        let mut block = Block::default()
            .with_statement(DoStatement::default())
            .with_statement(DoStatement::default())
            .with_tokens(BlockTokens {
                semicolons: vec![Some(Token::from_content(";"))],
                last_semicolon: None,
                final_token: None,
            });

        block.filter_statements(|_statement| false);

        pretty_assertions::assert_eq!(
            block,
            Block::default().with_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: None,
                final_token: None,
            })
        );
    }

    #[test]
    fn filter_mut_statements_does_not_panic_when_semicolons_do_not_match() {
        let mut block = Block::default()
            .with_statement(DoStatement::default())
            .with_statement(DoStatement::default())
            .with_tokens(BlockTokens {
                semicolons: vec![Some(Token::from_content(";"))],
                last_semicolon: None,
                final_token: None,
            });

        block.filter_mut_statements(|_statement| false);

        pretty_assertions::assert_eq!(
            block,
            Block::default().with_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: None,
                final_token: None,
            })
        );
    }

    mod statement_removal {
        use super::*;

        fn remove_statement_test(index: usize, code: &str) -> String {
            let mut block = parse_block_with_tokens(code);

            block.remove_statement(index);

            let mut generator = TokenBasedLuaGenerator::new(code);

            generator.write_block(&block);

            generator.into_string()
        }

        #[test]
        fn remove_single_statement_preserves_leading_comments() {
            let lua_code = remove_statement_test(0, "-- comment\nlocal a = 1");

            insta::assert_snapshot!(lua_code, @"-- comment");
        }

        #[test]
        fn remove_single_statement_preserves_trailing_comments() {
            let lua_code = remove_statement_test(0, "local a = 1 -- comment");

            insta::assert_snapshot!(lua_code, @"-- comment");
        }

        #[test]
        fn remove_statement_preserves_comments() {
            let lua_code = remove_statement_test(0, "local a = 1 -- comment\nlocal b = 2");

            insta::assert_snapshot!(lua_code, @r###"
            -- comment
            local b = 2
            "###);
        }

        #[test]
        fn remove_statement_preserves_comments_before_return() {
            let lua_code = remove_statement_test(0, "local a = 1 -- comment\nreturn");

            insta::assert_snapshot!(lua_code, @r###"
            -- comment
            return
            "###);
        }

        #[test]
        fn remove_statement_preserves_comments_before_break() {
            let lua_code = remove_statement_test(0, "--first\nlocal a = 1 -- comment\nbreak");

            insta::assert_snapshot!(lua_code, @r###"
            --first
            -- comment
            break
            "###);
        }

        #[test]
        fn remove_statement_preserves_comments_before_continue() {
            let lua_code = remove_statement_test(0, "local a = 1 -- comment\ncontinue");

            insta::assert_snapshot!(lua_code, @r###"
            -- comment
            continue
            "###);
        }

        #[test]
        fn remove_statement_preserves_comments_after_semicolon() {
            let lua_code = remove_statement_test(0, "local a = 1; -- comment\nlocal b = 2;");

            insta::assert_snapshot!(lua_code, @r###"
            -- comment
            local b = 2;
            "###);
        }
    }
}
