use std::collections::HashMap;

use regex::Regex;
use serde::{Deserialize, Serialize};

use crate::{
    nodes::{DecimalNumber, Expression, StringExpression, TableEntry, TableExpression},
    process::to_expression,
};

use super::{
    require::{LuauRequireMode, PathRequireMode},
    RequireMode, RobloxRequireMode, RuleConfigurationError,
};

pub type RuleProperties = HashMap<String, RulePropertyValue>;

/// In order to be able to weakly-type the properties of any rule, this enum makes it possible to
/// easily use serde to gather the value associated with a property.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(untagged, rename_all = "snake_case")]
pub enum RulePropertyValue {
    Boolean(bool),
    String(String),
    Usize(usize),
    Float(f64),
    StringList(Vec<String>),
    RequireMode(RequireMode),
    None,
    #[doc(hidden)]
    Map(serde_json::Map<String, serde_json::Value>),
    #[doc(hidden)]
    Array(Vec<serde_json::Value>),
}

impl RulePropertyValue {
    pub(crate) fn expect_bool(self, key: &str) -> Result<bool, RuleConfigurationError> {
        if let Self::Boolean(value) = self {
            Ok(value)
        } else {
            Err(RuleConfigurationError::BooleanExpected(key.to_owned()))
        }
    }

    pub(crate) fn expect_string(self, key: &str) -> Result<String, RuleConfigurationError> {
        if let Self::String(value) = self {
            Ok(value)
        } else {
            Err(RuleConfigurationError::StringExpected(key.to_owned()))
        }
    }

    pub(crate) fn expect_string_list(
        self,
        key: &str,
    ) -> Result<Vec<String>, RuleConfigurationError> {
        if let Self::StringList(value) = self {
            Ok(value)
        } else {
            Err(RuleConfigurationError::StringListExpected(key.to_owned()))
        }
    }

    pub(crate) fn expect_regex_list(self, key: &str) -> Result<Vec<Regex>, RuleConfigurationError> {
        if let Self::StringList(value) = self {
            value
                .into_iter()
                .map(|regex_str| {
                    Regex::new(&regex_str).map_err(|err| RuleConfigurationError::UnexpectedValue {
                        property: key.to_owned(),
                        message: format!("invalid regex provided `{}`\n  {}", regex_str, err),
                    })
                })
                .collect()
        } else {
            Err(RuleConfigurationError::StringListExpected(key.to_owned()))
        }
    }

    pub(crate) fn expect_require_mode(
        self,
        key: &str,
    ) -> Result<RequireMode, RuleConfigurationError> {
        match self {
            Self::RequireMode(require_mode) => Ok(require_mode),
            Self::String(value) => {
                value
                    .parse()
                    .map_err(|err: String| RuleConfigurationError::UnexpectedValue {
                        property: key.to_owned(),
                        message: err,
                    })
            }
            _ => Err(RuleConfigurationError::RequireModeExpected(key.to_owned())),
        }
    }

    pub(crate) fn into_expression(self) -> Option<Expression> {
        match self {
            Self::None => Some(Expression::nil()),
            Self::String(value) => Some(StringExpression::from_value(value).into()),
            Self::Boolean(value) => Some(Expression::from(value)),
            Self::Usize(value) => Some(DecimalNumber::new(value as f64).into()),
            Self::Float(value) => Some(Expression::from(value)),
            Self::StringList(value) => Some(
                TableExpression::new(
                    value
                        .into_iter()
                        .map(|element| {
                            TableEntry::from_value(StringExpression::from_value(element))
                        })
                        .collect(),
                )
                .into(),
            ),
            Self::RequireMode(require_mode) => to_expression(&require_mode).ok(),
            Self::Map(value) => to_expression(&value).ok(),
            Self::Array(value) => to_expression(&value).ok(),
        }
    }
}

impl From<bool> for RulePropertyValue {
    fn from(value: bool) -> Self {
        Self::Boolean(value)
    }
}

