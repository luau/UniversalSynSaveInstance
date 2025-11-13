//! A module that contains the main [LuaGenerator](trait.LuaGenerator.html) trait
//! and its implementations.

use std::convert::TryInto;

use bstr::ByteSlice;

use crate::nodes::{
    Expression, FieldExpression, FunctionCall, IndexExpression, NumberExpression, Prefix,
    Statement, StringSegment, TableExpression, Variable,
};

const QUOTED_STRING_MAX_LENGTH: usize = 60;
const LONG_STRING_MIN_LENGTH: usize = 20;
const FORCE_LONG_STRING_NEW_LINE_THRESHOLD: usize = 6;

#[inline]
pub fn should_break_with_space(ending_character: char, next_character: char) -> bool {
    match ending_character {
        '0'..='9' => matches!(next_character, '0'..='9' | 'A'..='Z' | 'a'..='z' | '_' | '.'),
        'A'..='Z' | 'a'..='z' | '_' => {
            next_character.is_ascii_alphanumeric() || next_character == '_'
        }
        '>' => next_character == '=',
        '-' => next_character == '-',
        '[' => next_character == '[',
        ']' => next_character == ']',
        '.' => matches!(next_character, '.' | '0'..='9'),
        _ => false,
    }
}

pub fn break_long_string(last_str: &str) -> bool {
    if let Some(last_char) = last_str.chars().last() {
        last_char == '['
    } else {
        false
    }
}

pub fn break_variable_arguments(last_string: &str) -> bool {
    if let Some('.') = last_string.chars().last() {
        true
    } else if let Some(first_char) = last_string.chars().next() {
        first_char == '.' || first_char.is_ascii_digit()
    } else {
        false
    }
}

pub fn break_minus(last_string: &str) -> bool {
    if let Some(last_char) = last_string.chars().last() {
        last_char == '-'
    } else {
        false
    }
}

pub fn break_equal(last_string: &str) -> bool {
    if let Some(last_char) = last_string.chars().last() {
        last_char == '>'
    } else {
        false
    }
}

pub fn break_concat(last_string: &str) -> bool {
    if let Some('.') = last_string.chars().last() {
        true
    } else if let Some(first_char) = last_string.chars().next() {
        first_char == '.' || first_char.is_ascii_digit()
    } else {
        false
    }
}

pub fn ends_with_prefix(statement: &Statement) -> bool {
    match statement {
        Statement::Assign(assign) => {
            if let Some(value) = assign.last_value() {
                expression_ends_with_prefix(value)
            } else {
                false
            }
        }
        Statement::CompoundAssign(assign) => expression_ends_with_prefix(assign.get_value()),
        Statement::Call(_) => true,
        Statement::Repeat(repeat) => expression_ends_with_prefix(repeat.get_condition()),
        Statement::LocalAssign(assign) => {
            if let Some(value) = assign.last_value() {
                expression_ends_with_prefix(value)
            } else {
                false
            }
        }
        _ => false,
    }
}

pub fn starts_with_table(mut expression: &Expression) -> Option<&TableExpression> {
    loop {
        match expression {
            Expression::Table(table) => break Some(table),
            Expression::Binary(binary) => {
                expression = binary.left();
            }
            Expression::Call(_)
            | Expression::False(_)
            | Expression::Field(_)
            | Expression::Function(_)
            | Expression::Identifier(_)
            | Expression::If(_)
            | Expression::Index(_)
            | Expression::Nil(_)
            | Expression::Number(_)
            | Expression::Parenthese(_)
            | Expression::String(_)
            | Expression::InterpolatedString(_)
            | Expression::True(_)
            | Expression::Unary(_)
            | Expression::VariableArguments(_) => break None,
            Expression::TypeCast(type_cast) => {
                expression = type_cast.get_expression();
            }
        }
    }
}

