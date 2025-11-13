use darklua_core::rules::{RemoveFunctionCallParens, Rule};

test_rule!(
    remove_function_call_parens,
    RemoveFunctionCallParens::default(),
    call_statement_with_empty_string("foo('')") => "foo''",
    call_statement_with_empty_table("foo({})") => "foo{}",
    call_expression_with_empty_string("return foo('')") => "return foo''",
    call_expression_with_empty_table("return foo({})") => "return foo{}"
);

test_rule_without_effects!(
    RemoveFunctionCallParens::default(),
    two_strings("foo('bar', 'baz')"),
    two_tables("foo({}, {})"),
    variable_parameter("foo(bar)")
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_function_call_parens',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_function_call_parens'").unwrap();
}