impl From<&str> for RulePropertyValue {
    fn from(value: &str) -> Self {
        Self::String(value.to_owned())
    }
}

impl From<&String> for RulePropertyValue {
    fn from(value: &String) -> Self {
        Self::String(value.to_owned())
    }
}

impl From<String> for RulePropertyValue {
    fn from(value: String) -> Self {
        Self::String(value)
    }
}

impl From<usize> for RulePropertyValue {
    fn from(value: usize) -> Self {
        Self::Usize(value)
    }
}

impl From<f64> for RulePropertyValue {
    fn from(value: f64) -> Self {
        Self::Float(value)
    }
}

impl From<&RequireMode> for RulePropertyValue {
    fn from(value: &RequireMode) -> Self {
        match value {
            RequireMode::Path(mode) => {
                if mode == &PathRequireMode::default() {
                    return Self::from("path");
                }
            }
            RequireMode::Luau(mode) => {
                if mode == &LuauRequireMode::default() {
                    return Self::from("luau");
                }
            }
            RequireMode::Roblox(mode) => {
                if mode == &RobloxRequireMode::default() {
                    return Self::from("roblox");
                }
            }
        }

        Self::RequireMode(value.clone())
    }
}

impl<T: Into<RulePropertyValue>> From<Option<T>> for RulePropertyValue {
    fn from(value: Option<T>) -> Self {
        match value {
            Some(value) => value.into(),
            None => Self::None,
        }
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::approx_constant)]
    use super::*;

    #[test]
    fn from_true() {
        assert_eq!(
            RulePropertyValue::from(true),
            RulePropertyValue::Boolean(true)
        );
    }

    #[test]
    fn from_false() {
        assert_eq!(
            RulePropertyValue::from(false),
            RulePropertyValue::Boolean(false)
        );
    }

    #[test]
    fn from_string() {
        assert_eq!(
            RulePropertyValue::from(String::from("hello")),
            RulePropertyValue::String(String::from("hello"))
        );
    }

    #[test]
    fn from_string_ref() {
        assert_eq!(
            RulePropertyValue::from(&String::from("hello")),
            RulePropertyValue::String(String::from("hello"))
        );
    }

    #[test]
    fn from_str() {
        assert_eq!(
            RulePropertyValue::from("hello"),
            RulePropertyValue::String(String::from("hello"))
        );
    }

    #[test]
    fn from_usize() {
        assert_eq!(RulePropertyValue::from(6), RulePropertyValue::Usize(6));
    }

    #[test]
    fn from_float() {
        assert_eq!(RulePropertyValue::from(1.0), RulePropertyValue::Float(1.0));
    }

    #[test]
    fn from_boolean_option_some() {
        let bool = Some(true);
        assert_eq!(
            RulePropertyValue::from(bool),
            RulePropertyValue::Boolean(true)
        );
    }

    #[test]
    fn from_boolean_option_none() {
        let bool: Option<bool> = None;
        assert_eq!(RulePropertyValue::from(bool), RulePropertyValue::None);
    }

    mod parse {
        use super::*;

        fn parse_rule_property(json: &str, expect_property: RulePropertyValue) {
            let parsed: RulePropertyValue = serde_json::from_str(json).unwrap();
            assert_eq!(parsed, expect_property);
        }

        #[test]
        fn parse_boolean_true() {
            parse_rule_property("true", RulePropertyValue::Boolean(true));
        }

        #[test]
        fn parse_boolean_false() {
            parse_rule_property("false", RulePropertyValue::Boolean(false));
        }

        #[test]
        fn parse_string() {
            parse_rule_property(
                r#""hello world""#,
                RulePropertyValue::String("hello world".to_owned()),
            );
        }

        #[test]
        fn parse_empty_string() {
            parse_rule_property(r#""""#, RulePropertyValue::String("".to_owned()));
        }

        #[test]
        fn parse_string_with_escapes() {
            parse_rule_property(
                r#""hello\nworld\twith\"quotes\"""#,
                RulePropertyValue::String("hello\nworld\twith\"quotes\"".to_owned()),
            );
        }

        #[test]
        fn parse_usize_zero() {
            parse_rule_property("0", RulePropertyValue::Usize(0));
        }

        #[test]
        fn parse_usize_positive() {
            parse_rule_property("42", RulePropertyValue::Usize(42));
        }

        #[test]
        fn parse_float_zero() {
            parse_rule_property("0.0", RulePropertyValue::Float(0.0));
        }

        #[test]
        fn parse_float_positive() {
            parse_rule_property("3.14159", RulePropertyValue::Float(3.14159));
        }

        #[test]
        fn parse_float_negative() {
            parse_rule_property("-2.718", RulePropertyValue::Float(-2.718));
        }

        #[test]
        fn parse_float_scientific_notation() {
            parse_rule_property("1.23e-4", RulePropertyValue::Float(1.23e-4));
        }

        #[test]
        fn parse_string_list_empty() {
            parse_rule_property("[]", RulePropertyValue::StringList(vec![]));
        }

        #[test]
        fn parse_string_list_single() {
            parse_rule_property(
                r#"["hello"]"#,
                RulePropertyValue::StringList(vec!["hello".to_owned()]),
            );
        }

        #[test]
        fn parse_string_list_multiple() {
            parse_rule_property(
                r#"["hello", "world", "test"]"#,
                RulePropertyValue::StringList(vec![
                    "hello".to_owned(),
                    "world".to_owned(),
                    "test".to_owned(),
                ]),
            );
        }

        #[test]
        fn parse_string_list_with_empty_strings() {
            parse_rule_property(
                r#"["", "hello", ""]"#,
                RulePropertyValue::StringList(vec![
                    "".to_owned(),
                    "hello".to_owned(),
                    "".to_owned(),
                ]),
            );
        }

        #[test]
        fn parse_require_mode_path_string() {
            parse_rule_property(r#""path""#, RulePropertyValue::String("path".to_owned()));
        }

        #[test]
        fn parse_require_mode_luau_string() {
            parse_rule_property(r#""luau""#, RulePropertyValue::String("luau".to_owned()));
        }

        #[test]
        fn parse_require_mode_roblox_string() {
            parse_rule_property(
                r#""roblox""#,
                RulePropertyValue::String("roblox".to_owned()),
            );
        }

        #[test]
        fn parse_require_mode_path_object() {
            parse_rule_property(
                r#"{"name": "path"}"#,
                RulePropertyValue::RequireMode(RequireMode::Path(PathRequireMode::default())),
            );
        }

        #[test]
        fn parse_require_mode_path_object_with_options() {
            parse_rule_property(
                r#"{"name": "path", "module_folder_name": "index"}"#,
                RulePropertyValue::RequireMode(RequireMode::Path(PathRequireMode::new("index"))),
            );
        }

        #[test]
        fn parse_require_mode_roblox_object() {
            parse_rule_property(
                r#"{"name": "roblox"}"#,
                RulePropertyValue::RequireMode(RequireMode::Roblox(RobloxRequireMode::default())),
            );
        }

        #[test]
        fn parse_require_mode_roblox_object_with_options() {
            parse_rule_property(
                r#"{"name": "roblox", "rojo_sourcemap": "./sourcemap.json"}"#,
                RulePropertyValue::RequireMode(RequireMode::Roblox(
                    serde_json::from_str::<RobloxRequireMode>(
                        r#"{"rojo_sourcemap": "./sourcemap.json"}"#,
                    )
                    .unwrap(),
                )),
            );
        }

        #[test]
        fn parse_require_mode_luau_object() {
            parse_rule_property(
                r#"{ "name": "luau" }"#,
                RulePropertyValue::RequireMode(RequireMode::Luau(LuauRequireMode::default())),
            );
        }

        #[test]
        fn parse_null_as_none() {
            parse_rule_property("null", RulePropertyValue::None);
        }
    }
}
