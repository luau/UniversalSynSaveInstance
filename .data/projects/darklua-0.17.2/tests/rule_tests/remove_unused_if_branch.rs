use darklua_core::rules::{RemoveUnusedIfBranch, Rule};

test_rule!(
    remove_unused_if_branch,
    RemoveUnusedIfBranch::default(),
    falsy_branch_is_removed("if false then end") => "",
    falsy_branch_with_empty_else_block_is_removed("if false then else end") => "",
    two_falsy_branch_with_empty_else_block_is_removed("if false then elseif false then end") => "",
    falsy_branch_with_else_block_converts_to_do("if false then else return end") => "do return end",
    keep_branch_and_remove_empty_else("if condition then return else end") => "if condition then return end",
    one_truthy_branch_remove_else_block("if true then break else end") => "do break end",
    remove_falsy_elseif_branch("if foo then break elseif false then end") => "if foo then break end",
    remove_falsy_elseif_branch_and_empty_else("if foo then break elseif false then else end") => "if foo then break end",
    remove_branch_after_truthy_branch("if foo then break elseif true then return elseif foo then end")
        => "if foo then break else return end",
    // if expressions
    expression_true_inline_result_branch("return if true then 'first' else 'second'") => "return 'first'",
    expression_one_inline_result_branch("return if 1 then 'first' else 'second'") => "return 'first'",
    expression_true_inline_result_branch_with_field_expression(
        "return if true then value.prop else 'second'"
    ) => "return (value.prop)",
    expression_true_inline_result_branch_with_index_expression(
        "return if true then value['prop'] else 'second'"
    ) => "return (value['prop'])",
    expression_true_inline_result_branch_with_variadic_expression(
        "return if true then ... else 'second'"
    ) => "return (...)",
    expression_true_inline_result_branch_with_function_call("return if true then call() else 'second'") => "return (call())",
    expression_false_inline_else_branch("return if false then 'first' else 'second'") => "return 'second'",
    expression_nil_inline_else_branch("return if nil then 'first' else 'second'") => "return 'second'",
    expression_false_inline_else_branch_with_variadic_expression("return if false then 'first' else ...") => "return (...)",
    expression_false_inline_else_branch_with_function_call("return if false then 'first' else call()") => "return (call())",
    expression_first_elseif_is_true("return if false then 'first' elseif true then 'second' else 'third'") => "return 'second'",
    expression_all_elseif_are_false(
        "return if false then 'first' elseif false then 'second' elseif false then 'third' else 'fourth'"
    ) => "return 'fourth'",
    expression_remove_elseif_after_first_true(
        "return if var then 1 elseif var2 then 2 elseif true then 3 elseif var4 then 4 else 5"
    ) => "return if var then 1 elseif var2 then 2 else 3",
    expression_if_unknown_and_first_elseif_is_true(
        "return if var then 'first' elseif true then 'second' else 'third'"
    ) => "return if var then 'first' else 'second'",
    expression_if_unknown_and_single_elseif_is_false(
        "return if var then 'first' elseif false then 'second' else 'third'"
    ) => "return if var then 'first' else 'third'",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_unused_if_branch',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_unused_if_branch'").unwrap();
}
