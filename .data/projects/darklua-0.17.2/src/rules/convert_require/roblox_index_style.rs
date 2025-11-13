use serde::{Deserialize, Serialize};

use crate::nodes::{FieldExpression, FunctionCall, IndexExpression, Prefix, StringExpression};
use crate::process::utils::is_valid_identifier;

use std::str::FromStr;

/// Represents the different styles of indexing in Roblox.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case", tag = "name")]
pub enum RobloxIndexStyle {
    /// Uses `:FindFirstChild(name)` calls to access child Instances.
    FindFirstChild,
    /// Uses `:WaitForChild(name)` calls to access child Instances.
    WaitForChild,
    /// Uses the property syntax (`parent.ObjectName`) to access child Instances.
    Property,
}

impl Default for RobloxIndexStyle {
    fn default() -> Self {
        Self::FindFirstChild
    }
}

impl RobloxIndexStyle {
    pub(crate) fn index(&self, instance: Prefix, child_name: &str) -> Prefix {
        let child_name = if child_name.ends_with(".lua") {
            child_name.get(0..child_name.len() - 4).unwrap()
        } else if child_name.ends_with(".luau") {
            child_name.get(0..child_name.len() - 5).unwrap()
        } else {
            child_name
        };
        match self {
            RobloxIndexStyle::FindFirstChild => FunctionCall::from_prefix(instance)
                .with_method("FindFirstChild")
                .with_argument(StringExpression::from_value(child_name))
                .into(),
            RobloxIndexStyle::WaitForChild => FunctionCall::from_prefix(instance)
                .with_method("WaitForChild")
                .with_argument(StringExpression::from_value(child_name))
                .into(),
            RobloxIndexStyle::Property => {
                if is_valid_identifier(child_name) {
                    FieldExpression::new(instance, child_name).into()
                } else {
                    IndexExpression::new(instance, StringExpression::from_value(child_name)).into()
                }
            }
        }
    }
}

impl FromStr for RobloxIndexStyle {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "find_first_child" => Self::FindFirstChild,
            "wait_for_child" => Self::WaitForChild,
            "property" => Self::Property,
            _ => return Err(format!("invalid roblox index style `{}`", s)),
        })
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn deserialize_find_first_child() {
        assert_eq!(
            RobloxIndexStyle::FindFirstChild,
            "find_first_child".parse().unwrap()
        );
    }

    #[test]
    fn deserialize_wait_for_child() {
        assert_eq!(
            RobloxIndexStyle::WaitForChild,
            "wait_for_child".parse().unwrap()
        );
    }

    #[test]
    fn deserialize_property() {
        assert_eq!(RobloxIndexStyle::Property, "property".parse().unwrap());
    }

    #[test]
    fn deserialize_invalid() {
        assert_eq!(
            "invalid roblox index style `oops`",
            "oops".parse::<RobloxIndexStyle>().unwrap_err()
        );
    }
}
