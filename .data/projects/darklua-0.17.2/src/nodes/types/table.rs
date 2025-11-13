use crate::nodes::{Identifier, Token, Trivia};

use super::{StringType, Type};

/// Represents an indexer in a table type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableIndexerType {
    key_type: Box<Type>,
    value_type: Box<Type>,
    tokens: Option<TableIndexTypeTokens>,
}

impl TableIndexerType {
    /// Creates a new table indexer with the specified key and value types.
    pub fn new(key_type: impl Into<Type>, value_type: impl Into<Type>) -> Self {
        Self {
            key_type: Box::new(key_type.into()),
            value_type: Box::new(value_type.into()),
            tokens: None,
        }
    }

    /// Returns the key type of this indexer.
    #[inline]
    pub fn get_key_type(&self) -> &Type {
        &self.key_type
    }

    /// Returns a mutable reference to the key type of this indexer.
    #[inline]
    pub fn mutate_key_type(&mut self) -> &mut Type {
        &mut self.key_type
    }

    /// Returns the value type of this indexer.
    #[inline]
    pub fn get_value_type(&self) -> &Type {
        &self.value_type
    }

    /// Returns a mutable reference to the value type of this indexer.
    #[inline]
    pub fn mutate_value_type(&mut self) -> &mut Type {
        &mut self.value_type
    }

    /// Associates tokens with this indexer and returns the modified indexer.
    pub fn with_tokens(mut self, token: TableIndexTypeTokens) -> Self {
        self.tokens = Some(token);
        self
    }

    /// Sets the tokens associated with this indexer.
    #[inline]
    pub fn set_tokens(&mut self, token: TableIndexTypeTokens) {
        self.tokens = Some(token);
    }

    /// Returns the tokens associated with this indexer, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TableIndexTypeTokens> {
        self.tokens.as_ref()
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains the tokens that define an indexer's syntax.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableIndexTypeTokens {
    /// The opening bracket token.
    pub opening_bracket: Token,
    /// The closing bracket token.
    pub closing_bracket: Token,
    /// The colon token.
    pub colon: Token,
}

impl TableIndexTypeTokens {
    super::impl_token_fns!(target = [opening_bracket, closing_bracket, colon]);
}

/// Represents a named property in a table type annotation (i.e. `name: Type`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TablePropertyType {
    property: Identifier,
    r#type: Box<Type>,
    token: Option<Token>,
}

impl TablePropertyType {
    /// Creates a new table property with the specified name and type.
    pub fn new(property: impl Into<Identifier>, r#type: impl Into<Type>) -> Self {
        Self {
            property: property.into(),
            r#type: Box::new(r#type.into()),
            token: None,
        }
    }

    /// Returns the identifier of this property.
    #[inline]
    pub fn get_identifier(&self) -> &Identifier {
        &self.property
    }

    /// Returns a mutable reference to the identifier of this property.
    #[inline]
    pub fn mutate_identifier(&mut self) -> &mut Identifier {
        &mut self.property
    }

    /// Returns the type of this property.
    #[inline]
    pub fn get_type(&self) -> &Type {
        &self.r#type
    }

    /// Returns a mutable reference to the type of this property.
    #[inline]
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.r#type
    }

    /// Associates a token for the colon with this property.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for the colon associated with this property.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token for the colon associated with this property, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    super::impl_token_fns!(target = [property] iter = [token]);
}

/// Represents a string literal property in a table type annotation (i.e. `["key"]: Type`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableLiteralPropertyType {
    string: StringType,
    r#type: Box<Type>,
    tokens: Option<TableIndexTypeTokens>,
}

impl TableLiteralPropertyType {
    /// Creates a new string literal property with the specified key and type.
    pub fn new(string: StringType, r#type: impl Into<Type>) -> Self {
        Self {
            string,
            r#type: Box::new(r#type.into()),
            tokens: None,
        }
    }

    /// Returns the string key of this property.
    #[inline]
    pub fn get_string(&self) -> &StringType {
        &self.string
    }

    /// Returns a mutable reference to the string key of this property.
    #[inline]
    pub fn mutate_string(&mut self) -> &mut StringType {
        &mut self.string
    }

    /// Returns the type of this property.
    #[inline]
    pub fn get_type(&self) -> &Type {
        &self.r#type
    }

    /// Returns a mutable reference to the type of this property.
    #[inline]
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.r#type
    }

    /// Associates tokens with this property.
    pub fn with_tokens(mut self, tokens: TableIndexTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this property.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TableIndexTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this property, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TableIndexTypeTokens> {
        self.tokens.as_ref()
    }

    super::impl_token_fns!(target = [string] iter = [tokens]);
}

/// Represents an entry in a table type annotation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TableEntryType {
    /// A named property entry.
    Property(TablePropertyType),
    /// A string literal property entry.
    Literal(TableLiteralPropertyType),
    /// An indexer entry.
    Indexer(TableIndexerType),
}

impl TableEntryType {
    /// Removes all comments from this table entry.
    pub fn clear_comments(&mut self) {
        match self {
            TableEntryType::Property(property) => property.clear_comments(),
            TableEntryType::Literal(literal) => literal.clear_comments(),
            TableEntryType::Indexer(indexer) => indexer.clear_comments(),
        }
    }

