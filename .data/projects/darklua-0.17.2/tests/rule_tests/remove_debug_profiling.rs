use darklua_core::rules::{RemoveDebugProfiling, Rule};

test_rule!(
    remove_debug_profiling,
    RemoveDebugProfiling::default(),
    remove_profile_begin("debug.profilebegin('label')") => "do end",
    remove_profile_end("debug.profileend()") => "do end",
    remove_profiling_around_function_call("debug.profilebegin('label') fn() debug.profileend()") => "do end fn() do end",
    remove_profile_begin_with_maybe_side_effects("debug.profilebegin(getLabel())") => "getLabel()",
);

test_rule!(
    remove_debug_profiling_without_side_effects,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_debug_profiling',
        preserve_arguments_side_effects: false,
    }"#,
    )
    .unwrap(),
    remove_profile_begin("debug.profilebegin('label')") => "do end",
    remove_profile_end("debug.profileend()") => "do end",
    remove_profiling_around_function_call("debug.profilebegin('label') fn() debug.profileend()") => "do end fn() do end",
    remove_profile_begin_with_maybe_side_effects("debug.profilebegin(getLabel())") => "do end",
);

test_rule_without_effects!(
    RemoveDebugProfiling::default(),
    debug_library_identifier_used("local debug = nil debug.profilebegin('label')"),
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_debug_profiling',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_debug_profiling'").unwrap();
}
