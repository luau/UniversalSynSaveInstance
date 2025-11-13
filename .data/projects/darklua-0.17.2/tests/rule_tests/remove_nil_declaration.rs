use darklua_core::rules::{RemoveNilDeclaration, Rule};

test_rule!(
    remove_nil_declaration,
    RemoveNilDeclaration::default(),
    assign_to_nil("local a = nil") => "local a",
    assign_to_nil_and_extra_true("local a = nil, true") => "local a",
    assign_to_true_nil_and_false("local a, b, c = true, nil, false") => "local a, c, b = true, false",
    assign_to_true_and_nil("local a, b = true, nil") => "local a, b = true",
    assign_to_nil_and_nil("local a, b = nil, nil") => "local a, b",
    assign_call_and_nil("local a, b = call(), nil") => "local a, b = (call())",
    assign_variadic_args_and_nil("local a, b = ..., nil") => "local a, b = (...)",
    assign_field_expression_and_nil("local a, b = object.prop, nil") => "local a, b = (object.prop)",
    assign_index_expression_and_nil("local a, b = object[key], nil") => "local a, b = (object[key])",
    assign_call_and_nil_and_nil("local a, b, c = call(), nil, nil") => "local a, b, c = (call())",
    // we can re-order variables that gets assigned to `nil`
    assign_to_nil_and_true("local a, b = nil, true") => "local b, a = true",
    assign_to_nil_and_nil_and_true("local a, b, c = nil, nil, true") => "local c, a, b = true",
    assign_to_nil_and_call("local a, b = nil, call()") => "local b, a = (call())",
    assign_to_nil_and_call_and_false("local a, b, c = nil, call(), false") => "local b, c, a = call(), false",
    // the rule may trim unnecessary expressions in declarations
    assign_to_call_and_true_and_variable("local a = call(), true, var") => "local a = call()",
);

test_rule_without_effects!(
    RemoveNilDeclaration::default(),
    assign_to_true("local a = true"),
    assign_to_nil_and_extra_call("local a = nil, call()"),
    assign_to_nil_and_extract_varargs("local a, b, c = nil, ..."),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_nil_declaration',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_nil_declaration'").unwrap();
}
