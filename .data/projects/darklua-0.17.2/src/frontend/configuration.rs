use std::{
    collections::HashSet,
    path::{Path, PathBuf},
    str::FromStr,
};

use serde::{Deserialize, Serialize};

use crate::{
    generator::{DenseLuaGenerator, LuaGenerator, ReadableLuaGenerator, TokenBasedLuaGenerator},
    nodes::Block,
    rules::{
        bundle::{BundleRequireMode, Bundler},
        get_default_rules, Rule,
    },
    Parser,
};

const DEFAULT_COLUMN_SPAN: usize = 80;

fn get_default_column_span() -> usize {
    DEFAULT_COLUMN_SPAN
}

/// Configuration for processing files (rules, generator, bundling).
#[derive(Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Configuration {
    #[serde(alias = "process", default = "get_default_rules")]
    rules: Vec<Box<dyn Rule>>,
    #[serde(default, deserialize_with = "crate::utils::string_or_struct")]
    generator: GeneratorParameters,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    bundle: Option<BundleConfiguration>,
    #[serde(default, skip)]
    location: Option<PathBuf>,
}

impl Configuration {
    /// Creates a configuration object without any rules and with the default generator.
    pub fn empty() -> Self {
        Self {
            rules: Vec::new(),
            generator: GeneratorParameters::default(),
            bundle: None,
            location: None,
        }
    }

    /// Sets the generator parameters for this configuration.
    #[inline]
    pub fn with_generator(mut self, generator: GeneratorParameters) -> Self {
        self.generator = generator;
        self
    }

    /// Sets the generator parameters for this configuration.
    #[inline]
    pub fn set_generator(&mut self, generator: GeneratorParameters) {
        self.generator = generator;
    }

    /// Adds a rule to this configuration.
    #[inline]
    pub fn with_rule(mut self, rule: impl Into<Box<dyn Rule>>) -> Self {
        self.push_rule(rule);
        self
    }

    /// Sets the bundle configuration for this configuration.
    #[inline]
    pub fn with_bundle_configuration(mut self, configuration: BundleConfiguration) -> Self {
        self.bundle = Some(configuration);
        self
    }

    /// Sets the location of this configuration.
    #[inline]
    pub fn with_location(mut self, location: impl Into<PathBuf>) -> Self {
        self.location = Some(location.into());
        self
    }

    /// Adds a rule to this configuration.
    #[inline]
    pub fn push_rule(&mut self, rule: impl Into<Box<dyn Rule>>) {
        self.rules.push(rule.into());
    }

    #[inline]
    pub(crate) fn rules<'a, 'b: 'a>(&'b self) -> impl Iterator<Item = &'a dyn Rule> {
        self.rules.iter().map(AsRef::as_ref)
    }

    #[inline]
    pub(crate) fn build_parser(&self) -> Parser {
        self.generator.build_parser()
    }

    #[inline]
    pub(crate) fn generate_lua(&self, block: &Block, code: &str) -> String {
        self.generator.generate_lua(block, code)
    }

    pub(crate) fn bundle(&self) -> Option<Bundler> {
        if let Some(bundle_config) = self.bundle.as_ref() {
            let bundler = Bundler::new(
                self.build_parser(),
                bundle_config.require_mode().clone(),
                bundle_config.excludes(),
            )
            .with_modules_identifier(bundle_config.modules_identifier());
            Some(bundler)
        } else {
            None
        }
    }

    #[inline]
    pub(crate) fn rules_len(&self) -> usize {
        self.rules.len()
    }

    #[inline]
    pub(crate) fn location(&self) -> Option<&Path> {
        self.location.as_deref()
    }
}

impl Default for Configuration {
    fn default() -> Self {
        Self {
            rules: get_default_rules(),
            generator: Default::default(),
            bundle: None,
            location: None,
        }
    }
}

impl std::fmt::Debug for Configuration {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Config")
            .field("generator", &self.generator)
            .field(
                "rules",
                &self
                    .rules
                    .iter()
                    .map(|rule| {
                        json5::to_string(rule)
                            .ok()
                            .unwrap_or_else(|| rule.get_name().to_owned())
                    })
                    .collect::<Vec<_>>()
                    .join(", "),
            )
            .finish()
    }
}

