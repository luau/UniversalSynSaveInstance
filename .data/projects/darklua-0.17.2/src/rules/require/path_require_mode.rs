use serde::{Deserialize, Serialize};

use crate::frontend::DarkluaResult;
use crate::nodes::{Arguments, FunctionCall, StringExpression};
use crate::rules::require::path_utils::get_relative_path;
use crate::rules::require::{match_path_require_call, path_utils, PathLocator};
use crate::rules::{Context, RequireMode};
use crate::utils;
use crate::DarkluaError;

use std::collections::HashMap;
use std::ffi::OsStr;
use std::path::{Path, PathBuf};

use super::RequirePathLocator;

/// A require mode for handling content from file system paths.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case")]
pub struct PathRequireMode {
    #[serde(
        skip_serializing_if = "is_default_module_folder_name",
        default = "get_default_module_folder_name"
    )]
    module_folder_name: String,
    #[serde(default, skip_serializing_if = "HashMap::is_empty")]
    sources: HashMap<String, PathBuf>,
    #[serde(default = "default_use_luau_configuration")]
    use_luau_configuration: bool,
    #[serde(skip)]
    luau_rc_aliases: Option<HashMap<String, PathBuf>>,
}

fn default_use_luau_configuration() -> bool {
    true
}

impl Default for PathRequireMode {
    fn default() -> Self {
        Self {
            module_folder_name: get_default_module_folder_name(),
            sources: Default::default(),
            use_luau_configuration: default_use_luau_configuration(),
            luau_rc_aliases: Default::default(),
        }
    }
}

const DEFAULT_MODULE_FOLDER_NAME: &str = "init";

#[inline]
fn get_default_module_folder_name() -> String {
    DEFAULT_MODULE_FOLDER_NAME.to_owned()
}

fn is_default_module_folder_name(value: &String) -> bool {
    value == DEFAULT_MODULE_FOLDER_NAME
}

impl PathRequireMode {
    /// Creates a new path require mode with the specified module folder name.
    pub fn new(module_folder_name: impl Into<String>) -> Self {
        Self {
            module_folder_name: module_folder_name.into(),
            sources: Default::default(),
            use_luau_configuration: default_use_luau_configuration(),
            luau_rc_aliases: Default::default(),
        }
    }

    pub(crate) fn initialize(&mut self, context: &Context) -> Result<(), DarkluaError> {
        if !self.use_luau_configuration {
            self.luau_rc_aliases.take();
            return Ok(());
        }

        if let Some(config) =
            utils::find_luau_configuration(context.current_path(), context.resources())?
        {
            self.luau_rc_aliases.replace(config.aliases);
        } else {
            self.luau_rc_aliases.take();
        }

        Ok(())
    }

    pub(crate) fn module_folder_name(&self) -> &str {
        &self.module_folder_name
    }

    pub(crate) fn get_source(&self, name: &str, rel: &Path) -> Option<PathBuf> {
        log::trace!(
            "lookup alias `{}` from `{}` (path mode)",
            name,
            rel.display()
        );

        self.sources
            .get(name)
            .map(|alias| rel.join(alias))
            .or_else(|| {
                self.luau_rc_aliases
                    .as_ref()
                    .and_then(|aliases| aliases.get(name))
                    .map(ToOwned::to_owned)
            })
    }

    pub(crate) fn find_require(
        &self,
        call: &FunctionCall,
        context: &Context,
    ) -> DarkluaResult<Option<PathBuf>> {
        if let Some(literal_path) = match_path_require_call(call) {
            let required_path =
                RequirePathLocator::new(self, context.project_location(), context.resources())
                    .find_require_path(literal_path, context.current_path())?;

            Ok(Some(required_path))
        } else {
            Ok(None)
        }
    }

    pub(crate) fn is_module_folder_name(&self, path: &Path) -> bool {
        let expect_value = Some(self.module_folder_name.as_str());
        path.file_name().and_then(OsStr::to_str) == expect_value
            || path.file_stem().and_then(OsStr::to_str) == expect_value
    }

    pub(crate) fn generate_require(
        &self,
        require_path: &Path,
        _current: &RequireMode,
        context: &Context<'_, '_, '_>,
    ) -> Result<Option<crate::nodes::Arguments>, crate::DarkluaError> {
        let source_path = utils::normalize_path(context.current_path());
        log::debug!(
            "generate path require for `{}` from `{}`",
            require_path.display(),
            source_path.display(),
        );

        let mut generated_path = if path_utils::is_require_relative(require_path) {
            require_path.to_path_buf()
        } else {
            let normalized_require_path = utils::normalize_path(require_path);
            log::trace!(
                " ⨽ adjust non-relative path `{}` (normalized to `{}`) from `{}`",
                require_path.display(),
                normalized_require_path.display(),
                source_path.display()
            );

            let mut potential_aliases: Vec<_> = self
                .sources
                .iter()
                .map(|(alias_name, alias_path)| {
                    (
                        alias_name,
                        utils::normalize_path(context.project_location().join(alias_path)),
                    )
                })
                .filter(|(_, alias_path)| normalized_require_path.starts_with(alias_path))
                .inspect(|(alias_name, alias_path)| {
                    log::trace!(
                        "   > alias candidate `{}` (`{}`)",
                        alias_name,
                        alias_path.display()
                    );
                })
                .collect();
            potential_aliases.sort_by_cached_key(|(_, alias_path)| alias_path.components().count());

            if let Some((alias_name, alias_path)) = potential_aliases.into_iter().next_back() {
                let mut new_path = PathBuf::from(alias_name);

                new_path.extend(
                    normalized_require_path
                        .components()
                        .skip(alias_path.components().count()),
                );

                new_path
            } else if let Some(relative_require_path) =
                get_relative_path(&normalized_require_path, &source_path, true)?
            {
                log::trace!(
                    "   found relative path from source: `{}`",
                    relative_require_path.display()
                );

                if !(relative_require_path.starts_with(".")
                    || relative_require_path.starts_with(".."))
                {
                    Path::new(".").join(relative_require_path)
                } else {
                    relative_require_path
                }
            } else {
                normalized_require_path
            }
        };

        if self.is_module_folder_name(&generated_path) {
            generated_path.pop();
        } else if matches!(generated_path.extension(), Some(extension) if extension == "lua" || extension == "luau")
        {
            generated_path.set_extension("");
        }

        path_utils::write_require_path(&generated_path).map(generate_require_arguments)
    }
}

fn generate_require_arguments(value: String) -> Option<Arguments> {
    Some(Arguments::default().with_argument(StringExpression::from_value(value)))
}

#[cfg(test)]
mod test {
    use super::*;

    mod is_module_folder_name {
        use super::*;

        #[test]
        fn default_mode_is_false_for_regular_name() {
            let require_mode = PathRequireMode::default();

            assert!(!require_mode.is_module_folder_name(Path::new("oops.lua")));
        }

        #[test]
        fn default_mode_is_true_for_init_lua() {
            let require_mode = PathRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("init.lua")));
        }

        #[test]
        fn default_mode_is_true_for_init_luau() {
            let require_mode = PathRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("init.luau")));
        }

        #[test]
        fn default_mode_is_true_for_folder_init_lua() {
            let require_mode = PathRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("folder/init.lua")));
        }

        #[test]
        fn default_mode_is_true_for_folder_init_luau() {
            let require_mode = PathRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("folder/init.luau")));
        }
    }
}
