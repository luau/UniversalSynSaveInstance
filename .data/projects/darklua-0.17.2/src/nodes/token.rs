use std::borrow::Cow;

/// Represents a position in the source code.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Position {
    /// A position that references a specific range in the source code
    /// with line number information.
    LineNumberReference {
        start: usize,
        end: usize,
        line_number: usize,
    },
    /// A position that contains content and line number information.
    LineNumber {
        content: Cow<'static, str>,
        line_number: usize,
    },
    /// A position that only contains content without any line number
    /// information.
    Any { content: Cow<'static, str> },
}

impl Position {
    /// Creates a new position with line number information and content.
    #[inline]
    pub fn line_number(content: impl Into<Cow<'static, str>>, line_number: usize) -> Position {
        Self::LineNumber {
            content: content.into(),
            line_number,
        }
    }
}

/// An enum to represent source code text.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TriviaKind {
    /// A comment.
    Comment,
    /// Whitespace characters.
    Whitespace,
}

impl TriviaKind {
    /// Creates a new trivia with line number reference information.
    pub fn at(self, start: usize, end: usize, line_number: usize) -> Trivia {
        Trivia {
            position: Position::LineNumberReference {
                start,
                end,
                line_number,
            },
            kind: self,
        }
    }

    /// Creates a new trivia with content.
    pub fn with_content<IntoCowStr: Into<Cow<'static, str>>>(self, content: IntoCowStr) -> Trivia {
        Trivia {
            position: Position::Any {
                content: content.into(),
            },
            kind: self,
        }
    }
}

/// Represents a piece of trivia (whitespace or comments) in the source code.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Trivia {
    position: Position,
    kind: TriviaKind,
}

impl Trivia {
    /// Reads the content of the trivia from the source code.
    ///
    /// # Panics
    /// Panics if the position is a line number reference and the range is invalid.
    pub fn read<'a: 'b, 'b>(&'a self, code: &'b str) -> &'b str {
        match &self.position {
            Position::LineNumberReference { start, end, .. } => {
                code.get(*start..*end).unwrap_or_else(|| {
                    panic!("unable to extract code from position: {} - {}", start, end);
                })
            }
            Position::LineNumber { content, .. } | Position::Any { content } => content,
        }
    }

    /// Attempts to read the content of the trivia without requiring source code.
    ///
    /// Returns `None` if the position is a line number reference, as it requires source code to read.
    pub fn try_read(&self) -> Option<&str> {
        match &self.position {
            Position::LineNumberReference { .. } => None,
            Position::LineNumber { content, .. } | Position::Any { content } => Some(content),
        }
    }

    /// Returns the kind of trivia.
    pub fn kind(&self) -> TriviaKind {
        self.kind.clone()
    }

    /// Returns the line number of the trivia, if available.
    pub fn get_line_number(&self) -> Option<usize> {
        match &self.position {
            Position::LineNumber { line_number, .. }
            | Position::LineNumberReference { line_number, .. } => Some(*line_number),
            Position::Any { .. } => None,
        }
    }
}

/// Represents a token in the source code with its position and associated comments or whitespaces.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Token {
    position: Position,
    leading_trivia: Vec<Trivia>,
    trailing_trivia: Vec<Trivia>,
}

impl Token {
    /// Creates a token where the position refers to the original code where
    /// the token was parsed with the line number where it starts.
    pub fn new_with_line(start: usize, end: usize, line_number: usize) -> Self {
        Self {
            position: Position::LineNumberReference {
                start,
                end,
                line_number,
            },
            leading_trivia: Vec::new(),
            trailing_trivia: Vec::new(),
        }
    }

