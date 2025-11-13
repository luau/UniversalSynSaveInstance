use darklua_core::{rules::Rule, Options, Resources};

use crate::utils;

use super::memory_resources;

test_rule!(
    convert_path_require_to_roblox,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: 'path',
            target: { name: 'roblox', indexing_style: 'find_first_child' },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/init.lua" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/module.lua" => "return nil",
        "src/test/module.luau" => "return nil",
        "src/test/folder/lib.lua" => "return nil",
        "src/sub/lib.lua" => "return nil",
        "src/format.lua" => "return nil",
        "project.lua" => "return nil",
    ),
    test_file_name = "src/test/runner.lua",
    sibling_module("local module = require('./module.lua')")
        => "local module = require(script.Parent:FindFirstChild('module'))",
    sibling_luau_module("local module = require('./module.luau')")
        => "local module = require(script.Parent:FindFirstChild('module'))",
    sibling_folder_module("local module = require('./module')")
        => "local module = require(script.Parent:FindFirstChild('module'))",
    sibling_module_is_init_file_with_extension("local module = require('./init.lua')")
        => "local module = require(script.Parent)",
    sibling_module_is_init_file_with_luau_extension("local module = require('./init.luau')")
        => "local module = require(script.Parent)",
    module_nested_in_sibling_folder("local module = require('./folder/lib.lua')")
        => "local module = require(script.Parent:FindFirstChild('folder'):FindFirstChild('lib'))",
    module_in_parent("local module = require('../format.lua')")
        => "local module = require(script.Parent.Parent:FindFirstChild('format'))",
    module_nested_in_folder_from_parent("local module = require('../sub/lib.lua')")
        => "local module = require(script.Parent.Parent:FindFirstChild('sub'):FindFirstChild('lib'))",
    module_in_double_parent("local module = require('../../project.lua')")
        => "local module = require(script.Parent.Parent.Parent:FindFirstChild('project'))",
    module_in_parent_with_current_dir("local module = require('.././format.lua')")
        => "local module = require(script.Parent.Parent:FindFirstChild('format'))",
);

test_rule!(
    convert_path_require_to_roblox_with_wait_for_child,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: 'path',
            target: { name: 'roblox', indexing_style: 'wait_for_child' },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/init.lua" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/module.lua" => "return nil",
        "src/test/module.luau" => "return nil",
        "src/test/folder/lib.lua" => "return nil",
        "src/sub/lib.lua" => "return nil",
        "src/format.lua" => "return nil",
        "project.lua" => "return nil",
    ),
    test_file_name = "src/test/runner.lua",
    sibling_module("local module = require('./module.lua')")
        => "local module = require(script.Parent:WaitForChild('module'))",
    sibling_luau_module("local module = require('./module.luau')")
        => "local module = require(script.Parent:WaitForChild('module'))",
    sibling_folder_module("local module = require('./module')")
        => "local module = require(script.Parent:WaitForChild('module'))",
    sibling_module_is_init_file_with_extension("local module = require('./init.lua')")
        => "local module = require(script.Parent)",
    sibling_module_is_init_file_with_luau_extension("local module = require('./init.luau')")
        => "local module = require(script.Parent)",
    module_nested_in_sibling_folder("local module = require('./folder/lib.lua')")
        => "local module = require(script.Parent:WaitForChild('folder'):WaitForChild('lib'))",
    module_in_parent("local module = require('../format.lua')")
        => "local module = require(script.Parent.Parent:WaitForChild('format'))",
    module_nested_in_folder_from_parent("local module = require('../sub/lib.lua')")
        => "local module = require(script.Parent.Parent:WaitForChild('sub'):WaitForChild('lib'))",
    module_in_double_parent("local module = require('../../project.lua')")
        => "local module = require(script.Parent.Parent.Parent:WaitForChild('project'))",
    module_in_parent_with_current_dir("local module = require('.././format.lua')")
        => "local module = require(script.Parent.Parent:WaitForChild('format'))",
);

