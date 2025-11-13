use darklua_core::rules::{RenameVariables, Rule};

test_rule!(
    rename_variables_and_functions,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'rename_variables',
        include_functions: true,
    }"#,
    ).unwrap(),
    local_function_name("local function foo() end") => "local function a() end",
    local_function_name_parameters("local function foo(bar, baz) end")
        => "local function a(b, c) end",
    local_function_name_reference("local function foo() end return foo()")
        => "local function a() end return a()",
    redefine_local_function_name("local var local function a() return var end")
        => "local a local function b() return a end",
    // rename variable only cases
    local_assign("local foo") => "local a",
    local_assign_with_multiple_variable("local foo, bar") => "local a, b",
    local_assign_reference("local foo return foo") => "local a return a",
    local_assign_values_are_processed_first("local foo; local foo, bar = 1, foo")
        => "local a; local b, c = 1, a",
    numeric_for_identifier("for i=1, 10 do foo = i end") => "for a=1, 10 do foo=a end",
    generic_for_identifiers("for key, value in t do return key end")
        => "for a, b in t do return a end",
    repeat_condition_is_from_block("local foo repeat local bar until bar")
        => "local a repeat local b until b",
    while_statement("local foo while foo do local foo end") => "local a while a do local b end",
    if_statement("local foo if foo then return foo end") => "local a if a then return a end",
    if_with_else("local foo if foo then local foo else return foo end")
        => "local a if a then local b else return a end",
    if_with_elseif_and_else("local foo if foo then elseif not foo then else return foo end")
        => "local a if a then elseif not a then else return a end",
    global_function_parameter("function foo(bar) end") => "function foo(a) end",
    global_function_parameter_reference("function foo(bar) return bar end")
        => "function foo(a) return a end",
    global_function_parameter_reference_named_self("function foo(self) return self end")
        => "function foo(a) return a end",
    global_function_with_field_parameter_reference_named_self("function foo.fn(self) return self end")
        => "function foo.fn(a) return a end",
    global_function_name("local foo; function foo() end") => "local a; function a() end",
    function_expression_parameters("return function(foo, bar) end") => "return function(a, b) end",
    function_expression_parameters_reference("return function(foo, bar) return foo + bar end")
        => "return function(a, b) return a + b end",
    recycle_previous_identifiers("do local foo end local foo") => "do local a end local a",
    reexported_type_field("local types = require('./types') export type Oof = types.Oof") => "local a = require('./types') export type Oof = a.Oof",
    type_variable_type_field("local React = require('@pkg/@jsdotlua/react') type Props = { children: React.ReactNode }")
        => "local a = require('@pkg/@jsdotlua/react') type Props = { children: a.ReactNode }",
);

test_rule!(
    rename_variables,
    RenameVariables::default(),
    local_function_name_parameters("local function foo(bar, baz) end")
        => "local function foo(a, b) end",
    avoid_defined_local_function_name("local var local function a() return var end")
        => "local b local function a() return b end",
    method_function_do_not_rename_self("function class:foo(bar, baz) return self._prop end")
        => "function class:foo(a, b) return self._prop end",
    method_function_do_not_rename_self_but_rename_self_as_variable("local self = 1 function class:foo(bar) return self._prop end return self")
        => "local a = 1 function class:foo(b) return self._prop end return a",
    rename_variable_but_keep_redeclared_function_name("local fn = nil print(fn) local function fn() end return fn")
        => "local a = nil print(a) local function fn() end return fn",
    // rename variable only cases
    local_assign("local foo") => "local a",
    local_assign_with_multiple_variable("local foo, bar") => "local a, b",
    local_assign_reference("local foo return foo") => "local a return a",
    local_assign_values_are_processed_first("local foo; local foo, bar = 1, foo")
        => "local a; local b, c = 1, a",
    numeric_for_identifier("for i=1, 10 do foo = i end") => "for a=1, 10 do foo=a end",
    generic_for_identifiers("for key, value in t do return key end")
        => "for a, b in t do return a end",
    repeat_condition_is_from_block("local foo repeat local bar until bar")
        => "local a repeat local b until b",
    while_statement("local foo while foo do local foo end") => "local a while a do local b end",
    if_statement("local foo if foo then return foo end") => "local a if a then return a end",
    if_with_else("local foo if foo then local foo else return foo end")
        => "local a if a then local b else return a end",
    if_with_elseif_and_else("local foo if foo then elseif not foo then else return foo end")
        => "local a if a then elseif not a then else return a end",
    global_function_parameter("function foo(bar) end") => "function foo(a) end",
    global_function_parameter_reference("function foo(bar) return bar end")
        => "function foo(a) return a end",
    global_function_parameter_reference_named_self("function foo(self) return self end")
        => "function foo(a) return a end",
    global_function_with_field_parameter_reference_named_self("function foo.fn(self) return self end")
        => "function foo.fn(a) return a end",
    global_function_name("local foo; function foo() end") => "local a; function a() end",
    function_expression_parameters("return function(foo, bar) end") => "return function(a, b) end",
    function_expression_parameters_reference("return function(foo, bar) return foo + bar end")
        => "return function(a, b) return a + b end",
    recycle_previous_identifiers("do local foo end local foo") => "do local a end local a",
    reexported_type_field("local types = require('./types') export type Oof = types.Oof") => "local a = require('./types') export type Oof = a.Oof",
    type_variable_type_field("local React = require('@pkg/@jsdotlua/react') type Props = { children: React.ReactNode }")
        => "local a = require('@pkg/@jsdotlua/react') type Props = { children: a.ReactNode }",
);

test_rule_without_effects!(
    RenameVariables::default(),
    local_function_name("local function foo() end"),
    does_not_rename_functions("local function foo() end return foo()"),
);

#[test]
fn deserialize_with_special_empty_globals() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'rename_variables',
        globals: []
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_with_special_default_globals() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'rename_variables',
        globals: ['$default']
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_with_special_roblox_globals() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'rename_variables',
        globals: ['$roblox']
    }"#,
    )
    .unwrap();
}
