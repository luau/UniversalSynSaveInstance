use std::time::Duration;

use darklua_core::{
    generator::{LuaGenerator, ReadableLuaGenerator},
    nodes::Type,
    process::{DefaultVisitor, NodeProcessor, NodeVisitor},
    rules::{ContextBuilder, FlawlessRule, RemoveTypes, Rule},
    Resources,
};

use crate::{
    ast_fuzzer::{AstFuzzer, FuzzBudget},
    utils,
};

test_rule!(
    remove_types,
    RemoveTypes::default(),
    remove_type_declaration("type T = string | number") => "",
    remove_type_declaration_keep_leading_comment("--!native\ntype T = string | number") => "--!native\n",
    remove_type_declaration_keep_trailing_comment("type T = string | number\n-- end of file") => "\n-- end of file",
    remove_exported_type_declaration("export type T = { Node }") => "",
    remove_type_in_local_assign("local var: boolean = true") => "local var = true",
    remove_type_in_numeric_for("for i: number=a, b do end") => "for i=a, b do end",
    remove_types_in_generic_for("for k: string, v: boolean in pairs({}) do end")
        => "for k, v in pairs({}) do end",
    remove_type_cast("return value :: string") => "return value",
    remove_types_in_local_function_param("local function foo(param: T) end")
        => "local function foo(param) end",
    remove_types_in_local_function_variadic_param("local function foo(...: string) end")
        => "local function foo(...) end",
    remove_types_in_local_function_return_type("local function foo(): boolean end")
        => "local function foo() end",
    remove_types_in_function_statement_param("function test(param: T) end")
        => "function test(param) end",
    remove_types_in_function_statement_variadic_param("function foo(...: string) end")
        => "function foo(...) end",
    remove_types_in_function_statement_return_type("function foo(): boolean end")
        => "function foo() end",
    remove_types_in_function_expression_param("return function(param: T) end")
        => "return function(param) end",
    remove_types_in_function_expression_variadic_param("return function(...: string) end")
        => "return function(...) end",
    remove_types_in_function_expression_return_type("return function(): boolean end")
        => "return function() end",
    remove_types_in_type_cast_of_function_call("return call() :: any")
        => "return (call())",
    remove_types_in_type_cast_of_variadic_arguments("return ... :: any")
        => "return (...)",
    remove_types_in_type_cast_of_identifier("return value :: any")
        => "return value",
    remove_types_in_type_cast_of_table("return {} :: any")
        => "return {}",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'remove_types',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'remove_types'").unwrap();
}

#[test]
fn fuzz_bundle() {
    struct HasTypeProcessor {
        found_type: bool,
    }

    impl HasTypeProcessor {
        fn new() -> Self {
            Self { found_type: false }
        }
    }

    impl NodeProcessor for HasTypeProcessor {
        fn process_type(&mut self, _: &mut Type) {
            if !self.found_type {
                self.found_type = true;
            }
        }
    }

    utils::run_for_minimum_time(Duration::from_millis(250), || {
        let fuzz_budget = FuzzBudget::new(20, 40).with_types(40);
        let mut block = AstFuzzer::new(fuzz_budget).fuzz_block();

        RemoveTypes::default().flawless_process(
            &mut block,
            &ContextBuilder::new("test.lua", &Resources::from_memory(), "").build(),
        );

        let mut generator = ReadableLuaGenerator::new(80);

        generator.write_block(&block);

        let block_content = generator.into_string();

        let mut result_block = utils::parse_input(&block_content);

        let mut processor = HasTypeProcessor::new();
        DefaultVisitor::visit_block(&mut result_block, &mut processor);

        assert!(!processor.found_type);
    })
}
