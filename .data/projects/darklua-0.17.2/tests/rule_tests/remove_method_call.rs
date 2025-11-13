use darklua_core::rules::{RemoveMethodCall, Rule};

test_rule!(
    remove_method_call,
    RemoveMethodCall::default(),
    simple_method_call("obj:method()") => "obj.method(obj)",
    method_call_with_args("obj:method(1, 2, 3)") => "obj.method(obj, 1, 2, 3)",
    method_call_with_string("obj:method('hello')") => "obj.method(obj, 'hello')",
    method_call_with_string_args("obj:method'hello'") => "obj.method(obj, 'hello')",
    method_call_with_table("obj:method({key = 'value'})") => "obj.method(obj, {key = 'value'})",
    method_call_with_table_args("obj:method{key = 'value'}") => "obj.method(obj, {key = 'value'})",
    assign_method_call("local result = obj:method()") => "local result = obj.method(obj)",
    nested_method_call("other:func(obj:method())") => "other.func(other, obj.method(obj))",
    method_call_with_variadic_argument("myTable:insert(...)") => "myTable.insert(myTable, ...)",
    removes_parentheses_of_a_method_call("(obj):method()") => "obj.method(obj)",
);

test_rule_without_effects!(
    RemoveMethodCall::default(),
    regular_function_call("obj.method()"),
    regular_function_call_with_args("obj.method(1, 2, 3)"),
    field_method_call("obj.field:method()"),
    index_method_call("obj[key]:method()"),
    call_method_call("obj():method()"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_method_call',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_method_call'").unwrap();
}
