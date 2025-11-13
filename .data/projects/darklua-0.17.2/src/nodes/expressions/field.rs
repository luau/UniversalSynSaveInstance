use crate::nodes::{Identifier, Prefix, Token};

/// Represents a field access expression.
///
/// A field access expression accesses a member of a table using dot notation,
/// such as `table.field`. It consists of a prefix (the table being accessed)
/// and a field identifier.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FieldExpression {
    prefix: Prefix,
    field: Identifier,
    token: Option<Token>,
}

impl FieldExpression {
    /// Creates a new field access expression.
    pub fn new<IntoPrefix: Into<Prefix>, IntoIdentifier: Into<Identifier>>(
        prefix: IntoPrefix,
        field: IntoIdentifier,
    ) -> Self {
        Self {
            prefix: prefix.into(),
            field: field.into(),
            token: None,
        }
    }

    /// Attaches a token to this field expression and returns the updated expression.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Attaches a token to this field expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the token attached to this field expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a reference to the prefix of this field expression.
    #[inline]
    pub fn get_prefix(&self) -> &Prefix {
        &self.prefix
    }

    /// Returns a reference to the field identifier of this field expression.
    #[inline]
    pub fn get_field(&self) -> &Identifier {
        &self.field
    }

    /// Returns a mutable reference to the prefix of this field expression.
    pub fn mutate_prefix(&mut self) -> &mut Prefix {
        &mut self.prefix
    }

    /// Returns a mutable reference to the first token of this field expression,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.prefix.mutate_first_token()
    }

    /// Returns a mutable reference to the last token of this field expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.field.mutate_or_insert_token()
    }

    super::impl_token_fns!(
        target = [field]
        iter = [token]
    );
}
