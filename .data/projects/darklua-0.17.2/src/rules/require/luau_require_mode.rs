use serde::{Deserialize, Serialize};

use crate::frontend::DarkluaResult;
use crate::nodes::{Arguments, FunctionCall, StringExpression};
use crate::rules::require::{match_path_require_call, path_utils, LuauPathLocator, PathLocator};
use crate::rules::{Context, RequireMode};
use crate::utils;
use crate::DarkluaError;

use std::collections::HashMap;
use std::ffi::OsStr;
use std::iter::FromIterator;
use std::path::{Component, Path, PathBuf};

/// A require mode for handling content using Luau's require system.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case")]
pub struct LuauRequireMode {
    #[serde(default = "default_use_luau_configuration")]
    use_luau_configuration: bool,
    #[serde(default, skip_serializing_if = "HashMap::is_empty", alias = "sources")]
    aliases: HashMap<String, PathBuf>,
    #[serde(skip)]
    luau_rc_aliases: Option<HashMap<String, PathBuf>>,
}

fn default_use_luau_configuration() -> bool {
    true
}

impl Default for LuauRequireMode {
    fn default() -> Self {
        Self {
            use_luau_configuration: default_use_luau_configuration(),
            aliases: Default::default(),
            luau_rc_aliases: Default::default(),
        }
    }
}

impl LuauRequireMode {
    /// Set if the require mode should use `.luaurc` configuration to resolve aliases.
    pub fn with_configuration(mut self, use_luau_configuration: bool) -> Self {
        self.use_luau_configuration = use_luau_configuration;
        self
    }

    /// Add a new Luau alias to the require mode.
    pub fn with_alias(mut self, name: impl Into<String>, path: impl Into<PathBuf>) -> Self {
        self.aliases.insert(name.into(), path.into());
        self
    }

    pub(crate) fn initialize(&mut self, context: &Context) -> Result<(), DarkluaError> {
        if !self.use_luau_configuration {
            self.luau_rc_aliases.take();
            return Ok(());
        }

        // Load aliases from .luaurc configuration
        if let Some(config) =
            utils::find_luau_configuration(context.current_path(), context.resources())?
        {
            self.luau_rc_aliases.replace(config.aliases);
        } else {
            self.luau_rc_aliases.take();
        }

        Ok(())
    }

    #[inline]
    pub(crate) fn module_folder_name(&self) -> &str {
        "init"
    }

    pub(crate) fn is_module_folder_name(&self, path: &Path) -> bool {
        let expect_value = Some(self.module_folder_name());
        path.file_name().and_then(OsStr::to_str) == expect_value
            || path.file_stem().and_then(OsStr::to_str) == expect_value
    }

    pub(crate) fn find_require(
        &self,
        call: &FunctionCall,
        context: &Context,
    ) -> DarkluaResult<Option<PathBuf>> {
        if let Some(literal_path) = match_path_require_call(call) {
            let path_locator =
                LuauPathLocator::new(self, context.project_location(), context.resources());

            let required_path =
                path_locator.find_require_path(literal_path, context.current_path())?;

            Ok(Some(required_path))
        } else {
            Ok(None)
        }
    }