    /// Creates a new token that is not constrained to any existing position.
    pub fn from_content<IntoCowStr: Into<Cow<'static, str>>>(content: IntoCowStr) -> Self {
        Self {
            position: Position::Any {
                content: content.into(),
            },
            leading_trivia: Vec::new(),
            trailing_trivia: Vec::new(),
        }
    }

    /// Creates a new token from a position.
    pub fn from_position(position: Position) -> Self {
        Self {
            position,
            leading_trivia: Vec::new(),
            trailing_trivia: Vec::new(),
        }
    }

    /// Adds leading trivia to the token and returns the updated token.
    pub fn with_leading_trivia(mut self, trivia: Trivia) -> Self {
        self.leading_trivia.push(trivia);
        self
    }

    /// Adds trailing trivia to the token and returns the updated token.
    pub fn with_trailing_trivia(mut self, trivia: Trivia) -> Self {
        self.trailing_trivia.push(trivia);
        self
    }

    /// Returns whether the token has any trivia (leading or trailing).
    #[inline]
    pub fn has_trivia(&self) -> bool {
        !self.leading_trivia.is_empty() || !self.trailing_trivia.is_empty()
    }

    /// Adds leading trivia to the token.
    #[inline]
    pub fn push_leading_trivia(&mut self, trivia: Trivia) {
        self.leading_trivia.push(trivia);
    }

    /// Inserts leading trivia at the given index.
    pub fn insert_leading_trivia(&mut self, index: usize, trivia: Trivia) {
        if index > self.leading_trivia.len() {
            self.leading_trivia.push(trivia);
        } else {
            self.leading_trivia.insert(index, trivia);
        }
    }

    /// Adds trailing trivia to the token.
    #[inline]
    pub fn push_trailing_trivia(&mut self, trivia: Trivia) {
        self.trailing_trivia.push(trivia);
    }

    /// Returns an iterator over the leading trivia.
    #[inline]
    pub fn iter_leading_trivia(&self) -> impl Iterator<Item = &Trivia> {
        self.leading_trivia.iter()
    }

    /// Returns an iterator over the leading trivia and removes them from the token.
    #[inline]
    pub fn drain_leading_trivia(&mut self) -> impl Iterator<Item = Trivia> + '_ {
        self.leading_trivia.drain(..)
    }

    /// Returns an iterator over the trailing trivia.
    #[inline]
    pub fn iter_trailing_trivia(&self) -> impl Iterator<Item = &Trivia> {
        self.trailing_trivia.iter()
    }

    /// Returns an iterator over the trailing trivia and removes them from the token.
    #[inline]
    pub fn drain_trailing_trivia(&mut self) -> impl Iterator<Item = Trivia> + '_ {
        self.trailing_trivia.drain(..)
    }

    /// Reads the content of the token from the source code.
    ///
    /// # Panics
    /// Panics if the position is a line number reference and the range is invalid.
    pub fn read<'a: 'b, 'b>(&'a self, code: &'b str) -> &'b str {
        match &self.position {
            Position::LineNumberReference { start, end, .. } => code
                .get(*start..*end)
                .expect("unable to extract code from position"),
            Position::LineNumber { content, .. } | Position::Any { content } => content,
        }
    }

    /// Returns the line number of the token, if available.
    pub fn get_line_number(&self) -> Option<usize> {
        match &self.position {
            Position::LineNumber { line_number, .. }
            | Position::LineNumberReference { line_number, .. } => Some(*line_number),
            Position::Any { .. } => None,
        }
    }

    /// Replaces the token's content with new content while preserving line number information.
    pub fn replace_with_content<IntoCowStr: Into<Cow<'static, str>>>(
        &mut self,
        content: IntoCowStr,
    ) {
        self.position = match &self.position {
            Position::LineNumber { line_number, .. }
            | Position::LineNumberReference { line_number, .. } => Position::LineNumber {
                line_number: *line_number,
                content: content.into(),
            },

            Position::Any { .. } => Position::Any {
                content: content.into(),
            },
        };
    }

    /// Clears all comments from the tokens in this node.
    pub fn clear_comments(&mut self) {
        self.leading_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Comment);
        self.trailing_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Comment);
    }

    /// Clears all whitespaces information from the tokens in this node.
    pub fn clear_whitespaces(&mut self) {
        self.leading_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Whitespace);
        self.trailing_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Whitespace);
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        self.leading_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Comment || filter(trivia));
        self.trailing_trivia
            .retain(|trivia| trivia.kind() != TriviaKind::Comment || filter(trivia));
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        if let Position::LineNumberReference {
            start,
            end,
            line_number,
        } = self.position
        {
            self.position = Position::LineNumber {
                line_number,
                content: code
                    .get(start..end)
                    .expect("unable to extract code from position")
                    .to_owned()
                    .into(),
            }
        };
        for trivia in self
            .leading_trivia
            .iter_mut()
            .chain(self.trailing_trivia.iter_mut())
        {
            if let Position::LineNumberReference {
                start,
                end,
                line_number,
            } = trivia.position
            {
                trivia.position = Position::LineNumber {
                    line_number,
                    content: code
                        .get(start..end)
                        .expect("unable to extract code from position")
                        .to_owned()
                        .into(),
                }
            };
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match &mut self.position {
            Position::LineNumberReference { line_number, .. }
            | Position::LineNumber { line_number, .. } => {
                *line_number = line_number.saturating_add_signed(amount);
            }
            Position::Any { .. } => {}
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn read_line_number_reference_token() {
        let code = "return true";
        let token = Token::new_with_line(7, 11, 1);

        assert_eq!("true", token.read(code));
    }

    #[test]
    fn read_any_position_token() {
        let token = Token::from_content("true");

        assert_eq!("true", token.read(""));
    }
}