test_rule!(
    convert_path_require_to_roblox_with_property_index,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: 'path',
            target: { name: 'roblox', indexing_style: 'property' },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/init.lua" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/module.lua" => "return nil",
        "src/test/module.luau" => "return nil",
        "src/test/folder/lib.lua" => "return nil",
        "src/sub/lib.lua" => "return nil",
        "src/format.lua" => "return nil",
        "project.lua" => "return nil",
        // specific to property index style tests
        "src/test/while.lua" => "return nil",
        "src/test/a module.lua" => "return nil",
    ),
    test_file_name = "src/test/runner.lua",
    sibling_module("local module = require('./module.lua')")
        => "local module = require(script.Parent.module)",
    sibling_luau_module("local module = require('./module.luau')")
        => "local module = require(script.Parent.module)",
    sibling_folder_module("local module = require('./module')")
        => "local module = require(script.Parent.module)",
    sibling_module_is_init_file_with_extension("local module = require('./init.lua')")
        => "local module = require(script.Parent)",
    sibling_module_is_init_file_with_luau_extension("local module = require('./init.luau')")
        => "local module = require(script.Parent)",
    module_nested_in_sibling_folder("local module = require('./folder/lib.lua')")
        => "local module = require(script.Parent.folder.lib)",
    module_in_parent("local module = require('../format.lua')")
        => "local module = require(script.Parent.Parent.format)",
    module_nested_in_folder_from_parent("local module = require('../sub/lib.lua')")
        => "local module = require(script.Parent.Parent.sub.lib)",
    module_in_double_parent("local module = require('../../project.lua')")
        => "local module = require(script.Parent.Parent.Parent.project)",
    module_in_parent_with_current_dir("local module = require('.././format.lua')")
        => "local module = require(script.Parent.Parent.format)",
    // specific to property index style
    sibling_module_with_keyword_name("local module = require('./while.lua')")
        => "local module = require(script.Parent['while'])",
    sibling_module_with_name_with_space("local module = require('./a module.lua')")
        => "local module = require(script.Parent['a module'])",
);

test_rule!(
    convert_path_require_to_path,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'path',
                sources: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'path',
                sources: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
        // specific to alias tests
        "src/test/while.luau" => "return nil",
        "src/test/a module.luau" => "return nil",
    ),
    test_file_name = "src/test/runner.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('../format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('./module')")
        => "local module = require('./module')",
    relative_path_conversion_with_extension("local module = require('./module.luau')")
        => "local module = require('./module')",
    parent_path_conversion("local module = require('../format')")
        => "local module = require('../format')",
    nested_parent_path_conversion("local module = require('../sub/lib')")
        => "local module = require('../sub/lib')",
    double_parent_path_conversion("local module = require('../../project')")
        => "local module = require('../../project')",
    // Init file conversions
    init_file_conversion("local module = require('./init')")
        => "local module = require('.')",
);

test_rule!(
    convert_path_require_to_path_from_init_module,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'path',
                sources: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'path',
                sources: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
    ),
    test_file_name = "src/test/init.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('../format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('./module')")
        => "local module = require('./module')",
    relative_path_conversion_with_extension("local module = require('./module.luau')")
        => "local module = require('./module')",
    parent_path_conversion("local module = require('../format')")
        => "local module = require('../format')",
    nested_parent_path_conversion("local module = require('../sub/lib')")
        => "local module = require('../sub/lib')",
    double_parent_path_conversion("local module = require('../../project')")
        => "local module = require('../../project')",
);

test_rule!(
    convert_path_require_to_luau,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'path',
                sources: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'luau',
                aliases: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
        // specific to alias tests
        "src/test/while.luau" => "return nil",
        "src/test/a module.luau" => "return nil",
    ),
    test_file_name = "src/test/runner.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('../format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('./module')")
        => "local module = require('./module')",
    relative_path_conversion_with_extension("local module = require('./module.luau')")
        => "local module = require('./module')",
    parent_path_conversion("local module = require('../format')")
        => "local module = require('../format')",
    nested_parent_path_conversion("local module = require('../sub/lib')")
        => "local module = require('../sub/lib')",
    double_parent_path_conversion("local module = require('../../project')")
        => "local module = require('../../project')",
    // Init file conversions
    init_file_conversion("local module = require('./init')")
        => "local module = require('.')",
);

