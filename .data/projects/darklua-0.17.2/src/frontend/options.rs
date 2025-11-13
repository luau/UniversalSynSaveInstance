use std::path::{Path, PathBuf};

use super::configuration::{Configuration, GeneratorParameters};

/// Options for configuring the darklua process function. This is not
/// the [`Configuration`] data itself.
#[derive(Debug)]
pub struct Options {
    input: PathBuf,
    config_path: Option<PathBuf>,
    config: Option<Configuration>,
    config_generator_override: Option<GeneratorParameters>,
    output: Option<PathBuf>,
    fail_fast: bool,
}

impl Options {
    /// Creates a new options instance with the specified input path.
    pub fn new(input: impl Into<PathBuf>) -> Self {
        Self {
            input: input.into(),
            config_path: None,
            config: None,
            output: None,
            fail_fast: false,
            config_generator_override: None,
        }
    }

    /// Sets the path to the configuration file.
    pub fn with_configuration_at(mut self, config: impl Into<PathBuf>) -> Self {
        self.config_path = Some(config.into());
        self
    }

    /// Sets the configuration directly.
    pub fn with_configuration(mut self, config: Configuration) -> Self {
        self.config = Some(config);
        self
    }

    /// Sets the output path.
    pub fn with_output(mut self, output: impl Into<PathBuf>) -> Self {
        self.output = Some(output.into());
        self
    }

    /// Enables fail-fast mode.
    ///
    /// When fail-fast is enabled, processing will stop immediately when an error occurs.
    pub fn fail_fast(mut self) -> Self {
        self.fail_fast = true;
        self
    }

    /// Sets a generator override for the configuration.
    ///
    /// This will override any generator settings in the configuration file.
    pub fn with_generator_override(mut self, generator: impl Into<GeneratorParameters>) -> Self {
        self.config_generator_override = Some(generator.into());
        self
    }

    /// Gets the input path.
    pub fn input(&self) -> &Path {
        &self.input
    }

    /// Gets the output path, if set.
    pub fn output(&self) -> Option<&Path> {
        self.output.as_ref().map(AsRef::as_ref)
    }

    /// Checks if fail-fast mode is enabled.
    pub fn should_fail_fast(&self) -> bool {
        self.fail_fast
    }

    /// Gets the configuration file path, if set.
    pub fn configuration_path(&self) -> Option<&Path> {
        self.config_path.as_ref().map(AsRef::as_ref)
    }

    /// Gets the generator override, if set.
    pub fn generator_override(&self) -> Option<&GeneratorParameters> {
        self.config_generator_override.as_ref()
    }

    /// Takes the configuration, if set.
    ///
    /// This removes the configuration from the options and returns it.
    pub fn take_configuration(&mut self) -> Option<Configuration> {
        self.config.take()
    }
}
