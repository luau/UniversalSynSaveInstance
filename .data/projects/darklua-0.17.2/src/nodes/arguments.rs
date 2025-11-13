use std::{iter, mem};

use crate::nodes::{Expression, StringExpression, TableExpression, Token};

/// Tokens associated with tuple arguments.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TupleArgumentsTokens {
    pub opening_parenthese: Token,
    pub closing_parenthese: Token,
    pub commas: Vec<Token>,
}

impl TupleArgumentsTokens {
    super::impl_token_fns!(
        target = [opening_parenthese, closing_parenthese]
        iter = [commas]
    );
}

/// Represents a list of arguments enclosed in parentheses.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct TupleArguments {
    values: Vec<Expression>,
    tokens: Option<TupleArgumentsTokens>,
}

impl TupleArguments {
    /// Creates a new tuple of arguments with the given expressions.
    pub fn new(values: Vec<Expression>) -> Self {
        Self {
            values,
            tokens: None,
        }
    }

    /// Converts this tuple into expressions.
    #[inline]
    pub fn to_expressions(self) -> Vec<Expression> {
        self.values
    }

    /// Sets the tokens for this tuple.
    pub fn with_tokens(mut self, tokens: TupleArgumentsTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this tuple.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TupleArgumentsTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this tuple, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TupleArgumentsTokens> {
        self.tokens.as_ref()
    }

    /// Adds an argument to this tuple.
    pub fn with_argument<T: Into<Expression>>(mut self, argument: T) -> Self {
        self.push(argument.into());
        self
    }

    /// Pushes an argument to this tuple.
    pub fn push(&mut self, argument: impl Into<Expression>) {
        let argument = argument.into();
        let initial_len = self.values.len();

        self.values.push(argument);

        if initial_len != 0 {
            if let Some(tokens) = &mut self.tokens {
                if tokens.commas.len() == initial_len - 1 {
                    tokens.commas.push(Token::from_content(","));
                }
            }
        }
    }

    /// Inserts an argument at the specified index.
    pub fn insert(&mut self, index: usize, argument: impl Into<Expression>) {
        if index >= self.values.len() {
            self.push(argument.into());
        } else {
            self.values.insert(index, argument.into());

            if let Some(tokens) = &mut self.tokens {
                if index <= tokens.commas.len() {
                    tokens.commas.insert(index, Token::from_content(","));
                }
            }
        }
    }

    /// Returns a mutable reference to the last token of this tuple of arguments,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        if self.get_tokens().is_none() {
            self.set_tokens(TupleArgumentsTokens {
                opening_parenthese: Token::from_content("("),
                closing_parenthese: Token::from_content(")"),
                commas: (0..self.len().saturating_sub(1))
                    .map(|_| Token::from_content(","))
                    .collect(),
            });
        }
        &mut self.tokens.as_mut().unwrap().closing_parenthese
    }

    /// Returns the number of arguments in this tuple.
    #[inline]
    pub fn len(&self) -> usize {
        self.values.len()
    }

    /// Returns whether this tuple has no arguments.
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.values.is_empty()
    }

    /// Returns an iterator over the argument expressions.
    #[inline]
    pub fn iter_values(&self) -> impl Iterator<Item = &Expression> {
        self.values.iter()
    }

    /// Returns a mutable iterator over the argument expressions.
    #[inline]
    pub fn iter_mut_values(&mut self) -> impl Iterator<Item = &mut Expression> {
        self.values.iter_mut()
    }

    super::impl_token_fns!(iter = [tokens]);
}

impl From<Arguments> for TupleArguments {
    fn from(arguments: Arguments) -> Self {
        match arguments {
            Arguments::Tuple(tuple) => tuple,
            Arguments::String(string) => TupleArguments::default().with_argument(string),
            Arguments::Table(table) => TupleArguments::default().with_argument(table),
        }
    }
}

impl iter::FromIterator<Expression> for TupleArguments {
    fn from_iter<T: IntoIterator<Item = Expression>>(iter: T) -> Self {
        Self {
            values: iter.into_iter().collect(),
            tokens: None,
        }
    }
}

