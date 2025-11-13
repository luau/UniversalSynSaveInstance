use darklua_core::rules::{ConvertFunctionToAssign, Rule};

test_rule!(
    convert_function_to_assignment,
    ConvertFunctionToAssign::default(),
    empty_function("function foo() end") => "foo = function() end",
    empty_function_with_arguments("function foo(a, b) end") => "foo = function(a, b) end",
    empty_variadic_function("function foo(...) end") => "foo = function(...) end",
    empty_variadic_function_with_arguments("function foo(a, b, c, ...) end") => "foo = function(a, b, c, ...) end",
    function_with_block("function foo() return true end") => "foo = function() return true end",
    function_with_field("function foo.bar() end") => "foo.bar = function() end",
    function_with_field_and_arguments("function foo.bar(a, b) end") => "foo.bar = function(a, b) end",
    function_with_nested_fields("function foo.bar.baz() end") => "foo.bar.baz = function() end",
    function_with_method("function foo:bar() end") => "foo.bar = function(self) end",
    function_with_method_and_arguments("function foo:bar(a, b) end") => "foo.bar = function(self, a, b) end",
    function_with_method_and_variadic("function foo:bar(...) end") => "foo.bar = function(self, ...) end",
    function_with_nested_fields_and_method("function foo.bar:baz() end") => "foo.bar.baz = function(self) end",
    function_with_body("function foo() local x = 1 return x end") => "foo = function() local x = 1 return x end",
    recursive_function("function foo() foo() end") => "foo = function() foo() end"
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'convert_function_to_assignment',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'convert_function_to_assignment'").unwrap();
}
