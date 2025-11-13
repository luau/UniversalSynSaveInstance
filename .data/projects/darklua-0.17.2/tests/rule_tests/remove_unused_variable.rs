use darklua_core::rules::{RemoveUnusedVariable, Rule};

test_rule!(
    remove_unused_variable,
    RemoveUnusedVariable::default(),
    remove_unused_local("local foo = true") => "",
    remove_two_unused_local("local foo, bar = true") => "",
    remove_unused_local_function("local function foo() end") => "",
    remove_unused_local_function_single_statement("local function foo() end") => "",
    remove_unused_local_function_recursive("local function foo() foo() end") => "",
    remove_function_used_by_unused_function(
        "local function foo() end local function bar() foo() end"
    ) => "",
    remove_local_but_keep_function_call("local foo = print('hello')") => "print('hello')",
    remove_two_locals_but_keep_function_call(
        "local foo, bar = print('hello')"
    ) => "print('hello')",
    remove_two_locals_and_a_value_but_keep_function_call(
        "local foo, bar = print('hello'), false"
    ) => "print('hello')",
    remove_one_local_and_keep_side_effect_value(
        "local foo = true, print('hello')"
    ) => "print('hello')",
    remove_first_local_and_keep_multiple_side_effect_values(
        "local foo, bar = true, false, print('hello'), print('bye') return bar"
    ) => "local bar = false, print('hello'), print('bye') return bar",
    remove_second_local_and_keep_multiple_side_effect_values(
        "local foo, bar = true, false, print('hello'), print('bye') return foo"
    ) => "local foo = true, print('hello'), print('bye') return foo",
    keep_only_used_constants(
        "local a, b = true, false return b"
    ) => "local b = false return b",
    remove_unused_after_last_used_in_tuple_extract(
        "local a, b, c = ... return b"
    ) => "local a, b = ... return b",
    remove_variable_before_tuple_extract(
        "local a, b, c = true, ... return b"
    ) => "local b = ... return b",
    remove_variable_before_tuple_extract_and_after_last_used(
        "local a, b, c = true, ... return c"
    ) => "local b, c = ... return c",
    keep_variable_before_tuple_extract_and_remove_after_last_used(
        "local a, b, c, d = true, ... return a and c"
    ) => "local a, b, c = true, ... return a and c",
    remove_variable_if_shadowed_variable_is_used(
        "local a = true do local a = 1 print(a) end"
    ) => "do local a = 1 print(a) end",
    remove_variable_if_shadowed_self_variable_is_used(
        "local self = true function class:method() return self:_method() end"
    ) => "function class:method() return self:_method() end",
    remove_variable_if_shadowed_undeclared_variable_is_used(
        "local a = true do local a print(a) end"
    ) => "do local a print(a) end",
    remove_variable_before_call_statement("local x call()") => "call()",
    remove_two_variables_before_call_statement("local x local y call()") => "call()",
    remove_unused_variable_but_keep_require_side_effect("local _requireZero = require('./requireZero.roblox.lua')") => "require('./requireZero.roblox.lua')",
    remove_unused_variable_but_keep_require_side_effect_in_parens("local _requireZero = (require('./requireZero.roblox.lua'))") => "require('./requireZero.roblox.lua')",
    remove_unused_variable_but_keep_require_side_effect_in_parens_with_type_cast("local _requireZero = (require('./requireZero.roblox.lua') :: any)") => "require('./requireZero.roblox.lua')",
    remove_unused_variable_but_not_initially_assigned_variable("local a, b = true b = false") => "local b = nil b = false",
    remove_unused_variable_but_not_initially_assigned_variable_with_unused_trailing_variable("local a, b, c = true b = false") => "local b = nil b = false",
    keep_used_variable_bounded_by_unused_variable_with_side_effect("local a, b, c = call() b = false") => "local a, b = call() b = false",
    // remove variables that are used more than once, but never read
    // remove_if_only_assigned("local a = true a = false") => "",
    // remove_if_only_field_assigned("local a = {} a.foo = false") => "",
    // remove_if_only_nested_field_assigned("local a = {b = {}} a.b.foo = false") => "",
    // remove_if_only_index_assigned("local a = {} a['foo'] = false") => "",
    // remove_if_only_nested_index_assigned("local a = {b = {}} a['b']['foo'] = false") => "",
    // remove_if_only_parenthese_field_assigned("local a = {} (a).foo = false") => "",
    // remove_if_only_assigned_with_a_function(
    //     "local a = true function a() end"
    // ) => "",
    // remove_if_only_assigned_with_a_field_function(
    //     "local a = {} function a.foo() end"
    // ) => "",
    // remove_if_only_assigned_with_a_method_function(
    //     "local a = {} function a:foo() end"
    // ) => "",
    // remove_if_only_assigned_but_keep_used_variable(
    //     "local a, b = true, false a = false return b"
    // ) => "local b = false return b",

    // remove_but_keep_side_effect_from_index_expression(
    //     "local a = {} a[print('foo')] = false"
    // ) => "print('foo')",
);

test_rule_without_effects!(
    RemoveUnusedVariable::default(),
    keep_returning_local_function("local function foo() end return foo"),
    keep_used_local_function("local function foo() end foo()"),
    keep_not_initialized_variable("local foo return foo"),
    keep_previous_identifiers_for_tuple_extraction("local a, b, c = ... return c"),
    keep_previous_identifiers_if_it_has_side_effects("local a, b = print(), false return b"),
    keep_if_variable_is_called_in_assignment(
        "local a = {} local function b() print() return a end b().a = true"
    ),
    keep_if_variable_is_used_in_index_assignment("local a, b = {}, true a[b] = false return a"),
    keep_variable_in_repeat_condition("repeat local x = true until x"),
    keep_variable_used_in_for_loop("local x, y = {}, {} function y.toString() end for k,v in y do x[k] = v end return { x = x }"),
    keep_variable_used_in_returned_table_entry("local x = {} return { x = x }"),
    keep_variable_used_in_type_declaration("local x = require('./m') export type X = x.X return {}"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_unused_variable',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_unused_variable'").unwrap();
}
