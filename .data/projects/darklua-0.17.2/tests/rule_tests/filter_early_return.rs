use darklua_core::rules::{FilterAfterEarlyReturn, Rule};

test_rule!(
    filter_early_return,
    FilterAfterEarlyReturn::default(),
    return_in_do_removes_outer_return("do return true end return false") => "do return true end",
    keep_statements_before_returning_do("local a = 1 do return a end return a + a") => "local a = 1 do return a end",
    nested_return(
        "local a = {} do function a.call() end do return a end end function a.call() process() end return a"
    ) => "local a = {} do function a.call() end do return a end end",
    nested_returns_clears_nested_statements(
        "do do return 1 end do return 2 end return 3 end do return 4 end return last"
    ) => "do do return 1 end end",
    conditional_nested_return(
        "if condition then do return 1 end local a return 2 end return 3"
    ) => "if condition then do return 1 end end return 3",
);

test_rule_without_effects!(
    FilterAfterEarlyReturn::default(),
    return_nil("return nil"),
    return_in_condition("if condition then return 'ok' end return nil"),
    return_in_while("while condition do return 'ok' end return nil"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'filter_after_early_return',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'filter_after_early_return'").unwrap();
}