    pub(crate) fn generate_require(
        &self,
        require_path: &Path,
        _current: &RequireMode,
        context: &Context<'_, '_, '_>,
    ) -> Result<Option<Arguments>, crate::DarkluaError> {
        let source_path = utils::normalize_path(context.current_path());
        log::debug!(
            "generate luau require for `{}` from `{}`",
            require_path.display(),
            source_path.display(),
        );

        let mut generated_path = if path_utils::is_require_relative(require_path) {
            log::trace!(
                " ⨽ adjust relative path `{}` from `{}`",
                require_path.display(),
                source_path.display()
            );

            // if the source path is 'init.luau' or 'init.lua', we need to use @self
            if self.is_module_folder_name(&source_path) {
                let require_is_module_folder_name = self.is_module_folder_name(require_path);
                // if we are about to make a require to a path like `./x/y/z/init.lua`
                // we can pop the last component from the path
                let take_components = require_path
                    .components()
                    .count()
                    .saturating_sub(if require_is_module_folder_name { 1 } else { 0 });
                let mut path_components: Vec<_> =
                    require_path.components().take(take_components).collect();

                if path_components.starts_with(&[Component::CurDir]) {
                    path_components[0] = Component::Normal(OsStr::new("@self"));
                } else if path_components.starts_with(&[Component::ParentDir, Component::ParentDir])
                {
                    path_components.remove(0);
                } else if path_components.starts_with(&[Component::ParentDir]) {
                    path_components[0] = Component::CurDir;
                }

                PathBuf::from_iter(path_components)
            } else {
                require_path.to_path_buf()
            }
        } else {
            let normalized_require_path = utils::normalize_path(require_path);
            log::trace!(
                " ⨽ adjust non-relative path `{}` (normalized to `{}`) from `{}`",
                require_path.display(),
                normalized_require_path.display(),
                source_path.display()
            );

            let mut potential_aliases: Vec<_> = self
                .aliases
                .iter()
                .map(|(alias_name, alias_path)| {
                    (
                        alias_name,
                        utils::normalize_path(context.project_location().join(alias_path)),
                    )
                })
                .inspect(|(alias_name, alias_path)| {
                    log::trace!(
                        "   found alias candidate `{}` (`{}`)",
                        alias_name,
                        alias_path.display()
                    );
                })
                .filter(|(_, alias_path)| normalized_require_path.starts_with(alias_path))
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
                path_utils::get_relative_path(&normalized_require_path, &source_path, true)?
            {
                log::trace!(
                    " ⨽ adjust relative path from source: `{}`",
                    relative_require_path.display()
                );

                if self.is_module_folder_name(&source_path) {
                    if relative_require_path.starts_with(".") {
                        let mut new_path = PathBuf::from("@self");
                        new_path.extend(relative_require_path.components().skip(1));
                        new_path
                    } else if relative_require_path.starts_with("../..") {
                        relative_require_path.components().skip(1).collect()
                    } else if relative_require_path.starts_with("..") {
                        let mut new_path = PathBuf::from(".");
                        new_path.extend(relative_require_path.components().skip(1));
                        new_path
                    } else {
                        relative_require_path
                    }
                } else if !(relative_require_path.starts_with(".")
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

    pub(crate) fn get_source(&self, name: &str, rel: &Path) -> Option<PathBuf> {
        log::trace!(
            "lookup alias `{}` from `{}` (luau mode)",
            name,
            rel.display()
        );

        self.luau_rc_aliases
            .as_ref()
            .and_then(|aliases| aliases.get(name))
            .map(ToOwned::to_owned)
            .or_else(|| {
                self.aliases.get(name).map(|alias| {
                    log::trace!(
                        " ⨽ found alias candidate `{}` (relative to `{}`)",
                        alias.display(),
                        rel.display()
                    );
                    rel.join(alias)
                })
            })
    }
}

fn generate_require_arguments(value: String) -> Option<Arguments> {
    Some(Arguments::default().with_argument(StringExpression::from_value(value)))
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::nodes::{FunctionCall, StringExpression};
    use crate::rules::Context;
    use std::path::PathBuf;

    fn make_call(arg: &str) -> FunctionCall {
        FunctionCall::from_name("require").with_arguments(StringExpression::from_value(arg))
    }

    fn make_context_with_files(
        current_path: &str,
        files: &[&str],
    ) -> Context<'static, 'static, 'static> {
        use crate::rules::{ContextBuilder, Resources};
        use std::sync::LazyLock;
        static RESOURCES: LazyLock<Resources> = LazyLock::new(Resources::from_memory);
        for file in files {
            RESOURCES.write(file, "test").unwrap();
        }
        ContextBuilder::new(PathBuf::from(current_path), &RESOURCES, "")
            .with_project_location("/project")
            .build()
    }

    #[test]
    fn parses_relative_path() {
        let mode = LuauRequireMode::default();
        let context = make_context_with_files("/project/src/main.luau", &["/project/src/./module"]);
        let call = make_call("./module");
        let result = mode.find_require(&call, &context).unwrap();
        assert_eq!(result, Some(PathBuf::from("/project/src/./module")));
    }

    #[test]
    fn parses_parent_relative_path() {
        let mode = LuauRequireMode::default();
        let context =
            make_context_with_files("/project/src/main.luau", &["/project/src/../module"]);
        let call = make_call("../module");
        let result = mode.find_require(&call, &context).unwrap();
        use std::path::Path;
        let expected = Path::new("/project/module")
            .components()
            .collect::<std::path::PathBuf>();
        let norm = |p: &std::path::PathBuf| p.components().collect::<std::path::PathBuf>();
        assert_eq!(result.map(|p| norm(&p)), Some(norm(&expected)));
    }

    mod default {
        use super::*;

        #[test]
        fn creates_default_configuration() {
            let require_mode = LuauRequireMode::default();

            assert!(require_mode.use_luau_configuration);
            assert!(require_mode.luau_rc_aliases.is_none());
        }
    }

    mod is_module_folder_name {
        use super::*;

        #[test]
        fn is_false_for_regular_name() {
            let require_mode = LuauRequireMode::default();

            assert!(!require_mode.is_module_folder_name(Path::new("oops.lua")));
        }

        #[test]
        fn is_true_for_init_lua() {
            let require_mode = LuauRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("init.lua")));
        }

        #[test]
        fn is_true_for_init_luau() {
            let require_mode = LuauRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("init.luau")));
        }

        #[test]
        fn is_true_for_folder_init_lua() {
            let require_mode = LuauRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("folder/init.lua")));
        }

        #[test]
        fn is_true_for_folder_init_luau() {
            let require_mode = LuauRequireMode::default();

            assert!(require_mode.is_module_folder_name(Path::new("folder/init.luau")));
        }
    }

    mod serialization {
        use super::*;

        #[test]
        fn serializes_default_configuration() {
            let require_mode = LuauRequireMode::default();
            let serialized = serde_json::to_string(&require_mode).unwrap();

            assert_eq!(serialized, r#"{"use_luau_configuration":true}"#);
        }

        #[test]
        fn deserializes_default_configuration() {
            let json = r#"{"use_luau_configuration":true}"#;
            let require_mode: LuauRequireMode = serde_json::from_str(json).unwrap();

            assert!(require_mode.use_luau_configuration);
            assert!(require_mode.luau_rc_aliases.is_none());
        }

        #[test]
        fn deserializes_custom_configuration() {
            let json = r#"{"use_luau_configuration":false}"#;
            let require_mode: LuauRequireMode = serde_json::from_str(json).unwrap();

            assert!(!require_mode.use_luau_configuration);
            assert!(require_mode.luau_rc_aliases.is_none());
        }

        #[test]
        fn rejects_unknown_fields() {
            let json = r#"{"use_luau_configuration":true,"unknown_field":true}"#;
            let result: Result<LuauRequireMode, _> = serde_json::from_str(json);

            assert!(result.is_err());
        }
    }
}
