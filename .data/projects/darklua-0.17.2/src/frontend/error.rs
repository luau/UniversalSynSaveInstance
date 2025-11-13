use std::{
    borrow::Cow,
    cmp::Ordering,
    collections::HashSet,
    ffi::{OsStr, OsString},
    fmt::{self, Display},
    path::PathBuf,
};

use crate::{process::LuaSerializerError, rules::Rule, ParserError};

use super::{
    resources::ResourceError,
    work_item::{WorkData, WorkItem, WorkStatus},
};

#[derive(Debug, Clone)]
enum ErrorKind {
    Parser {
        path: PathBuf,
        error: ParserError,
    },
    ResourceNotFound {
        path: PathBuf,
    },
    InvalidConfiguration {
        path: PathBuf,
    },
    MultipleConfigurationFound {
        paths: Vec<PathBuf>,
    },
    IO {
        path: PathBuf,
        error: String,
    },
    UncachedWork {
        path: PathBuf,
    },
    RuleError {
        path: PathBuf,
        rule_name: String,
        rule_number: Option<usize>,
        error: String,
    },
    CyclicWork {
        work: Vec<(WorkData, Vec<PathBuf>)>,
    },
    Deserialization {
        message: String,
        data_type: &'static str,
    },
    Serialization {
        message: String,
        data_type: &'static str,
    },
    InvalidResourcePath {
        location: String,
        message: String,
    },
    InvalidResourceExtension {
        location: PathBuf,
    },
    OsStringConversion {
        os_string: OsString,
    },
    Custom {
        message: Cow<'static, str>,
    },
}

/// A type alias for `Result<T, DarkluaError>`.
pub type DarkluaResult<T> = Result<T, DarkluaError>;

/// The main error type for the darklua library.
///
/// This error type represents all possible errors that can occur during
/// the processing of Lua files. It includes errors from parsing, file I/O,
/// configuration, and rule application.
#[derive(Debug, Clone)]
pub struct DarkluaError {
    kind: Box<ErrorKind>,
    context: Option<Cow<'static, str>>,
}

impl DarkluaError {
    fn new(kind: ErrorKind) -> Self {
        Self {
            kind: kind.into(),
            context: None,
        }
    }

    pub(crate) fn context(mut self, context: impl Into<Cow<'static, str>>) -> Self {
        self.context = Some(context.into());
        self
    }

    pub(crate) fn parser_error(path: impl Into<PathBuf>, error: ParserError) -> Self {
        Self::new(ErrorKind::Parser {
            path: path.into(),
            error,
        })
    }

    pub(crate) fn multiple_configuration_found(
        configuration_files: impl Iterator<Item = PathBuf>,
    ) -> Self {
        Self::new(ErrorKind::MultipleConfigurationFound {
            paths: configuration_files.collect(),
        })
    }

    pub(crate) fn io_error(path: impl Into<PathBuf>, error: impl Into<String>) -> Self {
        Self::new(ErrorKind::IO {
            path: path.into(),
            error: error.into(),
        })
    }

    pub(crate) fn resource_not_found(path: impl Into<PathBuf>) -> Self {
        Self::new(ErrorKind::ResourceNotFound { path: path.into() })
    }

    pub(crate) fn invalid_configuration_file(path: impl Into<PathBuf>) -> Self {
        Self::new(ErrorKind::InvalidConfiguration { path: path.into() })
    }

    pub(crate) fn uncached_work(path: impl Into<PathBuf>) -> Self {
        Self::new(ErrorKind::UncachedWork { path: path.into() })
    }

    pub(crate) fn rule_error(
        path: impl Into<PathBuf>,
        rule: &dyn Rule,
        rule_index: usize,
        rule_error: impl Into<String>,
    ) -> Self {
        Self::new(ErrorKind::RuleError {
            path: path.into(),
            rule_name: rule.get_name().to_owned(),
            rule_number: Some(rule_index),
            error: rule_error.into(),
        })
    }

