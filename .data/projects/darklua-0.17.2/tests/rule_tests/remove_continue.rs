use darklua_core::rules::{RemoveContinue, Rule};

test_rule_snapshot!(
    remove_continue,
    RemoveContinue::default(),
    numeric_for_continue_first_case(
        r#"
    for i = 1, 10 do
        if i == 1 then
            continue
        end
        print(i)
    end
    "#
    ),
    generic_for_continue_or_break(
        r#"
    for key, value in array do
        if skip(key) then
            continue
        elseif stop(key) then
            break
        end
        print(value)
    end
    "#
    ),
    for_inside_while(
        r#"
    while notDone() do
        if hasEnded() then
            break
        end
        for i = 1, 10 do
            if i == 1 then
                continue
            end
            print(i)
        end
    end
    "#
    ),
    repeat_inside_for(
        r#"
    for key, value in array do
        if type(key) == 'number' then
            repeat
                key -= 1
            until key == 0
        elseif stop(key) then
            break
        end
        print(value)
    end
    "#
    ),
    nested_for_continue_statements(
        r#"
    for i = 1, 10 do
        for j = 1, 10 do
            if j % 2 == 0 then
                continue
            end
            print(i, j)
        end
    end
    "#
    ),
    multiple_conditions_continue(
        r#"
    for i = 1, 10 do
        if i < 3 or i > 8 then
            continue
        end
        print(i)
    end
    "#
    ),
    function_with_continue(
        r#"
    for i = 1, 10 do
        local function shouldSkip(val)
            return val % 2 == 0
        end
        if shouldSkip(i) then
            continue
        end
        print(i)
    end
    "#
    ),
    sequential_loops_with_continue(
        r#"
    for i = 1, 5 do
        if i % 2 == 0 then
            continue
        end
        print(i)
    end

    for j = 6, 10 do
        if j % 3 == 0 then
            continue
        end
        print(j)
    end
    "#
    ),
    for_continue_with_comment(
        r#"
    for i = 1, 10 do
        if i % 2 == 0 then
            continue -- Skip even numbers
        end
        -- Print odd numbers
        print(i)
    end
    "#
    ),
    for_loop_with_only_continue(
        r#"
    for i = 1, 10 do
        continue
    end
    "#
    ),
    for_loop_continue_in_function_expression(
        r#"
    for i = 1, 10 do
        array[i] = function()
            for j = i, i + 10 do
                if j % 2 == 0 then
                    continue
                else
                    print(i)
                end
            end
        end
    end
    "#
    ),
    for_loop_continue_in_function_statement(
        r#"
    for i = 1, 10 do
        local element = array[i]
        function element.call()
            for j = i, i + 10 do
                if j % 2 == 0 then
                    continue
                else
                    print(i)
                end
            end
        end
    end
    "#
    ),
);

test_rule_without_effects!(
    RemoveContinue::default(),
    numeric_for_loop(
        r#"
    for i = 1, 10 do
        print(i)
    end
    "#
    ),
    generic_for_loop(
        r#"
    for key, value in array do
        print(key, value)
    end
    "#
    ),
    while_loop_without_continue(
        r#"
    local i = 0
    while i < 10 do
        i += 1
        print(i)
    end
    "#
    ),
    repeat_until_without_continue(
        r#"
    local i = 0
    repeat
        i += 1
        print(i)
    until i >= 10
    "#
    ),
    nested_for_no_continue(
        r#"
    for i = 1, 5 do
        for j = 1, 5 do
            print(i, j)
        end
    end
    "#
    ),
    empty_numeric_for(
        r#"
    for i = 1, 10 do
    end
    "#
    ),
    numeric_for_comments_only(
        r#"
    for i = 1, 10 do
        -- This is a comment
        -- Another comment
    end
    "#
    ),
    numeric_for_with_if_break(
        r#"
    for i = 1, 10 do
        if i % 2 == 0 then
            break
        end
    end
    "#
    ),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_continue'
    }"#,
    )
    .unwrap();
}