pub fn starts_with_parenthese(statement: &Statement) -> bool {
    match statement {
        Statement::Assign(assign) => {
            if let Some(variable) = assign.get_variables().first() {
                match variable {
                    Variable::Identifier(_) => false,
                    Variable::Field(field) => field_starts_with_parenthese(field),
                    Variable::Index(index) => index_starts_with_parenthese(index),
                }
            } else {
                false
            }
        }
        Statement::CompoundAssign(assign) => match assign.get_variable() {
            Variable::Identifier(_) => false,
            Variable::Field(field) => field_starts_with_parenthese(field),
            Variable::Index(index) => index_starts_with_parenthese(index),
        },
        Statement::Call(call) => call_starts_with_parenthese(call),
        _ => false,
    }
}

fn expression_ends_with_prefix(expression: &Expression) -> bool {
    match expression {
        Expression::Binary(binary) => expression_ends_with_prefix(binary.right()),
        Expression::Call(_)
        | Expression::Parenthese(_)
        | Expression::Identifier(_)
        | Expression::Field(_)
        | Expression::Index(_) => true,
        Expression::Unary(unary) => expression_ends_with_prefix(unary.get_expression()),
        Expression::If(if_expression) => {
            expression_ends_with_prefix(if_expression.get_else_result())
        }
        Expression::False(_)
        | Expression::Function(_)
        | Expression::Nil(_)
        | Expression::Number(_)
        | Expression::String(_)
        | Expression::InterpolatedString(_)
        | Expression::Table(_)
        | Expression::True(_)
        | Expression::VariableArguments(_)
        | Expression::TypeCast(_) => false,
    }
}

fn prefix_starts_with_parenthese(prefix: &Prefix) -> bool {
    match prefix {
        Prefix::Parenthese(_) => true,
        Prefix::Call(call) => call_starts_with_parenthese(call),
        Prefix::Field(field) => field_starts_with_parenthese(field),
        Prefix::Index(index) => index_starts_with_parenthese(index),
        Prefix::Identifier(_) => false,
    }
}

#[inline]
fn call_starts_with_parenthese(call: &FunctionCall) -> bool {
    prefix_starts_with_parenthese(call.get_prefix())
}

#[inline]
fn field_starts_with_parenthese(field: &FieldExpression) -> bool {
    prefix_starts_with_parenthese(field.get_prefix())
}

#[inline]
fn index_starts_with_parenthese(index: &IndexExpression) -> bool {
    prefix_starts_with_parenthese(index.get_prefix())
}

pub fn write_number(number: &NumberExpression) -> String {
    match number {
        NumberExpression::Decimal(number) => {
            let float = number.get_raw_float();
            #[allow(clippy::if_same_then_else)]
            if float.is_nan() {
                "(0/0)".to_owned()
            } else if float.is_infinite() {
                format!("({}1/0)", if float.is_sign_negative() { "-" } else { "" })
            } else if let Some(exponent) = number
                .get_exponent()
                .map(TryInto::try_into)
                .and_then(Result::ok)
            {
                let mantissa: f64 = float / 10.0_f64.powi(exponent);

                let formatted = format!(
                    "{}{}{}",
                    mantissa,
                    if number.is_uppercase().unwrap_or_default() {
                        "E"
                    } else {
                        "e"
                    },
                    exponent
                );

                // verify if we did not lose any precision
                if formatted.parse::<f64>() == Ok(float) {
                    formatted
                } else if number.is_uppercase().unwrap_or_default() {
                    format!("{:E}", float)
                } else {
                    format!("{:e}", float)
                }
            } else if float.fract() == 0.0 {
                format!("{}", float)
            } else {
                format!("{:.}", float)
            }
        }
        NumberExpression::Hex(number) => {
            format!(
                "0{}{:x}{}",
                if number.is_x_uppercase() { 'X' } else { 'x' },
                number.get_raw_integer(),
                number
                    .get_exponent()
                    .map(|exponent| {
                        let exponent_char = number
                            .is_exponent_uppercase()
                            .map(|is_uppercase| if is_uppercase { 'P' } else { 'p' })
                            .unwrap_or('p');
                        format!("{}{}", exponent_char, exponent)
                    })
                    .unwrap_or_else(|| "".to_owned())
            )
        }
        NumberExpression::Binary(number) => {
            format!(
                "0{}{:b}",
                if number.is_b_uppercase() { 'B' } else { 'b' },
                number.get_raw_value()
            )
        }
    }
}

