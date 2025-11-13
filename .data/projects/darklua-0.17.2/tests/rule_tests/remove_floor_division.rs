use darklua_core::rules::{RemoveFloorDivision, Rule};

test_rule!(
    remove_floor_division,
    RemoveFloorDivision::default(),
    compound_floor_division("variable //= num") => "variable = math.floor(variable / num)",
    return_floor_division("return 1 // 3") => "return math.floor(1 / 3)",
    floor_division_in_binary_expression("return offset + variable // divider") => "return offset + math.floor(variable / divider)",

    floor_division_with_index_without_side_effect("a[prop] //= 1") => "a[prop] = math.floor(a[prop] / 1)",
    floor_division_with_index_with_true("a[true] //= 1") => "a[true] = math.floor(a[true] / 1)",
    floor_division_with_index_with_false("a[false] //= 1") => "a[false] = math.floor(a[false] / 1)",
    floor_division_with_index_with_parenthese_expression("a[(key)] //= 1") => "a[key] = math.floor(a[key] / 1)",
    floor_division_with_field("a.counter //= 1") => "a.counter = math.floor(a.counter / 1)",
    floor_division_with_field_on_function_call("getObject().counter //= 1")
        => "do local __DARKLUA_VAR = getObject() __DARKLUA_VAR.counter = math.floor(__DARKLUA_VAR.counter / 1) end",
    floor_division_with_field_on_parentheses("(if condition then a else b).counter //= 1")
        => "do local __DARKLUA_VAR = if condition then a else b __DARKLUA_VAR.counter = math.floor(__DARKLUA_VAR.counter / 1) end",
    floor_division_with_identifier_in_parenthese_for_field("(a).counter //= 1") => "a.counter = math.floor(a.counter / 1)",
    floor_division_with_false_in_parenthese_for_field("(false).counter //= 1") => "(false).counter = math.floor((false).counter / 1)",
    floor_division_with_identifier_in_parenthese_for_index("(a)['counter'] //= 1") => "a['counter'] = math.floor(a['counter'] / 1)",
    floor_division_with_true_in_parenthese_for_index("(true)['counter'] //= 1") => "(true)['counter'] = math.floor((true)['counter'] / 1)",
    floor_division_with_index_with_side_effects_in_index("a[call()] //= 1")
        => "do local __DARKLUA_VAR = call() a[__DARKLUA_VAR] = math.floor(a[__DARKLUA_VAR] / 1) end",
    floor_division_with_index_with_side_effects_in_prefix("object[call()][key] //= 1")
        => "do local __DARKLUA_VAR = object[call()] __DARKLUA_VAR[key] = math.floor(__DARKLUA_VAR[key] / 1) end",
    floor_division_with_index_with_side_effects_in_prefix_and_index("object[call()][getKey()] //= 1")
        => "do local __DARKLUA_VAR, __DARKLUA_VAR0 = object[call()], getKey() __DARKLUA_VAR[__DARKLUA_VAR0] = math.floor(__DARKLUA_VAR[__DARKLUA_VAR0] / 1) end",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_floor_division',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_floor_division'").unwrap();
}