test_rule!(
    convert_path_require_to_luau_from_init_module,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'path',
                sources: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'luau',
                aliases: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
    ),
    test_file_name = "src/test/init.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('./format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('./module')")
        => "local module = require('@self/module')",
    relative_path_conversion_with_extension("local module = require('./module.luau')")
        => "local module = require('@self/module')",
    parent_path_conversion("local module = require('../format')")
        => "local module = require('./format')",
    nested_parent_path_conversion("local module = require('../sub/lib')")
        => "local module = require('./sub/lib')",
    double_parent_path_conversion("local module = require('../../project')")
        => "local module = require('../project')",
);

test_rule!(
    convert_luau_require_to_path,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'luau',
                sources: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'path',
                sources: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
        "/root/lib/name.luau" => "return nil",
        // specific to alias tests
        "src/test/while.luau" => "return nil",
        "src/test/a module.luau" => "return nil",
    ),
    test_file_name = "src/test/runner.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('../format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('./module')")
        => "local module = require('./module')",
    relative_path_conversion_with_extension("local module = require('./module.luau')")
        => "local module = require('./module')",
    parent_path_conversion("local module = require('../format')")
        => "local module = require('../format')",
    nested_parent_path_conversion("local module = require('../sub/lib')")
        => "local module = require('../sub/lib')",
    double_parent_path_conversion("local module = require('../../project')")
        => "local module = require('../../project')",
    // Absolute path conversions
    absolute_path_lib("local module = require('/root/lib/name.luau')")
        => "local module = require('/root/lib/name')",
    // Init file conversions
    init_file_conversion("local module = require('./init')")
        => "local module = require('.')",
);

test_rule!(
    convert_luau_require_to_path_from_init_module,
    json5::from_str::<Box<dyn Rule>>(
        r#"{
            rule: 'convert_require',
            current: {
                name: 'luau',
                aliases: { '@value': './value', '@format': '../format' }
            },
            target: {
                name: 'path',
                sources: { '@value': './value' },
            },
        }"#
    ).unwrap(),
    resources = memory_resources!(
        "src/test/module.luau" => "return nil",
        "src/test/value/default.luau" => "return nil",
        "src/test/value/init.luau" => "return nil",
        "src/test/folder/lib.luau" => "return nil",
        "src/sub/lib.luau" => "return nil",
        "src/format.luau" => "return nil",
        "project.luau" => "return nil",
        "/root/lib/name.luau" => "return nil",
    ),
    test_file_name = "src/test/init.luau",
    // alias conversions
    alias_conversion("local module = require('@value')")
        => "local module = require('@value')",
    removed_alias("local module = require('@format')")
        => "local module = require('../format')",
    nested_alias_conversion("local module = require('@value/default')")
        => "local module = require('@value/default')",
    // Relative path conversions
    relative_path_conversion("local module = require('@self/module')")
        => "local module = require('./module')",
    relative_path_conversion_with_extension("local module = require('@self/module.luau')")
        => "local module = require('./module')",
    parent_path_conversion("local module = require('./format')")
        => "local module = require('../format')",
    nested_parent_path_conversion("local module = require('./sub/lib')")
        => "local module = require('../sub/lib')",
    double_parent_path_conversion("local module = require('../project')")
        => "local module = require('../../project')",
    // Absolute path conversions
    absolute_path_lib("local module = require('/root/lib/name.luau')")
        => "local module = require('/root/lib/name')",
);

fn process_file(resources: &Resources, file_name: &str) -> String {
    darklua_core::process(resources, Options::new(file_name))
        .unwrap()
        .result()
        .unwrap();

    resources.get(file_name).unwrap()
}

fn expect_file_process(resources: &Resources, file_name: &str, expect_content: &str) {
    pretty_assertions::assert_eq!(process_file(resources, file_name), expect_content);
}

const CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG: &str =
    "{ rules: [{ rule: 'convert_require', current: 'path', target: 'roblox' }], generator: \"retain_lines\" }";

#[test]
fn convert_sibling_module_from_init_module() {
    let resources = memory_resources!(
        "src/init.lua" => "local value = require('./value.lua')",
        "src/value.lua" => "return nil",
        ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
    );
    expect_file_process(
        &resources,
        "src/init.lua",
        "local value = require(script:FindFirstChild('value'))",
    );
}

