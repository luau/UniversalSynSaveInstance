use darklua_core::rules::{RemoveCompoundAssignment, Rule};

test_rule!(
    remove_compound_assignment,
    RemoveCompoundAssignment::default(),
    increase_identifier("a += 1") => "a = a + 1",
    decrease_identifier("a -= 1") => "a = a - 1",
    multiply_identifier("a *= 2") => "a = a * 2",
    divide_identifier("a /= 2") => "a = a / 2",
    mod_identifier("a %= 2") => "a = a % 2",
    exp_identifier("a ^= 2") => "a = a ^ 2",
    concat_identifier("a ..= 'suffix'") => "a = a .. 'suffix'",
    increase_index_without_side_effect("a[prop] += 1") => "a[prop] = a[prop] + 1",
    increase_index_with_true("a[true] += 1") => "a[true] = a[true] + 1",
    increase_index_with_false("a[false] += 1") => "a[false] = a[false] + 1",
    increase_index_with_parenthese_expression("a[(key)] += 1") => "a[key] = a[key] + 1",
    increase_field("a.counter += 1") => "a.counter = a.counter + 1",
    increase_field_on_function_call("getObject().counter += 1")
        => "do local __DARKLUA_VAR = getObject() __DARKLUA_VAR.counter = __DARKLUA_VAR.counter + 1 end",
    increase_field_on_parentheses("(if condition then a else b).counter += 1")
        => "do local __DARKLUA_VAR = if condition then a else b __DARKLUA_VAR.counter = __DARKLUA_VAR.counter + 1 end",
    increase_identifier_in_parenthese_for_field("(a).counter += 1") => "a.counter = a.counter + 1",
    increase_false_in_parenthese_for_field("(false).counter += 1") => "(false).counter = (false).counter + 1",
    increase_identifier_in_parenthese_for_index("(a)['counter'] += 1") => "a['counter'] = a['counter'] + 1",
    increase_true_in_parenthese_for_index("(true)['counter'] += 1") => "(true)['counter'] = (true)['counter'] + 1",
    increase_index_with_side_effects_in_index("a[call()] += 1")
        => "do local __DARKLUA_VAR = call() a[__DARKLUA_VAR] = a[__DARKLUA_VAR] + 1 end",
    increase_index_with_side_effects_in_prefix("object[call()][key] += 1")
        => "do local __DARKLUA_VAR = object[call()] __DARKLUA_VAR[key] = __DARKLUA_VAR[key] + 1 end",
    increase_index_with_side_effects_in_prefix_and_index("object[call()][getKey()] += 1")
        => "do local __DARKLUA_VAR, __DARKLUA_VAR0 = object[call()], getKey() __DARKLUA_VAR[__DARKLUA_VAR0] = __DARKLUA_VAR[__DARKLUA_VAR0] + 1 end",
    nested_field_expressions("var.object.prop += 1")
        => "do local __DARKLUA_VAR = var.object __DARKLUA_VAR.prop = __DARKLUA_VAR.prop + 1 end",
    consecutive_nested_field_assignments("a.object.counter += 1 b.object.counter -= 1")
        => "do local __DARKLUA_VAR = a.object __DARKLUA_VAR.counter = __DARKLUA_VAR.counter + 1 end do local __DARKLUA_VAR0 = b.object __DARKLUA_VAR0.counter = __DARKLUA_VAR0.counter - 1 end",
);

test_rule_with_tokens!(
    remove_compound_assignment_with_tokens,
    RemoveCompoundAssignment::default(),
    trailing_comment("i += 1 -- comment") => "i =i+ 1 -- comment",
    trailing_comment_on_second_line("\ni += 1 -- comment") => "\ni =i+ 1 -- comment",
    comment_after_operator("i += --[[ comment ]] 1") => "i =i+ --[[ comment ]] 1",
    comment_after_variable("i --[[ comment ]] += 1") => "i --[[ comment ]] =i+ 1",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_compound_assignment',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_compound_assignment'").unwrap();
}
