use crate::nodes::Token;

use super::Expression;

/// Represents an if expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfExpression {
    condition: Expression,
    result: Expression,
    else_result: Expression,
    branches: Vec<ElseIfExpressionBranch>,
    tokens: Option<IfExpressionTokens>,
}

impl IfExpression {
    /// Creates a new if expression with the given condition, result, and else result.
    pub fn new<E: Into<Expression>, E2: Into<Expression>, E3: Into<Expression>>(
        condition: E,
        result: E2,
        else_result: E3,
    ) -> Self {
        Self {
            condition: condition.into(),
            result: result.into(),
            else_result: else_result.into(),
            branches: Vec::new(),
            tokens: None,
        }
    }

    /// Attaches tokens to this if expression.
    pub fn with_tokens(mut self, tokens: IfExpressionTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Adds an elseif branch to this if expression.
    pub fn with_branch<E: Into<Expression>, E2: Into<Expression>>(
        mut self,
        condition: E,
        result: E2,
    ) -> Self {
        self.branches
            .push(ElseIfExpressionBranch::new(condition, result));
        self
    }

    /// Adds an elseif branch to this if expression.
    #[inline]
    pub fn push_branch(&mut self, branch: ElseIfExpressionBranch) {
        self.branches.push(branch);
    }

    /// Attaches tokens to this if expression.
    #[inline]
    pub fn set_tokens(&mut self, tokens: IfExpressionTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns a reference to the tokens attached to this if expression, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&IfExpressionTokens> {
        self.tokens.as_ref()
    }

    /// Returns a reference to the condition of this if expression.
    #[inline]
    pub fn get_condition(&self) -> &Expression {
        &self.condition
    }

    /// Returns a mutable reference to the condition of this if expression.
    #[inline]
    pub fn mutate_condition(&mut self) -> &mut Expression {
        &mut self.condition
    }

    /// Returns a reference to the result of this if expression (returned when condition is true).
    #[inline]
    pub fn get_result(&self) -> &Expression {
        &self.result
    }

    /// Returns a mutable reference to the result of this if expression.
    #[inline]
    pub fn mutate_result(&mut self) -> &mut Expression {
        &mut self.result
    }

    /// Returns a reference to the else result of this if expression.
    #[inline]
    pub fn get_else_result(&self) -> &Expression {
        &self.else_result
    }

    /// Returns a mutable reference to the else result of this if expression.
    #[inline]
    pub fn mutate_else_result(&mut self) -> &mut Expression {
        &mut self.else_result
    }

    /// Returns whether this if expression has any elseif branches.
    #[inline]
    pub fn has_elseif_branch(&self) -> bool {
        !self.branches.is_empty()
    }

    /// Returns an iterator over the elseif branches of this if expression.
    #[inline]
    pub fn iter_branches(&self) -> impl Iterator<Item = &ElseIfExpressionBranch> {
        self.branches.iter()
    }

    /// Removes all elseif branches from this if expression.
    #[inline]
    pub fn clear_elseif_branches(&mut self) {
        self.branches.clear();
    }

    /// Retains only the elseif branches that satisfy the predicate.
    #[inline]
    pub fn retain_elseif_branches_mut(
        &mut self,
        filter: impl FnMut(&mut ElseIfExpressionBranch) -> bool,
    ) {
        self.branches.retain_mut(filter);
    }

    /// Removes an elseif branch at the specified index and returns it.
    pub fn remove_branch(&mut self, index: usize) -> Option<ElseIfExpressionBranch> {
        if index < self.branches.len() {
            Some(self.branches.remove(index))
        } else {
            None
        }
    }

    /// Returns a mutable iterator over the elseif branches of this if expression.
    #[inline]
    pub fn iter_mut_branches(&mut self) -> impl Iterator<Item = &mut ElseIfExpressionBranch> {
        self.branches.iter_mut()
    }

    /// Returns a mutable reference to the first token for this if expression,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(IfExpressionTokens {
                r#if: Token::from_content("if"),
                then: Token::from_content("then"),
                r#else: Token::from_content("else"),
            });
        }
        &mut self.tokens.as_mut().unwrap().r#if
    }

    /// Returns a mutable reference to the last token for this if expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.result.mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens, branches]);
}

/// Represents an elseif branch in an if expression.
///
/// Each branch has a condition and a result expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ElseIfExpressionBranch {
    condition: Expression,
    result: Expression,
    tokens: Option<ElseIfExpressionBranchTokens>,
}

impl ElseIfExpressionBranch {
    /// Creates a new elseif branch with the given condition and result.
    pub fn new<E: Into<Expression>, E2: Into<Expression>>(condition: E, result: E2) -> Self {
        Self {
            condition: condition.into(),
            result: result.into(),
            tokens: None,
        }
    }

    /// Attaches tokens to this elseif branch.
    #[inline]
    pub fn set_tokens(&mut self, tokens: ElseIfExpressionBranchTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns a reference to the tokens attached to this elseif branch, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&ElseIfExpressionBranchTokens> {
        self.tokens.as_ref()
    }

    /// Returns a reference to the condition of this elseif branch.
    #[inline]
    pub fn get_condition(&self) -> &Expression {
        &self.condition
    }

    /// Returns a mutable reference to the condition of this elseif branch.
    #[inline]
    pub fn mutate_condition(&mut self) -> &mut Expression {
        &mut self.condition
    }

    /// Returns a reference to the result of this elseif branch.
    #[inline]
    pub fn get_result(&self) -> &Expression {
        &self.result
    }

    /// Returns a mutable reference to the result of this elseif branch.
    #[inline]
    pub fn mutate_result(&mut self) -> &mut Expression {
        &mut self.result
    }

    /// Consumes this branch and returns a tuple of (condition, result).
    pub fn into_expressions(self) -> (Expression, Expression) {
        (self.condition, self.result)
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains token information for an if expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct IfExpressionTokens {
    /// The 'if' keyword token
    pub r#if: Token,
    /// The 'then' keyword token
    pub then: Token,
    /// The 'else' keyword token
    pub r#else: Token,
}

impl IfExpressionTokens {
    super::impl_token_fns!(target = [r#if, then, r#else]);
}

/// Contains token information for an elseif branch in an if expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ElseIfExpressionBranchTokens {
    /// The 'elseif' keyword token
    pub elseif: Token,
    /// The 'then' keyword token
    pub then: Token,
}

impl ElseIfExpressionBranchTokens {
    super::impl_token_fns!(target = [elseif, then]);
}
