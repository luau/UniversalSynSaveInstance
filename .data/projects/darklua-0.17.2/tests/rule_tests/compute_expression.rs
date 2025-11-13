use darklua_core::rules::{ComputeExpression, Rule};

test_rule!(
    compute_expression,
    ComputeExpression::default(),
    binary_true_and_false("return true and false") => "return false",
    binary_true_and_call("return true and call()") => "return call()",
    binary_false_and_true("return false and true") => "return false",
    binary_false_and_variable("return false and var") => "return false",
    binary_false_and_call("return false and func()") => "return false",
    binary_true_or_call("return true or func()") => "return true",
    binary_true_or_function("return false or function() print('ok') end") => "return function() print('ok') end",
    binary_false_or_call("return false or call()") => "return call()",
    binary_nil_or_call("return nil or call()") => "return call()",
    binary_number_equals("return 1 == 1") => "return true",
    binary_number_equals_in_different_notation("return 1 == 1.0") => "return true",
    binary_number_equals_in_different_exponent_notation("return 2.5e3 == 25e2") => "return true",
    binary_table_or_call("return {} or func()") => "return {}",
    true_and_func_or_call("return true and function() end or call()") => "return function() end",
    nil_and_call_or_func("return nil and call() or function() end") => "return function() end",
    number_addition("return 1 + 2") => "return 3",
    multiple_addition("return 1 + 2 + 5") => "return 8",
    division("return 1/3") => "return 0.3333333333333333",
    division_test("return 3 * 0.3333333333333333") => "return 1",
    multiply_small_number("return 2 * 1e-50") => "return 2E-50",
    unary_minus_number("return -1") => "return -1",
    if_expression_always_true("return if true then 'is true' else 'is false'") => "return 'is true'",
    if_expression_always_true_with_dead_branch_has_side_effects("return if true then 'is true' else call()")
        => "return 'is true'",
    if_expression_always_false("return if false then 'is true' else 'is false'") => "return 'is false'",
    if_expression_always_false_with_dead_branch_has_side_effects("return if false then call() else 'is false'")
        => "return 'is false'",
    if_expression_elseif_always_true("return if false then 'is true' elseif 1 == 1 then 'is equal' else nil")
        => "return 'is equal'",
    if_expression_elseif_always_false("return if false then 'is true' elseif 1 == 2 then 'is equal' else nil")
        => "return nil",
    preserve_negative_zero("return -0") => "return -0",
    addition_preserve_negative_zero("return -0 + -0") => "return -0",
    subtract_preserve_negative_zero("return -0 - 0") => "return -0",
);

test_rule_without_effects!(
    ComputeExpression::default(),
    if_expression_unknown_condition("return if condition then func() else func2()"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'compute_expression',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'compute_expression'").unwrap();
}
