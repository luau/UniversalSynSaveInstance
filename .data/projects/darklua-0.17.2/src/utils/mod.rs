mod expressions_as_statement;
pub(crate) mod lines;
mod luau_config;
mod preserve_arguments_side_effects;
mod scoped_hash_map;
mod serde_string_or_struct;
mod timer;

pub(crate) use expressions_as_statement::{expressions_as_expression, expressions_as_statement};
pub(crate) use luau_config::{clear_luau_configuration_cache, find_luau_configuration};
pub(crate) use preserve_arguments_side_effects::preserve_arguments_side_effects;
pub(crate) use scoped_hash_map::ScopedHashMap;
pub(crate) use serde_string_or_struct::string_or_struct;
use std::{
    ffi::OsStr,
    iter::FromIterator,
    path::{Component, Path, PathBuf},
};
pub use timer::Timer;

use crate::DarkluaError;

pub(crate) fn convert_os_string(os_str: &OsStr) -> Result<&str, DarkluaError> {
    os_str
        .to_str()
        .ok_or_else(|| DarkluaError::os_string_conversion(os_str))
}

pub(crate) fn normalize_path(path: impl AsRef<Path>) -> PathBuf {
    normalize(path, false)
}

pub(crate) fn normalize_path_with_current_dir(path: impl AsRef<Path>) -> PathBuf {
    normalize(path, true)
}

#[inline]
fn current_dir() -> &'static OsStr {
    OsStr::new(".")
}

#[inline]
fn parent_dir() -> &'static OsStr {
    OsStr::new("..")
}

fn normalize(path: impl AsRef<Path>, keep_current_dir: bool) -> PathBuf {
    let path = path.as_ref();

    if path == Path::new("") {
        return PathBuf::new();
    }

    let mut components = path.components().peekable();
    let mut ret = if let Some(c @ Component::Prefix(..)) = components.peek().cloned() {
        components.next();
        vec![c.as_os_str()]
    } else {
        Vec::new()
    };

    for component in components {
        match component {
            Component::Prefix(..) => unreachable!(),
            Component::RootDir => {
                ret.push(component.as_os_str());
            }
            Component::CurDir => {
                if keep_current_dir && ret.is_empty() {
                    ret.push(current_dir());
                }
            }
            Component::ParentDir => {
                if let Some(last) = ret.last() {
                    let last = *last;
                    if last == current_dir() {
                        ret.pop();
                        ret.push(parent_dir());
                    } else if last != parent_dir() {
                        ret.pop();
                    } else {
                        ret.push(parent_dir());
                    }
                } else {
                    ret.push(parent_dir());
                }
            }
            Component::Normal(c) => {
                ret.push(c);
            }
        }
    }

    if ret.is_empty() {
        ret.push(OsStr::new("."));
    }

    PathBuf::from_iter(ret)
}

#[cfg(test)]
mod test {
    use super::*;

    fn verify_normalize_path(input: impl AsRef<Path>, output: impl AsRef<Path>) {
        assert_eq!(normalize_path(input.as_ref()), output.as_ref());
    }

    #[test]
    fn current_directory_with_name() {
        verify_normalize_path("./directory", "directory")
    }

    #[test]
    fn from_directory() {
        verify_normalize_path("/directory", "/directory")
    }

    #[test]
    fn parent_directory_path() {
        verify_normalize_path("..", "..")
    }

    #[test]
    fn current_directory_path() {
        verify_normalize_path(".", ".")
    }

    #[test]
    fn src_parent_with_directory_name() {
        verify_normalize_path("src/../directory", "directory")
    }

    #[test]
    fn src_current_dir_with_directory_name() {
        verify_normalize_path("src/./directory", "src/directory")
    }

    #[test]
    fn double_parent_directory_path() {
        verify_normalize_path("../..", "../..")
    }

    #[test]
    fn current_dir_parent_directory_path() {
        verify_normalize_path("./..", "..")
    }

    #[test]
    fn parent_directory_of_directory_inside_current_path() {
        verify_normalize_path("./directory/..", ".")
    }

    #[test]
    fn empty_path() {
        verify_normalize_path("", "")
    }

    mod with_current_dir {
        use super::*;

        fn verify_normalize_path_with_current_dir(
            input: impl AsRef<Path>,
            output: impl AsRef<Path>,
        ) {
            assert_eq!(
                normalize_path_with_current_dir(input.as_ref()),
                output.as_ref()
            );
        }

        #[test]
        fn current_directory_with_name() {
            verify_normalize_path_with_current_dir("./directory", "./directory")
        }

        #[test]
        fn src_parent_with_directory_name_from_current_directory() {
            verify_normalize_path_with_current_dir("./src/../directory", "./directory")
        }

        #[test]
        fn current_dir_parent_directory_path() {
            verify_normalize_path_with_current_dir("./..", "..")
        }

        #[test]
        fn current_directory_path() {
            verify_normalize_path_with_current_dir(".", ".")
        }

        #[test]
        fn parent_directory_of_directory_inside_current_path() {
            verify_normalize_path_with_current_dir("./directory/..", ".")
        }

        #[test]
        fn empty_path() {
            verify_normalize_path_with_current_dir("", "")
        }
    }
}