fn needs_escaping(character: u8) -> bool {
    !(character.is_ascii_graphic() || character == b' ') || character == b'\\'
}

fn needs_quoted_string(character: &u8) -> bool {
    !(character.is_ascii_graphic() || *character == b' ' || *character == b'\n')
}

fn escape(character: u8, next_character: Option<u8>) -> String {
    match character {
        b'\n' => "\\n".to_owned(),
        b'\t' => "\\t".to_owned(),
        b'\\' => "\\\\".to_owned(),
        b'\r' => "\\r".to_owned(),
        b'\x07' => "\\a".to_owned(),
        b'\x08' => "\\b".to_owned(),
        b'\x0B' => "\\v".to_owned(),
        b'\x0C' => "\\f".to_owned(),
        character => {
            if next_character.filter(|c: &u8| c.is_ascii_digit()).is_some() {
                format!("\\{:03}", character)
            } else {
                format!("\\{}", character)
            }
        }
    }
}

#[inline]
pub fn count_new_lines(string: &[u8]) -> usize {
    string.iter().filter(|c| **c == b'\n').count()
}

pub fn write_string(value: &[u8]) -> String {
    if value.is_empty() {
        return "''".to_owned();
    }

    if value.len() == 1 {
        let character = value
            .iter()
            .next()
            .expect("string should have at least one character");
        match *character {
            b'\'' => return "\"'\"".to_owned(),
            b'"' => return "'\"'".to_owned(),
            character => {
                if needs_escaping(character) {
                    return format!("'{}'", escape(character, None));
                } else {
                    return format!("'{}'", character as char);
                }
            }
        }
    }

    if !value.iter().any(needs_quoted_string)
        && value.len() >= LONG_STRING_MIN_LENGTH
        && (value.len() >= QUOTED_STRING_MAX_LENGTH
            || count_new_lines(value) >= FORCE_LONG_STRING_NEW_LINE_THRESHOLD)
    {
        write_long_bracket(value).unwrap_or_else(|| write_quoted(value))
    } else {
        write_quoted(value)
    }
}

pub fn write_interpolated_string_segment(segment: &StringSegment) -> String {
    let value = segment.get_value();

    if value.is_empty() {
        return "".to_owned();
    }

    let mut result = String::new();

    result.reserve(value.len());

    for (character, next_character) in iter_with_next(value, value) {
        match character {
            b'`' | b'{' => {
                result.push('\\');
                result.push(*character as char);
            }
            _ if needs_escaping(*character) => {
                result.push_str(&escape(*character, next_character.copied()));
            }
            _ => {
                result.push(*character as char);
            }
        }
    }

    result
}

fn iter_with_next<T>(
    value: impl IntoIterator<Item = T>,
    same_iterable: impl IntoIterator<Item = T>,
) -> impl Iterator<Item = (T, Option<T>)> {
    value.into_iter().zip(
        same_iterable
            .into_iter()
            .skip(1)
            .map(Some)
            .chain(std::iter::once(None)),
    )
}

fn write_long_bracket(value: &[u8]) -> Option<String> {
    let stringified = str::from_utf8(value).ok()?;

    let mut i: usize = value.ends_with(b"]").into();
    let mut equals = b"=".repeat(i);
    equals.insert(0, b']');
    equals.push(b']');

    loop {
        if value.find(&equals).is_none() {
            break;
        } else {
            i += 1;
            equals[i] = b'=';
            equals.push(b']');
        };
    }
    let needs_extra_new_line = if value.starts_with(b"\n") { "\n" } else { "" };
    let equal_signs = "=".repeat(i);

    Some(format!(
        "[{}[{}{}]{}]",
        equal_signs, needs_extra_new_line, stringified, equal_signs
    ))
}

