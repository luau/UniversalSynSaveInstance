use crate::nodes::{StringError, StringExpression, Token};

/// Represents a string literal used in type annotations.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StringType {
    value: StringExpression,
}

impl StringType {
    /// Creates a new string type from a raw Lua string literal.
    pub fn new(string: &str) -> Result<Self, StringError> {
        StringExpression::new(string).map(|value| Self { value })
    }

    /// Creates an empty string type.
    pub fn empty() -> Self {
        Self {
            value: StringExpression::empty(),
        }
    }

    /// Creates a string type from a value.
    pub fn from_value<T: Into<String>>(value: T) -> Self {
        Self {
            value: StringExpression::from_value(value.into()),
        }
    }

    /// Associates a token with this string type.
    pub fn with_token(mut self, token: Token) -> Self {
        self.value.set_token(token);
        self
    }

    /// Sets the token associated with this string type.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.value.set_token(token);
    }

    /// Returns the token associated with this string type, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.value.get_token()
    }

    /// Returns the string value of this type.
    #[inline]
    pub fn get_value(&self) -> &[u8] {
        self.value.get_value()
    }

    /// Returns the string value if it is valid UTF-8.
    #[inline]
    pub fn get_string_value(&self) -> Option<&str> {
        self.value.get_string_value()
    }

    /// Consumes this string type and returns its string value.
    #[inline]
    pub fn into_value(self) -> Vec<u8> {
        self.value.into_value()
    }

    /// Consumes the string expression and returns the inner string value if it is valid UTF-8.
    #[inline]
    pub fn into_string(self) -> Option<String> {
        self.value.into_string()
    }

    /// Returns whether this string type is a multiline string.
    #[inline]
    pub fn is_multiline(&self) -> bool {
        self.value.is_multiline()
    }

    /// Returns whether this string type uses single quotes.
    #[inline]
    pub fn has_single_quote(&self) -> bool {
        self.value.has_single_quote()
    }

    /// Returns whether this string type uses double quotes.
    #[inline]
    pub fn has_double_quote(&self) -> bool {
        self.value.has_double_quote()
    }

    pub(crate) fn mutate_or_insert_token(&mut self) -> &mut Token {
        self.value.mutate_or_insert_token()
    }

    super::impl_token_fns!(target = [value]);
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn empty_string_get_empty_string_value() {
        let string_type = StringType::empty();

        assert_eq!(string_type.get_string_value().unwrap(), "");
    }

    #[test]
    fn empty_string_get_bytes_is_empty() {
        let string_type = StringType::empty();

        assert_eq!(string_type.get_value(), b"");
    }

    #[test]
    fn empty_string_is_not_multiline() {
        let string_type = StringType::empty();

        assert!(!string_type.is_multiline());
    }

    #[test]
    fn has_single_quote_is_false_if_no_single_quotes() {
        let string = StringType::from_value("hello");

        assert!(!string.has_single_quote());
    }
}
