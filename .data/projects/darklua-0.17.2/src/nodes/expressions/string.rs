use crate::{
    generator::utils::write_string,
    nodes::{StringError, Token},
};

use super::string_utils;

/// Represents a string literal in Lua source code.
///
/// String literals in Lua can be written with single quotes, double quotes,
/// or with long brackets (`[[...]]` or `[=[...]=]` etc.) for multi-line strings.
#[derive(Clone, PartialEq, Eq)]
pub struct StringExpression {
    value: Vec<u8>,
    token: Option<Token>,
}

impl std::fmt::Debug for StringExpression {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("StringExpression")
            .field("token", &self.token)
            .field("value", &{
                if let Ok(s) = str::from_utf8(&self.value) {
                    format!("{:?}", s)
                } else {
                    let escaped = self
                        .value
                        .iter()
                        .flat_map(|&b| {
                            if b <= 0x7f {
                                vec![b as char]
                            } else {
                                format!("\\x{:02x}", b).chars().collect()
                            }
                        })
                        .collect::<String>();
                    format!("{:?}", escaped)
                }
            })
            .finish()
    }
}

impl StringExpression {
    /// Creates a new `StringExpression` from a raw Lua string literal.
    ///
    /// Handles quoted strings (with either ' or " delimiters), long bracket strings,
    /// and processes escape sequences in quoted strings.
    ///
    /// ```
    /// # use darklua_core::nodes::StringExpression;
    /// let single_quoted = StringExpression::new("'hello'").unwrap();
    /// let double_quoted = StringExpression::new("\"world\"").unwrap();
    /// let bracket_string = StringExpression::new("[[multi\nline]]").unwrap();
    /// ```
    pub fn new(string: &str) -> Result<Self, StringError> {
        if string.starts_with('[') {
            return string
                .chars()
                .skip(1)
                .enumerate()
                .find_map(|(indice, character)| if character == '[' { Some(indice) } else { None })
                .ok_or_else(|| StringError::invalid("unable to find `[` delimiter"))
                .and_then(|indice| {
                    let length = 2 + indice;
                    let start = if string
                        .get(length..length + 1)
                        .filter(|char| char == &"\n")
                        .is_some()
                    {
                        length + 1
                    } else {
                        length
                    };
                    string
                        .get(start..string.len() - length)
                        .map(str::to_owned)
                        .ok_or_else(|| StringError::invalid(""))
                })
                .map(Self::from_value);
        }

        let mut chars = string.char_indices();

        match (chars.next(), chars.next_back()) {
            (Some((_, '"')), Some((_, '"'))) | (Some((_, '\'')), Some((_, '\''))) => {
                string_utils::read_escaped_string(chars, Some(string.len())).map(Self::from_value)
            }
            (Some((_, '"')), Some((_, '\''))) | (Some((_, '\'')), Some((_, '"'))) => {
                Err(StringError::invalid("quotes do not match"))
            }
            _ => Err(StringError::invalid("missing quotes")),
        }
    }

    /// Creates an empty string expression.
    pub fn empty() -> Self {
        Self {
            value: b"".to_vec(),
            token: None,
        }
    }

    /// Creates a new `StringExpression` from a string value.
    pub fn from_value(value: impl IntoLuaStringValue) -> Self {
        Self {
            value: value.into_lua_string_value(),
            token: None,
        }
    }

    /// Attaches a token to this string expression.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token for this string expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this string expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the token attached to this string expression,
    /// creating it if missing.
    pub(crate) fn mutate_or_insert_token(&mut self) -> &mut Token {
        if self.token.is_none() {
            let content = write_string(&self.value);
            self.token = Some(Token::from_content(content));
        }
        self.token.as_mut().unwrap()
    }

    /// Returns the string value.
    #[inline]
    pub fn get_value(&self) -> &[u8] {
        &self.value
    }

    /// Returns the string value if it is valid UTF-8.
    #[inline]
    pub fn get_string_value(&self) -> Option<&str> {
        str::from_utf8(&self.value).ok()
    }

    /// Consumes the string expression and returns the inner string value.
    #[inline]
    pub fn into_value(self) -> Vec<u8> {
        self.value
    }

    /// Consumes the string expression and returns the inner string value if it is valid UTF-8.
    #[inline]
    pub fn into_string(self) -> Option<String> {
        String::from_utf8(self.value).ok()
    }

    /// Checks if the string contains newline characters.
    pub fn is_multiline(&self) -> bool {
        self.value.contains(&b'\n')
    }

    /// Checks if the string contains single quotes.
    ///
    /// Useful when determining the best quote style to use when serializing the string.
    pub fn has_single_quote(&self) -> bool {
        self.find_not_escaped(b'\'').is_some()
    }

    /// Checks if the string contains double quotes.
    ///
    /// Useful when determining the best quote style to use when serializing the string.
    pub fn has_double_quote(&self) -> bool {
        self.find_not_escaped(b'"').is_some()
    }

    fn find_not_escaped(&self, pattern: u8) -> Option<usize> {
        self.find_not_escaped_from(pattern, &mut self.value.iter().copied().enumerate())
    }

