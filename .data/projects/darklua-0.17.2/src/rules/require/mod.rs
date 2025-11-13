mod luau_path_locator;
mod luau_require_mode;
mod match_require;
mod path_iterator;
mod path_locator;
mod path_require_mode;
pub(crate) mod path_utils;

use std::path::{Path, PathBuf};

pub(crate) use luau_path_locator::LuauPathLocator;
pub use luau_require_mode::LuauRequireMode;
pub(crate) use match_require::{is_require_call, match_path_require_call};
pub(crate) use path_locator::RequirePathLocator;
pub use path_require_mode::PathRequireMode;

use crate::DarkluaError;

pub(crate) trait PathLocator {
    fn find_require_path(
        &self,
        path: impl Into<PathBuf>,
        source: &Path,
    ) -> Result<PathBuf, DarkluaError>;
}
