use std::{
    cell::RefCell,
    collections::HashMap,
    path::{Path, PathBuf},
};

use serde::Deserialize;

use crate::{utils::normalize_path, DarkluaError, Resources};

const LUAU_RC_FILE_NAME: &str = ".luaurc";

#[derive(Debug, Clone, Default, Deserialize, PartialEq, Eq)]
pub(crate) struct LuauConfiguration {
    #[serde(default)]
    pub(crate) aliases: HashMap<String, PathBuf>,
}

fn find_luau_configuration_private(
    luau_file: &Path,
    resources: &Resources,
) -> Result<Option<LuauConfiguration>, DarkluaError> {
    log::debug!(
        "find closest {} for '{}'",
        LUAU_RC_FILE_NAME,
        luau_file.display()
    );

    for ancestor in luau_file.ancestors() {
        let config_path = ancestor.join(LUAU_RC_FILE_NAME);

        if resources.exists(&config_path)? {
            let config = resources.get(&config_path)?;
            log::trace!(
                "attempt to parse luau configuration at '{}'",
                config_path.display()
            );

            return serde_json::from_str(&config)
                .map(|mut config: LuauConfiguration| {
                    log::debug!("found luau configuration at '{}'", config_path.display());

                    config.aliases = config
                        .aliases
                        .into_iter()
                        .map(|(mut key, value)| {
                            key.insert(0, '@');
                            (key, normalize_path(ancestor.join(value)))
                        })
                        .inspect(|(key, value)| {
                            log::trace!(" ⨽ parsed alias `{}` (`{}`)", key, value.display())
                        })
                        .collect();

                    Some(config)
                })
                .map_err(Into::into);
        }
    }

    Ok(None)
}

thread_local! {
    static LUAU_RC_CACHE: RefCell<HashMap<Option<PathBuf>, Option<LuauConfiguration>>> =  RefCell::new(HashMap::new());
}

pub(crate) fn find_luau_configuration(
    luau_file: &Path,
    resources: &Resources,
) -> Result<Option<LuauConfiguration>, DarkluaError> {
    let key = luau_file.parent().map(Path::to_path_buf);

    LUAU_RC_CACHE.with(|luau_rc_cache| {
        {
            let cache = luau_rc_cache.borrow();

            let res = cache.get(&key);
            if let Some(res) = res {
                log::trace!(
                    "found luau configuration in cache for '{}'",
                    luau_file.display()
                );
                return Ok(res.clone());
            }
        }

        let mut cache = luau_rc_cache.borrow_mut();

        let value = find_luau_configuration_private(luau_file, resources)?;

        cache.insert(key, value.clone());

        Ok(value)
    })
}

pub fn clear_luau_configuration_cache() {
    LUAU_RC_CACHE.with(|luau_rc_cache| {
        let mut cache = luau_rc_cache.borrow_mut();
        cache.clear();
        log::debug!("luau configuration cache cleared");
    })
}
