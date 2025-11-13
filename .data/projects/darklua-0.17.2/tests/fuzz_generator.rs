#![cfg(not(coverage))]

use darklua_core::{
    generator::LuaGenerator,
    nodes::{
        BinaryExpression, BinaryOperator, Expression, Identifier, IfExpression, LastStatement,
        Type, TypeCastExpression, UnaryExpression,
    },
};
use std::time::Duration;

mod ast_fuzzer;
mod utils;

use ast_fuzzer::*;

macro_rules! fuzz_test_expression {
    ($node:expr,  $generator:expr) => {
        let node: Expression = $node.into();
        let mut generator = $generator;
        generator.write_expression(&node);
        let lua_code = format!("return {}", generator.into_string());

        let mut generated_block = match utils::try_parse_input(&lua_code) {
            Ok(block) => block,
            Err(error) => panic!(
                concat!(
                    "could not parse content: {:?}\n",
                    "============================================================\n",
                    ">>> Lua code input:\n{}\n",
                    "============================================================\n",
                    "\n",
                    "============================================================\n",
                    ">>> Node that produced the generated code:\n{:?}\n",
                    "============================================================\n",
                ),
                error, lua_code, node,
            ),
        };

        let last_statement = generated_block
            .take_last_statement()
            .expect("should have a last statement");

        let generated_node = match last_statement {
            LastStatement::Return(statement) => {
                if statement.len() != 1 {
                    panic!("should have exactly one expression")
                }
                statement.into_iter_expressions().next().unwrap()
            }
            _ => panic!("return statement expected"),
        };

        let mut compare_generator = darklua_core::generator::ReadableLuaGenerator::default();
        compare_generator.write_expression(&generated_node);
        let generated_lua_code = compare_generator.into_string();

        assert_eq!(
            node,
            generated_node,
            concat!(
                "\n",
                "============================================================\n",
                "{}",
                "============================================================\n",
                ">>> Lua code generated:\n{}\n",
                ">>> Node code generated:\n{}\n",
                "============================================================\n",
            ),
            pretty_assertions::Comparison::new(&node, &generated_node),
            lua_code,
            generated_lua_code,
        );
    };
}

macro_rules! fuzz_test_block {
    ($budget:expr, $generator:expr) => {
        let block = AstFuzzer::new($budget).fuzz_block();

        let mut generator = $generator;
        generator.write_block(&block);
        let lua_code = generator.into_string();

        // let mut temp_file = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR"));
        // temp_file.push("fuzzed-code.lua");
        // std::fs::write(&temp_file, &lua_code).expect("Unable to write file");

        let generated_block = match utils::try_parse_input(&lua_code) {
            Ok(block) => block,
            Err(error) => panic!(
                concat!(
                    "could not parse content: {:?}\n",
                    "============================================================\n",
                    ">>> Lua code input:\n{}\n",
                    "============================================================\n",
                    "\n",
                    "============================================================\n",
                    ">>> Block that produced the generated code:\n{:#?}\n",
                    "============================================================\n",
                ),
                error, lua_code, block,
            ),
        };

        let mut compare_generator = darklua_core::generator::ReadableLuaGenerator::default();
        compare_generator.write_block(&generated_block);
        let generated_lua_code = compare_generator.into_string();

        assert_eq!(
            block,
            generated_block,
            concat!(
                "\n",
                "============================================================\n",
                "{}",
                "============================================================\n",
                ">>> Lua code generated:\n{}\n",
                ">>> Lua code from parsed generated block:\n{}\n",
                "============================================================\n",
            ),
            pretty_assertions::Comparison::new(&block, &generated_block),
            lua_code,
            generated_lua_code,
        );
    };
}

fn run_for_minimum_time<F: Fn()>(func: F) {
    let millis = option_env!("FUZZ_DURATION_MILLISECONDS")
        .and_then(|value| value.parse::<u64>().ok())
        .unwrap_or(1500);

    let duration = Duration::from_millis(millis);

    utils::run_for_minimum_time(duration, func);
}

