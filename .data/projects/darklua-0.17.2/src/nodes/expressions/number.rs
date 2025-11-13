use std::fmt::{Display, Formatter, Result as FmtResult};
use std::str::FromStr;

use crate::generator::utils::write_number;
use crate::nodes::{Token, Trivia};

/// Represents a decimal number.
#[derive(Clone, Debug, PartialEq)]
pub struct DecimalNumber {
    float: f64,
    exponent: Option<(i64, bool)>,
    token: Option<Token>,
}

impl Eq for DecimalNumber {}

impl DecimalNumber {
    /// Creates a new decimal number with the given floating-point value.
    pub fn new(value: f64) -> Self {
        Self {
            float: value,
            exponent: None,
            token: None,
        }
    }

    /// Attaches a token to this decimal number.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Attaches a token to this decimal number.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the token attached to this decimal number, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the token attached to this decimal number, if any.
    #[inline]
    pub fn mutate_token(&mut self) -> Option<&mut Token> {
        self.token.as_mut()
    }

    /// Sets an exponent for this decimal number and returns the updated number.
    ///
    /// The `is_uppercase` parameter determines whether the exponent uses uppercase 'E'
    /// or lowercase 'e' notation.
    pub fn with_exponent(mut self, exponent: i64, is_uppercase: bool) -> Self {
        self.exponent.replace((exponent, is_uppercase));
        self
    }

    /// Sets whether the exponent notation should use uppercase 'E' or lowercase 'e'.
    #[inline]
    pub fn set_uppercase(&mut self, is_uppercase: bool) {
        self.exponent = self.exponent.map(|(exponent, _)| (exponent, is_uppercase));
    }

    /// Returns the raw floating-point value of this decimal number.
    #[inline]
    pub(crate) fn get_raw_float(&self) -> f64 {
        self.float
    }

    /// Returns whether the exponent notation uses uppercase 'E', if an exponent is present.
    #[inline]
    pub fn is_uppercase(&self) -> Option<bool> {
        self.exponent.map(|(_, uppercase)| uppercase)
    }

    /// Returns the exponent value, if one is present.
    #[inline]
    pub fn get_exponent(&self) -> Option<i64> {
        self.exponent.map(|(exponent, _)| exponent)
    }

    /// Computes the actual numerical value represented by this decimal number.
    pub fn compute_value(&self) -> f64 {
        self.float
    }

    super::impl_token_fns!(iter = [token]);
}

/// Represents a hexadecimal number.
///
/// Hexadecimal numbers are prefixed with '0x' or '0X' and can include
/// optional binary exponents.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HexNumber {
    integer: u64,
    exponent: Option<(u32, bool)>,
    is_x_uppercase: bool,
    token: Option<Token>,
}

impl HexNumber {
    /// Creates a new hexadecimal number with the given integer value.
    ///
    /// The `is_x_uppercase` parameter determines whether the hexadecimal prefix
    /// uses uppercase 'X' (0X) or lowercase 'x' (0x).
    pub fn new(integer: u64, is_x_uppercase: bool) -> Self {
        Self {
            integer,
            exponent: None,
            is_x_uppercase,
            token: None,
        }
    }

    /// Attaches a token to this hexadecimal number and returns the updated number.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Attaches a token to this hexadecimal number.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the token attached to this hexadecimal number, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the token attached to this hexadecimal number, if any.
    #[inline]
    pub fn mutate_token(&mut self) -> Option<&mut Token> {
        self.token.as_mut()
    }

    /// Sets a binary exponent for this hexadecimal number and returns the updated number.
    ///
    /// The `is_uppercase` parameter determines whether the exponent uses uppercase 'P'
    /// or lowercase 'p' notation.
    pub fn with_exponent(mut self, exponent: u32, is_uppercase: bool) -> Self {
        self.exponent.replace((exponent, is_uppercase));
        self
    }

    /// Sets whether the hexadecimal prefix and exponent notation should use uppercase letters.
    pub fn set_uppercase(&mut self, is_uppercase: bool) {
        self.exponent = self.exponent.map(|(value, _)| (value, is_uppercase));
        self.is_x_uppercase = is_uppercase;
    }

