use darklua_core::rules::{ConvertSquareRootCall, Rule};

test_rule!(
    convert_square_root_call,
    ConvertSquareRootCall::default(),
    constant("return math.sqrt(16)") => "return 16 ^ 0.5",
    variable("return math.sqrt(x)") => "return x ^ 0.5",
    binary_expression("return math.sqrt(x + y)") => "return (x + y) ^ 0.5",
    function_call("return math.sqrt(call())") => "return call() ^ 0.5",
    complex_expression("return math.sqrt((a + b) * c)") => "return ((a + b) * c) ^ 0.5",
    in_function("local function test(x) return math.sqrt(x) end") => "local function test(x) return x ^ 0.5 end",
    in_assignment("local result = math.sqrt(25)") => "local result = 25 ^ 0.5",
    in_binary_expression("local result = math.sqrt(16) + 5") => "local result = 16 ^ 0.5 + 5",
    as_statement("math.sqrt(16)") => "do end",
    as_statement_preserve_side_effect("math.sqrt(calculate())") => "calculate()",
    as_statement_preserve_multiple_side_effect("math.sqrt(calculate() + getResult())")
        => "local _ = calculate() + getResult()",
);

test_rule_without_effects!(
    ConvertSquareRootCall::default(),
    multiple_arguments("math.sqrt(16, 25)"),
    no_arguments("math.sqrt()"),
    math_abs_call("math.abs(16)"),
    shadowed_math_library("local math = {} math.sqrt(16)"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'convert_square_root_call',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'convert_square_root_call'").unwrap();
}
