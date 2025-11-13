use crate::{
    nodes::{Expression, Identifier, Token, Trivia},
    process::utils::is_valid_identifier,
};

use super::StringExpression;

/// Represents a field entry in a table literal where the key is an identifier.
///
/// This corresponds to the form: `{ field = value }`
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableFieldEntry {
    field: Identifier,
    value: Expression,
    token: Option<Token>,
}

impl TableFieldEntry {
    /// Creates a new table field entry with the given field name and value.
    pub fn new<I: Into<Identifier>, E: Into<Expression>>(field: I, value: E) -> Self {
        Self {
            field: field.into(),
            value: value.into(),
            token: None,
        }
    }

    /// Attaches a token to this field entry.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for this field entry.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this field entry, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns the field name.
    #[inline]
    pub fn get_field(&self) -> &Identifier {
        &self.field
    }

    /// Returns a mutable reference to the field name.
    #[inline]
    pub fn mutate_field(&mut self) -> &mut Identifier {
        &mut self.field
    }

    /// Returns the field value.
    #[inline]
    pub fn get_value(&self) -> &Expression {
        &self.value
    }

    /// Returns a mutable reference to the field value.
    #[inline]
    pub fn mutate_value(&mut self) -> &mut Expression {
        &mut self.value
    }

    super::impl_token_fns!(
        target = [field]
        iter = [token]
    );
}

/// Contains tokens for a table index entry.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableIndexEntryTokens {
    /// Token for the opening bracket `[`
    pub opening_bracket: Token,
    /// Token for the closing bracket `]`
    pub closing_bracket: Token,
    /// Token for the equals sign `=`
    pub equal: Token,
}

impl TableIndexEntryTokens {
    super::impl_token_fns!(target = [opening_bracket, closing_bracket, equal]);
}

/// Represents an index entry in a table literal where the key is a computed expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableIndexEntry {
    key: Expression,
    value: Expression,
    tokens: Option<Box<TableIndexEntryTokens>>,
}

impl TableIndexEntry {
    /// Creates a new table index entry with the given key and value.
    pub fn new<T: Into<Expression>, U: Into<Expression>>(key: T, value: U) -> Self {
        Self {
            key: key.into(),
            value: value.into(),
            tokens: None,
        }
    }

    /// Attaches tokens to this index entry and returns the modified entry.
    pub fn with_tokens(mut self, tokens: TableIndexEntryTokens) -> Self {
        self.tokens = Some(tokens.into());
        self
    }

    /// Sets the tokens for this index entry.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TableIndexEntryTokens) {
        self.tokens = Some(tokens.into());
    }

    /// Returns the tokens associated with this index entry, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TableIndexEntryTokens> {
        self.tokens.as_ref().map(|tokens| tokens.as_ref())
    }

    /// Returns the key expression.
    #[inline]
    pub fn get_key(&self) -> &Expression {
        &self.key
    }

    /// Returns a mutable reference to the key expression.
    #[inline]
    pub fn mutate_key(&mut self) -> &mut Expression {
        &mut self.key
    }

    /// Returns the value expression.
    #[inline]
    pub fn get_value(&self) -> &Expression {
        &self.value
    }

    /// Returns a mutable reference to the value expression.
    #[inline]
    pub fn mutate_value(&mut self) -> &mut Expression {
        &mut self.value
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Represents a single entry in a table literal.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TableEntry {
    /// A named field entry (e.g., `{ field = value }`)
    Field(Box<TableFieldEntry>),
    /// A computed index entry (e.g., `{ [expr] = value }`)
    Index(Box<TableIndexEntry>),
    /// A value entry for array-like tables (e.g., `{ value }`)
    Value(Box<Expression>),
}

impl TableEntry {
    /// Creates an array-like table entry from a value.
    pub fn from_value(value: impl Into<Expression>) -> Self {
        Self::Value(Box::new(value.into()))
    }

    /// Creates a table entry from a string key and value.
    ///
    /// If the key is a valid Lua identifier, a `Field` entry is created.
    /// Otherwise, an `Index` entry with a string key is created.
    pub fn from_string_key_and_value(key: impl Into<String>, value: impl Into<Expression>) -> Self {
        let key = key.into();
        let value = value.into();
        if is_valid_identifier(&key) {
            Self::Field(Box::new(TableFieldEntry {
                field: Identifier::new(key),
                value,
                token: None,
            }))
        } else {
            Self::Index(Box::new(TableIndexEntry {
                key: Expression::String(StringExpression::from_value(key)),
                value,
                tokens: None,
            }))
        }
    }

    /// Clears all comments from the tokens in this node.
    pub fn clear_comments(&mut self) {
        match self {
            TableEntry::Field(entry) => entry.clear_comments(),
            TableEntry::Index(entry) => entry.clear_comments(),
            TableEntry::Value(_) => {}
        }
    }

    /// Clears all whitespaces information from the tokens in this node.
    pub fn clear_whitespaces(&mut self) {
        match self {
            TableEntry::Field(entry) => entry.clear_whitespaces(),
            TableEntry::Index(entry) => entry.clear_whitespaces(),
            TableEntry::Value(_) => {}
        }
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        match self {
            TableEntry::Field(entry) => entry.replace_referenced_tokens(code),
            TableEntry::Index(entry) => entry.replace_referenced_tokens(code),
            TableEntry::Value(_) => {}
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match self {
            TableEntry::Field(entry) => entry.shift_token_line(amount),
            TableEntry::Index(entry) => entry.shift_token_line(amount),
            TableEntry::Value(_) => {}
        }
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        match self {
            TableEntry::Field(entry) => entry.filter_comments(filter),
            TableEntry::Index(entry) => entry.filter_comments(filter),
            TableEntry::Value(_) => {}
        }
    }
}

impl From<TableFieldEntry> for TableEntry {
    fn from(entry: TableFieldEntry) -> Self {
        Self::Field(Box::new(entry))
    }
}

impl From<TableIndexEntry> for TableEntry {
    fn from(entry: TableIndexEntry) -> Self {
        Self::Index(Box::new(entry))
    }
}

/// Contains tokens for a table expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableTokens {
    /// Token for the opening brace `{`
    pub opening_brace: Token,
    /// Token for the closing brace `}`
    pub closing_brace: Token,
    /// Tokens for the separators between entries (commas and/or semicolons)
    pub separators: Vec<Token>,
}

impl TableTokens {
    super::impl_token_fns!(
        target = [opening_brace, closing_brace]
        iter = [separators]
    );
}

/// Represents a table expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableExpression {
    entries: Vec<TableEntry>,
    tokens: Option<TableTokens>,
}

