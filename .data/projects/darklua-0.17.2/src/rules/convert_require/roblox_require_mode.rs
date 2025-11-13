use serde::{Deserialize, Serialize};

use crate::{
    frontend::DarkluaResult,
    nodes::{Arguments, FunctionCall, Prefix},
    rules::{
        convert_require::rojo_sourcemap::RojoSourcemap,
        require::path_utils::{get_relative_parent_path, get_relative_path},
        Context,
    },
    utils, DarkluaError,
};

use std::path::{Component, Path, PathBuf};

use super::{
    instance_path::{get_parent_instance, script_identifier},
    RequireMode, RobloxIndexStyle,
};

#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case")]
pub struct RobloxRequireMode {
    rojo_sourcemap: Option<PathBuf>,
    #[serde(default, deserialize_with = "crate::utils::string_or_struct")]
    indexing_style: RobloxIndexStyle,
    #[serde(skip)]
    cached_sourcemap: Option<RojoSourcemap>,
}

impl RobloxRequireMode {
    pub(crate) fn initialize(&mut self, context: &Context) -> DarkluaResult<()> {
        if let Some(ref rojo_sourcemap_path) = self
            .rojo_sourcemap
            .as_ref()
            .map(|rojo_sourcemap_path| context.project_location().join(rojo_sourcemap_path))
        {
            context.add_file_dependency(rojo_sourcemap_path.clone());

            let sourcemap_parent_location = get_relative_parent_path(rojo_sourcemap_path);
            let sourcemap = RojoSourcemap::parse(
                &context
                    .resources()
                    .get(rojo_sourcemap_path)
                    .map_err(|err| {
                        DarkluaError::from(err).context("while initializing Roblox require mode")
                    })?,
                sourcemap_parent_location,
            )
            .map_err(|err| {
                err.context(format!(
                    "unable to parse Rojo sourcemap at `{}`",
                    rojo_sourcemap_path.display()
                ))
            })?;
            self.cached_sourcemap = Some(sourcemap);
        }
        Ok(())
    }

    pub(crate) fn find_require(
        &self,
        _call: &FunctionCall,
        _context: &Context,
    ) -> DarkluaResult<Option<PathBuf>> {
        Err(DarkluaError::custom("unsupported initial require mode")
            .context("Roblox require mode cannot be used as the current require mode"))
    }

    pub(crate) fn generate_require(
        &self,
        require_path: &Path,
        current: &RequireMode,
        context: &Context,
    ) -> DarkluaResult<Option<Arguments>> {
        let source_path = utils::normalize_path(context.current_path());
        log::trace!(
            "generate Roblox require for `{}` from `{}`",
            require_path.display(),
            source_path.display(),
        );

        if let Some((sourcemap, sourcemap_path)) = self
            .cached_sourcemap
            .as_ref()
            .zip(self.rojo_sourcemap.as_ref())
        {
            if let Some(require_relative_to_sourcemap) = get_relative_path(
                require_path,
                get_relative_parent_path(sourcemap_path),
                false,
            )? {
                log::trace!(
                    "  ⨽ use sourcemap at `{}` to find `{}`",
                    sourcemap_path.display(),
                    require_relative_to_sourcemap.display()
                );

                if let Some(instance_path) =
                    sourcemap.get_instance_path(&source_path, &require_relative_to_sourcemap)
                {
                    Ok(Some(Arguments::default().with_argument(
                        instance_path.convert(&self.indexing_style),
                    )))
                } else {
                    match (
                        sourcemap.exists(&source_path),
                        sourcemap.exists(&require_relative_to_sourcemap),
                    ) {
                        (true, true) => {
                            log::warn!(
                                "unable to get relative path to `{}` in sourcemap (from `{}`)",
                                require_relative_to_sourcemap.display(),
                                source_path.display()
                            );
                        }
                        (false, _) => {
                            log::warn!(
                                "unable to find source path `{}` in sourcemap",
                                source_path.display()
                            );
                        }
                        (true, false) => {
                            log::warn!(
                                "unable to find path `{}` in sourcemap (from `{}`)",
                                require_relative_to_sourcemap.display(),
                                source_path.display()
                            );
                        }
                    }
                    Ok(None)
                }
            } else {
                log::debug!(
                    "unable to get relative path from sourcemap for `{}`",
                    require_path.display()
                );
                Ok(None)
            }
        } else if let Some(relative_require_path) =
            get_relative_path(require_path, &source_path, true)?
        {
            log::trace!(
                "make require path relative to source: `{}`",
                relative_require_path.display()
            );

            let require_is_module_folder_name =
                current.is_module_folder_name(&relative_require_path);
            // if we are about to make a require to a path like `./x/y/z/init.lua`
            // we can pop the last component from the path
            let take_components = relative_require_path
                .components()
                .count()
                .saturating_sub(if require_is_module_folder_name { 1 } else { 0 });
            let mut path_components = relative_require_path.components().take(take_components);

            if let Some(first_component) = path_components.next() {
                let source_is_module_folder_name = current.is_module_folder_name(&source_path);

                let instance_path = path_components.try_fold(
                    match first_component {
                        Component::CurDir => {
                            if source_is_module_folder_name {
                                script_identifier().into()
                            } else {
                                get_parent_instance(script_identifier())
                            }
                        }
                        Component::ParentDir => {
                            if source_is_module_folder_name {
                                get_parent_instance(script_identifier())
                            } else {
                                get_parent_instance(get_parent_instance(script_identifier()))
                            }
                        }
                        Component::Normal(_) => {
                            return Err(DarkluaError::custom(format!(
                                concat!(
                                    "unable to convert path `{}`: the require path should be ",
                                    "relative and start with `.` or `..` (got `{}`)"
                                ),
                                require_path.display(),
                                relative_require_path.display(),
                            )))
                        }
                        Component::Prefix(_) | Component::RootDir => {
                            return Err(DarkluaError::custom(format!(
                                concat!(
                                    "unable to convert absolute path `{}`: ",
                                    "without a provided Rojo sourcemap, ",
                                    "darklua can only convert relative paths ",
                                    "(starting with `.` or `..`)"
                                ),
                                require_path.display(),
                            )))
                        }
                    },
                    |instance: Prefix, component| match component {
                        Component::CurDir => Ok(instance),
                        Component::ParentDir => Ok(get_parent_instance(instance)),
                        Component::Normal(name) => utils::convert_os_string(name)
                            .map(|child_name| self.indexing_style.index(instance, child_name)),
                        Component::Prefix(_) | Component::RootDir => {
                            Err(DarkluaError::custom(format!(
                                "unable to convert path `{}`: unexpected component in relative path `{}`",
                                require_path.display(),
                                relative_require_path.display(),
                            )))
                        },
                    },
                )?;

                Ok(Some(Arguments::default().with_argument(instance_path)))
            } else {
                Err(DarkluaError::custom(format!(
                    "unable to convert path `{}` from `{}` without a sourcemap: the relative path is empty `{}`",
                    require_path.display(),
                    source_path.display(),
                    relative_require_path.display(),
                )))
            }
        } else {
            Err(DarkluaError::custom(format!(
                concat!(
                    "unable to convert path `{}` from `{}` without a sourcemap: unable to ",
                    "make the require path relative to the source file"
                ),
                require_path.display(),
                source_path.display(),
            )))
        }
    }
}
