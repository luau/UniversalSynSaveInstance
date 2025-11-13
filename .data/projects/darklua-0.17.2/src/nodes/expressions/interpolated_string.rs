use std::iter::FromIterator;

use crate::nodes::{IntoLuaStringValue, StringError, Token, Trivia};

use super::{string_utils, Expression};

/// Represents a string segment in an interpolated string.
///
/// String segments are the literal text parts of an interpolated string,
/// appearing between expression segments.
#[derive(Clone, PartialEq, Eq)]
pub struct StringSegment {
    value: Vec<u8>,
    token: Option<Token>,
}

impl std::fmt::Debug for StringSegment {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("StringSegment")
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

impl StringSegment {
    /// Creates a new string segment from a string value, processing escape sequences.
    pub fn new(value: impl AsRef<str>) -> Result<Self, StringError> {
        let value = value.as_ref();
        string_utils::read_escaped_string(value.char_indices(), Some(value.len()))
            .map(Self::from_value)
    }

    /// Creates a new string segment from a string value without processing escapes.
    pub fn from_value(value: impl IntoLuaStringValue) -> Self {
        Self {
            value: value.into_lua_string_value(),
            token: None,
        }
    }

    /// Attaches a token to this string segment and returns the updated segment.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Attaches a token to this string segment.
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the token attached to this string segment, if any.
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns the string value of this segment.
    pub fn get_value(&self) -> &[u8] {
        &self.value
    }

    /// Returns the string value if it is valid UTF-8.
    #[inline]
    pub fn get_string_value(&self) -> Option<&str> {
        str::from_utf8(&self.value).ok()
    }

    fn append(&mut self, mut other: Self) {
        self.value.append(&mut other.value);
        self.token = None;
    }

    /// Returns the length of the string value in this segment.
    #[inline]
    pub fn len(&self) -> usize {
        self.value.len()
    }

    /// Returns whether the string value in this segment is empty.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.value.is_empty()
    }

    super::impl_token_fns!(iter = [token]);
}

/// Represents an expression segment in an interpolated string.
///
/// Value segments contain expressions that are evaluated and converted to strings
/// when the interpolated string is evaluated.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ValueSegment {
    value: Box<Expression>,
    tokens: Option<ValueSegmentTokens>,
}

impl ValueSegment {
    /// Creates a new value segment with the given expression.
    pub fn new(value: impl Into<Expression>) -> Self {
        Self {
            value: Box::new(value.into()),
            tokens: None,
        }
    }

    /// Attaches tokens to this value segment.
    pub fn with_tokens(mut self, tokens: ValueSegmentTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Attaches tokens to this value segment.
    pub fn set_tokens(&mut self, tokens: ValueSegmentTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns a reference to the tokens attached to this value segment, if any.
    pub fn get_tokens(&self) -> Option<&ValueSegmentTokens> {
        self.tokens.as_ref()
    }

    /// Returns a reference to the expression in this value segment.
    pub fn get_expression(&self) -> &Expression {
        &self.value
    }

    /// Returns a mutable reference to the expression in this value segment.
    pub fn mutate_expression(&mut self) -> &mut Expression {
        &mut self.value
    }

    super::impl_token_fns!(iter = [tokens]);
}

/// Contains token information for a value segment in an interpolated string.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ValueSegmentTokens {
    /// The opening brace token (`{`)
    pub opening_brace: Token,
    /// The closing brace token (`}`)
    pub closing_brace: Token,
}

impl ValueSegmentTokens {
    super::impl_token_fns!(target = [opening_brace, closing_brace]);
}

/// Represents a segment in an interpolated string.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum InterpolationSegment {
    /// A literal string segment
    String(StringSegment),
    /// An expression value segment
    Value(ValueSegment),
}

impl InterpolationSegment {
    /// Clears all comments from the tokens in this node.
    pub fn clear_comments(&mut self) {
        match self {
            InterpolationSegment::String(segment) => segment.clear_comments(),
            InterpolationSegment::Value(segment) => segment.clear_comments(),
        }
    }

