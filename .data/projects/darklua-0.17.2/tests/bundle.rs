use darklua_core::{process, Options, Resources};

mod ast_fuzzer;
mod utils;

use utils::memory_resources;

const DARKLUA_BUNDLE_ONLY_READABLE_CONFIG: &str =
    "{ \"rules\": [], \"generator\": \"readable\", \"bundle\": { \"require_mode\": \"path\" } }";

const DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE: &str =
    "{ \"rules\": [], \"generator\": \"readable\", \"bundle\": { \"require_mode\": \"luau\" } }";

const DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG: &str =
    "{ \"rules\": [], \"generator\": \"retain_lines\", \"bundle\": { \"require_mode\": \"path\" } }";

fn process_main_unchanged(resources: &Resources, main_code: &'static str) {
    resources.write("src/main.lua", main_code).unwrap();
    process(
        resources,
        Options::new("src/main.lua").with_output("out.lua"),
    )
    .unwrap()
    .result()
    .unwrap();

    let main = resources.get("out.lua").unwrap();

    pretty_assertions::assert_eq!(main, main_code);
}

#[test]
fn skip_require_call_without_a_string() {
    let resources = memory_resources!(
        ".darklua.json" => DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG,
    );

    process_main_unchanged(&resources, "local library = require( {} )");
}

#[test]
fn skip_require_call_with_method() {
    let resources = memory_resources!(
        ".darklua.json" => DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG,
    );

    process_main_unchanged(
        &resources,
        "local library = require:method('./library.luau')",
    );
}

#[test]
fn skip_require_call_with_2_arguments() {
    let resources = memory_resources!(
        ".darklua.json" => DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG,
    );

    process_main_unchanged(
        &resources,
        "local library = require('./example', 'argument')",
    );
}

mod without_rules {
    use std::time::Duration;

    use darklua_core::{
        generator::{LuaGenerator, ReadableLuaGenerator},
        nodes::{Expression, ReturnStatement},
    };

    use crate::ast_fuzzer::{AstFuzzer, FuzzBudget};

    use super::*;

    fn process_main(resources: &Resources, snapshot_name: &'static str) {
        process(
            resources,
            Options::new("src/main.lua").with_output("out.lua"),
        )
        .unwrap()
        .result()
        .unwrap();

        let main = resources.get("out.lua").unwrap();

        insta::assert_snapshot!(format!("bundle_without_rules_{}", snapshot_name), main);
    }

    fn process_init(resources: &Resources, snapshot_name: &'static str) {
        process(
            resources,
            Options::new("src/init.lua").with_output("out.lua"),
        )
        .unwrap()
        .result()
        .unwrap();

        let main = resources.get("out.lua").unwrap();

        insta::assert_snapshot!(format!("bundle_without_rules_{}", snapshot_name), main);
    }

    fn process_main_with_errors(resources: &Resources, snapshot_name: &str) {
        let errors = process(
            resources,
            Options::new("src/main.lua").with_output("out.lua"),
        )
        .unwrap()
        .result()
        .unwrap_err();

        let error_display: Vec<_> = errors.into_iter().map(|err| err.to_string()).collect();

        let mut settings = insta::Settings::clone_current();
        settings.add_filter("\\\\", "/");
        settings.bind(|| {
            insta::assert_snapshot!(snapshot_name, error_display.join("\n"));
        });
    }

    mod module_locations {
        use super::*;

        fn process_main_require_value(resources: Resources) {
            // we can re-use the same snapshot because the output file should
            // resolve to the same code
            process_main(&resources, "require_lua_file");
        }

        fn process_init_require_value(resources: Resources) {
            // we can re-use the same snapshot because the output file should
            // resolve to the same code
            process_init(&resources, "require_lua_file");
        }

