use std::path::{Path, PathBuf};

use super::{path_iterator, LuauRequireMode};
use crate::rules::require::path_utils::{get_relative_parent_path, is_require_relative};
use crate::{utils, DarkluaError, Resources};

/// A path locator specifically for Luau require mode that implements
/// the behavior defined in the Luau RFCs for module path resolution.
#[derive(Debug)]
pub(crate) struct LuauPathLocator<'a, 'b, 'resources> {
    luau_require_mode: &'a LuauRequireMode,
    extra_module_relative_location: &'b Path,
    resources: &'resources Resources,
}

impl<'a, 'b, 'c> LuauPathLocator<'a, 'b, 'c> {
    pub(crate) fn new(
        luau_require_mode: &'a LuauRequireMode,
        extra_module_relative_location: &'b Path,
        resources: &'c Resources,
    ) -> Self {
        Self {
            luau_require_mode,
            extra_module_relative_location,
            resources,
        }
    }
}

impl super::PathLocator for LuauPathLocator<'_, '_, '_> {
    fn find_require_path(
        &self,
        path: impl Into<PathBuf>,
        source: &Path,
    ) -> Result<PathBuf, DarkluaError> {
        let mut path = path.into();
        log::trace!(
            "find require path for `{}` from `{}` (luau mode)",
            path.display(),
            source.display()
        );

        if is_require_relative(&path) {
            if self.luau_require_mode.is_module_folder_name(source) {
                path = get_relative_parent_path(get_relative_parent_path(source)).join(path);
            } else {
                path = get_relative_parent_path(source).join(path);
            }
        } else if !path.is_absolute() {
            let mut components = path.components();
            let root = components.next().ok_or_else(|| {
                DarkluaError::invalid_resource_path(path.display().to_string(), "path is empty")
            })?;
            let source_name = utils::convert_os_string(root.as_os_str()).map_err(|err| {
                err.context(format!(
                    "cannot convert source name to utf-8 in `{}`",
                    path.display(),
                ))
            })?;

            if source_name == "@self" {
                path = get_relative_parent_path(source).join(components);
            } else if source_name.starts_with("@") {
                let mut extra_module_location = self
                    .luau_require_mode
                    .get_source(source_name, self.extra_module_relative_location)
                    .ok_or_else(|| {
                        DarkluaError::invalid_resource_path(
                            path.display().to_string(),
                            format!("unknown source name `{}`", source_name),
                        )
                    })?;
                extra_module_location.extend(components);
                path = extra_module_location;
            }
        }

        let normalized_path = utils::normalize_path_with_current_dir(&path);
        for potential_path in path_iterator::find_require_paths(
            &normalized_path,
            self.luau_require_mode.module_folder_name(),
        ) {
            if self.resources.is_file(&potential_path)? {
                return Ok(utils::normalize_path_with_current_dir(potential_path));
            }
        }

        Err(
            DarkluaError::resource_not_found(&normalized_path).context(format!(
                "tried `{}`",
                path_iterator::find_require_paths(
                    &normalized_path,
                    self.luau_require_mode.module_folder_name(),
                )
                .map(|potential_path| potential_path.display().to_string())
                .collect::<Vec<_>>()
                .join("`, `")
            )),
        )
    }
}