    /// Returns whether the hexadecimal prefix uses uppercase 'X' (0X) or lowercase 'x' (0x).
    #[inline]
    pub fn is_x_uppercase(&self) -> bool {
        self.is_x_uppercase
    }

    /// Returns whether the exponent notation uses uppercase 'P', if an exponent is present.
    #[inline]
    pub fn is_exponent_uppercase(&self) -> Option<bool> {
        self.exponent.map(|(_, uppercase)| uppercase)
    }

    /// Returns the raw integer value of this hexadecimal number.
    #[inline]
    pub fn get_raw_integer(&self) -> u64 {
        self.integer
    }

    /// Returns the exponent value, if one is present.
    #[inline]
    pub fn get_exponent(&self) -> Option<u32> {
        self.exponent.map(|(value, _)| value)
    }

    /// Computes the actual numerical value represented by this hexadecimal number.
    pub fn compute_value(&self) -> f64 {
        if let Some((exponent, _)) = self.exponent {
            (self.integer * 2_u64.pow(exponent)) as f64
        } else {
            self.integer as f64
        }
    }

    super::impl_token_fns!(iter = [token]);
}

/// Represents a binary number.
///
/// Binary numbers are prefixed with '0b' or '0B' and consist of 0s and 1s.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BinaryNumber {
    value: u64,
    is_b_uppercase: bool,
    token: Option<Token>,
}

impl BinaryNumber {
    /// Creates a new binary number with the given value.
    ///
    /// The `is_b_uppercase` parameter determines whether the binary prefix
    /// uses uppercase 'B' (0B) or lowercase 'b' (0b).
    pub fn new(value: u64, is_b_uppercase: bool) -> Self {
        Self {
            value,
            is_b_uppercase,
            token: None,
        }
    }

    /// Attaches a token to this binary number.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Attaches a token to this binary number.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the token attached to this binary number, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a mutable reference to the token attached to this binary number, if any.
    #[inline]
    pub fn mutate_token(&mut self) -> Option<&mut Token> {
        self.token.as_mut()
    }

    /// Sets whether the binary prefix should use uppercase 'B' (0B) or lowercase 'b' (0b).
    pub fn set_uppercase(&mut self, is_uppercase: bool) {
        self.is_b_uppercase = is_uppercase;
    }

    /// Returns whether the binary prefix uses uppercase 'B' (0B) or lowercase 'b' (0b).
    #[inline]
    pub fn is_b_uppercase(&self) -> bool {
        self.is_b_uppercase
    }

    /// Computes the actual numerical value represented by this binary number.
    pub fn compute_value(&self) -> f64 {
        self.value as f64
    }

    /// Returns the raw integer value of this binary number.
    #[inline]
    pub fn get_raw_value(&self) -> u64 {
        self.value
    }

    super::impl_token_fns!(iter = [token]);
}

/// Represents a numeric literal expression.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum NumberExpression {
    /// A decimal number (e.g., `123.45`, `1e10`)
    Decimal(DecimalNumber),
    /// A hexadecimal number (e.g., `0xFF`, `0x1p2`)
    Hex(HexNumber),
    /// A binary number (e.g., `0b101`, `0B1010`)
    Binary(BinaryNumber),
}

impl NumberExpression {
    /// Sets whether the number notation should use uppercase letters.
    pub fn set_uppercase(&mut self, is_uppercase: bool) {
        match self {
            Self::Decimal(number) => number.set_uppercase(is_uppercase),
            Self::Hex(number) => number.set_uppercase(is_uppercase),
            Self::Binary(number) => number.set_uppercase(is_uppercase),
        }
    }

    /// Computes the actual numerical value represented by this number expression.
    pub fn compute_value(&self) -> f64 {
        match self {
            Self::Decimal(decimal) => decimal.compute_value(),
            Self::Hex(hex) => hex.compute_value(),
            Self::Binary(binary) => binary.compute_value(),
        }
    }

    /// Attaches a token to this number expression.
    pub fn with_token(mut self, token: Token) -> Self {
        match &mut self {
            NumberExpression::Decimal(number) => number.set_token(token),
            NumberExpression::Hex(number) => number.set_token(token),
            NumberExpression::Binary(number) => number.set_token(token),
        }
        self
    }

