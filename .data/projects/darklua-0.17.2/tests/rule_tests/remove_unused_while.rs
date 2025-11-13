use darklua_core::rules::{RemoveUnusedWhile, Rule};

test_rule!(
    remove_unused_while,
    RemoveUnusedWhile::default(),
    while_with_false_condition("while false do end") => "",
    while_with_nil_condition("while nil do end") => "",
    while_with_block("while false do print('hello') end") => ""
);

test_rule_without_effects!(
    RemoveUnusedWhile::default(),
    while_with_true_condition("while true do end")
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_unused_while',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_unused_while'").unwrap();
}
