use std::str::FromStr;

use serde::{Deserialize, Serialize};

use crate::rules::{
    require::{LuauPathLocator, LuauRequireMode, PathRequireMode, RequirePathLocator},
    RuleProcessResult,
};
use crate::{nodes::Block, rules::Context};

use super::{path_require_mode, BundleOptions};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case", tag = "name")]
pub enum BundleRequireMode {
    Path(PathRequireMode),
    Luau(LuauRequireMode),
}

impl From<PathRequireMode> for BundleRequireMode {
    fn from(mode: PathRequireMode) -> Self {
        Self::Path(mode)
    }
}

impl FromStr for BundleRequireMode {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "path" => Self::Path(Default::default()),
            "luau" => Self::Luau(Default::default()),
            _ => return Err(format!("invalid require mode `{}`", s)),
        })
    }
}

impl Default for BundleRequireMode {
    fn default() -> Self {
        Self::Path(Default::default())
    }
}

impl BundleRequireMode {
    pub(crate) fn process_block(
        &self,
        block: &mut Block,
        context: &Context,
        options: &BundleOptions,
    ) -> RuleProcessResult {
        match self {
            Self::Path(path_require_mode) => {
                let mut require_mode = path_require_mode.clone();
                require_mode
                    .initialize(context)
                    .map_err(|err| err.to_string())?;

                let locator = RequirePathLocator::new(
                    &require_mode,
                    context.project_location(),
                    context.resources(),
                );

                path_require_mode::process_block(block, context, options, locator)
            }
            Self::Luau(luau_require_mode) => {
                let mut require_mode = luau_require_mode.clone();
                require_mode
                    .initialize(context)
                    .map_err(|err| err.to_string())?;

                let locator = LuauPathLocator::new(
                    &require_mode,
                    context.project_location(),
                    context.resources(),
                );

                path_require_mode::process_block(block, context, options, locator)
            }
        }
    }
}