    /// Attaches a token to this number expression.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        match self {
            NumberExpression::Decimal(number) => number.set_token(token),
            NumberExpression::Hex(number) => number.set_token(token),
            NumberExpression::Binary(number) => number.set_token(token),
        }
    }

    /// Returns a reference to the token attached to this number expression, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        match self {
            NumberExpression::Decimal(number) => number.get_token(),
            NumberExpression::Hex(number) => number.get_token(),
            NumberExpression::Binary(number) => number.get_token(),
        }
    }

    /// Returns a mutable reference to the token attached to this number expression, if any.
    #[inline]
    pub fn mutate_token(&mut self) -> Option<&mut Token> {
        match self {
            NumberExpression::Decimal(number) => number.mutate_token(),
            NumberExpression::Hex(number) => number.mutate_token(),
            NumberExpression::Binary(number) => number.mutate_token(),
        }
    }

    /// Clears all comments from the tokens in this node.
    pub fn clear_comments(&mut self) {
        match self {
            NumberExpression::Decimal(number) => number.clear_comments(),
            NumberExpression::Hex(number) => number.clear_comments(),
            NumberExpression::Binary(number) => number.clear_comments(),
        }
    }

    /// Clears all whitespaces information from the tokens in this node.
    pub fn clear_whitespaces(&mut self) {
        match self {
            NumberExpression::Decimal(number) => number.clear_whitespaces(),
            NumberExpression::Hex(number) => number.clear_whitespaces(),
            NumberExpression::Binary(number) => number.clear_whitespaces(),
        }
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        match self {
            NumberExpression::Decimal(number) => number.replace_referenced_tokens(code),
            NumberExpression::Hex(number) => number.replace_referenced_tokens(code),
            NumberExpression::Binary(number) => number.replace_referenced_tokens(code),
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        match self {
            NumberExpression::Decimal(number) => number.shift_token_line(amount),
            NumberExpression::Hex(number) => number.shift_token_line(amount),
            NumberExpression::Binary(number) => number.shift_token_line(amount),
        }
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        match self {
            NumberExpression::Decimal(number) => number.filter_comments(filter),
            NumberExpression::Hex(number) => number.filter_comments(filter),
            NumberExpression::Binary(number) => number.filter_comments(filter),
        }
    }

    pub(crate) fn mutate_or_insert_token(&mut self) -> &mut Token {
        if self.get_token().is_none() {
            let content = write_number(self);
            self.set_token(Token::from_content(content));
        }
        self.mutate_token().unwrap()
    }
}

impl From<DecimalNumber> for NumberExpression {
    fn from(number: DecimalNumber) -> Self {
        Self::Decimal(number)
    }
}

impl From<HexNumber> for NumberExpression {
    fn from(number: HexNumber) -> Self {
        Self::Hex(number)
    }
}

impl From<BinaryNumber> for NumberExpression {
    fn from(number: BinaryNumber) -> Self {
        Self::Binary(number)
    }
}

/// An error that can occur when parsing a number.
///
/// # Example
/// ```rust
/// # use darklua_core::nodes::NumberExpression;
/// let number: NumberExpression = "123.45".parse().unwrap();
/// let hex_number: NumberExpression = "0xFF".parse().unwrap();
/// let binary_number: NumberExpression = "0b1010".parse().unwrap();
///
/// // Invalid numbers will return a NumberParsingError
/// assert!("abc".parse::<NumberExpression>().is_err());
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NumberParsingError {
    InvalidHexadecimalNumber,
    InvalidHexadecimalExponent,
    InvalidDecimalNumber,
    InvalidDecimalExponent,
    InvalidBinaryNumber,
}

impl Display for NumberParsingError {
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        use NumberParsingError::*;

        match self {
            InvalidHexadecimalNumber => write!(f, "could not parse hexadecimal number"),
            InvalidHexadecimalExponent => write!(f, "could not parse hexadecimal exponent"),
            InvalidDecimalNumber => write!(f, "could not parse decimal number"),
            InvalidDecimalExponent => write!(f, "could not parse decimal exponent"),
            InvalidBinaryNumber => write!(f, "could not parse binary number"),
        }
    }
}