    /// Removes all whitespace from this table entry.
    pub fn clear_whitespaces(&mut self) {
        match self {
            TableEntryType::Property(property) => property.clear_whitespaces(),
            TableEntryType::Literal(literal) => literal.clear_whitespaces(),
            TableEntryType::Indexer(indexer) => indexer.clear_whitespaces(),
        }
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        match self {
            TableEntryType::Property(property) => property.replace_referenced_tokens(code),
            TableEntryType::Literal(literal) => literal.replace_referenced_tokens(code),
            TableEntryType::Indexer(indexer) => indexer.replace_referenced_tokens(code),
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match self {
            TableEntryType::Property(property) => property.shift_token_line(amount),
            TableEntryType::Literal(literal) => literal.shift_token_line(amount),
            TableEntryType::Indexer(indexer) => indexer.shift_token_line(amount),
        }
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        match self {
            TableEntryType::Property(property) => property.filter_comments(filter),
            TableEntryType::Literal(literal) => literal.filter_comments(filter),
            TableEntryType::Indexer(indexer) => indexer.filter_comments(filter),
        }
    }
}

impl From<TablePropertyType> for TableEntryType {
    fn from(value: TablePropertyType) -> Self {
        Self::Property(value)
    }
}

impl From<TableLiteralPropertyType> for TableEntryType {
    fn from(value: TableLiteralPropertyType) -> Self {
        Self::Literal(value)
    }
}

impl From<TableIndexerType> for TableEntryType {
    fn from(value: TableIndexerType) -> Self {
        Self::Indexer(value)
    }
}

/// Represents a table type annotation.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct TableType {
    entries: Vec<TableEntryType>,
    tokens: Option<TableTypeTokens>,
}

impl TableType {
    /// Creates a new table type with a property and returns the modified table type.
    pub fn with_new_property(
        mut self,
        property: impl Into<Identifier>,
        r#type: impl Into<Type>,
    ) -> Self {
        self.entries
            .push(TablePropertyType::new(property.into(), r#type.into()).into());
        self
    }

    /// Adds a property to this table type and returns the modified table type.
    pub fn with_property(mut self, property: impl Into<TableEntryType>) -> Self {
        self.push_property(property.into());
        self
    }

    /// Adds a property to this table type.
    #[inline]
    pub fn push_property(&mut self, property: impl Into<TableEntryType>) {
        let property = property.into();
        match property {
            TableEntryType::Indexer(indexer) => {
                self.set_indexer_type(indexer);
            }
            _ => {
                self.entries.push(property);
            }
        }
    }

    /// Sets the indexer type for this table type and returns the modified table type.
    pub fn with_indexer_type(mut self, indexer_type: TableIndexerType) -> Self {
        self.set_indexer_type(indexer_type);
        self
    }

    /// Sets the indexer type for this table type.
    /// If the key type is a string, converts it to a string literal property.
    /// Returns the previous indexer type if one existed.
    #[inline]
    pub fn set_indexer_type(&mut self, indexer_type: TableIndexerType) -> Option<TableIndexerType> {
        match *indexer_type.key_type {
            Type::String(string_type) => {
                self.entries
                    .push(TableEntryType::Literal(TableLiteralPropertyType {
                        string: string_type,
                        r#type: indexer_type.value_type,
                        tokens: indexer_type.tokens,
                    }));
                None
            }
            _ => {
                let removed = if let Some((remove_index, _)) = self
                    .entries
                    .iter()
                    .enumerate()
                    .find(|(_, entry)| matches!(entry, TableEntryType::Indexer(_)))
                {
                    match self.entries.remove(remove_index) {
                        TableEntryType::Indexer(indexer) => Some(indexer),
                        TableEntryType::Property(_) | TableEntryType::Literal(_) => unreachable!(),
                    }
                } else {
                    None
                };
                self.entries.push(TableEntryType::Indexer(indexer_type));
                removed
            }
        }
    }

    /// Returns whether this table type has an indexer.
    #[inline]
    pub fn has_indexer_type(&self) -> bool {
        self.entries
            .iter()
            .any(|entry| matches!(entry, TableEntryType::Indexer(_)))
    }

    /// Returns the number of entries in this table type.
    #[inline]
    pub fn len(&self) -> usize {
        self.entries.len()
    }

    /// Returns whether this table type has no entries.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    /// Returns an iterator over the entries in this table type.
    #[inline]
    pub fn iter_entries(&self) -> impl Iterator<Item = &TableEntryType> {
        self.entries.iter()
    }

    /// Returns a mutable iterator over the entries in this table type.
    #[inline]
    pub fn iter_mut_entries(&mut self) -> impl Iterator<Item = &mut TableEntryType> {
        self.entries.iter_mut()
    }

    /// Associates tokens with this table type and returns the modified table type.
    pub fn with_tokens(mut self, tokens: TableTypeTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens associated with this table type.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TableTypeTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens associated with this table type, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TableTypeTokens> {
        self.tokens.as_ref()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.tokens.is_none() {
            self.tokens = Some(TableTypeTokens {
                opening_brace: Token::from_content("{"),
                closing_brace: Token::from_content("}"),
                separators: Vec::new(),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_brace
    }

    super::impl_token_fns!(iter = [entries, tokens]);
}

/// Contains the tokens that define a table type's syntax.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableTypeTokens {
    /// The opening brace token.
    pub opening_brace: Token,
    /// The closing brace token.
    pub closing_brace: Token,
    /// The comma tokens separating the entries.
    pub separators: Vec<Token>,
}

impl TableTypeTokens {
    super::impl_token_fns!(
        target = [opening_brace, closing_brace]
        iter = [separators]
    );
}
