pub(crate) mod path_require_mode;
mod rename_type_declaration;
mod require_mode;

use std::path::Path;

use crate::nodes::Block;
use crate::rules::{
    Context, Rule, RuleConfiguration, RuleConfigurationError, RuleProcessResult, RuleProperties,
};
use crate::Parser;

pub(crate) use rename_type_declaration::RenameTypeDeclarationProcessor;
pub use require_mode::BundleRequireMode;
use wax::Pattern;

pub const BUNDLER_RULE_NAME: &str = "bundler";

#[derive(Debug)]
pub(crate) struct BundleOptions {
    parser: Parser,
    modules_identifier: String,
    excludes: Option<wax::Any<'static>>,
}

impl BundleOptions {
    fn new<'a>(
        parser: Parser,
        modules_identifier: impl Into<String>,
        excludes: impl Iterator<Item = &'a str>,
    ) -> Self {
        let excludes: Vec<_> = excludes
            .filter_map(|exclusion| match wax::Glob::new(exclusion) {
                Ok(glob) => Some(glob.into_owned()),
                Err(err) => {
                    log::warn!(
                        "unable to create exclude matcher from `{}`: {}",
                        exclusion,
                        err
                    );
                    None
                }
            })
            .collect();
        Self {
            parser,
            modules_identifier: modules_identifier.into(),
            excludes: if excludes.is_empty() {
                None
            } else {
                let any_pattern = wax::any(excludes)
                    .expect("exclude globs errors should be filtered and only emit a warning");
                Some(any_pattern)
            },
        }
    }

    fn parser(&self) -> &Parser {
        &self.parser
    }

    fn modules_identifier(&self) -> &str {
        &self.modules_identifier
    }

    fn is_excluded(&self, require: &Path) -> bool {
        self.excludes
            .as_ref()
            .map(|any| any.is_match(require))
            .unwrap_or(false)
    }
}

/// A rule that inlines required modules
#[derive(Debug)]
pub(crate) struct Bundler {
    require_mode: BundleRequireMode,
    options: BundleOptions,
}

impl Bundler {
    pub(crate) fn new<'a>(
        parser: Parser,
        require_mode: BundleRequireMode,
        excludes: impl Iterator<Item = &'a str>,
    ) -> Self {
        Self {
            require_mode,
            options: BundleOptions::new(parser, DEFAULT_MODULE_IDENTIFIER, excludes),
        }
    }

    pub(crate) fn with_modules_identifier(mut self, modules_identifier: impl Into<String>) -> Self {
        self.options.modules_identifier = modules_identifier.into();
        self
    }
}

impl Rule for Bundler {
    fn process(&self, block: &mut Block, context: &Context) -> RuleProcessResult {
        self.require_mode
            .process_block(block, context, &self.options)
    }
}

impl RuleConfiguration for Bundler {
    fn configure(&mut self, _properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        Err(RuleConfigurationError::InternalUsageOnly(
            self.get_name().to_owned(),
        ))
    }

    fn get_name(&self) -> &'static str {
        BUNDLER_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

const DEFAULT_MODULE_IDENTIFIER: &str = "__DARKLUA_BUNDLE_MODULES";

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::{require::PathRequireMode, Rule};

    use insta::assert_json_snapshot;

    fn new_rule() -> Bundler {
        Bundler::new(
            Parser::default(),
            BundleRequireMode::default(),
            std::iter::empty(),
        )
    }

    fn new_rule_with_require_mode(mode: impl Into<BundleRequireMode>) -> Bundler {
        Bundler::new(Parser::default(), mode.into(), std::iter::empty())
    }

    // the bundler rule should only be used internally by darklua
    // so there is no need for it to serialize properly. The
    // implementation exist just make sure it does not panic

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_bundler", rule);
    }

    #[test]
    fn serialize_path_require_mode_with_custom_module_folder_name() {
        let rule: Box<dyn Rule> =
            Box::new(new_rule_with_require_mode(PathRequireMode::new("__init__")));

        assert_json_snapshot!("default_bundler", rule);
    }

    #[test]
    fn serialize_path_require_mode_with_custom_module_folder_name_and_modules_identifier() {
        let rule: Box<dyn Rule> = Box::new(
            new_rule_with_require_mode(PathRequireMode::new("__init__"))
                .with_modules_identifier("_CUSTOM_VAR"),
        );

        assert_json_snapshot!("default_bundler", rule);
    }

    #[test]
    fn serialize_with_custom_modules_identifier() {
        let rule: Box<dyn Rule> = Box::new(new_rule().with_modules_identifier("_CUSTOM_VAR"));

        assert_json_snapshot!("default_bundler", rule);
    }
}
