use darklua_core::rules::{RemoveMethodDefinition, Rule};

test_rule!(
    remove_method_definition,
    RemoveMethodDefinition::default(),
    name_without_method("function foo() end") => "function foo() end",
    name_with_method("function foo:bar() end") => "function foo.bar(self) end",
    name_with_field_and_method("function foo.bar:baz() end") => "function foo.bar.baz(self) end",
    with_arguments("function foo:bar(a, b, c) end") => "function foo.bar(self, a, b, c) end",
    variadic_function("function foo:bar(...) end") => "function foo.bar(self, ...) end",
    variadic_with_arguments("function foo:bar(a, b, c, ...) end") => "function foo.bar(self, a, b, c, ...) end"
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_method_definition',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_method_definition'").unwrap();
}