#[test]
fn convert_sibling_init_module_from_init_module() {
    let resources = memory_resources!(
        "src/init.lua" => "local value = require('./folder/init.lua')",
        "src/folder/init.lua" => "return nil",
        ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
    );
    expect_file_process(
        &resources,
        "src/init.lua",
        "local value = require(script:FindFirstChild('folder'))",
    );
}

#[test]
fn convert_parent_init_module_from_init_module() {
    let resources = memory_resources!(
        "src/module/init.lua" => "local value = require('../init.lua')",
        "src/init.lua" => "return nil",
        ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
    );
    expect_file_process(
        &resources,
        "src/module/init.lua",
        "local value = require(script.Parent)",
    );
}

#[test]
fn convert_sibling_module_from_init_module_with_non_luau_extension() {
    let resources = memory_resources!(
        "src/init.lua" => "local value = require('./value.global')",
        "src/value.global.lua" => "return nil",
        ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
    );
    expect_file_process(
        &resources,
        "src/init.lua",
        "local value = require(script:FindFirstChild('value.global'))",
    );
}

mod luau_to_roblox {
    use super::*;

    const CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG: &str =
        "{ rules: [{ rule: 'convert_require', current: 'luau', target: 'roblox' }], generator: \"retain_lines\" }";

    #[test]
    fn convert_sibling_module_from_init_module() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@self/value.lua')",
            "src/value.lua" => "return nil",
            ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('value'))",
        );
    }

    #[test]
    fn convert_sibling_init_module_from_init_module() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@self/folder/init.lua')",
            "src/folder/init.lua" => "return nil",
            ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('folder'))",
        );
    }

    #[test]
    fn convert_parent_init_module_from_init_module() {
        let resources = memory_resources!(
            "src/module/init.lua" => "local value = require('./init.lua')",
            "src/init.lua" => "return nil",
            ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/module/init.lua",
            "local value = require(script.Parent)",
        );
    }

    mod luaurc {
        use super::*;

        #[test]
        fn convert_alias_module_from_init_module() {
            let resources = memory_resources!(
                "src/init.lua" => "local value = require('@value')",
                "src/value.lua" => "return nil",
                ".luaurc" => r#"{ "aliases": { "value": "src/value.lua" } }"#,
                ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
            );
            expect_file_process(
                &resources,
                "src/init.lua",
                "local value = require(script:FindFirstChild('value'))",
            );
        }

        #[test]
        fn convert_alias_module_from_init_module_with_current_dir() {
            let resources = memory_resources!(
                "src/init.lua" => "local value = require('@value')",
                "src/value.lua" => "return nil",
                ".luaurc" => r#"{ "aliases": { "value": "./src/value.lua" } }"#,
                ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
            );
            expect_file_process(
                &resources,
                "src/init.lua",
                "local value = require(script:FindFirstChild('value'))",
            );
        }

        #[test]
        fn convert_folder_alias_module_from_init_module() {
            let resources = memory_resources!(
                "src/init.lua" => "local value = require('@value/default.lua')",
                "src/value/default.lua" => "return nil",
                ".luaurc" => r#"{ "aliases": { "value": "src/value" } }"#,
                ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
            );
            expect_file_process(
                &resources,
                "src/init.lua",
                "local value = require(script:FindFirstChild('value'):FindFirstChild('default'))",
            );
        }

        #[test]
        fn convert_folder_alias_module_from_init_module_without_extension() {
            let resources = memory_resources!(
                "src/init.lua" => "local value = require('@value/default')",
                "src/value/default.lua" => "return nil",
                ".luaurc" => r#"{ "aliases": { "value": "src/value" } }"#,
                ".darklua.json" => CONVERT_LUAU_TO_ROBLOX_DEFAULT_CONFIG,
            );
            expect_file_process(
                &resources,
                "src/init.lua",
                "local value = require(script:FindFirstChild('value'):FindFirstChild('default'))",
            );
        }
    }
}

mod luaurc {
    use super::*;

