use darklua_core::rules::{GroupLocalAssignment, Rule};

test_rule!(
    group_local_assignment,
    GroupLocalAssignment::default(),
    local_with_no_values("local foo; local bar") => "local foo, bar",
    two_locals("local foo = 1 local bar = 2") => "local foo, bar = 1, 2",
    three_locals("local foo = 1 local bar = 2 local baz = 3") => "local foo, bar, baz = 1, 2, 3",
    local_with_no_value_and_local_with_value("local a local b = 7") => "local a, b = nil, 7",
    local_with_no_values_are_set_to_nil("local a local b = true local c") => "local a, b, c = nil, true, nil"
);

test_rule_without_effects!(
    GroupLocalAssignment::default(),
    two_local_using_the_other("local foo = 1 local bar = foo"),
    multiple_return_values("local a, b = call() local c = 0")
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'group_local_assignment',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'group_local_assignment'").unwrap();
}
