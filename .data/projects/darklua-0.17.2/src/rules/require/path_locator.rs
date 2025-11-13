use std::path::{Path, PathBuf};

use super::{path_iterator, PathRequireMode};
use crate::{rules::require::path_utils::is_require_relative, utils, DarkluaError, Resources};

#[derive(Debug)]
pub(crate) struct RequirePathLocator<'a, 'b, 'resources> {
    path_require_mode: &'a PathRequireMode,
    extra_module_relative_location: &'b Path,
    resources: &'resources Resources,
}

impl<'a, 'b, 'c> RequirePathLocator<'a, 'b, 'c> {
    pub(crate) fn new(
        path_require_mode: &'a PathRequireMode,
        extra_module_relative_location: &'b Path,
        resources: &'c Resources,
    ) -> Self {
        Self {
            path_require_mode,
            extra_module_relative_location,
            resources,
        }
    }
}

impl super::PathLocator for RequirePathLocator<'_, '_, '_> {
    fn find_require_path(
        &self,
        path: impl Into<PathBuf>,
        source: &Path,
    ) -> Result<PathBuf, DarkluaError> {
        let mut path: PathBuf = path.into();
        log::trace!(
            "find require path for `{}` from `{}`",
            path.display(),
            source.display()
        );

        if is_require_relative(&path) {
            let mut new_path = source.to_path_buf();
            new_path.pop();
            new_path.push(path);
            path = new_path;
        } else if !path.is_absolute() {
            {
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

                let mut extra_module_location = self
                    .path_require_mode
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
        // else: the path is absolute so darklua should attempt to require it directly

        let normalized_path = utils::normalize_path_with_current_dir(&path);
        for potential_path in path_iterator::find_require_paths(
            &normalized_path,
            self.path_require_mode.module_folder_name(),
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
                    self.path_require_mode.module_folder_name(),
                )
                .map(|potential_path| potential_path.display().to_string())
                .collect::<Vec<_>>()
                .join("`, `")
            )),
        )
    }
}