fn filter_underscore(number: &str) -> String {
    number.chars().filter(|c| c != &'_').collect()
}

impl FromStr for NumberExpression {
    type Err = NumberParsingError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        let notation_prefix = value
            .char_indices()
            .filter(|(_, c)| *c != '_')
            .take(2)
            .nth(1);
        let starts_with_zero = value.starts_with('0');

        let number = match (starts_with_zero, notation_prefix) {
            (true, Some((position, notation))) if matches!(notation, 'x' | 'X' | 'b' | 'B') => {
                let is_uppercase = notation.is_uppercase();

                if notation == 'x' || notation == 'X' {
                    if let Some((exponent_is_uppercase, index)) = value
                        .find('p')
                        .map(|index| (false, index))
                        .or_else(|| value.find('P').map(|index| (true, index)))
                    {
                        let exponent = value
                            .get(index + 1..)
                            .and_then(|string| string.parse().ok())
                            .ok_or(Self::Err::InvalidHexadecimalExponent)?;
                        let before_exponent = value.get(position + 1..index).unwrap();
                        let number = u64::from_str_radix(before_exponent, 16)
                            .map_err(|_| Self::Err::InvalidHexadecimalNumber)?;

                        HexNumber::new(number, is_uppercase)
                            .with_exponent(exponent, exponent_is_uppercase)
                    } else {
                        let filtered = filter_underscore(value.get(position + 1..).unwrap());
                        let number = u64::from_str_radix(&filtered, 16)
                            .map_err(|_| Self::Err::InvalidHexadecimalNumber)?;

                        HexNumber::new(number, is_uppercase)
                    }
                    .into()
                } else if notation == 'b' || notation == 'B' {
                    let filtered = filter_underscore(value.get(position + 1..).unwrap());
                    let number = u64::from_str_radix(&filtered, 2)
                        .map_err(|_| Self::Err::InvalidBinaryNumber)?;

                    BinaryNumber::new(number, is_uppercase).into()
                } else {
                    unreachable!()
                }
            }
            _ => {
                // in Luau, underscores are valid everywhere in a number except
                // after a `.`
                if value.starts_with("._") {
                    return Err(Self::Err::InvalidDecimalNumber);
                }

                if let Some((exponent_is_uppercase, index)) = value
                    .find('e')
                    .map(|index| (false, index))
                    .or_else(|| value.find('E').map(|index| (true, index)))
                {
                    // in Luau, underscores are not valid before the exponent sign
                    if value.contains("_-") || value.contains("_+") {
                        return Err(Self::Err::InvalidDecimalExponent);
                    }

                    let exponent = value
                        .get(index + 1..)
                        .map(filter_underscore)
                        .and_then(|string| string.parse().ok())
                        .ok_or(Self::Err::InvalidDecimalExponent)?;
                    let _number: f64 = value
                        .get(0..index)
                        .map(filter_underscore)
                        .and_then(|string| string.parse().ok())
                        .ok_or(Self::Err::InvalidDecimalNumber)?;

                    DecimalNumber::new(
                        filter_underscore(value)
                            .parse::<f64>()
                            .map_err(|_| Self::Err::InvalidDecimalNumber)?,
                    )
                    .with_exponent(exponent, exponent_is_uppercase)
                } else {
                    let number = filter_underscore(value)
                        .parse::<f64>()
                        .map_err(|_| Self::Err::InvalidDecimalNumber)?;

                    DecimalNumber::new(number)
                }
                .into()
            }
        };

        Ok(number)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    mod decimal {
        use super::*;

        #[test]
        fn can_set_uppercase_to_number_without_exponent() {
            let mut number = DecimalNumber::new(1.0);
            number.set_uppercase(true);
            number.set_uppercase(false);

            assert_eq!(number.is_uppercase(), None);
        }

        #[test]
        fn set_uppercase_change() {
            let initial_case = true;
            let modified_case = !initial_case;
            let mut number = DecimalNumber::new(1.0).with_exponent(2, initial_case);

            number.set_uppercase(modified_case);

            assert_eq!(number.is_uppercase(), Some(modified_case));
        }
    }

