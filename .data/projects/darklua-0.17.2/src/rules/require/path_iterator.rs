use std::{
    ffi::OsStr,
    path::{Path, PathBuf},
};

pub(crate) fn find_require_paths<'a, 'b, 'c>(
    path: &'a Path,
    module_folder_name: &'b str,
) -> impl Iterator<Item = PathBuf> + 'c
where
    'a: 'c,
    'b: 'c,
{
    PathIterator::new(path, module_folder_name)
}

struct PathIterator<'a, 'b> {
    path: &'a Path,
    extension: Option<&'a OsStr>,
    file_name: Option<&'a OsStr>,
    module_folder_name: &'b str,
    index: u8,
}

impl<'a, 'b> PathIterator<'a, 'b> {
    fn new(path: &'a Path, module_folder_name: &'b str) -> Self {
        Self {
            path,
            extension: path.extension(),
            file_name: path.file_name(),
            module_folder_name,
            index: 0,
        }
    }

    #[inline]
    fn return_next(&mut self, path: PathBuf) -> Option<PathBuf> {
        self.index += 1;
        Some(path)
    }
}

impl Iterator for PathIterator<'_, '_> {
    type Item = PathBuf;

    fn next(&mut self) -> Option<Self::Item> {
        if self.index == 0 {
            return self.return_next(self.path.to_path_buf());
        }

        match (self.extension, self.file_name) {
            (Some(extension), _) if matches!(extension.to_str(), Some("luau" | "lua")) => None,
            (_, Some(name)) => match self.index {
                1 => {
                    let mut next_name = name.to_os_string();
                    next_name.push(".luau");
                    self.return_next(self.path.with_file_name(next_name))
                }
                2 => {
                    let mut next_name = name.to_os_string();
                    next_name.push(".lua");
                    self.return_next(self.path.with_file_name(next_name))
                }
                3 => self.return_next(self.path.join(self.module_folder_name)),
                4 | 5 => {
                    let mut next_path = self.path.join(self.module_folder_name);
                    if next_path.extension().is_some() {
                        None
                    } else {
                        next_path.set_extension(if self.index == 4 { "luau" } else { "lua" });
                        self.return_next(next_path)
                    }
                }
                _ => None,
            },
            (_, None) => match self.index {
                1 => self.return_next(self.path.join(self.module_folder_name)),
                2 | 3 => {
                    let mut next_path = self.path.join(self.module_folder_name);
                    if next_path.extension().is_some() {
                        None
                    } else {
                        next_path.set_extension(if self.index == 2 { "luau" } else { "lua" });
                        self.return_next(next_path)
                    }
                }
                _ => None,
            },
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    const ANY_FOLDER_NAME: &str = "test";
    const ANY_FOLDER_NAME_WITH_EXTENSION: &str = "test.luau";

    #[test]
    fn returns_exact_path_when_path_has_a_lua_extension() {
        let source = Path::new("hello.lua");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(vec![source.to_path_buf()], iterator.collect::<Vec<_>>())
    }

    #[test]
    fn returns_exact_path_when_path_has_a_luau_extension() {
        let source = Path::new("hello.luau");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(vec![source.to_path_buf()], iterator.collect::<Vec<_>>())
    }

    #[test]
    fn returns_paths_when_a_random_extension() {
        let source = Path::new("hello.global");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                PathBuf::from("hello.global.luau"),
                PathBuf::from("hello.global.lua"),
                source.join(ANY_FOLDER_NAME),
                source.join(ANY_FOLDER_NAME).with_extension("luau"),
                source.join(ANY_FOLDER_NAME).with_extension("lua"),
            ],
            iterator.collect::<Vec<_>>()
        )
    }

    #[test]
    fn returns_paths_when_path_has_no_extension() {
        let source = Path::new("hello");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                source.with_extension("luau"),
                source.with_extension("lua"),
                source.join(ANY_FOLDER_NAME),
                source.join(ANY_FOLDER_NAME).with_extension("luau"),
                source.join(ANY_FOLDER_NAME).with_extension("lua"),
            ],
            iterator.collect::<Vec<_>>()
        )
    }

    #[test]
    fn returns_paths_when_path_is_dot_luau() {
        let source = Path::new(".luau");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                source.with_extension("luau"),
                source.with_extension("lua"),
                source.join(ANY_FOLDER_NAME),
                source.join(ANY_FOLDER_NAME).with_extension("luau"),
                source.join(ANY_FOLDER_NAME).with_extension("lua"),
            ],
            iterator.collect::<Vec<_>>()
        )
    }

    #[test]
    fn returns_paths_when_path_is_parent() {
        let source = Path::new("..");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                source.join(ANY_FOLDER_NAME),
                source.join(ANY_FOLDER_NAME).with_extension("luau"),
                source.join(ANY_FOLDER_NAME).with_extension("lua"),
            ],
            iterator.collect::<Vec<_>>()
        )
    }

    #[test]
    fn returns_paths_when_path_is_current_directory() {
        let source = Path::new(".");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                source.join(ANY_FOLDER_NAME),
                source.join(ANY_FOLDER_NAME).with_extension("luau"),
                source.join(ANY_FOLDER_NAME).with_extension("lua"),
            ],
            iterator.collect::<Vec<_>>()
        )
    }

    #[test]
    fn returns_paths_when_path_has_no_extension_and_module_folder_name_has_an_extension() {
        let source = Path::new("hello");
        let iterator = PathIterator::new(source, ANY_FOLDER_NAME_WITH_EXTENSION);

        pretty_assertions::assert_eq!(
            vec![
                source.to_path_buf(),
                source.with_extension("luau"),
                source.with_extension("lua"),
                source.join(ANY_FOLDER_NAME_WITH_EXTENSION),
            ],
            iterator.collect::<Vec<_>>()
        )
    }
}
