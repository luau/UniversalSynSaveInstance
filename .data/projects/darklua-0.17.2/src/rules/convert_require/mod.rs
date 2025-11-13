mod instance_path;
mod roblox_index_style;
mod roblox_require_mode;
mod rojo_sourcemap;

use serde::{Deserialize, Serialize};

use crate::frontend::DarkluaResult;
use crate::nodes::{Arguments, Block, FunctionCall};
use crate::process::{DefaultVisitor, IdentifierTracker, NodeProcessor, NodeVisitor};
use crate::rules::require::is_require_call;
use crate::rules::{Context, RuleConfiguration, RuleConfigurationError, RuleProperties};

use instance_path::InstancePath;
pub use roblox_index_style::RobloxIndexStyle;
pub use roblox_require_mode::RobloxRequireMode;

use super::{verify_required_properties, PathRequireMode, Rule, RuleProcessResult};
use crate::rules::require::LuauRequireMode;

use std::ffi::OsStr;
use std::ops::{Deref, DerefMut};
use std::path::{Path, PathBuf};
use std::str::FromStr;

/// A representation of how require calls are handled and transformed.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields, rename_all = "snake_case", tag = "name")]
pub enum RequireMode {
    /// Handles requires using file system paths
    Path(PathRequireMode),
    /// Handles requires using Luau module paths
    Luau(LuauRequireMode),
    /// Handles requires using Roblox's instance-based require system
    Roblox(RobloxRequireMode),
}

impl RequireMode {
    pub(crate) fn find_require(
        &self,
        call: &FunctionCall,
        context: &Context,
    ) -> DarkluaResult<Option<PathBuf>> {
        match self {
            RequireMode::Path(path_mode) => path_mode.find_require(call, context),
            RequireMode::Luau(luau_mode) => luau_mode.find_require(call, context),
            RequireMode::Roblox(roblox_mode) => roblox_mode.find_require(call, context),
        }
    }

    fn generate_require(
        &self,
        path: &Path,
        current_mode: &Self,
        context: &Context,
    ) -> DarkluaResult<Option<Arguments>> {
        match self {
            RequireMode::Path(path_mode) => path_mode.generate_require(path, current_mode, context),
            RequireMode::Luau(luau_mode) => luau_mode.generate_require(path, current_mode, context),
            RequireMode::Roblox(roblox_mode) => {
                roblox_mode.generate_require(path, current_mode, context)
            }
        }
    }

    fn is_module_folder_name(&self, path: &Path) -> bool {
        match self {
            RequireMode::Path(path_mode) => path_mode.is_module_folder_name(path),
            RequireMode::Luau(luau_mode) => luau_mode.is_module_folder_name(path),
            RequireMode::Roblox(_roblox_mode) => {
                matches!(path.file_stem().and_then(OsStr::to_str), Some("init"))
            }
        }
    }

    fn initialize(&mut self, context: &Context) -> DarkluaResult<()> {
        match self {
            RequireMode::Roblox(roblox_mode) => roblox_mode.initialize(context),
            RequireMode::Path(path_mode) => path_mode.initialize(context),
            RequireMode::Luau(luau_mode) => luau_mode.initialize(context),
        }
    }
}

impl FromStr for RequireMode {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s {
            "path" => Self::Path(Default::default()),
            "luau" => Self::Luau(Default::default()),
            "roblox" => Self::Roblox(Default::default()),
            _ => return Err(format!("invalid require mode name `{}`", s)),
        })
    }
}

#[derive(Debug, Clone)]
struct RequireConverter<'a> {
    identifier_tracker: IdentifierTracker,
    current: RequireMode,
    target: RequireMode,
    context: &'a Context<'a, 'a, 'a>,
}

impl Deref for RequireConverter<'_> {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl DerefMut for RequireConverter<'_> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

impl<'a> RequireConverter<'a> {
    fn new(current: RequireMode, target: RequireMode, context: &'a Context) -> Self {
        Self {
            identifier_tracker: IdentifierTracker::new(),
            current,
            target,
            context,
        }
    }

    fn try_require_conversion(&mut self, call: &mut FunctionCall) -> DarkluaResult<()> {
        if let Some(require_path) = self.current.find_require(call, self.context)? {
            log::trace!("found require path `{}`", require_path.display());

            if let Some(new_arguments) =
                self.target
                    .generate_require(&require_path, &self.current, self.context)?
            {
                call.set_arguments(new_arguments);
            }
        }
        Ok(())
    }
}

impl NodeProcessor for RequireConverter<'_> {
    fn process_function_call(&mut self, call: &mut FunctionCall) {
        if is_require_call(call, self) {
            match self.try_require_conversion(call) {
                Ok(()) => {}
                Err(err) => {
                    log::warn!("{}", err);
                }
            }
        }
    }
}

pub const CONVERT_REQUIRE_RULE_NAME: &str = "convert_require";

/// A rule that converts require calls between environments
#[derive(Debug, PartialEq, Eq)]
pub struct ConvertRequire {
    current: RequireMode,
    target: RequireMode,
}

impl Default for ConvertRequire {
    fn default() -> Self {
        Self {
            current: RequireMode::Path(Default::default()),
            target: RequireMode::Roblox(Default::default()),
        }
    }
}

impl Rule for ConvertRequire {
    fn process(&self, block: &mut Block, context: &Context) -> RuleProcessResult {
        let mut current_mode = self.current.clone();
        current_mode
            .initialize(context)
            .map_err(|err| err.to_string())?;

        let mut target_mode = self.target.clone();
        target_mode
            .initialize(context)
            .map_err(|err| err.to_string())?;

        let mut processor = RequireConverter::new(current_mode, target_mode, context);
        DefaultVisitor::visit_block(block, &mut processor);
        Ok(())
    }
}

impl RuleConfiguration for ConvertRequire {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_required_properties(&properties, &["current", "target"])?;

        for (key, value) in properties {
            match key.as_str() {
                "current" => {
                    self.current = value.expect_require_mode(&key)?;
                }
                "target" => {
                    self.target = value.expect_require_mode(&key)?;
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        CONVERT_REQUIRE_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> ConvertRequire {
        ConvertRequire::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_convert_require", rule);
    }

    #[test]
    fn configure_with_invalid_require_mode_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_require',
            current: 'path',
            target: 'rblox',
        }"#,
        );
        pretty_assertions::assert_eq!(
            result.unwrap_err().to_string(),
            "unexpected value for field 'target': invalid require mode name `rblox`"
        );
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_require',
            current: 'path',
            target: 'path',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