    pub(crate) fn orphan_rule_error(
        path: impl Into<PathBuf>,
        rule: &dyn Rule,
        rule_error: impl Into<String>,
    ) -> Self {
        Self::new(ErrorKind::RuleError {
            path: path.into(),
            rule_name: rule.get_name().to_owned(),
            rule_number: None,
            error: rule_error.into(),
        })
    }

    pub(crate) fn cyclic_work(work_left: Vec<&WorkItem>) -> Self {
        let source_left: HashSet<PathBuf> = work_left
            .iter()
            .map(|work| work.source().to_path_buf())
            .collect();

        let mut required_work: Vec<_> = work_left
            .into_iter()
            .filter(|work| work.total_required_content() != 0)
            .filter_map(|work| match &work.status {
                WorkStatus::NotStarted => None,
                WorkStatus::InProgress(progress) => {
                    let mut content: Vec<_> = progress
                        .required_content()
                        .filter(|path| source_left.contains(*path))
                        .map(PathBuf::from)
                        .collect();
                    if content.is_empty() {
                        None
                    } else {
                        content.sort();
                        Some((work.data.clone(), content))
                    }
                }
                WorkStatus::Done(_) => None,
            })
            .collect();

        required_work.sort_by(|(a_data, a_content), (b_data, b_content)| {
            match a_content.len().cmp(&b_content.len()) {
                Ordering::Equal => a_data.source().cmp(b_data.source()),
                other => other,
            }
        });

        required_work.sort_by_key(|(_, content)| content.len());

        Self::new(ErrorKind::CyclicWork {
            work: required_work,
        })
    }

    pub(crate) fn invalid_resource_path(
        path: impl Into<String>,
        message: impl Into<String>,
    ) -> Self {
        Self::new(ErrorKind::InvalidResourcePath {
            location: path.into(),
            message: message.into(),
        })
    }

    pub(crate) fn invalid_resource_extension(path: impl Into<PathBuf>) -> Self {
        Self::new(ErrorKind::InvalidResourceExtension {
            location: path.into(),
        })
    }

    pub(crate) fn os_string_conversion(os_string: impl Into<OsString>) -> Self {
        Self::new(ErrorKind::OsStringConversion {
            os_string: os_string.into(),
        })
    }

    /// Creates a custom error with the given message.
    pub fn custom(message: impl Into<Cow<'static, str>>) -> Self {
        Self::new(ErrorKind::Custom {
            message: message.into(),
        })
    }
}

impl From<ResourceError> for DarkluaError {
    fn from(err: ResourceError) -> Self {
        match err {
            ResourceError::NotFound(path) => DarkluaError::resource_not_found(path),
            ResourceError::IO { path, error } => DarkluaError::io_error(path, error),
        }
    }
}

impl From<json5::Error> for DarkluaError {
    fn from(error: json5::Error) -> Self {
        Self::new(ErrorKind::Deserialization {
            message: error.to_string(),
            data_type: "json",
        })
    }
}

impl From<serde_json::Error> for DarkluaError {
    fn from(error: serde_json::Error) -> Self {
        Self::new(ErrorKind::Deserialization {
            message: error.to_string(),
            data_type: "json",
        })
    }
}

impl From<serde_yaml::Error> for DarkluaError {
    fn from(error: serde_yaml::Error) -> Self {
        Self::new(ErrorKind::Deserialization {
            message: error.to_string(),
            data_type: "yaml",
        })
    }
}

impl From<toml::de::Error> for DarkluaError {
    fn from(error: toml::de::Error) -> Self {
        Self::new(ErrorKind::Deserialization {
            message: error.to_string(),
            data_type: "toml",
        })
    }
}

impl From<toml::ser::Error> for DarkluaError {
    fn from(error: toml::ser::Error) -> Self {
        Self::new(ErrorKind::Serialization {
            message: error.to_string(),
            data_type: "toml",
        })
    }
}

impl From<LuaSerializerError> for DarkluaError {
    fn from(error: LuaSerializerError) -> Self {
        Self::new(ErrorKind::Serialization {
            message: error.to_string(),
            data_type: "lua",
        })
    }
}

