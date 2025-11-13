mod function_names;
mod globals;
mod rename_processor;

use rename_processor::RenameProcessor;

use crate::nodes::Block;
use crate::process::utils::is_valid_identifier;
use crate::process::{DefaultVisitor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
    RulePropertyValue,
};

use std::collections::HashSet;
use std::iter::FromIterator;

pub const RENAME_VARIABLES_RULE_NAME: &str = "rename_variables";

/// Rename all identifiers to small and meaningless names.
#[derive(Debug, PartialEq, Eq)]
pub struct RenameVariables {
    globals: Vec<String>,
    include_functions: bool,
}

impl RenameVariables {
    pub fn new<I: IntoIterator<Item = String>>(iter: I) -> Self {
        Self {
            globals: Vec::from_iter(iter),
            include_functions: false,
        }
    }

    pub fn with_function_names(mut self) -> Self {
        self.include_functions = true;
        self
    }

    fn set_globals(&mut self, list: Vec<String>) -> Result<(), RuleConfigurationError> {
        for value in list {
            match value.as_str() {
                "$default" => self
                    .globals
                    .extend(globals::DEFAULT.iter().map(ToString::to_string)),
                "$roblox" => self
                    .globals
                    .extend(globals::ROBLOX.iter().map(ToString::to_string)),
                identifier if !is_valid_identifier(identifier) => {
                    return Err(RuleConfigurationError::StringExpected("".to_owned()))
                }
                _ => self.globals.push(value),
            }
        }

        Ok(())
    }

    fn normalize_globals(&self) -> Vec<String> {
        let mut globals_set: HashSet<String> = self.globals.iter().cloned().collect();

        let mut result = Vec::new();

        if globals::DEFAULT
            .iter()
            .all(|identifier| globals_set.contains(*identifier))
        {
            globals::DEFAULT.iter().for_each(|identifier| {
                globals_set.remove(*identifier);
            });
            result.push("$default".to_owned());
        }

        if globals::ROBLOX
            .iter()
            .all(|identifier| globals_set.contains(*identifier))
        {
            globals::ROBLOX.iter().for_each(|identifier| {
                globals_set.remove(*identifier);
            });
            result.push("$roblox".to_owned());
        }

        result.extend(globals_set);
        result.sort();
        result
    }
}

impl Default for RenameVariables {
    fn default() -> Self {
        Self::new(globals::DEFAULT.iter().map(|string| (*string).to_owned()))
    }
}

impl FlawlessRule for RenameVariables {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let avoid_identifiers = if self.include_functions {
            Vec::new()
        } else {
            let mut collect_functions = function_names::CollectFunctionNames::default();
            DefaultVisitor::visit_block(block, &mut collect_functions);
            collect_functions.into()
        };

        let mut processor = RenameProcessor::new(
            self.globals.clone().into_iter().chain(avoid_identifiers),
            self.include_functions,
        );
        ScopeVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RenameVariables {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        for (key, value) in properties {
            match key.as_str() {
                "globals" => {
                    self.set_globals(value.expect_string_list(&key)?)?;
                }
                "include_functions" => {
                    self.include_functions = value.expect_bool(&key)?;
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        RENAME_VARIABLES_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        let mut properties = RuleProperties::new();

        let globals = self.normalize_globals();
        if !(globals.len() == 1 && globals.contains(&"$default".to_owned())) {
            properties.insert(
                "globals".to_owned(),
                RulePropertyValue::StringList(self.normalize_globals()),
            );
        }

        if self.include_functions {
            properties.insert(
                "include_functions".to_owned(),
                RulePropertyValue::Boolean(self.include_functions),
            );
        }

        properties
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;
    use std::iter::empty;

    fn new_rule() -> Box<dyn Rule> {
        Box::<RenameVariables>::default()
    }

    #[test]
    fn serialize_default_rule() {
        assert_json_snapshot!("default_rename_variables", new_rule());
    }

    #[test]
    fn serialize_no_globals_rule() {
        assert_json_snapshot!(
            "no_globals_rename_variables",
            Box::new(RenameVariables::new(empty())) as Box<dyn Rule>
        );
    }

    #[test]
    fn serialize_roblox_globals_rule() {
        let rule = Box::new(RenameVariables::new(
            globals::ROBLOX.iter().map(ToString::to_string),
        ));

        assert_json_snapshot!("roblox_globals_rename_variables", rule as Box<dyn Rule>);
    }

    #[test]
    fn serialize_with_function_names() {
        let rule = Box::new(
            RenameVariables::new(globals::DEFAULT.iter().map(ToString::to_string))
                .with_function_names(),
        );

        assert_json_snapshot!(
            "rename_variables_with_function_names",
            rule as Box<dyn Rule>
        );
    }

    #[test]
    fn serialize_skip_functions() {
        let rule = Box::new(RenameVariables::new(
            globals::ROBLOX.iter().map(ToString::to_string),
        ));

        assert_json_snapshot!("roblox_globals_rename_variables", rule as Box<dyn Rule>);
    }
}