/// Represents the different ways arguments can be passed to a function call.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Arguments {
    /// Multiple arguments in parentheses: `func(arg1, arg2)`
    Tuple(TupleArguments),
    /// A single string argument without parentheses: `func "string"`
    String(StringExpression),
    /// A single table argument without parentheses: `func {key=value}`
    Table(TableExpression),
}

impl Arguments {
    /// Returns the total number of arguments.
    #[inline]
    pub fn len(&self) -> usize {
        match self {
            Self::Tuple(tuple) => tuple.len(),
            Self::String(_) | Self::Table(_) => 1,
        }
    }

    /// Returns true if this is an empty tuple of arguments.
    #[inline]
    pub fn is_empty(&self) -> bool {
        match self {
            Self::Tuple(tuple) => tuple.is_empty(),
            Self::String(_) | Self::Table(_) => false,
        }
    }

    /// Converts these arguments into a vector of expressions.
    pub fn to_expressions(self) -> Vec<Expression> {
        match self {
            Self::Tuple(expressions) => expressions.to_expressions(),
            Self::String(string) => vec![string.into()],
            Self::Table(table) => vec![table.into()],
        }
    }

    /// Adds an argument to these arguments, converting to a tuple if needed.
    pub fn with_argument<T: Into<Expression>>(self, argument: T) -> Self {
        TupleArguments::from(self).with_argument(argument).into()
    }

    /// Pushes an argument to these arguments, converting to a tuple if needed.
    pub fn push(&mut self, argument: impl Into<Expression>) {
        let argument = argument.into();

        let tuple_args = match self {
            Arguments::Tuple(tuple) => {
                tuple.push(argument);
                return;
            }
            Arguments::String(value) => TupleArguments::default()
                .with_argument(mem::replace(value, StringExpression::empty())),
            Arguments::Table(value) => TupleArguments::default().with_argument(mem::take(value)),
        };

        *self = tuple_args.with_argument(argument).into();
    }

    /// Inserts an argument at the specified index, converting to a tuple if needed.
    pub fn insert(&mut self, index: usize, argument: impl Into<Expression>) {
        let argument = argument.into();

        let mut tuple_args = match self {
            Arguments::Tuple(tuple) => {
                tuple.insert(index, argument);
                return;
            }
            Arguments::String(value) => {
                let string = mem::replace(value, StringExpression::empty());
                TupleArguments::default().with_argument(Expression::from(string))
            }
            Arguments::Table(value) => {
                let table = mem::take(value);
                TupleArguments::default().with_argument(Expression::from(table))
            }
        };

        tuple_args.insert(index, argument);

        *self = tuple_args.into();
    }

    /// Returns a mutable reference to the last token of these arguments,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        match self {
            Arguments::Tuple(tuple) => tuple.mutate_last_token(),
            Arguments::String(string) => string.mutate_or_insert_token(),
            Arguments::Table(table) => table.mutate_last_token(),
        }
    }

    /// Removes all comments from these arguments.
    pub fn clear_comments(&mut self) {
        match self {
            Arguments::Tuple(tuple) => tuple.clear_comments(),
            Arguments::String(_) | Arguments::Table(_) => {}
        }
    }

    /// Removes all whitespace from these arguments.
    pub fn clear_whitespaces(&mut self) {
        match self {
            Arguments::Tuple(tuple) => tuple.clear_whitespaces(),
            Arguments::String(_) | Arguments::Table(_) => {}
        }
    }

    /// Replaces referenced tokens with the actual content from the source code.
    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        match self {
            Arguments::Tuple(tuple) => tuple.replace_referenced_tokens(code),
            Arguments::String(_) | Arguments::Table(_) => {}
        }
    }

    /// Shifts token line numbers by the specified amount.
    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match self {
            Arguments::Tuple(tuple) => tuple.shift_token_line(amount),
            Arguments::String(_) | Arguments::Table(_) => {}
        }
    }

    /// Filters comments using the provided predicate.
    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&super::Trivia) -> bool) {
        match self {
            Arguments::Tuple(tuple) => tuple.filter_comments(filter),
            Arguments::String(_) | Arguments::Table(_) => {}
        }
    }
}

impl Default for Arguments {
    fn default() -> Self {
        Self::Tuple(TupleArguments::default())
    }
}

impl From<TupleArguments> for Arguments {
    fn from(tuple: TupleArguments) -> Self {
        Self::Tuple(tuple)
    }
}