    #[test]
    fn convert_alias_module_from_init_module() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@value')",
            "src/value.lua" => "return nil",
            ".luaurc" => r#"{ "aliases": { "value": "src/value.lua" } }"#,
            ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('value'))",
        );
    }

    #[test]
    fn convert_alias_module_from_init_module_with_current_dir() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@value')",
            "src/value.lua" => "return nil",
            ".luaurc" => r#"{ "aliases": { "value": "./src/value.lua" } }"#,
            ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('value'))",
        );
    }

    #[test]
    fn convert_folder_alias_module_from_init_module() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@value/default.lua')",
            "src/value/default.lua" => "return nil",
            ".luaurc" => r#"{ "aliases": { "value": "src/value" } }"#,
            ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('value'):FindFirstChild('default'))",
        );
    }

    #[test]
    fn convert_folder_alias_module_from_init_module_without_extension() {
        let resources = memory_resources!(
            "src/init.lua" => "local value = require('@value/default')",
            "src/value/default.lua" => "return nil",
            ".luaurc" => r#"{ "aliases": { "value": "src/value" } }"#,
            ".darklua.json" => CONVERT_PATH_TO_ROBLOX_DEFAULT_CONFIG,
        );
        expect_file_process(
            &resources,
            "src/init.lua",
            "local value = require(script:FindFirstChild('value'):FindFirstChild('default'))",
        );
    }
}

mod sourcemap {
    use super::*;

    fn snapshot_file_process(resources: &Resources, file_name: &str, snapshot_name: &str) {
        insta::assert_snapshot!(
            snapshot_name,
            process_file(resources, file_name),
            &format!("process `tests/test_cases/sourcemap/{}`", file_name)
        );
    }

    fn get_darklua_config_with_sourcemap(sourcemap_path: &str) -> String {
        format!(
            r#"{{
                generator: 'retain_lines',
                rules: [
                    {{
                        rule: 'convert_require',
                        current: {{
                            name: 'path',
                            sources: {{
                                '@pkg': './Packages'
                            }}
                        }},
                        target: {{
                            name: 'roblox',
                            rojo_sourcemap: '{sourcemap_path}',
                        }}
                    }}
                ]
            }}"#
        )
    }

    fn get_resources_for_sourcemap(datamodel_case: bool, sourcemap_path: &str) -> Resources {
        memory_resources!(
            "src/init.lua" => include_str!("../test_cases/sourcemap/src/init.lua"),
            "src/a.lua" => include_str!("../test_cases/sourcemap/src/a.lua"),
            "src/b.lua" => include_str!("../test_cases/sourcemap/src/b.lua"),
            "src/c.lua" => include_str!("../test_cases/sourcemap/src/c.lua"),

            "src/d/init.lua" => include_str!("../test_cases/sourcemap/src/d/init.lua"),
            "src/d/d1.lua" => include_str!("../test_cases/sourcemap/src/d/d1.lua"),
            "src/d/d2.lua" => include_str!("../test_cases/sourcemap/src/d/d2.lua"),

            "Packages/Package1/init.lua" => include_str!("../test_cases/sourcemap/Packages/Package1/init.lua"),
            "Packages/Package1/value.lua" => include_str!("../test_cases/sourcemap/Packages/Package1/value.lua"),

            "main.server.lua" => include_str!("../test_cases/sourcemap/main.server.lua"),

            ".darklua.json" => get_darklua_config_with_sourcemap(sourcemap_path),
            "sourcemap.json" => if datamodel_case {
                include_str!("../test_cases/sourcemap/place-sourcemap.json")
            } else {
                include_str!("../test_cases/sourcemap/sourcemap.json")
            },
        )
    }

    #[test]
    fn invalid_sourcemap() {
        let resources = memory_resources!(
            "src/init.lua" => "return nil",
            ".darklua.json" => get_darklua_config_with_sourcemap("./sourcemap.json"),
            "sourcemap.json" => "",
        );
        utils::snapshot_file_process_file_errors(&resources, "src/init.lua", "invalid_sourcemap")
    }

    #[test]
    fn convert_sibling_module_from_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_init_module_with_sourcemap_without_current_dir() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_init_module_in_nested_sourcemap() {
        let resources = memory_resources!(
            "parent/src/d/init.lua" => include_str!("../test_cases/sourcemap/src/d/init.lua"),
            "parent/src/d/d1.lua" => include_str!("../test_cases/sourcemap/src/d/d1.lua"),
            "parent/src/d/d2.lua" => include_str!("../test_cases/sourcemap/src/d/d2.lua"),

            ".darklua.json" => r#"{
                generator: 'retain_lines',
                rules: [
                    {
                        rule: 'convert_require',
                        current: 'path',
                        target: {
                            name: 'roblox',
                            rojo_sourcemap: './parent/sourcemap.json',
                        }
                    }
                ]
            }"#,
            "parent/sourcemap.json" => include_str!("../test_cases/sourcemap/sourcemap.json"),
        );
        snapshot_file_process(
            &resources,
            "parent/src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn in_datamodel_convert_sibling_module_from_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_module_from_child_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/d2.lua",
            "convert_module_from_child_module",
        );
    }

    #[test]
    fn in_datamodel_convert_module_from_child_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/d2.lua",
            "convert_module_from_child_module",
        );
    }

    #[test]
    fn convert_multiple_sibling_modules_from_root_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/init.lua",
            "convert_multiple_sibling_modules_from_root_init_module",
        );
    }

    #[test]
    fn in_datamodel_convert_multiple_sibling_modules_from_root_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/init.lua",
            "convert_multiple_sibling_modules_from_root_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_sibling_module() {
        expect_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/b.lua",
            "local a = require(script.Parent:FindFirstChild('a'))\n\nreturn a\n",
        );
    }

    #[test]
    fn in_datamodel_convert_sibling_module_from_sibling_module() {
        expect_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/b.lua",
            "local a = require(script.Parent:FindFirstChild('a'))\n\nreturn a\n",
        );
    }

    #[test]
    fn convert_package_module_from_nested_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/d1.lua",
            "convert_package_module_from_nested_module",
        );
    }

    #[test]
    fn in_datamodel_convert_package_module_from_nested_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/d1.lua",
            "convert_package_module_from_nested_module",
        );
    }

    #[test]
    fn convert_nested_package_module_from_sibling_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "Packages/Package1/init.lua",
            "convert_nested_package_module_from_sibling_module",
        );
    }

    #[test]
    fn in_datamodel_convert_nested_package_module_from_sibling_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "Packages/Package1/init.lua",
            "convert_nested_package_module_from_sibling_module",
        );
    }

    // following tests are only on the DataModel sourcemap case
    #[test]
    fn in_datamodel_convert_module_require_across_service_instance() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "main.server.lua",
            "convert_module_require_across_service_instance",
        );
    }
}

