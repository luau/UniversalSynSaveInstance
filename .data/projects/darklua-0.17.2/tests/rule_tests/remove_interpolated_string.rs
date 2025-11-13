use darklua_core::rules::{RemoveInterpolatedString, Rule};

test_rule!(
    remove_interpolated_string,
    RemoveInterpolatedString::default(),
    empty_string("return ``") => "return ''",
    regular_string("return `abc`") => "return 'abc'",
    string_with_single_quote("return `'`") => "return \"'\"",
    string_with_double_quote("return `\"`") => "return '\"'",
    string_with_variable("return `{object}`") => "return tostring(object)",
    nested_interpolated_string("return `{'+' .. `{object}`}`") => "return tostring('+' .. tostring(object))",
    string_prefix_with_variable("return `-{object}`") => "return string.format('-%s', tostring(object))",
    string_prefix_need_escaping_with_variable("return `%{object}`") => "return string.format('%%%s', tostring(object))",
    string_suffix_with_variable("return `{object}-`") => "return string.format('%s-', tostring(object))",
    string_with_variable_shadowing_tostring("local tostring return `{object}`")
        => "local __DARKLUA_TO_STR = tostring local tostring return __DARKLUA_TO_STR(object)",
    string_prefix_need_escaping_with_variable_shadowing_tostring("local tostring return `%{object}`")
        => "local __DARKLUA_TO_STR = tostring local tostring return string.format('%%%s', __DARKLUA_TO_STR(object))",
    string_prefix_need_escaping_with_variable_shadowing_string("local string return `%{object}`")
        => "local __DARKLUA_STR_FMT = string.format local string return __DARKLUA_STR_FMT('%%%s', tostring(object))",
    string_prefix_need_escaping_with_variable_shadowing_string_and_tostring("local string, tostring return `%{object}`")
        => "local __DARKLUA_STR_FMT, __DARKLUA_TO_STR = string.format, tostring local string, tostring return __DARKLUA_STR_FMT('%%%s', __DARKLUA_TO_STR(object))",
    two_strings_with_variable_shadowing_tostring("local tostring local a, b = `{object}`, `{var}`")
    => "local __DARKLUA_TO_STR = tostring local tostring local a, b = __DARKLUA_TO_STR(object), __DARKLUA_TO_STR(var)",
);

test_rule!(
    remove_interpolated_string_using_tostring_specifier,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_interpolated_string',
        strategy: 'tostring',
    }"#,
    )
    .unwrap(),
    empty_string("return ``") => "return ''",
    regular_string("return `abc`") => "return 'abc'",
    string_with_single_quote("return `'`") => "return \"'\"",
    string_with_double_quote("return `\"`") => "return '\"'",
    string_with_variable("return `{object}`") => "return tostring(object)",
    nested_interpolated_string("return `{'+' .. `{object}`}`") => "return tostring('+' .. tostring(object))",
    string_prefix_with_variable("return `-{object}`") => "return string.format('-%*', object)",
    string_prefix_need_escaping_with_variable("return `%{object}`") => "return string.format('%%%*', object)",
    string_suffix_with_variable("return `{object}-`") => "return string.format('%*-', object)",
    string_with_variable_shadowing_tostring("local tostring return `{object}`")
        => "local __DARKLUA_TO_STR = tostring local tostring return __DARKLUA_TO_STR(object)",
    string_prefix_need_escaping_with_variable_shadowing_tostring("local tostring return `%{object}`")
        => "local tostring return string.format('%%%*', object)",
    string_prefix_need_escaping_with_variable_shadowing_string("local string return `%{object}`")
        => "local __DARKLUA_STR_FMT = string.format local string return __DARKLUA_STR_FMT('%%%*', object)",
    string_prefix_need_escaping_with_variable_shadowing_string_and_tostring("local string, tostring return `%{object}`")
        => "local __DARKLUA_STR_FMT = string.format local string, tostring return __DARKLUA_STR_FMT('%%%*', object)",
    two_strings_with_variable_shadowing_tostring("local tostring local a, b = `{object}`, `{var}`")
        => "local __DARKLUA_TO_STR = tostring local tostring local a, b = __DARKLUA_TO_STR(object), __DARKLUA_TO_STR(var)",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_interpolated_string',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_interpolated_string'").unwrap();
}
