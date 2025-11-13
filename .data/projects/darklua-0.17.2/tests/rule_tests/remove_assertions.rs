use darklua_core::rules::{RemoveAssertions, Rule};

test_rule!(
    remove_assertions,
    RemoveAssertions::default(),
    remove_variable_condition("assert(condition)") => "do end",
    remove_variable_condition_with_message("assert(condition, 'message')") => "do end",
    remove_function_call_condition("assert(validate(value))") => "validate(value)",
    remove_variable_condition_with_function_call_message("assert(condition, formatter(condition))") => "formatter(condition)",
    remove_function_call_condition_and_function_call_message("assert(validate(value), formatter(value))") => "do validate(value) formatter(value) end",
    as_expression_remove_variable_condition("return assert(condition)") => "return condition",
    as_expression_remove_variable_condition_with_message("return { assert(condition, 'message') }") => "return { select(1, condition, 'message') }",
    as_expression_remove_variable_condition_with_message_but_select_is_used("local select = true\nreturn { assert(condition, 'message') }")
        => "local __DARKLUA_REMOVE_CALL_RESERVED_1 = select local select = true\nreturn { __DARKLUA_REMOVE_CALL_RESERVED_1(1, condition, 'message') }",
    as_expression_remove_function_call_condition("call(assert(validate(value)))") => "call(validate(value))",
    as_expression_remove_variable_condition_with_function_call_message("return (assert(condition, formatter(condition)))") => "return (select(1, condition, formatter(condition)))",
    as_expression_remove_function_call_condition_and_function_call_message("return assert(validate(value), formatter(value))") => "return select(1, validate(value), formatter(value))",
);

test_rule!(
    remove_assertions_without_side_effects,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_assertions',
        preserve_arguments_side_effects: false,
    }"#,
    )
    .unwrap(),
    remove_variable_condition("assert(condition)") => "do end",
    remove_variable_condition_with_message("assert(condition, 'message')") => "do end",
    remove_function_call_condition("assert(validate(value))") => "do end",
    remove_variable_condition_with_function_call_message("assert(condition, formatter(condition))") => "do end",
);

test_rule_without_effects!(
    RemoveAssertions::default(),
    assert_function_used("local function assert() end assert('label')"),
    assert_with_method_call("assert:oops(condition)"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_assertions',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_assertions'").unwrap();
}
