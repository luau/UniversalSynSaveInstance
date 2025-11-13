use darklua_core::rules::{RemoveIfExpression, Rule};

test_rule!(
    remove_if_expression,
    RemoveIfExpression::default(),
    if_with_truthy_result("local a = if condition() then 1 else 2")
        => "local a = condition() and 1 or 2",
    if_with_truthy_result_else_nil("local a = if condition() then '' else nil")
        => "local a = condition() and '' or nil",
    if_with_truthy_result_else_false("local a = if condition() then {} else false")
        => "local a = condition() and {} or false",
    if_with_nil_result_else_false("local a = if condition() then nil else false")
        => "local a = (condition() and { nil } or { false })[1]",
    if_with_false_result_else_truthy("local a = if condition() then false else true")
        => "local a = (condition() and { false } or { true })[1]",
    if_with_unknown_result_else_unknown("local a = if condition() then update() else default()")
        => "local a = (condition() and { (update()) } or { (default()) })[1]",
    assign_if_expression_with_elseif("local a = if true then 1 elseif false then 2 else 3")
        => "local a = true and 1 or (false and 2 or 3)",
    if_expression_with_varargs("local function f(...: string) return if condition(...) then ... else transform(...) end")
        => "local function f(...: string) return (condition(...) and {(...)} or {(transform(...))})[1] end",
    if_expression_with_varargs_elseif("local function f(...: string) return if condition(...) then ... elseif condition2(...) then ... else transform(...) end")
        => "local function f(...: string) return (condition(...) and {(...)} or { ((condition2(...) and {(...)} or { (transform(...)) })[1]) }) [1] end"
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_if_expression',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_if_expression'").unwrap();
}