    /// Clears all whitespaces information from the tokens in this node.
    pub fn clear_whitespaces(&mut self) {
        match self {
            InterpolationSegment::String(segment) => segment.clear_whitespaces(),
            InterpolationSegment::Value(segment) => segment.clear_whitespaces(),
        }
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        match self {
            InterpolationSegment::String(segment) => segment.replace_referenced_tokens(code),
            InterpolationSegment::Value(segment) => segment.replace_referenced_tokens(code),
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match self {
            InterpolationSegment::String(segment) => segment.shift_token_line(amount),
            InterpolationSegment::Value(segment) => segment.shift_token_line(amount),
        }
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        match self {
            InterpolationSegment::String(segment) => segment.filter_comments(filter),
            InterpolationSegment::Value(segment) => segment.filter_comments(filter),
        }
    }
}

impl From<StringSegment> for InterpolationSegment {
    fn from(segment: StringSegment) -> Self {
        Self::String(segment)
    }
}

impl From<ValueSegment> for InterpolationSegment {
    fn from(segment: ValueSegment) -> Self {
        Self::Value(segment)
    }
}

impl<T: Into<Expression>> From<T> for InterpolationSegment {
    fn from(value: T) -> Self {
        Self::Value(ValueSegment::new(value.into()))
    }
}

impl From<&str> for InterpolationSegment {
    fn from(string: &str) -> Self {
        Self::String(StringSegment::from_value(string))
    }
}

impl From<&String> for InterpolationSegment {
    fn from(string: &String) -> Self {
        Self::String(StringSegment::from_value(string))
    }
}

impl From<String> for InterpolationSegment {
    fn from(string: String) -> Self {
        Self::String(StringSegment::from_value(string))
    }
}

/// Represents an interpolated string expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct InterpolatedStringExpression {
    segments: Vec<InterpolationSegment>,
    tokens: Option<InterpolatedStringTokens>,
}

impl InterpolatedStringExpression {
    /// Creates a new interpolated string expression with the given segments.
    pub fn new(segments: Vec<InterpolationSegment>) -> Self {
        Self {
            segments,
            tokens: None,
        }
    }

    /// Creates an empty interpolated string expression with no segments.
    pub fn empty() -> Self {
        Self::new(Vec::default())
    }

    /// Adds a segment to this interpolated string expression and returns the updated expression.
    pub fn with_segment(mut self, segment: impl Into<InterpolationSegment>) -> Self {
        self.push_segment(segment);
        self
    }

    /// Attaches tokens to this interpolated string expression.
    pub fn with_tokens(mut self, tokens: InterpolatedStringTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Returns a reference to the tokens attached to this interpolated string expression, if any.
    pub fn get_tokens(&self) -> Option<&InterpolatedStringTokens> {
        self.tokens.as_ref()
    }

    /// Attaches tokens to this interpolated string expression.
    pub fn set_tokens(&mut self, tokens: InterpolatedStringTokens) {
        self.tokens = Some(tokens);
    }

    super::impl_token_fns!(iter = [tokens, segments]);

    /// Returns an iterator over the segments in this interpolated string expression.
    pub fn iter_segments(&self) -> impl Iterator<Item = &InterpolationSegment> {
        self.segments.iter()
    }

    /// Returns a mutable iterator over the segments in this interpolated string expression.
    pub fn iter_mut_segments(&mut self) -> impl Iterator<Item = &mut InterpolationSegment> {
        self.segments.iter_mut()
    }

    /// Returns the number of segments in this interpolated string expression.
    #[inline]
    pub fn len(&self) -> usize {
        self.segments.len()
    }

    /// Returns whether this interpolated string expression is empty.
    ///
    /// An interpolated string is considered empty if it has no segments or all of its
    /// string segments are empty and it has no value segments.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.segments.iter().all(|segment| match segment {
            InterpolationSegment::String(string_segment) => string_segment.is_empty(),
            InterpolationSegment::Value(_) => false,
        })
    }

    /// Adds a segment to this interpolated string expression.
    pub fn push_segment(&mut self, segment: impl Into<InterpolationSegment>) {
        let new_segment = segment.into();
        match new_segment {
            InterpolationSegment::String(string_segment) => {
                if string_segment.get_value().is_empty() {
                    return;
                }
                if let Some(InterpolationSegment::String(last)) = self.segments.last_mut() {
                    last.append(string_segment);
                } else {
                    self.segments.push(string_segment.into());
                }
            }
            InterpolationSegment::Value(_) => {
                self.segments.push(new_segment);
            }
        }
    }

    /// Returns a mutable reference to the first token for this interpolated string,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().opening_tick
    }

    /// Returns a mutable reference to the last token for this interpolated string,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().closing_tick
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.set_tokens(InterpolatedStringTokens {
                opening_tick: Token::from_content("`"),
                closing_tick: Token::from_content("`"),
            });
        }
    }
}

impl FromIterator<InterpolationSegment> for InterpolatedStringExpression {
    fn from_iter<T: IntoIterator<Item = InterpolationSegment>>(iter: T) -> Self {
        Self {
            segments: iter.into_iter().collect(),
            tokens: None,
        }
    }
}

/// Contains token information for an interpolated string expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct InterpolatedStringTokens {
    /// The opening backtick token
    pub opening_tick: Token,
    /// The closing backtick token
    pub closing_tick: Token,
}

impl InterpolatedStringTokens {
    super::impl_token_fns!(target = [opening_tick, closing_tick]);
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn push_segment_with_empty_string_does_not_mutate() {
        let mut string = InterpolatedStringExpression::empty();
        string.push_segment("");

        pretty_assertions::assert_eq!(string, InterpolatedStringExpression::empty());
    }
}