mod luau_to_roblox_with_sourcemap {
    use super::*;

    fn snapshot_file_process(resources: &Resources, file_name: &str, snapshot_name: &str) {
        insta::assert_snapshot!(
            snapshot_name,
            process_file(resources, file_name),
            &format!("process `tests/test_cases/sourcemap_luau/{}`", file_name)
        );
    }

    fn get_darklua_config_with_sourcemap(sourcemap_path: &str) -> String {
        format!(
            r#"{{
                generator: 'retain_lines',
                rules: [
                    {{
                        rule: 'convert_require',
                        current: {{
                            name: 'luau',
                            sources: {{
                                '@pkg': './Packages'
                            }}
                        }},
                        target: {{
                            name: 'roblox',
                            rojo_sourcemap: '{sourcemap_path}',
                        }}
                    }}
                ]
            }}"#
        )
    }

    fn get_resources_for_sourcemap(datamodel_case: bool, sourcemap_path: &str) -> Resources {
        memory_resources!(
            "src/init.lua" => include_str!("../test_cases/sourcemap_luau/src/init.lua"),
            "src/a.lua" => include_str!("../test_cases/sourcemap_luau/src/a.lua"),
            "src/b.lua" => include_str!("../test_cases/sourcemap_luau/src/b.lua"),
            "src/c.lua" => include_str!("../test_cases/sourcemap_luau/src/c.lua"),

            "src/d/init.lua" => include_str!("../test_cases/sourcemap_luau/src/d/init.lua"),
            "src/d/d1.lua" => include_str!("../test_cases/sourcemap_luau/src/d/d1.lua"),
            "src/d/d2.lua" => include_str!("../test_cases/sourcemap_luau/src/d/d2.lua"),

            "Packages/Package1/init.lua" => include_str!("../test_cases/sourcemap_luau/Packages/Package1/init.lua"),
            "Packages/Package1/value.lua" => include_str!("../test_cases/sourcemap_luau/Packages/Package1/value.lua"),

            "main.server.lua" => include_str!("../test_cases/sourcemap_luau/main.server.lua"),

            ".darklua.json" => get_darklua_config_with_sourcemap(sourcemap_path),
            "sourcemap.json" => if datamodel_case {
                include_str!("../test_cases/sourcemap_luau/place-sourcemap.json")
            } else {
                include_str!("../test_cases/sourcemap_luau/sourcemap.json")
            },
        )
    }

    #[test]
    fn invalid_sourcemap() {
        let resources = memory_resources!(
            "src/init.lua" => "return nil",
            ".darklua.json" => get_darklua_config_with_sourcemap("./sourcemap.json"),
            "sourcemap.json" => "",
        );
        utils::snapshot_file_process_file_errors(&resources, "src/init.lua", "invalid_sourcemap")
    }

    #[test]
    fn convert_sibling_module_from_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_init_module_with_sourcemap_without_current_dir() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_init_module_in_nested_sourcemap() {
        let resources = memory_resources!(
            "parent/src/d/init.lua" => include_str!("../test_cases/sourcemap_luau/src/d/init.lua"),
            "parent/src/d/d1.lua" => include_str!("../test_cases/sourcemap_luau/src/d/d1.lua"),
            "parent/src/d/d2.lua" => include_str!("../test_cases/sourcemap_luau/src/d/d2.lua"),

            ".darklua.json" => r#"{
                generator: 'retain_lines',
                rules: [
                    {
                        rule: 'convert_require',
                        current: 'luau',
                        target: {
                            name: 'roblox',
                            rojo_sourcemap: './parent/sourcemap.json',
                        }
                    }
                ]
            }"#,
            "parent/sourcemap.json" => include_str!("../test_cases/sourcemap_luau/sourcemap.json"),
        );
        snapshot_file_process(
            &resources,
            "parent/src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn in_datamodel_convert_sibling_module_from_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/init.lua",
            "convert_sibling_module_from_init_module",
        );
    }

    #[test]
    fn convert_module_from_child_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/d2.lua",
            "convert_module_from_child_module",
        );
    }

    #[test]
    fn in_datamodel_convert_module_from_child_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/d2.lua",
            "convert_module_from_child_module",
        );
    }

    #[test]
    fn convert_multiple_sibling_modules_from_root_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/init.lua",
            "convert_multiple_sibling_modules_from_root_init_module",
        );
    }

    #[test]
    fn in_datamodel_convert_multiple_sibling_modules_from_root_init_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/init.lua",
            "convert_multiple_sibling_modules_from_root_init_module",
        );
    }

    #[test]
    fn convert_sibling_module_from_sibling_module() {
        expect_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/b.lua",
            "local a = require(script.Parent:FindFirstChild('a'))\n\nreturn a\n",
        );
    }

    #[test]
    fn in_datamodel_convert_sibling_module_from_sibling_module() {
        expect_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/b.lua",
            "local a = require(script.Parent:FindFirstChild('a'))\n\nreturn a\n",
        );
    }

    #[test]
    fn convert_package_module_from_nested_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "src/d/d1.lua",
            "convert_package_module_from_nested_module",
        );
    }

    #[test]
    fn in_datamodel_convert_package_module_from_nested_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "src/d/d1.lua",
            "convert_package_module_from_nested_module",
        );
    }

    #[test]
    fn convert_nested_package_module_from_sibling_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(false, "./sourcemap.json"),
            "Packages/Package1/init.lua",
            "convert_nested_package_module_from_sibling_module",
        );
    }

    #[test]
    fn in_datamodel_convert_nested_package_module_from_sibling_module() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "Packages/Package1/init.lua",
            "convert_nested_package_module_from_sibling_module",
        );
    }

    // following tests are only on the DataModel sourcemap case
    #[test]
    fn in_datamodel_convert_module_require_across_service_instance() {
        snapshot_file_process(
            &get_resources_for_sourcemap(true, "./sourcemap.json"),
            "main.server.lua",
            "convert_module_require_across_service_instance",
        );
    }
}