        #[test]
        fn require_lua_file() {
            process_main_require_value(memory_resources!(
                "src/value.lua" => "return true",
                "src/main.lua" => "local value = require('./value.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_lua_file_with_string_call() {
            process_main_require_value(memory_resources!(
                "src/value.lua" => "return true",
                "src/main.lua" => "local value = require './value.lua'",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_lua_file_in_sibling_nested_file() {
            process_main_require_value(memory_resources!(
                "src/constants/value.lua" => "return true",
                "src/main.lua" => "local value = require('./constants/value.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_lua_file_in_parent_directory() {
            process_main_require_value(memory_resources!(
                "value.lua" => "return true",
                "src/main.lua" => "local value = require('../value.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }
        #[test]
        fn require_lua_file_without_extension() {
            process_main_require_value(memory_resources!(
                "src/value.lua" => "return true",
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_lua_file_in_parent_directory_without_extension() {
            process_main_require_value(memory_resources!(
                "value.lua" => "return true",
                "src/main.lua" => "local value = require('../value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_luau_file_in_parent_directory_without_extension() {
            process_main_require_value(memory_resources!(
                "value.luau" => "return true",
                "src/main.lua" => "local value = require('../value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_luau_file_without_extension() {
            process_main_require_value(memory_resources!(
                "src/value.luau" => "return true",
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_directory_with_init_lua_file() {
            process_main_require_value(memory_resources!(
                "src/value/init.lua" => "return true",
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_directory_with_init_luau_file() {
            process_main_require_value(memory_resources!(
                "src/value/init.luau" => "return true",
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_in_parent_directory() {
            process_main_require_value(memory_resources!(
                "value.lua" => "return true",
                "src/main.lua" => "local value = require('../value.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_in_packages_directory() {
            process_main_require_value(memory_resources!(
                "packages/value.lua" => "return true",
                "src/main.lua" => "local value = require('Packages/value.lua')",
                ".darklua.json" => "{ \"rules\": [], \"generator\": \"readable\", \"bundle\": { \"require_mode\": { \"name\": \"path\", \"sources\": { \"Packages\": \"./packages\" } } } }",
            ));
        }

        #[test]
        fn require_in_packages_directory_using_luau_rc_alias() {
            process_main_require_value(memory_resources!(
                "packages/value.lua" => "return true",
                "src/main.lua" => "local value = require('@Packages/value.lua')",
                ".luaurc" => "{ \"aliases\": { \"Packages\": \"packages\" } }",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_in_packages_directory_using_luau_rc_alias_starting_with_dot() {
            process_main_require_value(memory_resources!(
                "packages/value.lua" => "return true",
                "src/main.lua" => "local value = require('@Packages/value.lua')",
                ".luaurc" => "{ \"aliases\": { \"Packages\": \"./packages\" } }",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ));
        }

        #[test]
        fn require_directory_with_custom_init_file() {
            process_main_require_value(memory_resources!(
                "src/value/__init__.lua" => "return true",
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => "{ \"rules\": [], \"generator\": \"readable\", \"bundle\": { \"require_mode\": { \"name\": \"path\", \"module_folder_name\": \"__init__.lua\" } } }",
            ));
        }

        mod luau_mode {
            use super::*;

            #[test]
            fn require_lua_file() {
                process_main_require_value(memory_resources!(
                    "src/value.lua" => "return true",
                    "src/main.lua" => "local value = require('./value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_in_init() {
                process_init_require_value(memory_resources!(
                    "src/value.lua" => "return true",
                    "src/init.lua" => "local value = require('@self/value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_with_string_call() {
                process_main_require_value(memory_resources!(
                    "src/value.lua" => "return true",
                    "src/main.lua" => "local value = require './value.lua'",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_in_sibling_nested_file() {
                process_main_require_value(memory_resources!(
                    "src/constants/value.lua" => "return true",
                    "src/main.lua" => "local value = require('./constants/value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_in_sibling_nested_file_in_init() {
                process_init_require_value(memory_resources!(
                    "src/constants/value.lua" => "return true",
                    "src/init.lua" => "local value = require('@self/constants/value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_in_parent_directory() {
                process_main_require_value(memory_resources!(
                    "value.lua" => "return true",
                    "src/main.lua" => "local value = require('../value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }
            #[test]
            fn require_lua_file_without_extension() {
                process_main_require_value(memory_resources!(
                    "src/value.lua" => "return true",
                    "src/main.lua" => "local value = require('./value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_lua_file_in_parent_directory_without_extension() {
                process_main_require_value(memory_resources!(
                    "value.lua" => "return true",
                    "src/main.lua" => "local value = require('../value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_luau_file_in_parent_directory_without_extension() {
                process_main_require_value(memory_resources!(
                    "value.luau" => "return true",
                    "src/main.lua" => "local value = require('../value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_luau_file_without_extension() {
                process_main_require_value(memory_resources!(
                    "src/value.luau" => "return true",
                    "src/main.lua" => "local value = require('./value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_directory_with_init_lua_file() {
                process_main_require_value(memory_resources!(
                    "src/value/init.lua" => "return true",
                    "src/main.lua" => "local value = require('./value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_directory_with_init_luau_file() {
                process_main_require_value(memory_resources!(
                    "src/value/init.luau" => "return true",
                    "src/main.lua" => "local value = require('./value')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_in_parent_directory() {
                process_main_require_value(memory_resources!(
                    "value.lua" => "return true",
                    "src/main.lua" => "local value = require('../value.lua')",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE,
                ));
            }

            #[test]
            fn require_in_packages_directory() {
                process_main_require_value(memory_resources!(
                    "packages/value.lua" => "return true",
                    "src/main.lua" => "local value = require('@Packages/value.lua')",
                    ".darklua.json" => "{ \"rules\": [], \"generator\": \"readable\", \"bundle\": { \"require_mode\": { \"name\": \"luau\", \"sources\": { \"@Packages\": \"./packages\" } } } }",
                ));
            }

            #[test]
            fn require_in_packages_directory_using_luau_rc_alias() {
                process_main_require_value(memory_resources!(
                    "packages/value.lua" => "return true",
                    "src/main.lua" => "local value = require('@Packages/value.lua')",
                    ".luaurc" => "{ \"aliases\": { \"Packages\": \"packages\" } }",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE
                ));
            }

            #[test]
            fn require_in_packages_directory_using_luau_rc_alias_starting_with_dot() {
                process_main_require_value(memory_resources!(
                    "packages/value.lua" => "return true",
                    "src/main.lua" => "local value = require('@Packages/value.lua')",
                    ".luaurc" => "{ \"aliases\": { \"Packages\": \"./packages\" } }",
                    ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG_LUAU_MODE
                ));
            }
        }
    }

    #[test]
    fn require_lua_file_forward_exported_types() {
        process_main(
            &memory_resources!(
                "src/value.lua" => "export type Value = string return true",
                "src/main.lua" => "local value = require('./value.lua') export type Value = value.Value",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ),
            "require_lua_file_forward_exported_types",
        );
    }

    #[test]
    fn require_lua_file_forward_exported_types_with_generics() {
        process_main(
            &memory_resources!(
                "src/value.lua" => "export type Value<T> = string | T return true",
                "src/main.lua" => "local value = require('./value.lua') export type Value<T> = value.Value<T>",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            ),
            "require_lua_file_forward_exported_types_with_generics",
        );
    }

    #[test]
    fn require_lua_file_after_declaration() {
        let resources = memory_resources!(
            "src/value.lua" => "return true",
            "src/main.lua" => "local const = 1\nlocal value = require('./value.lua')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_after_declaration");
    }

    #[test]
    fn require_lua_file_nested() {
        let resources = memory_resources!(
            "src/constant.lua" => "return 2",
            "src/value.lua" => "local constant = require('./constant.lua')\nreturn constant + constant",
            "src/main.lua" => "local value = require('./value.lua')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_nested");
    }

    #[test]
    fn require_lua_file_twice() {
        let resources = memory_resources!(
            "src/constant.lua" => "print('load constant module') return 2",
            "src/value_a.lua" => "print('load value a')\nlocal constant_a = require('./constant.lua')\nreturn constant_a",
            "src/value_b.lua" => "print('load value b')\nlocal constant_b = require('./constant.lua')\nreturn constant_b",
            "src/main.lua" => concat!(
                "local value_a = require('./value_a.lua')\n",
                "local value_b = require('./value_b.lua')\n",
                "print(value_a + value_b)"
            ),
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_twice");
    }

    #[test]
    fn require_lua_file_twice_with_different_paths() {
        let resources = memory_resources!(
            "src/constant.lua" => "print('load constant module') return 2",
            "src/a/value_a.lua" => "print('load value a')\nlocal constant_a = require('../constant.lua')\nreturn constant_a",
            "src/value_b.lua" => "print('load value b')\nlocal constant_b = require('./constant.lua')\nreturn constant_b",
            "src/main.lua" => concat!(
                "local value_a = require('./a/value_a.lua')\n",
                "local value_b = require('./value_b.lua')\n",
                "print(value_a + value_b)"
            ),
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_twice_with_different_paths");
    }

    #[test]
    fn require_lua_file_with_field_expression() {
        let resources = memory_resources!(
            "src/value.lua" => "return { value = 'oof' }",
            "src/main.lua" => "local value = require('./value.lua').value",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_with_field_expression");
    }

    #[test]
    fn require_lua_file_with_statement() {
        let resources = memory_resources!(
            "src/run.lua" => "print('run')\nreturn nil",
            "src/main.lua" => "require('./run.lua')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_lua_file_with_statement");
    }

    #[test]
    fn require_json_file_with_object() {
        let resources = memory_resources!(
            "src/value.json" => "{ \"value\": true }",
            "src/main.lua" => "local value = require('./value.json')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_json_file_with_object");
    }

    #[test]
    fn require_json5_file_with_object() {
        let resources = memory_resources!(
            "src/value.json5" => "{ value: true }",
            "src/main.lua" => "local value = require('./value.json5')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_json_file_with_object");
    }

    #[test]
    fn require_json5_file_as_json_with_object() {
        let resources = memory_resources!(
            "src/value.json" => "{ value: true }",
            "src/main.lua" => "local value = require('./value.json')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_json_file_with_object");
    }

    #[test]
    fn require_toml_with_object() {
        let resources = memory_resources!(
            "src/value.toml" => "name = 'darklua'\nvalue = 10",
            "src/main.lua" => "local value = require('./value.toml')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_toml_with_object");
    }

    #[test]
    fn require_yaml_with_array() {
        let resources = memory_resources!(
            "src/value.yaml" => r#"
- 0
- 100
            "#,
            "src/main.lua" => "local value = require('./value.yaml')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_yaml_with_array");
    }

    #[test]
    fn require_yml_with_object() {
        let resources = memory_resources!(
            "src/value.yml" => r#"
name: darklua
data:
    bool: true
    numbers:
    - 0
    - 100
            "#,
            "src/main.lua" => "local value = require('./value.yml')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_yml_with_object");
    }

    #[test]
    fn require_txt_file() {
        let resources = memory_resources!(
            "src/value.txt" => "Hello from txt file!\n\nThis is written on another line.\n",
            "src/main.lua" => "local value = require('./value.txt')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "require_txt_file");
    }

    #[test]
    fn require_value_and_override_require_function() {
        let resources = memory_resources!(
            "src/value.lua" => "return 1",
            "src/main.lua" => "local value = require('./value') local require = function()end local v = require('v')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main(&resources, "override_require");
    }

    #[test]
    fn require_unknown_module() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('@lune/library')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_unknown_module");
    }

    #[test]
    fn require_unknown_relative_file() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('./library')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_unknown_relative_file");
    }

    #[test]
    fn require_unknown_relative_file_with_extension() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('./library.luau')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_unknown_relative_file_with_extension");
    }

    #[test]
    fn require_empty_path_errors() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('')",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_empty_path_errors");
    }

    #[test]
    fn require_lua_file_with_parser_error() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('./value.lua')",
            "src/value.lua" => "returnone",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_lua_file_with_parser_error");
    }

    #[test]
    fn require_lua_file_with_unsupported_extension() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('./value.error')",
            "src/value.error" => "",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_lua_file_with_unsupported_extension");
    }

    #[test]
    fn require_own_lua_file() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('./main.lua') return nil",
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
        );

        process_main_with_errors(&resources, "require_own_lua_file");
    }

    #[test]
    fn require_skip_unknown_module() {
        let resources = memory_resources!(
            "src/main.lua" => "local library = require('@lune/library')",
            ".darklua.json" => "{ \"rules\": [], \"bundle\": { \"require_mode\": \"path\", \"excludes\": [\"@lune/**\"] } }",
        );

        process_main(&resources, "require_skip_unknown_module");
    }

    #[test]
    fn require_small_bundle_case() {
        let resources = memory_resources!(
            "src/initialize.lua" => include_str!("./test_cases/small_bundle/initialize.lua"),
            "src/value.lua" => include_str!("./test_cases/small_bundle/value.lua"),
            "src/format.lua" => include_str!("./test_cases/small_bundle/format.lua"),
            "src/main.lua" => include_str!("./test_cases/small_bundle/main.lua"),
            ".darklua.json" => DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG,
        );

        process_main(&resources, "require_small_bundle_case");
    }

    #[test]
    fn fuzz_bundle() {
        utils::run_for_minimum_time(Duration::from_millis(250), || {
            let fuzz_budget = FuzzBudget::new(20, 40).with_types(25);
            let mut block = AstFuzzer::new(fuzz_budget).fuzz_block();
            block.set_last_statement(ReturnStatement::one(Expression::nil()));

            let mut generator = ReadableLuaGenerator::new(80);

            generator.write_block(&block);

            let block_file = generator.into_string();

            let resources = memory_resources!(
                "src/value.lua" => &block_file,
                "src/main.lua" => "local value = require('./value')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_RETAIN_LINES_CONFIG,
            );
            let resource_ref = &resources;

            let result = std::panic::catch_unwind(|| {
                process(
                    resource_ref,
                    Options::new("src/main.lua").with_output("out.lua"),
                )
                .unwrap()
                .result()
                .unwrap();
            });

            result
                .inspect_err(|_err| {
                    std::fs::write("fuzz_bundle_failure.repro.lua", block_file).unwrap();

                    let out = resources.get("out.lua").unwrap();
                    std::fs::write("fuzz_bundle_failure.lua", out).unwrap();
                })
                .unwrap();
        })
    }

    mod cyclic_requires {
        use super::*;

        fn process_main_with_error(resources: &Resources, snapshot_name: &str) {
            process_main_with_errors(resources, &format!("cyclic_requires__{}", snapshot_name));
        }

        #[test]
        fn simple_direct_cycle() {
            let resources = memory_resources!(
                "src/value1.lua" => "return require('./value2')",
                "src/value2.lua" => "return require('./value1')",
                "src/main.lua" => "local value = require('./value1.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            );

            process_main_with_error(&resources, "simple_direct_cycle");
        }

        #[test]
        fn simple_direct_cycle_in_required_file() {
            let resources = memory_resources!(
                "src/value1.lua" => "return require('./value2')",
                "src/value2.lua" => "return require('./value1')",
                "src/constant.lua" => "return require('./value1.lua')",
                "src/main.lua" => "local value = require('./constant.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            );

            process_main_with_error(&resources, "simple_direct_cycle_in_required_file");
        }

        #[test]
        fn simple_transitive_cycle() {
            let resources = memory_resources!(
                "src/value1.lua" => "return require('./constant')",
                "src/value2.lua" => "return require('./value1')",
                "src/constant.lua" => "return require('./value2.lua')",
                "src/main.lua" => "local value = require('./value1.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            );

            process_main_with_error(&resources, "simple_transitive_cycle");
        }

        #[test]
        fn direct_cycle_in_required_file_with_ok_require() {
            let resources = memory_resources!(
                "src/value1.lua" => "return require('./value2')",
                "src/value2.lua" => "return require('./value1')",
                "src/constant.lua" => "return 1",
                "src/main.lua" => "local constant = require('./constant.lua')\nlocal value = require('./value1.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            );

            process_main_with_error(&resources, "direct_cycle_in_required_file_with_ok_require");
        }

        #[test]
        fn two_different_direct_cycles() {
            let resources = memory_resources!(
                "src/value1.lua" => "return require('./value2')",
                "src/value2.lua" => "return require('./value1')",
                "src/constant1.lua" => "return require('./constant2')",
                "src/constant2.lua" => "return require('./constant1')",
                "src/main.lua" => "local constant = require('./constant1.lua')\nlocal value = require('./value1.lua')",
                ".darklua.json" => DARKLUA_BUNDLE_ONLY_READABLE_CONFIG,
            );

            process_main_with_error(&resources, "two_different_direct_cycles");
        }
    }
}