/// Parameters for configuring the Lua code generator.
///
/// This enum defines different modes for generating Lua code, each with its own
/// formatting characteristics.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case", tag = "name")]
pub enum GeneratorParameters {
    /// Retains the original line structure of the input code.
    #[serde(alias = "retain-lines")]
    RetainLines,
    /// Generates dense, compact code with a specified column span.
    Dense {
        /// The maximum number of characters per line.
        #[serde(default = "get_default_column_span")]
        column_span: usize,
    },
    /// Attempts to generate readable code, with a specified column span.
    Readable {
        /// The maximum number of characters per line.
        #[serde(default = "get_default_column_span")]
        column_span: usize,
    },
}

impl Default for GeneratorParameters {
    fn default() -> Self {
        Self::RetainLines
    }
}

impl GeneratorParameters {
    /// Creates a new dense generator with default column span.
    pub fn default_dense() -> Self {
        Self::Dense {
            column_span: DEFAULT_COLUMN_SPAN,
        }
    }

    /// Creates a new readable generator with default column span.
    pub fn default_readable() -> Self {
        Self::Readable {
            column_span: DEFAULT_COLUMN_SPAN,
        }
    }

    fn generate_lua(&self, block: &Block, code: &str) -> String {
        match self {
            Self::RetainLines => {
                let mut generator = TokenBasedLuaGenerator::new(code);
                generator.write_block(block);
                generator.into_string()
            }
            Self::Dense { column_span } => {
                let mut generator = DenseLuaGenerator::new(*column_span);
                generator.write_block(block);
                generator.into_string()
            }
            Self::Readable { column_span } => {
                let mut generator = ReadableLuaGenerator::new(*column_span);
                generator.write_block(block);
                generator.into_string()
            }
        }
    }

    fn build_parser(&self) -> Parser {
        match self {
            Self::RetainLines => Parser::default().preserve_tokens(),
            Self::Dense { .. } | Self::Readable { .. } => Parser::default(),
        }
    }
}

impl FromStr for GeneratorParameters {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            // keep "retain-lines" for back-compatibility
            "retain_lines" | "retain-lines" => Self::RetainLines,
            "dense" => Self::Dense {
                column_span: DEFAULT_COLUMN_SPAN,
            },
            "readable" => Self::Readable {
                column_span: DEFAULT_COLUMN_SPAN,
            },
            _ => return Err(format!("invalid generator name `{}`", s)),
        })
    }
}

/// Configuration for bundling modules.
///
/// This struct defines how modules should be bundled together, including
/// how requires are handled.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case")]
pub struct BundleConfiguration {
    #[serde(deserialize_with = "crate::utils::string_or_struct")]
    require_mode: BundleRequireMode,
    #[serde(skip_serializing_if = "Option::is_none")]
    modules_identifier: Option<String>,
    #[serde(default, skip_serializing_if = "HashSet::is_empty")]
    excludes: HashSet<String>,
}

impl BundleConfiguration {
    /// Creates a new bundle configuration with the specified require mode.
    pub fn new(require_mode: impl Into<BundleRequireMode>) -> Self {
        Self {
            require_mode: require_mode.into(),
            modules_identifier: None,
            excludes: Default::default(),
        }
    }

    /// Sets the modules identifier for this bundle configuration.
    pub fn with_modules_identifier(mut self, modules_identifier: impl Into<String>) -> Self {
        self.modules_identifier = Some(modules_identifier.into());
        self
    }

    /// Adds a module to exclude from bundling.
    pub fn with_exclude(mut self, exclude: impl Into<String>) -> Self {
        self.excludes.insert(exclude.into());
        self
    }

    pub(crate) fn require_mode(&self) -> &BundleRequireMode {
        &self.require_mode
    }

    pub(crate) fn modules_identifier(&self) -> &str {
        self.modules_identifier
            .as_ref()
            .map(AsRef::as_ref)
            .unwrap_or("__DARKLUA_BUNDLE_MODULES")
    }

    pub(crate) fn excludes(&self) -> impl Iterator<Item = &str> {
        self.excludes.iter().map(AsRef::as_ref)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    mod generator_parameters {
        use super::*;

        #[test]
        fn deserialize_retain_lines_params() {
            let config: Configuration =
                json5::from_str("{ generator: { name: 'retain_lines' } }").unwrap();

            pretty_assertions::assert_eq!(config.generator, GeneratorParameters::RetainLines);
        }

        #[test]
        fn deserialize_retain_lines_params_deprecated() {
            let config: Configuration =
                json5::from_str("{ generator: { name: 'retain-lines' } }").unwrap();

            pretty_assertions::assert_eq!(config.generator, GeneratorParameters::RetainLines);
        }

        #[test]
        fn deserialize_dense_params() {
            let config: Configuration = json5::from_str("{ generator: { name: 'dense' }}").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Dense {
                    column_span: DEFAULT_COLUMN_SPAN
                }
            );
        }

        #[test]
        fn deserialize_dense_params_with_column_span() {
            let config: Configuration =
                json5::from_str("{ generator: { name: 'dense', column_span: 110 } }").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Dense { column_span: 110 }
            );
        }

