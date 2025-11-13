use crate::cli::error::CliError;
use crate::cli::utils::report_process;
#[cfg(not(target_arch = "wasm32"))]
use crate::cli::utils::FileWatcher;
use crate::cli::{CommandResult, GlobalOptions};

use clap::Args;
use darklua_core::{GeneratorParameters, Resources};
use std::path::PathBuf;
use std::str::FromStr;
use std::time::Instant;

#[derive(Debug, Args, Clone)]
pub struct Options {
    /// Path to the lua file to process.
    pub(crate) input_path: PathBuf,
    /// Where to output the result.
    output_path: PathBuf,
    /// Choose a specific configuration file.
    #[arg(long, short, alias = "config-path")]
    pub(crate) config: Option<PathBuf>,
    /// Choose how Lua code is formatted ('dense', 'readable' or 'retain_lines').
    /// This will override the format given by the configuration file.
    #[arg(long)]
    format: Option<LuaFormat>,
    /// Watch files and directories for changes and automatically re-run
    #[arg(long, short)]
    watch: bool,
}

#[derive(Debug, Copy, Clone)]
enum LuaFormat {
    Dense,
    Readable,
    RetainLines,
}

impl FromStr for LuaFormat {
    type Err = String;

    fn from_str(format: &str) -> Result<Self, Self::Err> {
        match format {
            "dense" => Ok(Self::Dense),
            "readable" => Ok(Self::Readable),
            // keep "retain-lines" for back-compatibility
            "retain_lines" | "retain-lines" => Ok(Self::RetainLines),
            _ => Err(format!(
                "format '{}' does not exist! (possible options are: 'dense', 'readable' or 'retain_lines'",
                format
            )),
        }
    }
}

fn process(resources: Resources, process_options: darklua_core::Options) -> CommandResult {
    let process_start_time = Instant::now();

    let result = darklua_core::process(&resources, process_options).map_err(|err| {
        log::error!("{}", err);
        CliError::new(1)
    })?;

    report_process("processed", &result, process_start_time.elapsed()).map_err(|_| CliError::new(1))
}

impl Options {
    pub(crate) fn get_process_options(&self) -> darklua_core::Options {
        let mut process_options =
            darklua_core::Options::new(&self.input_path).with_output(&self.output_path);

        if let Some(config) = self.config.as_ref() {
            process_options = process_options.with_configuration_at(config);
        }

        if let Some(format) = self.format {
            process_options = process_options.with_generator_override(match format {
                LuaFormat::Dense => GeneratorParameters::default_dense(),
                LuaFormat::Readable => GeneratorParameters::default_readable(),
                LuaFormat::RetainLines => GeneratorParameters::RetainLines,
            })
        }
        process_options
    }
}

pub fn run(options: &Options, _global: &GlobalOptions) -> CommandResult {
    log::debug!("running `process`: {:?}", options);

    if cfg!(not(target_arch = "wasm32")) && options.watch {
        let file_watcher = FileWatcher::new(options);

        file_watcher.start()?;

        Ok(())
    } else {
        let resources = Resources::from_file_system();

        process(resources, options.get_process_options())
    }
}