    mod hex {
        use super::*;

        #[test]
        fn set_uppercase_change() {
            let initial_case = true;
            let modified_case = !initial_case;
            let mut number = HexNumber::new(1, initial_case);

            number.set_uppercase(modified_case);

            assert_eq!(number.is_x_uppercase(), modified_case);
        }
    }

    mod binary {
        use super::*;

        #[test]
        fn set_uppercase_change() {
            let initial_case = true;
            let modified_case = !initial_case;
            let mut number = BinaryNumber::new(1, initial_case);

            number.set_uppercase(modified_case);

            assert_eq!(number.is_b_uppercase(), modified_case);
        }
    }

    mod parse_number {
        use super::*;

        macro_rules! test_numbers {
            ($($name:ident($input:literal) => $expect:expr),+ $(,)?) => {
                $(
                    #[test]
                    fn $name() {
                        let result: NumberExpression = $input.parse()
                            .expect("should be a valid number");

                        let expect: NumberExpression = $expect.into();

                        assert_eq!(result, expect);
                    }
                )+
            };
        }

        macro_rules! test_parse_errors {
            ($($name:ident($input:literal) => $expect:expr),+ $(,)?) => {
                $(
                    #[test]
                    fn $name() {
                        let result = $input.parse::<NumberExpression>()
                            .expect_err("should be an invalid number");

                        assert_eq!(result, $expect);
                    }
                )+
            };
        }

        test_numbers!(
            parse_zero("0") => DecimalNumber::new(0_f64),
            parse_integer("123") => DecimalNumber::new(123_f64),
            parse_integer_with_underscore_delimiter("123_456") => DecimalNumber::new(123_456_f64),
            parse_multiple_decimal("123.24") => DecimalNumber::new(123.24_f64),
            parse_multiple_decimal_with_underscore("123.245_6") => DecimalNumber::new(123.245_6_f64),
            parse_multiple_decimal_with_underscore_after_point("0._24") => DecimalNumber::new(0.24_f64),
            parse_float_with_trailing_dot("123.") => DecimalNumber::new(123_f64),
            parse_starting_with_dot(".123") => DecimalNumber::new(0.123_f64),
            parse_digit_with_exponent("1e10") => DecimalNumber::new(1e10_f64).with_exponent(10, false),
            parse_digit_with_exponent_and_underscore("1e_10") => DecimalNumber::new(1e10_f64).with_exponent(10, false),
            parse_number_with_exponent("123e101") => DecimalNumber::new(123e101_f64).with_exponent(101, false),
            parse_number_with_exponent_and_plus_symbol("123e+121") => DecimalNumber::new(123e121_f64).with_exponent(121, false),
            parse_number_with_negative_exponent("123e-456") => DecimalNumber::new(123e-456_f64).with_exponent(-456, false),
            parse_number_with_upper_exponent("123E4") => DecimalNumber::new(123e4_f64).with_exponent(4, true),
            parse_number_with_upper_negative_exponent("123E-456") => DecimalNumber::new(123e-456_f64).with_exponent(-456, true),
            parse_float_with_exponent("10.12e8") => DecimalNumber::new(10.12e8_f64).with_exponent(8, false),
            parse_float_with_exponent_and_underscores("10_0.12_e_8") => DecimalNumber::new(100.12e8_f64).with_exponent(8, false),
            parse_float_with_exponent_2("4.6982573308436185e159") => DecimalNumber::new(4.6982573308436185e159_f64).with_exponent(159, false),
            parse_trailing_dot_with_exponent("10.e8") => DecimalNumber::new(10e8_f64).with_exponent(8, false),
            parse_hex_number("0x12") => HexNumber::new(18, false),
            parse_hex_number_with_underscore_before_x("0_x12") => HexNumber::new(18, false),
            parse_hex_number_with_underscores_around_x("0_x_12") => HexNumber::new(18, false),
            parse_hex_number_with_underscore("0x12_13") => HexNumber::new(0x1213, false),
            parse_uppercase_hex_number("0X12") => HexNumber::new(18, true),
            parse_uppercase_hex_number_with_underscore_before_x("0_X13") => HexNumber::new(19, true),
            parse_hex_number_with_lowercase("0x12a") => HexNumber::new(298, false),
            parse_hex_number_with_uppercase("0x12A") => HexNumber::new(298, false),
            parse_hex_number_with_mixed_case("0x1bF2A") => HexNumber::new(114_474, false),
            parse_hex_with_exponent("0x12p4") => HexNumber::new(18, false).with_exponent(4, false),
            parse_hex_with_exponent_uppercase("0xABP3") => HexNumber::new(171, false).with_exponent(3, true),
            parse_binary_zero("0b0") => BinaryNumber::new(0, false),
            parse_binary_zero_with_underscore_before_b("0_b1") => BinaryNumber::new(1, false),
            parse_binary_zero_with_underscore("0b1010_1100") => BinaryNumber::new(0b1010_1100, false),
            parse_binary_zero_uppercase("0B0") => BinaryNumber::new(0, true),
            parse_binary_zero_uppercase_with_underscore_before_b("0_B1") => BinaryNumber::new(1, true),
        );

