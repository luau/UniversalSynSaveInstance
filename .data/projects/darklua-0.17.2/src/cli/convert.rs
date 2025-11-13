use crate::cli::{CommandResult, GlobalOptions};

use anstyle::Style;
use clap::Args;
use darklua_core::{DarkluaError, Resources};
use std::{ffi::OsStr, path::PathBuf, str::FromStr, time::Instant};

use super::error::CliError;

#[derive(Debug, Args)]
pub struct Options {
    /// Data file to convert to Lua
    input: PathBuf,
    /// Path where to write the Lua file
    output: Option<PathBuf>,
    /// Data format ('json', 'yaml' or 'toml')
    #[arg(short, long)]
    format: Option<DataFormat>,
}

#[derive(Debug, Copy, Clone)]
enum DataFormat {
    Json,
    Yaml,
    Toml,
}

impl FromStr for DataFormat {
    type Err = String;

    fn from_str(format: &str) -> Result<Self, Self::Err> {
        match format {
            "json" | "json5" => Ok(Self::Json),
            "yml" | "yaml" => Ok(Self::Yaml),
            "toml" => Ok(Self::Toml),
            _ => Err(format!(
                "invalid data format '{}' (possible options are: 'json', 'json5', 'yml' or 'toml')",
                format
            )),
        }
    }
}

pub fn run(options: &Options, _: &GlobalOptions) -> CommandResult {
    convert_data(options).map_err(|err| {
        eprintln!("an error happened: {}", err);
        CliError::new(1)
    })
}

fn convert_data(options: &Options) -> Result<(), DarkluaError> {
    let resources = Resources::from_file_system();

    let input = resources.get(&options.input).map_err(DarkluaError::from)?;

    let format = options
        .format
        .ok_or_else(|| DarkluaError::custom("unable to find data format"))
        .or_else(|_| {
            options
                .input
                .extension()
                .and_then(OsStr::to_str)
                .ok_or_else(|| {
                    DarkluaError::custom(format!(
                        "unable to find data format because the input file '{}' has no extension. Specify the data format using the '--format' option",
                        options.input.display()
                    ))
                })
                .and_then(|extension| {
                    DataFormat::from_str(extension).map_err(|err| {
                        DarkluaError::custom( format!("{} [unrecognized file extension]", err))
                    })
                })
        })?;

    log::debug!("use data format '{:?}'", format);

    let convert_start_time = Instant::now();

    let lua_code = match format {
        DataFormat::Json => darklua_core::convert_data(
            json5::from_str::<serde_json::Value>(&input).map_err(DarkluaError::from)?,
        ),
        DataFormat::Yaml => darklua_core::convert_data(
            serde_yaml::from_str::<serde_yaml::Value>(&input).map_err(DarkluaError::from)?,
        ),
        DataFormat::Toml => darklua_core::convert_data(
            toml::from_str::<toml::Value>(&input).map_err(DarkluaError::from)?,
        ),
    }?;

    let convert_duration = durationfmt::to_string(convert_start_time.elapsed());

    let success_style = Style::new()
        .fg_color(Some(anstyle::Color::Ansi(anstyle::AnsiColor::Green)))
        .dimmed();
    let dim_style = Style::new().dimmed();

    eprintln!(
        "{success_style}successfully converted {}{success_style:#} {dim_style}(in {}){dim_style:#}",
        options.input.display(),
        convert_duration
    );

    if let Some(output) = &options.output {
        resources
            .write(output, &lua_code)
            .map_err(DarkluaError::from)?;
    } else {
        println!("{}", lua_code);
    }

    Ok(())
}