    fn find_not_escaped_from(
        &self,
        pattern: u8,
        mut chars: impl Iterator<Item = (usize, u8)>,
    ) -> Option<usize> {
        let mut escaped = false;
        chars.find_map(|(index, character)| {
            if escaped {
                escaped = false;
                None
            } else {
                match character {
                    b'\\' => {
                        escaped = true;
                        None
                    }
                    value => {
                        if value == pattern {
                            Some(index)
                        } else {
                            None
                        }
                    }
                }
            }
        })
    }

    super::impl_token_fns!(iter = [token]);
}

/// Trait for converting string related values into a Lua string value.
pub trait IntoLuaStringValue {
    fn into_lua_string_value(self) -> Vec<u8>;
}

impl IntoLuaStringValue for String {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.into_bytes()
    }
}

impl IntoLuaStringValue for &String {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.as_bytes().to_vec()
    }
}

impl IntoLuaStringValue for &str {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.as_bytes().to_vec()
    }
}

impl IntoLuaStringValue for Vec<u8> {
    fn into_lua_string_value(self) -> Vec<u8> {
        self
    }
}

impl IntoLuaStringValue for &[u8] {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.to_vec()
    }
}

impl<const N: usize> IntoLuaStringValue for [u8; N] {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.to_vec()
    }
}

impl<const N: usize> IntoLuaStringValue for &[u8; N] {
    fn into_lua_string_value(self) -> Vec<u8> {
        self.to_vec()
    }
}

impl IntoLuaStringValue for char {
    fn into_lua_string_value(self) -> Vec<u8> {
        let mut buf = [0u8; 4];
        self.encode_utf8(&mut buf).as_bytes().to_vec()
    }
}

#[cfg(test)]
mod test {
    use super::*;

    macro_rules! test_quoted {
        ($($name:ident($input:literal) => $value:literal),* $(,)?) => {
            mod single_quoted {
                use super::*;
                $(
                    #[test]
                    fn $name() {
                        let quoted = format!("'{}'", $input);
                        assert_eq!(
                            StringExpression::new(&quoted)
                                .expect("unable to parse string")
                                .get_value(),
                            StringExpression::from_value($value).get_value(),
                        );
                    }
                )*
            }

            mod double_quoted {
                use super::*;
                $(
                    #[test]
                    fn $name() {
                        let quoted = format!("\"{}\"", $input);
                        assert_eq!(
                            StringExpression::new(&quoted)
                                .expect("unable to parse string")
                                .get_value(),
                            StringExpression::from_value($value).get_value(),
                        );
                    }
                )*
            }
        };
    }

    test_quoted!(
        empty("") => "",
        hello("hello") => "hello",
        escaped_new_line("\\n") => "\n",
        escaped_tab("\\t") => "\t",
        escaped_backslash("\\\\") => "\\",
        escaped_carriage_return("\\r") => "\r",
        escaped_bell("\\a") => "\u{7}",
        escaped_backspace("\\b") => "\u{8}",
        escaped_vertical_tab("\\v") => "\u{B}",
        escaped_form_feed("\\f") => "\u{C}",
        escaped_null("\\0") => "\0",
        escaped_two_digits("\\65") => "A",
        escaped_three_digits("\\123") => "{",
        escaped_null_hex("\\x00") => "\0",
        escaped_uppercase_a_hex("\\x41") => "A",
        escaped_tilde_hex_uppercase("\\x7E") => "~",
        escaped_tilde_hex_lowercase("\\x7e") => "~",
        skips_whitespaces_but_no_spaces("\\z") => "",
        skips_whitespaces("a\\z   \n\n   \\nb") => "a\nb",
        escaped_176("\\176") => b"\xB0",
        escaped_unicode_single_digit("\\u{0}") => "\0",
        escaped_unicode_two_hex_digits("\\u{AB}") => "\u{AB}",
        escaped_unicode_three_digit("\\u{123}") => "\u{123}",
        escaped_unicode_last_value("\\u{10FFFF}") => "\u{10FFFF}",
    );

    mod invalid_string_errors {
        use super::*;

