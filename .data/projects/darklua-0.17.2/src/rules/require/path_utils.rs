use std::path::{Component, Path, PathBuf};

use crate::{
    frontend::DarkluaResult,
    utils::{convert_os_string, normalize_path_with_current_dir},
    DarkluaError,
};

pub(crate) fn get_relative_path(
    require_path: &Path,
    source_path: &Path,
    use_current_dir_prefix: bool,
) -> Result<Option<PathBuf>, DarkluaError> {
    let source_parent = get_relative_parent_path(source_path);

    if require_path.has_root() && !source_parent.has_root() {
        return Ok(None);
    }

    Ok(pathdiff::diff_paths(require_path, source_parent)
        .map(|path| {
            if use_current_dir_prefix && !path.starts_with(".") && !path.starts_with("..") {
                Path::new(".").join(path)
            } else if !use_current_dir_prefix && path.starts_with(".") {
                path.strip_prefix(".")
                    .map(Path::to_path_buf)
                    .ok()
                    .unwrap_or(path)
            } else {
                path
            }
        })
        .map(normalize_path_with_current_dir))
}

pub(crate) fn get_relative_parent_path(path: &Path) -> &Path {
    match path.parent() {
        Some(parent) => {
            if parent == Path::new("") {
                Path::new(".")
            } else {
                parent
            }
        }
        None => Path::new(".."),
    }
}

/// This function is an alternative to the `is_relative` method from std::path::Path.
/// Darklua considers a require relative if the path starts with `.` or `..`.
pub(crate) fn is_require_relative(path: &Path) -> bool {
    path.starts_with(Path::new(".")) || path.starts_with(Path::new(".."))
}

pub(crate) fn write_require_path(path: &Path) -> DarkluaResult<String> {
    path.components()
        .try_fold(String::new(), |mut result, component| {
            if !(result.is_empty() || result.ends_with('/')) {
                result.push('/');
            }

            match component {
                Component::CurDir => {
                    result.push('.');
                }
                Component::ParentDir => {
                    result.push('.');
                    result.push('.');
                }
                Component::Normal(name) => {
                    return convert_os_string(name).map(|name| {
                        result.push_str(name);
                        result
                    });
                }
                Component::Prefix(prefix) => {
                    return convert_os_string(prefix.as_os_str()).map(|name| {
                        result.push_str(name);
                        result
                    });
                }
                Component::RootDir => {
                    if result.is_empty() {
                        result.push('/');
                    }
                }
            }

            Ok(result)
        })
}

#[cfg(test)]
mod test {
    use super::*;

    mod write_require_path {
        use super::*;

        macro_rules! test_write_require_path {
            ($($test_name:ident($path:expr) => $expected:expr),* $(,)?) => {
                $(
                    #[test]
                    fn $test_name() {
                        let path = Path::new($path);
                        let result = write_require_path(path).unwrap();

                        pretty_assertions::assert_eq!(result, $expected);
                    }
                )*
            };
        }

        test_write_require_path!(
            writes_current_dir(".") => ".",
            writes_parent_dir("..") => "..",
            writes_root_dir("/") => "/",
            relative_path("./folder") => "./folder",
            relative_path_to_file_with_extension("./folder/module.lua") => "./folder/module.lua",
            writes_root_dir_1_level("/root") => "/root",
            writes_root_dir_2_levels("/root/lib") => "/root/lib",
            writes_root_dir_3_levels("/root/lib/name") => "/root/lib/name",
            writes_root_dir_3_levels_with_extension("/root/lib/name.luau") => "/root/lib/name.luau",
        );

        #[cfg(windows)]
        test_write_require_path!(
            writes_root_with_prefix("c:\\root") => "c:/root",
        );
    }
}