impl Display for DarkluaError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &*self.kind {
            ErrorKind::Parser { path, error } => {
                write!(f, "unable to parse `{}`: {}", path.display(), error)?;
            }
            ErrorKind::ResourceNotFound { path } => {
                write!(f, "unable to find `{}`", path.display())?;
            }
            ErrorKind::InvalidConfiguration { path } => {
                write!(f, "invalid configuration file at `{}`", path.display())?;
            }
            ErrorKind::MultipleConfigurationFound { paths } => {
                write!(
                    f,
                    "multiple default configuration file found: {}",
                    paths
                        .iter()
                        .map(|path| format!("`{}`", path.display()))
                        .collect::<Vec<_>>()
                        .join(", ")
                )?;
            }
            ErrorKind::IO { path, error } => {
                write!(f, "IO error with `{}`: {}", path.display(), error)?;
            }
            ErrorKind::UncachedWork { path } => {
                write!(f, "attempt to obtain work at `{}`", path.display())?;
            }
            ErrorKind::RuleError {
                path,
                rule_name,
                rule_number,
                error,
            } => {
                if let Some(rule_number) = rule_number {
                    write!(
                        f,
                        "error processing `{}` ({} [#{}]):{}{}",
                        path.display(),
                        rule_name,
                        rule_number,
                        if error.contains('\n') { '\n' } else { ' ' },
                        error,
                    )?;
                } else {
                    write!(
                        f,
                        "error processing `{}` ({}):{}{}",
                        path.display(),
                        rule_name,
                        if error.contains('\n') { '\n' } else { ' ' },
                        error,
                    )?;
                }
            }
            ErrorKind::CyclicWork { work } => {
                const MAX_PRINTED_WORK: usize = 12;
                const MAX_REQUIRED_PATH: usize = 20;

                let total = work.len();
                let list: Vec<_> = work
                    .iter()
                    .take(MAX_PRINTED_WORK)
                    .map(|(data, required)| {
                        let required_list: Vec<_> = required
                            .iter()
                            .take(MAX_REQUIRED_PATH)
                            .map(|path| format!("      - {}", path.display()))
                            .collect();

                        format!(
                            "    `{}` needs:\n{}",
                            data.source().display(),
                            required_list.join("\n")
                        )
                    })
                    .collect();

                write!(
                    f,
                    "cyclic work detected:\n{}{}",
                    list.join("\n"),
                    if total <= MAX_PRINTED_WORK {
                        "".to_owned()
                    } else {
                        format!("\n    and {} more", total - MAX_PRINTED_WORK)
                    }
                )?;
            }
            ErrorKind::Deserialization { message, data_type } => {
                write!(f, "unable to read {} data: {}", data_type, message)?;
            }
            ErrorKind::Serialization { message, data_type } => {
                write!(f, "unable to serialize {} data: {}", data_type, message)?;
            }
            ErrorKind::InvalidResourcePath { location, message } => {
                write!(
                    f,
                    "unable to require resource at `{}`: {}",
                    location, message
                )?;
            }
            ErrorKind::InvalidResourceExtension { location } => {
                if let Some(extension) = location.extension().map(OsStr::to_string_lossy) {
                    write!(
                        f,
                        "unable to require resource with extension `{}` at `{}`",
                        extension,
                        location.display()
                    )?;
                } else {
                    write!(
                        f,
                        "unable to require resource without an extension at `{}`",
                        location.display()
                    )?;
                }
            }
            ErrorKind::OsStringConversion { os_string } => {
                write!(
                    f,
                    "unable to convert operating system string (`{}`) into a utf-8 string",
                    os_string.to_string_lossy(),
                )?;
            }
            ErrorKind::Custom { message } => {
                write!(f, "{}", message)?;
            }
        };

        if let Some(context) = &self.context {
            write!(f, " ({})", context)?;
        }

        Ok(())
    }
}