fn fuzz_three_terms_binary_expressions<T: LuaGenerator + Clone>(generator: T) {
    let expressions = [
        Expression::from(true),
        Identifier::new("var").into(),
        IfExpression::new(Identifier::new("condition"), false, true).into(),
        TypeCastExpression::new(Expression::nil(), Type::nil()).into(),
    ];

    for first in expressions.iter() {
        for second in expressions.iter() {
            for third in expressions.iter() {
                for operator in ast_fuzzer::combination::binary_operators() {
                    for nested_operator in ast_fuzzer::combination::binary_operators() {
                        for nested_left in [true, false] {
                            let nested_binary = BinaryExpression::new(
                                nested_operator,
                                wrap_binary_left(operator, first.clone()),
                                wrap_binary_right(operator, second.clone()),
                            )
                            .into();
                            let (left, right) = if nested_left {
                                (nested_binary, third.clone())
                            } else {
                                (third.clone(), nested_binary)
                            };

                            let binary = BinaryExpression::new(
                                operator,
                                wrap_binary_left(operator, left),
                                wrap_binary_right(operator, right),
                            );

                            fuzz_test_expression!(binary, generator.clone());
                        }
                    }
                }
            }
        }
    }
}

fn wrap_binary_left(operator: BinaryOperator, left: Expression) -> Expression {
    if operator.left_needs_parentheses(&left) {
        left.in_parentheses()
    } else {
        left
    }
}

fn wrap_binary_right(operator: BinaryOperator, right: Expression) -> Expression {
    if operator.right_needs_parentheses(&right) {
        right.in_parentheses()
    } else {
        right
    }
}

fn fuzz_binary_expressions_with_one_unary_expression<T: LuaGenerator + Clone>(generator: T) {
    let expressions = [
        Expression::from(true),
        Identifier::new("var").into(),
        IfExpression::new(Identifier::new("condition"), false, true).into(),
        TypeCastExpression::new(Expression::nil(), Type::nil()).into(),
    ];

    for first in expressions.iter() {
        for second in expressions.iter() {
            for binary_operator in ast_fuzzer::combination::binary_operators() {
                for unary_operator in ast_fuzzer::combination::unary_operators() {
                    for nested_left in [true, false] {
                        let unary = UnaryExpression::new(unary_operator, first.clone()).into();
                        let (left, right) = if nested_left {
                            (unary, second.clone())
                        } else {
                            (second.clone(), unary)
                        };

                        let binary = BinaryExpression::new(
                            binary_operator,
                            wrap_binary_left(binary_operator, left),
                            wrap_binary_right(binary_operator, right),
                        );

                        fuzz_test_expression!(binary, generator.clone());
                    }
                }
            }
        }
    }
}

macro_rules! generate_fuzz_tests {
    (
        $($name:ident($generator:expr) => { $($extra:tt)* }),+,
    ) => {
        $(
            #[cfg(not(coverage))]
            mod $name {
                use super::*;
                use darklua_core::generator::*;

                fn generator() -> impl LuaGenerator + Clone {
                    $generator
                }

                #[test]
                fn fuzz_three_terms_binary_expressions() {
                    super::fuzz_three_terms_binary_expressions(generator());
                }

                #[test]
                fn fuzz_binary_expressions_with_one_unary_expression() {
                    super::fuzz_binary_expressions_with_one_unary_expression(generator());
                }

                #[test]
                fn fuzz_single_statement() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(1, 5), generator());
                    });
                }

                #[test]
                fn fuzz_single_statement_with_types() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(1, 5).with_types(5), generator());
                    });
                }

                #[test]
                fn fuzz_tiny_block() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(2, 8), generator());
                    });
                }

                #[test]
                fn fuzz_small_block() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(20, 40), generator());
                    });
                }

                #[test]
                fn fuzz_medium_block() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(100, 200), generator());
                    });
                }

                #[test]
                fn fuzz_large_block() {
                    run_for_minimum_time(|| {
                        fuzz_test_block!(FuzzBudget::new(200, 200), generator());
                    });
                }

                $( $extra )*
            }
        )*
    };
}

generate_fuzz_tests!(
    dense_generator(DenseLuaGenerator::new(80)) => {
        #[test]
        fn fuzz_column_span() {
            super::run_for_minimum_time(|| {
                for i in 0..80 {
                    let generator = DenseLuaGenerator::new(i);
                    fuzz_test_block!(FuzzBudget::new(20, 40), generator);
                }
            });
        }
    },

    readable_generator(ReadableLuaGenerator::new(80)) => {
        #[test]
        fn fuzz_column_span() {
            super::run_for_minimum_time(|| {
                for i in 0..80 {
                    let generator = ReadableLuaGenerator::new(i);
                    fuzz_test_block!(FuzzBudget::new(20, 40), generator);
                }
            });
        }
    },

    token_based_generator(TokenBasedLuaGenerator::new("")) => {},
);
