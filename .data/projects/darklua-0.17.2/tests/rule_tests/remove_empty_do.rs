use darklua_core::rules::{RemoveEmptyDo, Rule};

test_rule!(
    remove_empty_do,
    RemoveEmptyDo::default(),
    multiple_empty_do_statements("do end do end") => "",
    empty_do_statement_in_numeric_for("for i=a, b do do end end") => "for i=a, b do end",
    empty_do_statements_in_local_function("local function foo() do end do do end end end")
        => "local function foo() end",
    empty_do_statement_in_generic_for("for k,v in pairs({}) do do end end") => "for k,v in pairs({}) do end"
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_empty_do',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_empty_do'").unwrap();
}