        #[test]
        fn deserialize_readable_params() {
            let config: Configuration =
                json5::from_str("{ generator: { name: 'readable' } }").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Readable {
                    column_span: DEFAULT_COLUMN_SPAN
                }
            );
        }

        #[test]
        fn deserialize_readable_params_with_column_span() {
            let config: Configuration =
                json5::from_str("{ generator: { name: 'readable', column_span: 110 }}").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Readable { column_span: 110 }
            );
        }

        #[test]
        fn deserialize_retain_lines_params_as_string() {
            let config: Configuration = json5::from_str("{generator: 'retain_lines'}").unwrap();

            pretty_assertions::assert_eq!(config.generator, GeneratorParameters::RetainLines);
        }

        #[test]
        fn deserialize_dense_params_as_string() {
            let config: Configuration = json5::from_str("{generator: 'dense'}").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Dense {
                    column_span: DEFAULT_COLUMN_SPAN
                }
            );
        }

        #[test]
        fn deserialize_readable_params_as_string() {
            let config: Configuration = json5::from_str("{generator: 'readable'}").unwrap();

            pretty_assertions::assert_eq!(
                config.generator,
                GeneratorParameters::Readable {
                    column_span: DEFAULT_COLUMN_SPAN
                }
            );
        }

        #[test]
        fn deserialize_unknown_generator_name() {
            let result: Result<Configuration, _> = json5::from_str("{generator: 'oops'}");

            pretty_assertions::assert_eq!(
                result.expect_err("deserialization should fail").to_string(),
                "invalid generator name `oops`"
            );
        }
    }

    mod bundle_configuration {
        use crate::rules::require::PathRequireMode;

        use super::*;

        #[test]
        fn deserialize_path_require_mode_as_string() {
            let config: Configuration =
                json5::from_str("{ bundle: { require_mode: 'path' } }").unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::default())
            );
        }

        #[test]
        fn deserialize_path_require_mode_as_object() {
            let config: Configuration =
                json5::from_str("{bundle: { require_mode: { name: 'path' } } }").unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::default())
            );
        }

        #[test]
        fn deserialize_path_require_mode_with_custom_module_folder_name() {
            let config: Configuration = json5::from_str(
                "{bundle: { require_mode: { name: 'path', module_folder_name: '__INIT__' } } }",
            )
            .unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::new("__INIT__"))
            );
        }

        #[test]
        fn deserialize_path_require_mode_with_custom_module_identifier() {
            let config: Configuration =
                json5::from_str("{bundle: { require_mode: 'path', modules_identifier: '__M' } }")
                    .unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::default()).with_modules_identifier("__M")
            );
        }

        #[test]
        fn deserialize_path_require_mode_with_custom_module_identifier_and_module_folder_name() {
            let config: Configuration = json5::from_str(
                "{bundle: { require_mode: { name: 'path', module_folder_name: '__INIT__' }, modules_identifier: '__M' } }",
            )
            .unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::new("__INIT__"))
                    .with_modules_identifier("__M")
            );
        }

        #[test]
        fn deserialize_path_require_mode_with_excludes() {
            let config: Configuration = json5::from_str(
                "{bundle: { require_mode: { name: 'path' }, excludes: ['@lune', 'secrets'] } }",
            )
            .unwrap();

            pretty_assertions::assert_eq!(
                config.bundle.unwrap(),
                BundleConfiguration::new(PathRequireMode::default())
                    .with_exclude("@lune")
                    .with_exclude("secrets")
            );
        }

        #[test]
        fn deserialize_unknown_require_mode_name() {
            let result: Result<Configuration, _> =
                json5::from_str("{bundle: { require_mode: 'oops' } }");

            pretty_assertions::assert_eq!(
                result.expect_err("deserialization should fail").to_string(),
                "invalid require mode `oops`"
            );
        }
    }
}