impl TableExpression {
    /// Creates a new table expression with the given entries.
    pub fn new(entries: Vec<TableEntry>) -> Self {
        Self {
            entries,
            tokens: None,
        }
    }

    /// Attaches tokens to this table expression.
    pub fn with_tokens(mut self, tokens: TableTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this table expression.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TableTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this table expression, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TableTokens> {
        self.tokens.as_ref()
    }

    /// Returns the entries in this table expression.
    #[inline]
    pub fn get_entries(&self) -> &Vec<TableEntry> {
        &self.entries
    }

    /// Returns an iterator over the entries in this table expression.
    #[inline]
    pub fn iter_entries(&self) -> impl Iterator<Item = &TableEntry> {
        self.entries.iter()
    }

    /// Returns a mutable iterator over the entries in this table expression.
    #[inline]
    pub fn iter_mut_entries(&mut self) -> impl Iterator<Item = &mut TableEntry> {
        self.entries.iter_mut()
    }

    /// Returns the number of entries in this table expression.
    #[inline]
    pub fn len(&self) -> usize {
        self.entries.len()
    }

    /// Returns whether this table expression is empty.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    /// Returns a mutable reference to the entries in this table expression.
    #[inline]
    pub fn mutate_entries(&mut self) -> &mut Vec<TableEntry> {
        &mut self.entries
    }

    /// Appends a new entry to this table expression.
    pub fn append_entry<T: Into<TableEntry>>(mut self, entry: T) -> Self {
        self.entries.push(entry.into());
        self
    }

    /// Appends a new field entry to this table expression.
    pub fn append_field<S: Into<Identifier>, E: Into<Expression>>(
        mut self,
        key: S,
        value: E,
    ) -> Self {
        self.entries.push(TableFieldEntry::new(key, value).into());
        self
    }

    /// Appends a new index entry to this table expression.
    pub fn append_index<T: Into<Expression>, U: Into<Expression>>(
        mut self,
        key: T,
        value: U,
    ) -> Self {
        self.entries
            .push(TableIndexEntry::new(key.into(), value.into()).into());
        self
    }

    /// Appends a new value entry to this table expression.
    pub fn append_array_value<E: Into<Expression>>(mut self, value: E) -> Self {
        self.entries.push(TableEntry::from_value(value));
        self
    }

    /// Returns a mutable reference to the first token for this table expression,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().opening_brace
    }

    /// Returns a mutable reference to the last token of this table expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().closing_brace
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.set_tokens(TableTokens {
                opening_brace: Token::from_content("{"),
                closing_brace: Token::from_content("}"),
                separators: Vec::new(),
            });
        }
    }

    super::impl_token_fns!(iter = [tokens, entries]);
}

impl Default for TableExpression {
    fn default() -> Self {
        Self::new(Vec::new())
    }
}