        test_parse_errors!(
            parse_empty_string("") => NumberParsingError::InvalidDecimalNumber,
            missing_exponent_value("1e") => NumberParsingError::InvalidDecimalExponent,
            missing_exponent_value_uppercase("1E") => NumberParsingError::InvalidDecimalExponent,
            invalid_underscore_position("._1") => NumberParsingError::InvalidDecimalNumber,
            missing_negative_exponent_value("1e-") => NumberParsingError::InvalidDecimalExponent,
            missing_negative_exponent_value_uppercase("1E-") => NumberParsingError::InvalidDecimalExponent,
            invalid_underscore_before_negative_exponent("1e_-1") => NumberParsingError::InvalidDecimalExponent,
            invalid_underscore_before_positive_exponent("1e_+1") => NumberParsingError::InvalidDecimalExponent,
            invalid_underscore_before_negative_exponent_uppercase("1E_-1") => NumberParsingError::InvalidDecimalExponent,
            invalid_underscore_before_positive_exponent_uppercase("1E_+1") => NumberParsingError::InvalidDecimalExponent,
            missing_hex_exponent_value("0x1p") => NumberParsingError::InvalidHexadecimalExponent,
            negative_hex_exponent_value("0x1p-3") => NumberParsingError::InvalidHexadecimalExponent,
            missing_hex_exponent_value_uppercase("0x1P") => NumberParsingError::InvalidHexadecimalExponent,
            invalid_hex_exponent_value("0x1p1Z") => NumberParsingError::InvalidHexadecimalExponent,
            invalid_hex_exponent_value_uppercase("0x1P1Z") => NumberParsingError::InvalidHexadecimalExponent,
            negative_hex_exponent_value_uppercase("0x1P-3") => NumberParsingError::InvalidHexadecimalExponent,
            invalid_digit_in_binary("0b190") => NumberParsingError::InvalidBinaryNumber,
            invalid_digit_in_binary_uppercase("0B190") => NumberParsingError::InvalidBinaryNumber,
        );
    }

    mod compute_value {
        use super::*;

        macro_rules! test_compute_value {
            ($($name:ident($input:literal) => $value:expr),* $(,)?) => {
                $(
                    #[test]
                    fn $name() {
                        let number = NumberExpression::from_str($input)
                            .expect(&format!("unable to parse `{}`", $input));
                        assert!((number.compute_value() - $value as f64).abs() < f64::EPSILON);
                    }
                )*
            };
        }

        test_compute_value!(
            zero("0") => 0,
            one("1") => 1,
            integer("123") => 123,
            multiple_decimal("0.512") => 0.512,
            integer_with_multiple_decimal("54.512") => 54.512,
            digit_with_exponent("1e5") => 1e5,
            number_with_exponent("123e4") => 123e4,
            number_with_negative_exponent("123e-4") => 123e-4,
            float_with_exponent("10.5e2") => 10.5e2,
            hex_number("0x12") => 0x12,
            hex_number_with_letter("0x12a") => 0x12a,
            hex_with_exponent("0x12p4") => 0x120,
            binary_zero("0b0") => 0b0,
            binary_ten("0b1010") => 0b1010,
        );
    }
}