        #[test]
        fn double_quoted_single_backslash() {
            insta::assert_snapshot!(StringExpression::new("\"\\\"").unwrap_err().to_string(), @r###"malformed escape sequence at 1: string ended after '\'"###);
        }

        #[test]
        fn single_quoted_single_backslash() {
            insta::assert_snapshot!(StringExpression::new("'\\'").unwrap_err().to_string(), @r###"malformed escape sequence at 1: string ended after '\'"###);
        }

        #[test]
        fn double_quoted_escaped_too_large_ascii() {
            insta::assert_snapshot!(StringExpression::new("\"\\256\"").unwrap_err().to_string(), @"malformed escape sequence at 1: cannot escape ascii character greater than 256");
        }

        #[test]
        fn single_quoted_escaped_too_large_ascii() {
            insta::assert_snapshot!(StringExpression::new("'\\256'").unwrap_err().to_string(), @"malformed escape sequence at 1: cannot escape ascii character greater than 256");
        }

        #[test]
        fn double_quoted_escaped_too_large_unicode() {
            insta::assert_snapshot!(StringExpression::new("\"\\u{110000}\"").unwrap_err().to_string(), @"malformed escape sequence at 1: invalid unicode value");
        }

        #[test]
        fn single_quoted_escaped_too_large_unicode() {
            insta::assert_snapshot!(StringExpression::new("'\\u{110000}'").unwrap_err().to_string(), @"malformed escape sequence at 1: invalid unicode value");
        }

        #[test]
        fn double_quoted_escaped_missing_opening_brace_unicode() {
            insta::assert_snapshot!(StringExpression::new("\"\\uAB\"").unwrap_err().to_string(), @"malformed escape sequence at 1: expected opening curly brace");
        }

        #[test]
        fn single_quoted_escaped_missing_opening_brace_unicode() {
            insta::assert_snapshot!(StringExpression::new("'\\uAB'").unwrap_err().to_string(), @"malformed escape sequence at 1: expected opening curly brace");
        }

        #[test]
        fn double_quoted_escaped_missing_closing_brace_unicode() {
            insta::assert_snapshot!(StringExpression::new("\"\\u{0p\"").unwrap_err().to_string(), @"malformed escape sequence at 1: expected closing curly brace");
        }

        #[test]
        fn single_quoted_escaped_missing_closing_brace_unicode() {
            insta::assert_snapshot!(StringExpression::new("'\\u{0p'").unwrap_err().to_string(), @"malformed escape sequence at 1: expected closing curly brace");
        }

        #[test]
        fn empty_string() {
            insta::assert_snapshot!(StringExpression::new("").unwrap_err().to_string(), @"invalid string: missing quotes");
        }

        #[test]
        fn missing_quotes() {
            insta::assert_snapshot!(StringExpression::new("hello").unwrap_err().to_string(), @"invalid string: missing quotes");
        }

        #[test]
        fn delimiters_matching_but_not_quotes() {
            insta::assert_snapshot!(StringExpression::new("aa").unwrap_err().to_string(), @"invalid string: missing quotes");
        }

        #[test]
        fn single_quote() {
            insta::assert_snapshot!(StringExpression::new("'").unwrap_err().to_string(), @"invalid string: missing quotes");
        }

        #[test]
        fn double_quote() {
            insta::assert_snapshot!(StringExpression::new("\"").unwrap_err().to_string(), @"invalid string: missing quotes");
        }

        #[test]
        fn quotes_not_matching() {
            insta::assert_snapshot!(StringExpression::new("'\"").unwrap_err().to_string(), @"invalid string: quotes do not match");
        }
    }

    #[test]
    fn new_removes_double_quotes() {
        let string = StringExpression::new(r#""hello""#).unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_removes_single_quotes() {
        let string = StringExpression::new("'hello'").unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_removes_double_brackets() {
        let string = StringExpression::new("[[hello]]").unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_removes_double_brackets_and_skip_first_new_line() {
        let string = StringExpression::new("[[\nhello]]").unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_removes_double_brackets_with_one_equals() {
        let string = StringExpression::new("[=[hello]=]").unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_removes_double_brackets_with_multiple_equals() {
        let string = StringExpression::new("[==[hello]==]").unwrap();

        assert_eq!(string.get_value(), b"hello");
    }

    #[test]
    fn new_skip_invalid_escape_in_double_quoted_string() {
        let string = StringExpression::new("'\\oo'").unwrap();

        assert_eq!(string.get_value(), b"oo");
    }

    #[test]
    fn new_skip_invalid_escape_in_single_quoted_string() {
        let string = StringExpression::new("\"\\oo\"").unwrap();

        assert_eq!(string.get_value(), b"oo");
    }

    #[test]
    fn has_single_quote_is_false_if_no_single_quotes() {
        let string = StringExpression::from_value("hello");

        assert!(!string.has_single_quote());
    }

    #[test]
    fn has_single_quote_is_true_if_unescaped_single_quotes() {
        let string = StringExpression::from_value("don't");

        assert!(string.has_single_quote());
    }

    #[test]
    fn has_single_quote_is_true_if_unescaped_single_quotes_with_escaped_backslash() {
        let string = StringExpression::from_value(r"don\\'t");

        assert!(string.has_single_quote());
    }

    #[test]
    fn has_single_quote_is_false_if_escaped_single_quotes() {
        let string = StringExpression::from_value(r"don\'t");

        assert!(!string.has_single_quote());
    }

    #[test]
    fn has_double_quote_is_false_if_no_double_quotes() {
        let string = StringExpression::from_value("hello");

        assert!(!string.has_double_quote());
    }

    #[test]
    fn has_double_quote_is_true_if_unescaped_double_quotes() {
        let string = StringExpression::from_value(r#"Say: "Hi!""#);

        assert!(string.has_double_quote());
    }

    #[test]
    fn has_double_quote_is_false_if_escaped_double_quotes() {
        let string = StringExpression::from_value(r#"hel\"o"#);

        assert!(!string.has_double_quote());
    }
}
