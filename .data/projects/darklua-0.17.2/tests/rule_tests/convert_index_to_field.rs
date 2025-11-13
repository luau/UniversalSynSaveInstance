use darklua_core::rules::{ConvertIndexToField, Rule};

test_rule!(
    convert_index_to_field,
    ConvertIndexToField::default(),
    key_is_a_valid_identifier("return var['field']") => "return var.field",
    key_is_a_valid_identifier_with_number("return var['field1']") => "return var.field1",
    key_in_double_index("return var['props'][' ']") => "return var.props[' ']",
    assign_to_a_valid_identifier("var[\"field\"] = call()") => "var.field = call()",
    multiple_assign_to_a_valid_identifier("var[\"field\"], var['key'], var.prop = call()") => "var.field, var.key, var.prop = call()",
    call_function("object['process'](true)") => "object.process(true)",
    call_method("object['sub']:method(...)") => "object.sub:method(...)",
    // table entries
    table_key_is_valid_identifier("return { [\"a\"] = true }") => "return { a = true }",
    table_key_is_valid_identifier_with_number("return { [\"key1\"] = true }") => "return { key1 = true }",
    function_table_args_key_is_valid_identifier("call { ['a'] = true }")=> "call { a = true }",
    function_table_args_key_is_valid_identifier_with_number("call { ['key1'] = true }") => "call { key1 = true }",
    table_with_multiple_keys("return { 'one', 'two', [\"a\"] = true, [\"b\"] = false, c = 0, [{}] = {} }")
        => "return { 'one', 'two', a = true, b = false, c = 0, [{}] = {} }",
);

test_rule_without_effects!(
    ConvertIndexToField::default(),
    key_is_empty_string("return var[\"\"]"),
    key_starts_with_space("return var[' bar']"),
    key_ends_with_space("return var['bar ']"),
    key_starts_with_dollar_sign("return var['$$ok']"),
    key_has_dollar_sign("return var['field$end']"),
    key_is_do_keyword("return var['do']"),
    key_starts_with_number("return var['1field']"),
    call_function("object['function'](true)"),
    key_is_a_table("return var[{}]"),
    // table entries
    table_key_is_empty_string("return { [\"\"] = true }"),
    table_key_with_space("return { [\"field \"] = true }"),
    table_key_with_interogation_point("return { [\"key?\"] = true }"),
    table_key_is_repeat_keyword("return { ['repeat'] = true }"),
    function_table_args_key_is_while_keyword("return call { ['while'] = true }"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'convert_index_to_field',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'convert_index_to_field'").unwrap();
}
