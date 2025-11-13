use std::fmt;

/// When implementing the configure method of the Rule trait, the method returns a result that uses
/// this error type.
#[derive(Debug, Clone, Eq, PartialEq)]
pub enum RuleConfigurationError {
    /// When a rule gets an unknown property. The string should be the unknown field name.
    UnexpectedProperty(String),
    /// When a rule has a required property. The string should be the field name.
    MissingProperty(String),
    /// When a rule must define at least one property in a given set.
    MissingAnyProperty(Vec<String>),
    /// When a property is associated with something else than an expected boolean. The string is
    /// the property name.
    BooleanExpected(String),
    /// When a property is associated with something else than an expected string. The string is
    /// the property name.
    StringExpected(String),
    /// When a property is associated with something else than an expected unsigned number. The
    /// string is the property name.
    UsizeExpected(String),
    /// When a property is associated with something else than an expected float. The string is the
    /// property name.
    FloatExpected(String),
    /// When a property is associated with something else than an expected list of strings. The
    /// string is the property name.
    StringListExpected(String),
    /// When a property is associated with something else than an expected require mode. The
    /// string is the property name.
    RequireModeExpected(String),
    /// When the value type is invalid. The string is the property name that was given the wrong
    /// value type.
    UnexpectedValueType(String),
    /// When the value is invalid.
    UnexpectedValue { property: String, message: String },
    /// When a rule cannot have multiple properties defined at the same time.
    PropertyCollision(Vec<String>),
    /// When a rule can only be used internally by darklua. The string is the rule name
    /// (this error should not surface to external consumers)
    InternalUsageOnly(String),
}

fn enumerate_properties(properties: &[String]) -> String {
    let last_index = properties.len().saturating_sub(1);
    properties
        .iter()
        .enumerate()
        .map(|(i, name)| {
            if i == 0 {
                format!("`{}`", name)
            } else if i == last_index {
                format!(" and `{}`", name)
            } else {
                format!(", `{}`", name)
            }
        })
        .collect()
}

impl fmt::Display for RuleConfigurationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use RuleConfigurationError::*;

        match self {
            UnexpectedProperty(property) => write!(f, "unexpected field '{}'", property),
            MissingProperty(property) => write!(f, "missing required field '{}'", property),
            MissingAnyProperty(properties) => write!(
                f,
                "missing one field from {}",
                enumerate_properties(properties)
            ),
            BooleanExpected(property) => {
                write!(f, "boolean value expected for field '{}'", property)
            }
            StringExpected(property) => write!(f, "string value expected for field '{}'", property),
            UsizeExpected(property) => {
                write!(f, "unsigned integer expected for field '{}'", property)
            }
            FloatExpected(property) => write!(f, "float value expected for field '{}'", property),
            StringListExpected(property) => {
                write!(f, "list of string expected for field '{}'", property)
            }
            RequireModeExpected(property) => {
                write!(f, "require mode value expected for field `{}`", property)
            }
            UnexpectedValueType(property) => write!(f, "unexpected type for field '{}'", property),
            UnexpectedValue { property, message } => {
                write!(f, "unexpected value for field '{}': {}", property, message)
            }
            PropertyCollision(properties) => write!(
                f,
                "the fields {} cannot be defined together",
                enumerate_properties(properties)
            ),
            InternalUsageOnly(rule_name) => {
                write!(
                    f,
                    "usage of rule `{}` is reserved for darklua internal processing",
                    rule_name
                )
            }
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn enumerate_one_property() {
        assert_eq!(enumerate_properties(&["prop".to_owned()]), "`prop`")
    }

    #[test]
    fn enumerate_two_properties() {
        assert_eq!(
            enumerate_properties(&["prop".to_owned(), "prop2".to_owned()]),
            "`prop` and `prop2`"
        )
    }

    #[test]
    fn enumerate_three_properties() {
        assert_eq!(
            enumerate_properties(&["prop".to_owned(), "prop2".to_owned(), "prop3".to_owned()]),
            "`prop`, `prop2` and `prop3`"
        )
    }
}
