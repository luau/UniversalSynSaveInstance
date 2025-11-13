use darklua_core::rules::{ConvertLocalFunctionToAssign, Rule};

test_rule!(
    convert_local_function_to_assign,
    ConvertLocalFunctionToAssign::default(),
    empty_function("local function foo() end") => "local foo = function() end",
    empty_function_with_arguments("local function foo(a, b) end") => "local foo = function(a, b) end",
    empty_variadic_function("local function foo(...) end") => "local foo = function(...) end",
    empty_variadic_function_with_arguments("local function foo(a, b, c, ...) end") => "local foo = function(a, b, c, ...) end",
    function_with_block("local function foo() return true end") => "local foo = function() return true end",
    name_in_parameters("local function foo(foo) return foo end") => "local foo = function(foo) return foo end"
);

test_rule_without_effects!(
    ConvertLocalFunctionToAssign::default(),
    two_local_using_the_other("local function foo() foo() end")
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'convert_local_function_to_assign',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'convert_local_function_to_assign'").unwrap();
}