fn write_quoted(value: &[u8]) -> String {
    let mut quoted = String::new();
    quoted.reserve(value.len() + 2);

    let quote_symbol = get_quote_symbol(value);
    quoted.push(quote_symbol);

    if let Ok(stringified) = str::from_utf8(value) {
        for (character, next_character) in iter_with_next(stringified.chars(), stringified.chars())
        {
            if character == quote_symbol {
                quoted.push('\\');
                quoted.push(quote_symbol);
            } else if !character.is_ascii() || needs_escaping(character as u8) {
                if character.is_ascii() {
                    quoted.push_str(&escape(character as u8, next_character.map(|c| c as u8)));
                } else {
                    quoted.push_str("\\u{");
                    quoted.push_str(&format!("{:x}", character as u32));
                    quoted.push('}');
                }
            } else {
                quoted.push(character);
            }
        }
    } else {
        for (character, next_character) in iter_with_next(value, value) {
            if *character == quote_symbol as u8 {
                quoted.push('\\');
                quoted.push(quote_symbol);
            } else if needs_escaping(*character) {
                quoted.push_str(&escape(*character, next_character.copied()));
            } else {
                quoted.push(*character as char);
            }
        }
    }

    quoted.push(quote_symbol);
    quoted.shrink_to_fit();
    quoted
}

fn get_quote_symbol(value: &[u8]) -> char {
    if value.contains(&b'"') {
        '\''
    } else if value.contains(&b'\'') {
        '"'
    } else {
        '\''
    }
}

#[cfg(test)]
mod test {
    use super::*;

    mod write_string {
        use super::*;

        macro_rules! test_output {
            ($($name:ident($input:literal) => $value:literal),* $(,)?) => {
                $(
                    #[test]
                    fn $name() {
                        assert_eq!($value, write_string($input.as_bytes()));
                    }
                )*
            };
        }

        test_output!(
            empty("") => "''",
            single_letter("a") => "'a'",
            single_digit("8") => "'8'",
            single_symbol("!") => "'!'",
            single_space(" ") => "' '",
            abc("abc") => "'abc'",
            three_spaces("   ") => "'   '",
            new_line("\n") => "'\\n'",
            bell("\u{7}") => "'\\a'",
            backspace("\u{8}") => "'\\b'",
            form_feed("\u{c}") => "'\\f'",
            tab("\t") => "'\\t'",
            carriage_return("\u{D}") => "'\\r'",
            vertical_tab("\u{B}") => "'\\v'",
            backslash("\\") => "'\\\\'",
            single_quote("'") => "\"'\"",
            double_quote("\"") => "'\"'",
            null("\0") => "'\\0'",
            escape_as_digits("\u{1B}") => "'\\27'",
            escape_as_digits_followed_by_digit("\u{1B}0") => "'\\0270'",
            escape_as_single_digit_followed_by_digit("\u{1}0") => "'\\0010'",
            extended_ascii("\u{C3}") => "'\\u{c3}'",
            unicode("\u{25C1}") => "'\\u{25c1}'",
            escape_degree_symbol("°") => "'\\u{b0}'",
            im_cool("I'm cool") => "\"I'm cool\"",
            ends_with_closing_bracket("oof]") => "'oof]'",
            multiline_ends_with_closing_bracket("oof\noof]") => "'oof\\noof]'",
            large_multiline_does_not_end_with_closing_bracket("ooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof")
                => "[[ooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof]]",
            large_multiline_ends_with_closing_bracket("ooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof]")
                => "[=[ooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof]]=]",
            large_multiline_starts_with_new_line("\nooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof")
                => "[[\n\nooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof]]",

            large_multiline_with_unicode("\nooof\nooof\nooof\nooof\nooof\nooof\nooof\nooof\noof\u{10FFFF}")
                => "'\\nooof\\nooof\\nooof\\nooof\\nooof\\nooof\\nooof\\nooof\\noof\\u{10ffff}'",
        );
    }
}