impl From<TableExpression> for Arguments {
    fn from(table: TableExpression) -> Self {
        Self::Table(table)
    }
}

impl From<StringExpression> for Arguments {
    fn from(string: StringExpression) -> Self {
        Self::String(string)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{
        nodes::{Identifier, Statement},
        Parser,
    };

    fn parse_arguments_with_tokens(lua: &str) -> Arguments {
        let parser = Parser::default().preserve_tokens();

        let code = format!("f {}", lua);

        let block = parser.parse(&code).expect("code should parse");
        if let Some(Statement::Call(call)) = block.first_statement() {
            return call.get_arguments().clone();
        }
        panic!("failed to parse call arguments from: {}", lua);
    }

    fn get_tuple_tokens(args: &Arguments) -> &TupleArgumentsTokens {
        match args {
            Arguments::Tuple(tuple) => tuple.get_tokens().expect("tuple should have tokens"),
            Arguments::String(_) | Arguments::Table(_) => panic!("expected tuple arguments"),
        }
    }

    fn expect_comma_tokens(args: &Arguments, index: usize) {
        let tokens = get_tuple_tokens(args);
        assert_eq!(tokens.commas[index], Token::from_content(","));
    }

    mod arguments_len {
        use super::*;

        #[test]
        fn empty_tuple() {
            let empty_tuple = Arguments::Tuple(TupleArguments::new(vec![]));
            assert_eq!(empty_tuple.len(), 0);
        }

        #[test]
        fn single_tuple() {
            let single_tuple = Arguments::Tuple(TupleArguments::new(vec![Expression::Identifier(
                Identifier::new("x"),
            )]));
            assert_eq!(single_tuple.len(), 1);
        }

        #[test]
        fn multi_tuple() {
            let multi_tuple = Arguments::Tuple(TupleArguments::new(vec![
                Expression::Identifier(Identifier::new("x")),
                Expression::Identifier(Identifier::new("y")),
                Expression::Identifier(Identifier::new("z")),
            ]));
            assert_eq!(multi_tuple.len(), 3);
        }

        #[test]
        fn string() {
            let string_args = Arguments::String(StringExpression::from_value("test"));
            assert_eq!(string_args.len(), 1);
        }

        #[test]
        fn table() {
            let table_args = Arguments::Table(TableExpression::new(vec![]));
            assert_eq!(table_args.len(), 1);
        }
    }

    mod arguments_is_empty {
        use super::*;

        #[test]
        fn empty_tuple() {
            let empty_tuple = Arguments::Tuple(TupleArguments::new(vec![]));
            assert!(empty_tuple.is_empty());
        }

        #[test]
        fn single_tuple() {
            let single_tuple = Arguments::Tuple(TupleArguments::new(vec![Expression::Identifier(
                Identifier::new("x"),
            )]));
            assert!(!single_tuple.is_empty());
        }

        #[test]
        fn multi_tuple() {
            let multi_tuple = Arguments::Tuple(TupleArguments::new(vec![
                Expression::Identifier(Identifier::new("x")),
                Expression::Identifier(Identifier::new("y")),
            ]));
            assert!(!multi_tuple.is_empty());
        }

        #[test]
        fn string() {
            let string_args = Arguments::String(StringExpression::from_value("test"));
            assert!(!string_args.is_empty());
        }

        #[test]
        fn table() {
            let table_args = Arguments::Table(TableExpression::new(vec![]));
            assert!(!table_args.is_empty());
        }
    }

    #[test]
    fn push_argument_handles_commas() {
        let mut args = parse_arguments_with_tokens("()");

        args.push(Identifier::new("first"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 0);

        args.push(Identifier::new("second"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 1);
        expect_comma_tokens(&args, 0);

        args.push(Identifier::new("third"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 2);
        expect_comma_tokens(&args, 1);
    }

    #[test]
    fn insert_argument_handles_commas() {
        let mut args = parse_arguments_with_tokens("(first, third)");

        args.insert(1, Identifier::new("second"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 2);
        expect_comma_tokens(&args, 1);

        args.insert(3, Identifier::new("fourth"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 3);

        args.insert(0, Identifier::new("zero"));
        assert_eq!(get_tuple_tokens(&args).commas.len(), 4);
    }
}
