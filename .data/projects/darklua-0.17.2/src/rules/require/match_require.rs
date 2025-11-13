use std::path::{Path, PathBuf};

use bstr::{BStr, ByteSlice};

use crate::{
    nodes::{Arguments, Expression, FunctionCall, Prefix, StringExpression},
    process::IdentifierTracker,
    utils,
};

const REQUIRE_FUNCTION_IDENTIFIER: &str = "require";

pub(crate) fn is_require_call(call: &FunctionCall, identifier_tracker: &IdentifierTracker) -> bool {
    if call.get_method().is_some() {
        return false;
    }

    match call.get_prefix() {
        Prefix::Identifier(identifier) => {
            identifier.get_name() == REQUIRE_FUNCTION_IDENTIFIER
                && !identifier_tracker.is_identifier_used(REQUIRE_FUNCTION_IDENTIFIER)
        }
        _ => false,
    }
}

fn convert_string_expression_to_path(string: &StringExpression) -> Option<&Path> {
    string
        .get_string_value()
        .map(Path::new)
        .or_else(|| BStr::new(string.get_value()).to_path().ok())
}

pub(crate) fn match_path_require_call(call: &FunctionCall) -> Option<PathBuf> {
    match call.get_arguments() {
        Arguments::String(string) => convert_string_expression_to_path(string),
        Arguments::Tuple(tuple) if tuple.len() == 1 => {
            let expression = tuple.iter_values().next().unwrap();

            match expression {
                Expression::String(string) => convert_string_expression_to_path(string),
                _ => None,
            }
        }
        _ => None,
    }
    .map(utils::normalize_path_with_current_dir)
}
