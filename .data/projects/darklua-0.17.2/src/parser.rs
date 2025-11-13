use std::fmt;

use full_moon::{ast::Ast, LuaVersion};

use crate::{
    ast_converter::{AstConverter, ConvertError},
    nodes::*,
    utils::Timer,
};

/// A parser for Luau code that converts it into an abstract syntax tree.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Parser {
    hold_token_data: bool,
}

impl Parser {
    /// Parses Lua code into a [`Block`].
    pub fn parse(&self, code: &str) -> Result<Block, ParserError> {
        let full_moon_parse_timer = Timer::now();
        let parse_result = full_moon::parse_fallible(code, LuaVersion::luau()).into_result();
        log::trace!(
            "full-moon parsing done in {}",
            full_moon_parse_timer.duration_label()
        );
        parse_result.map_err(ParserError::parsing).and_then(|ast| {
            log::trace!("start converting full-moon AST");
            let conversion_timer = Timer::now();
            let block = self.convert_ast(ast).map_err(ParserError::converting);
            log::trace!(
                " ⨽ completed AST conversion in {}",
                conversion_timer.duration_label()
            );
            block
        })
    }

    /// Configures the parser to preserve token data (line numbers, whitespace and comments).
    pub fn preserve_tokens(mut self) -> Self {
        self.hold_token_data = true;
        self
    }

    pub(crate) fn is_preserving_tokens(&self) -> bool {
        self.hold_token_data
    }

    #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
    fn convert_ast(&self, ast: Ast) -> Result<Block, ConvertError> {
        AstConverter::new(self.hold_token_data).convert(&ast)
    }
}

#[derive(Clone, Debug)]
enum ParserErrorKind {
    Parsing(Vec<full_moon::Error>),
    Converting(ConvertError),
}

/// The error type that can occur when parsing code.
#[derive(Clone, Debug)]
pub struct ParserError {
    kind: Box<ParserErrorKind>,
}

impl ParserError {
    fn parsing(err: Vec<full_moon::Error>) -> Self {
        Self {
            kind: ParserErrorKind::Parsing(err).into(),
        }
    }

    fn converting(err: ConvertError) -> Self {
        Self {
            kind: ParserErrorKind::Converting(err).into(),
        }
    }
}

impl fmt::Display for ParserError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &*self.kind {
            ParserErrorKind::Parsing(errors) => {
                for err in errors {
                    writeln!(f, "{}", err)?;
                }
                Ok(())
            }
            ParserErrorKind::Converting(err) => write!(f, "{}", err),
        }
    }
}

#[cfg(test)]
mod test {
    use std::str::FromStr;

    use crate::nodes::ReturnStatement;

    use super::*;

    macro_rules! test_parse {
        ($($name:ident($input:literal) => $value:expr),* $(,)?) => {
            $(
                #[test]
                fn $name() {
                    let parser = Parser::default();
                    let block = parser.parse($input)
                        .expect(&format!("failed to parse `{}`", $input));

                    let expect_block = $value.into();
                    pretty_assertions::assert_eq!(block, expect_block);
                }
            )*
        };
    }

    test_parse!(
        empty_string("") => Block::default(),
        single_line_comment("-- todo") => Block::default(),
        empty_do("do end") => DoStatement::default(),
        empty_do_nested("do do end end") => DoStatement::new(DoStatement::default().into()),
        two_nested_empty_do_in_do_statement("do do end do end end") => DoStatement::new(
            Block::default().with_statement(DoStatement::default()).with_statement(DoStatement::default())
        ),
        triple_nested_do_statements("do do end do do end end end") => DoStatement::new(
            Block::default()
                .with_statement(DoStatement::default())
                .with_statement(DoStatement::new(DoStatement::default().into()))
        ),
        do_return_end("do return end") => DoStatement::new(ReturnStatement::default().into()),
        break_statement("break") => LastStatement::new_break(),
        return_no_values("return") => ReturnStatement::default(),
        return_true("return true") => ReturnStatement::one(Expression::from(true)),
        return_false("return false") => ReturnStatement::one(false),
        return_nil("return nil") => ReturnStatement::one(Expression::nil()),
        return_variable_arguments("return ...") => ReturnStatement::one(Expression::variable_arguments()),
        return_variable("return var") => ReturnStatement::one(Expression::identifier("var")),
        return_parentheses_true("return (true)") => ReturnStatement::one(
            Expression::from(true).in_parentheses(),
        ),
        return_true_false("return true, false") => ReturnStatement::one(Expression::from(true))
            .with_expression(false),
        return_empty_single_quote_string("return ''") => ReturnStatement::one(StringExpression::new("''").unwrap()),
        return_empty_double_quote_string("return \"\"") => ReturnStatement::one(StringExpression::new("\"\"").unwrap()),
        return_empty_backtick_string("return ``") => ReturnStatement::one(InterpolatedStringExpression::empty()),
        return_backtick_string_hello("return `hello`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![StringSegment::from_value("hello").into()]
        )),
        return_backtick_string_with_single_value("return `{true}`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![ValueSegment::new(true).into()]
        )),
        return_backtick_string_with_prefixed_single_value("return `value = {true}`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![
                StringSegment::from_value("value = ").into(),
                ValueSegment::new(true).into(),
            ]
        )),
        return_backtick_string_with_suffixed_single_value("return `{false} -> condition`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![
                ValueSegment::new(false).into(),
                StringSegment::from_value(" -> condition").into(),
            ]
        )),
        return_backtick_string_with_prefix_and_suffixed_single_value("return `-> {value} (value)`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![
                StringSegment::from_value("-> ").into(),
                ValueSegment::new(Expression::identifier("value")).into(),
                StringSegment::from_value(" (value)").into(),
            ]
        )),
        return_backtick_string_escape_braces("return `Hello \\{}`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![StringSegment::from_value("Hello {}").into()]
        )),
        return_backtick_string_escape_backtick("return `Delimiter: \\``") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![StringSegment::from_value("Delimiter: `").into()]
        )),
        return_backtick_string_escape_backslash("return `\\\\`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![StringSegment::from_value("\\").into()]
        )),
        return_backtick_string_with_table_value("return `{ {} }`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![ValueSegment::new(TableExpression::default()).into()]
        )),
        return_backtick_string_with_backtrick_string_value("return `{`a`}`") => ReturnStatement::one(InterpolatedStringExpression::new(
            vec![ValueSegment::new(
                InterpolatedStringExpression::new(vec![StringSegment::from_value("a").into()])
            ).into()]
        )),
        empty_while_true_do("while true do end") => WhileStatement::new(Block::default(), true),
        while_false_do_break("while false do break end") => WhileStatement::new(
            LastStatement::new_break(),
            false,
        ),
        empty_repeat("repeat until true") => RepeatStatement::new(Block::default(), true),
        repeat_break("repeat break until true") => RepeatStatement::new(
            LastStatement::new_break(),
            true,
        ),
        repeat_continue("repeat continue until true") => RepeatStatement::new(
            LastStatement::new_continue(),
            true,
        ),
        local_assignment_with_no_values("local var") => LocalAssignStatement::from_variable("var"),
        multiple_local_assignment_with_no_values("local foo, bar") => LocalAssignStatement::from_variable("foo")
            .with_variable("bar"),
        local_assignment_with_one_value("local var = true") => LocalAssignStatement::from_variable("var")
            .with_value(true),
        multiple_local_assignment_with_two_values("local foo, bar = true, false") => LocalAssignStatement::from_variable("foo")
            .with_variable("bar")
            .with_value(true)
            .with_value(false),
        return_binary_and("return true and false") => ReturnStatement::one(
            BinaryExpression::new(BinaryOperator::And, true, false),
        ),
        return_binary_floor_division("return 10 // 3") => ReturnStatement::one(
            BinaryExpression::new(BinaryOperator::DoubleSlash, 10, 3),
        ),
        return_zero("return 0") => ReturnStatement::one(
            NumberExpression::from_str("0").unwrap(),
        ),
        return_one("return 1") => ReturnStatement::one(
            NumberExpression::from_str("1").unwrap(),
        ),
        return_float("return 1.5") => ReturnStatement::one(
            NumberExpression::from_str("1.5").unwrap(),
        ),
        return_zero_point_five("return .5") => ReturnStatement::one(
            NumberExpression::from_str(".5").unwrap(),
        ),
        return_not_true("return not true") => ReturnStatement::one(
            UnaryExpression::new(UnaryOperator::Not, true),
        ),
        return_variable_length("return #array") => ReturnStatement::one(
            UnaryExpression::new(
                UnaryOperator::Length,
                Expression::identifier("array"),
            ),
        ),
        return_minus_variable("return -num") => ReturnStatement::one(
            UnaryExpression::new(
                UnaryOperator::Minus,
                Expression::identifier("num"),
            ),
        ),
        call_function("call()") => FunctionCall::from_name("call"),
        call_indexed_table("foo.bar()") => FunctionCall::from_prefix(
            FieldExpression::new(Prefix::from_name("foo"), "bar")
        ),
        call_method("foo:bar()") => FunctionCall::from_name("foo").with_method("bar"),
        call_method_with_one_argument("foo:bar(true)") => FunctionCall::from_name("foo")
            .with_method("bar")
            .with_argument(true),
        call_function_with_one_argument("call(true)") => FunctionCall::from_name("call")
            .with_argument(true),
        call_function_with_two_arguments("call(true, false)") => FunctionCall::from_name("call")
            .with_argument(true)
            .with_argument(false),
        call_chain_empty("call()()") => FunctionCall::from_prefix(
            FunctionCall::from_name("call")
        ),
        call_chain_with_args("call(true)(false)") => FunctionCall::from_prefix(
            FunctionCall::from_name("call").with_argument(true)
        ).with_argument(false),
        call_method_chain_empty("call():method()") => FunctionCall::from_prefix(
            FunctionCall::from_name("call")
        ).with_method("method"),
        call_method_chain_with_arguments("call(true):method(false)") => FunctionCall::from_prefix(
            FunctionCall::from_name("call").with_argument(true)
        ).with_method("method").with_argument(false),
        call_index_chain_empty("call().method()") => FunctionCall::from_prefix(
            FieldExpression::new(FunctionCall::from_name("call"), "method")
        ),
        call_with_empty_table_argument("call{}") => FunctionCall::from_name("call")
            .with_arguments(TableExpression::default()),
        call_with_empty_string_argument("call''") => FunctionCall::from_name("call")
            .with_arguments(StringExpression::empty()),
        return_call_function("return call()") => ReturnStatement::one(
            FunctionCall::from_name("call"),
        ),
        return_call_indexed_table("return foo.bar()") => ReturnStatement::one(
            FunctionCall::from_prefix(FieldExpression::new(Prefix::from_name("foo"), "bar")),
        ),
        return_call_method("return foo:bar()") => ReturnStatement::one(
            FunctionCall::from_name("foo").with_method("bar"),
        ),
        return_call_method_with_one_argument("return foo:bar(true)") => ReturnStatement::one(
            FunctionCall::from_name("foo").with_method("bar").with_argument(true),
        ),
        return_call_function_with_one_argument("return call(true)") => ReturnStatement::one(
            FunctionCall::from_name("call").with_argument(true),
        ),
        return_call_function_with_two_arguments("return call(true, false)") => ReturnStatement::one(
            FunctionCall::from_name("call")
                .with_argument(true)
                .with_argument(false),
        ),
        return_call_chain_empty("return call()()") => ReturnStatement::one(
            FunctionCall::from_prefix(FunctionCall::from_name("call")),
        ),
        return_call_chain_with_args("return call(true)(false)") => ReturnStatement::one(
            FunctionCall::from_prefix(
                FunctionCall::from_name("call").with_argument(true)
            ).with_argument(false),
        ),
        return_call_method_chain_empty("return call():method()") => ReturnStatement::one(
            FunctionCall::from_prefix(FunctionCall::from_name("call")).with_method("method"),
        ),
        return_call_method_chain_with_arguments("return call(true):method(false)")
            => ReturnStatement::one(
                FunctionCall::from_prefix(FunctionCall::from_name("call").with_argument(true))
                    .with_method("method")
                    .with_argument(false),
            ),
        return_call_index_chain_empty("return call().method()") => ReturnStatement::one(
            FunctionCall::from_prefix(FieldExpression::new(FunctionCall::from_name("call"), "method")),
        ),
        return_call_new_empty_function("return (function() end)()") => ReturnStatement::one(
            FunctionCall::from_prefix(
                ParentheseExpression::new(FunctionExpression::default())
            ),
        ),
        return_call_variable_argument("return (...)()") => ReturnStatement::one(
            FunctionCall::from_prefix(ParentheseExpression::new(Expression::variable_arguments())),
        ),
        return_call_variable_in_parentheses("return (var)()") => ReturnStatement::one(
            FunctionCall::from_prefix(ParentheseExpression::new(Expression::identifier("var"))),
        ),
        return_call_variable_in_double_parentheses("return ((var))()") => ReturnStatement::one(
            FunctionCall::from_prefix(
                ParentheseExpression::new(Expression::identifier("var").in_parentheses())
            ),
        ),
        return_field_expression("return math.huge") => ReturnStatement::one(
            FieldExpression::new(Prefix::from_name("math"), "huge")
        ),
        index_field_function_call("return call().result") => ReturnStatement::one(
            FieldExpression::new(FunctionCall::from_name("call"), "result"),
        ),
        return_index_expression("return value[true]") => ReturnStatement::one(
            IndexExpression::new(Prefix::from_name("value"), true)
        ),
        return_empty_table("return {}") => ReturnStatement::one(TableExpression::default()),
        return_array_with_one_element("return {true}") => ReturnStatement::one(
            TableExpression::default().append_array_value(true)
        ),
        return_array_with_two_elements("return {true, false}") => ReturnStatement::one(
            TableExpression::default()
                .append_array_value(true)
                .append_array_value(false)

        ),
        return_array_with_one_field("return { field = true }") => ReturnStatement::one(
            TableExpression::default().append_field("field", true)
        ),
        return_array_with_one_key_expression("return { [false] = true }") => ReturnStatement::one(
            TableExpression::default().append_index(false, true)
        ),
        assign_variable("var = true") => AssignStatement::from_variable(
            Variable::new("var"),
            true,
        ),
        assign_two_variables("var, var2 = true, false") => AssignStatement::from_variable(
            Variable::new("var"),
            true,
        ).append_assignment(Variable::new("var2"), false),
        assign_one_variable_with_two_values("var = 0b1010, ...") => AssignStatement::new(
            vec![Variable::new("var")],
            vec!["0b1010".parse::<NumberExpression>().unwrap().into(), Expression::variable_arguments()],
        ),
        assign_field("var.field = true") => AssignStatement::from_variable(
            FieldExpression::new(Prefix::from_name("var"), "field"),
            true,
        ),
        assign_field_and_variable("var.field, other = true, 1 + value") =>
            AssignStatement::from_variable(
                FieldExpression::new(Prefix::from_name("var"), "field"),
                true,
            ).append_assignment(
                Variable::new("other"),
                BinaryExpression::new(BinaryOperator::Plus, 1.0, Expression::identifier("value"))
            ),
        assign_index("var[false] = true") => AssignStatement::from_variable(
            IndexExpression::new(Prefix::from_name("var"), false),
            true,
        ),
        return_empty_function("return function() end") => ReturnStatement::one(
            FunctionExpression::default(),
        ),
        return_empty_function_with_one_param("return function(a) end") => ReturnStatement::one(
            FunctionExpression::default().with_parameter("a"),
        ),
        return_empty_function_with_two_params("return function(a, b) end") => ReturnStatement::one(
            FunctionExpression::default().with_parameter("a").with_parameter("b"),
        ),
        return_empty_variadic_function("return function(...) end") => ReturnStatement::one(
            FunctionExpression::default().variadic(),
        ),
        return_empty_variadic_function_with_one_param("return function(a, ...) end")
            => ReturnStatement::one(
                FunctionExpression::default().with_parameter("a").variadic(),
            ),
        return_function_that_returns("return function() return true end")
            => ReturnStatement::one(
                FunctionExpression::from_block(ReturnStatement::one(Expression::from(true)))
            ),
        empty_if_statement("if true then end") => IfStatement::create(true, Block::default()),
        if_statement_returns("if true then return end") => IfStatement::create(
            Expression::from(true),
            ReturnStatement::default(),
        ),
        empty_if_statement_with_empty_else("if true then else end")
            => IfStatement::create(true, Block::default())
                .with_else_block(Block::default()),
        empty_if_statement_with_empty_elseif("if true then elseif false then end")
            => IfStatement::create(true, Block::default())
                .with_new_branch(false, Block::default()),
        empty_if_statement_with_empty_elseif_and_empty_else("if true then elseif false then else end")
            => IfStatement::create(true, Block::default())
                .with_new_branch(false, Block::default())
                .with_else_block(Block::default()),
        empty_if_statement_with_returning_else("if true then else return end")
            => IfStatement::create(true, Block::default())
                .with_else_block(ReturnStatement::default()),
        empty_local_function("local function name() end")
            => LocalFunctionStatement::from_name("name", Block::default()),
        empty_local_function_variadic("local function name(...) end")
            => LocalFunctionStatement::from_name("name", Block::default()).variadic(),
        empty_local_function_variadic_with_one_parameter("local function name(a, ...) end")
            => LocalFunctionStatement::from_name("name", Block::default())
                .with_parameter("a")
                .variadic(),
        local_function_return("local function name() return end")
            => LocalFunctionStatement::from_name("name", ReturnStatement::default()),

        empty_function_statement("function name() end")
            => FunctionStatement::from_name("name", Block::default()),
        empty_function_statement_variadic("function name(...) end")
            => FunctionStatement::from_name("name", Block::default()).variadic(),
        empty_function_statement_variadic_with_one_parameter("function name(a, ...) end")
            => FunctionStatement::from_name("name", Block::default())
                .with_parameter("a")
                .variadic(),
        function_statement_return("function name() return end")
            => FunctionStatement::from_name("name", ReturnStatement::default()),
        empty_generic_for("for key in pairs(t) do end") => GenericForStatement::new(
            vec!["key".into()],
            vec![
                FunctionCall::from_name("pairs")
                    .with_argument(Expression::identifier("t"))
                    .into(),
            ],
            Block::default(),
        ),
        empty_generic_for_with_typed_key("for key: string in t do end") => GenericForStatement::new(
            vec![Identifier::new("key").with_type(TypeName::new("string"))],
            vec![
                Expression::identifier("t"),
            ],
            Block::default(),
        ),
        empty_generic_for_multiple_variables("for key, value in pairs(t) do end") => GenericForStatement::new(
            vec!["key".into(), "value".into()],
            vec![
                FunctionCall::from_name("pairs")
                    .with_argument(Expression::identifier("t"))
                    .into(),
            ],
            Block::default(),
        ),
        empty_generic_for_multiple_values("for key in next, t do end") => GenericForStatement::new(
            vec!["key".into()],
            vec![Expression::identifier("next"), Expression::identifier("t")],
            Block::default(),
        ),
        generic_for_break("for key in pairs(t) do break end") => GenericForStatement::new(
            vec!["key".into()],
            vec![
                FunctionCall::from_name("pairs")
                    .with_argument(Expression::identifier("t"))
                    .into(),
            ],
            LastStatement::new_break(),
        ),
        empty_numeric_for("for i=start, bound do end") => NumericForStatement::new(
            "i",
            Expression::identifier("start"),
            Expression::identifier("bound"),
            None,
            Block::default(),
        ),
        empty_numeric_for_with_step("for i=start, bound, step do end") => NumericForStatement::new(
            "i",
            Expression::identifier("start"),
            Expression::identifier("bound"),
            Some(Expression::identifier("step")),
            Block::default(),
        ),
        numeric_for_that_breaks("for i=start, bound do break end") => NumericForStatement::new(
            "i",
            Expression::identifier("start"),
            Expression::identifier("bound"),
            None,
            LastStatement::new_break(),
        ),
        compound_increment("var += amount") => CompoundAssignStatement::new(
            CompoundOperator::Plus,
            Variable::new("var"),
            Expression::identifier("amount"),
        ),
        compound_floor_division("var //= divider") => CompoundAssignStatement::new(
            CompoundOperator::DoubleSlash,
            Variable::new("var"),
            Expression::identifier("divider"),
        ),
    );

    mod parse_with_tokens {
        use super::*;

        macro_rules! test_parse_block_with_tokens {
            ($($name:ident($input:literal) => $value:expr),* $(,)?) => {
                $(
                    #[test]
                    fn $name() {
                        let parser = Parser::default().preserve_tokens();
                        let block = match parser.parse($input) {
                            Ok(block) => block,
                            Err(err) => {
                                panic!(
                                    "failed to parse `{}`: {}\nfull-moon result:\n{:#?}",
                                    $input,
                                    err,
                                    full_moon::parse_fallible($input, LuaVersion::luau()).into_result()
                                );
                            }
                        };

                        let expect_block = $value;

                        pretty_assertions::assert_eq!(block, expect_block);
                    }
                )*
            };
        }

        macro_rules! test_parse_statement_with_tokens {
            ($($name:ident($input:literal) => $value:expr),* $(,)?) => {
                test_parse_block_with_tokens!(
                    $(
                        $name($input) => Block::from($value).with_tokens(BlockTokens {
                            semicolons: vec![None],
                            last_semicolon: None,
                            final_token: None,
                        }),
                    )*
                );
            };
        }

        macro_rules! test_parse_last_statement_with_tokens {
            ($($name:ident($input:literal) => $value:expr),* $(,)?) => {
                test_parse_block_with_tokens!(
                    $(
                        $name($input) => Block::from($value).with_tokens(BlockTokens {
                            semicolons: Vec::new(),
                            last_semicolon: None,
                            final_token: None,
                        }),
                    )*
                );
            };
        }

        fn create_true(start: usize, whitespace_length: usize) -> Expression {
            let end = start + 4;
            let token = Token::new_with_line(start, end, 1);
            Expression::True(Some(if whitespace_length == 0 {
                token
            } else {
                token.with_trailing_trivia(TriviaKind::Whitespace.at(
                    end,
                    end + whitespace_length,
                    1,
                ))
            }))
        }

        fn create_identifier(
            identifier: &str,
            start: usize,
            whitespace_length: usize,
        ) -> Identifier {
            create_identifier_at_line(identifier, start, whitespace_length, 1)
        }

        fn create_identifier_at_line(
            identifier: &str,
            start: usize,
            whitespace_length: usize,
            line: usize,
        ) -> Identifier {
            let end = start + identifier.len();
            Identifier::new(identifier).with_token({
                let token = Token::new_with_line(start, end, line);
                if whitespace_length != 0 {
                    token.with_trailing_trivia(TriviaKind::Whitespace.at(
                        end,
                        end + whitespace_length,
                        line,
                    ))
                } else {
                    token
                }
            })
        }

        fn spaced_token(start: usize, end: usize) -> Token {
            spaced_token_at_line(start, end, 1)
        }

        fn spaced_token_at_line(start: usize, end: usize, line: usize) -> Token {
            Token::new_with_line(start, end, line).with_trailing_trivia(TriviaKind::Whitespace.at(
                end,
                end + 1,
                line,
            ))
        }

        fn default_block() -> Block {
            Block::default().with_tokens(BlockTokens {
                semicolons: Vec::new(),
                last_semicolon: None,
                final_token: None,
            })
        }

        fn token_at_first_line(start: usize, end: usize) -> Token {
            Token::new_with_line(start, end, 1)
        }

        test_parse_last_statement_with_tokens!(
            return_with_comment("return -- comment") => ReturnStatement::default()
                .with_tokens(ReturnTokens {
                    r#return: token_at_first_line(0, 6)
                        .with_trailing_trivia(TriviaKind::Whitespace.at(6, 7, 1))
                        .with_trailing_trivia(TriviaKind::Comment.at(7, 17, 1)),
                    commas: Vec::new(),
                }),
            return_true("return true") => ReturnStatement::one(create_true(7, 0))
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_false("return false") => ReturnStatement::one(
                Expression::False(Some(token_at_first_line(7, 12)))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_nil("return nil") => ReturnStatement::one(
                Expression::Nil(Some(token_at_first_line(7, 10)))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_variable_arguments("return ...") => ReturnStatement::one(
                Expression::VariableArguments(Some(token_at_first_line(7, 10)))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_single_quote_string("return ''") => ReturnStatement::one(
                StringExpression::empty().with_token(token_at_first_line(7, 9))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_double_quote_string("return \"\"") => ReturnStatement::one(
                StringExpression::empty().with_token(token_at_first_line(7, 9))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_double_quote_string("return \"abc\"") => ReturnStatement::one(
                StringExpression::from_value("abc").with_token(token_at_first_line(7, 12))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_backtick_string("return ``") => ReturnStatement::one(
                InterpolatedStringExpression::empty().with_tokens(
                    InterpolatedStringTokens {
                        opening_tick: token_at_first_line(7, 8),
                        closing_tick: token_at_first_line(8, 9),
                    }
                )
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_with_escaped_backtick("return `\\``") => ReturnStatement::one(
                InterpolatedStringExpression::empty()
                .with_segment(
                    StringSegment::from_value('`').with_token(token_at_first_line(8, 10))
                )
                .with_tokens(
                    InterpolatedStringTokens {
                        opening_tick: token_at_first_line(7, 8),
                        closing_tick: token_at_first_line(10, 11),
                    }
                )
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_hello("return `hello`") => ReturnStatement::one(
                InterpolatedStringExpression::new(vec![
                    StringSegment::from_value("hello")
                        .with_token(token_at_first_line(8, 13))
                        .into()
                ])
                .with_tokens(InterpolatedStringTokens {
                    opening_tick: token_at_first_line(7, 8),
                    closing_tick: token_at_first_line(13, 14),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_with_single_value("return `{true}`") => ReturnStatement::one(
                InterpolatedStringExpression::new(vec![
                    ValueSegment::new(create_true(9, 0)).with_tokens(ValueSegmentTokens {
                        opening_brace: token_at_first_line(8, 9),
                        closing_brace: token_at_first_line(13, 14),
                    }).into()
                ])
                .with_tokens(InterpolatedStringTokens {
                    opening_tick: token_at_first_line(7, 8),
                    closing_tick: token_at_first_line(14, 15),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_with_prefixed_single_value("return `value = {true}`") => ReturnStatement::one(
                InterpolatedStringExpression::new(
                    vec![
                        StringSegment::from_value("value = ")
                            .with_token(token_at_first_line(8, 16))
                            .into(),
                        ValueSegment::new(create_true(17, 0))
                            .with_tokens(ValueSegmentTokens {
                                opening_brace: token_at_first_line(16, 17),
                                closing_brace: token_at_first_line(21, 22),
                            }).into(),
                    ]
                )
                .with_tokens(InterpolatedStringTokens {
                    opening_tick: token_at_first_line(7, 8),
                    closing_tick: token_at_first_line(22, 23),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_with_suffixed_single_value("return `{true} -> condition`") => ReturnStatement::one(
                InterpolatedStringExpression::new(
                    vec![
                        ValueSegment::new(create_true(9, 0))
                            .with_tokens(ValueSegmentTokens {
                                opening_brace: token_at_first_line(8, 9),
                                closing_brace: token_at_first_line(13, 14),
                            }).into(),
                        StringSegment::from_value(" -> condition")
                            .with_token(token_at_first_line(14, 27))
                            .into(),
                    ]
                )
                .with_tokens(InterpolatedStringTokens {
                    opening_tick: token_at_first_line(7, 8),
                    closing_tick: token_at_first_line(27, 28),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_backtick_string_with_prefix_and_suffixed_single_value("return `-> {value} (value)`") => ReturnStatement::one(
                InterpolatedStringExpression::new(
                    vec![
                        StringSegment::from_value("-> ")
                            .with_token(token_at_first_line(8, 11))
                            .into(),
                        ValueSegment::new(create_identifier("value", 12, 0))
                            .with_tokens(ValueSegmentTokens {
                                opening_brace: token_at_first_line(11, 12),
                                closing_brace: token_at_first_line(17, 18),
                            }).into(),
                        StringSegment::from_value(" (value)")
                            .with_token(token_at_first_line(18, 26))
                            .into(),
                    ]
                )
                .with_tokens(InterpolatedStringTokens {
                    opening_tick: token_at_first_line(7, 8),
                    closing_tick: token_at_first_line(26, 27),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_integer_number("return 123") => ReturnStatement::one(
                DecimalNumber::new(123.0).with_token(token_at_first_line(7, 10))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_float("return 12.34 -- value") => ReturnStatement::one(
                DecimalNumber::new(12.34).with_token(
                    spaced_token(7, 12).with_trailing_trivia(TriviaKind::Comment.at(13, 21, 1))
                )
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_binary_number("return 0b1010") => ReturnStatement::one(
                BinaryNumber::new(0b1010, false).with_token(token_at_first_line(7, 13))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_hexadecimal_number("return 0x12EF") => ReturnStatement::one(
                HexNumber::new(0x12EF, false).with_token(token_at_first_line(7, 13))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_table("return {--[[ inside ]]}") => ReturnStatement::one(
                TableExpression::default().with_tokens(TableTokens {
                    opening_brace: token_at_first_line(7, 8)
                        .with_trailing_trivia(TriviaKind::Comment.at(8, 22, 1)),
                    closing_brace: token_at_first_line(22, 23),
                    separators: Vec::new(),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_array_with_one_element("return { true} ") => ReturnStatement::one(
                TableExpression::default()
                    .append_array_value(create_true(9, 0))
                    .with_tokens(TableTokens {
                        opening_brace: spaced_token(7, 8),
                        closing_brace: spaced_token(13, 14),
                        separators: Vec::new(),
                    })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_array_with_two_elements("return {true, true}") => ReturnStatement::one(
                TableExpression::default()
                    .append_array_value(create_true(8, 0))
                    .append_array_value(create_true(14, 0))
                    .with_tokens(TableTokens {
                        opening_brace: token_at_first_line(7, 8),
                        closing_brace: token_at_first_line(18, 19),
                        separators: vec![spaced_token(12, 13)],
                    })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_array_with_one_field("return { field = true; }") => ReturnStatement::one(
                TableExpression::default()
                    .append_entry(
                        TableFieldEntry::new(
                            create_identifier("field", 9, 1),
                            create_true(17, 0),
                        ).with_token(spaced_token(15, 16))
                    )
                    .with_tokens(TableTokens {
                        opening_brace: spaced_token(7, 8),
                        closing_brace: token_at_first_line(23, 24),
                        separators: vec![spaced_token(21, 22)],
                    })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_array_with_one_key_expression("return { [var] = true }") => ReturnStatement::one(
                TableExpression::default()
                    .append_entry(
                        TableIndexEntry::new(
                            create_identifier("var", 10, 0),
                            create_true(17, 1),
                        ).with_tokens(TableIndexEntryTokens {
                            opening_bracket: token_at_first_line(9, 10),
                            closing_bracket: spaced_token(13, 14),
                            equal: spaced_token(15, 16),
                        })
                    )
                    .with_tokens(TableTokens {
                        opening_brace: spaced_token(7, 8),
                        closing_brace: token_at_first_line(22, 23),
                        separators: Vec::new(),
                    })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_field_expression("return math.huge") => ReturnStatement::one(
                FieldExpression::new(
                    Prefix::from_name(create_identifier("math", 7, 0)),
                    create_identifier("huge", 12, 0)
                ).with_token(token_at_first_line(11, 12))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_double_field_expression("return table.ok .result") => ReturnStatement::one(
                FieldExpression::new(
                    FieldExpression::new(
                        Prefix::from_name(create_identifier("table", 7, 0)),
                        create_identifier("ok", 13, 1)
                    ).with_token(token_at_first_line(12, 13)),
                    create_identifier("result", 17, 0)
                ).with_token(token_at_first_line(16, 17))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_index_expression("return value [ true ] ") => ReturnStatement::one(
                IndexExpression::new(
                    create_identifier("value", 7, 1),
                    create_true(15, 1)
                ).with_tokens(IndexExpressionTokens {
                    opening_bracket: spaced_token(13, 14),
                    closing_bracket: spaced_token(20, 21),
                })
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_true_and_true("return true and true") => ReturnStatement::default()
                .with_expression(
                    BinaryExpression::new(
                        BinaryOperator::And,
                        create_true(7, 1),
                        create_true(16, 0),
                    ).with_token(spaced_token(12, 15))
                )
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_not_true("return not true") => ReturnStatement::default()
                .with_expression(
                    UnaryExpression::new(
                        UnaryOperator::Not,
                        create_true(11, 0),
                    ).with_token(spaced_token(7, 10))
                )
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_parenthese_expression("return ( true )") => ReturnStatement::default()
                .with_expression(
                    ParentheseExpression::new(create_true(9, 1))
                        .with_tokens(
                            ParentheseTokens {
                                left_parenthese: spaced_token(7, 8),
                                right_parenthese: token_at_first_line(14, 15),
                            }
                        )
                )
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_type_cast("return var :: T") => ReturnStatement::one(
                    TypeCastExpression::new(
                        create_identifier("var", 7, 1),
                        TypeName::new(create_identifier("T", 14, 0))
                    ).with_token(spaced_token(11, 13))
                ).with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_type_cast_to_intersection_with_right_type_in_parenthese("return var :: nil&(''|true)") => ReturnStatement::one(
                    TypeCastExpression::new(
                        create_identifier("var", 7, 1),
                        IntersectionType::new(
                            Type::Nil(Some(token_at_first_line(14, 17))),
                            ParentheseType::new(
                                UnionType::new(
                                    StringType::from_value("").with_token(token_at_first_line(19, 21)),
                                    Type::True(Some(token_at_first_line(22, 26)))
                                ).with_tokens(UnionTypeTokens {
                                    leading_token: None,
                                    separators: vec![token_at_first_line(21, 22)],
                                })
                            )
                            .with_tokens(ParentheseTypeTokens {
                                left_parenthese: token_at_first_line(18, 19),
                                right_parenthese: token_at_first_line(26, 27),
                            })
                        ).with_tokens(IntersectionTypeTokens {
                            leading_token: None,
                            separators: vec![token_at_first_line(17, 18)],
                        })
                    ).with_token(spaced_token(11, 13))
                ).with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            return_type_cast_to_intersection_with_function_type_and_name(
                "return var :: (Ox:false,qv:fX)->zmTaj...&T"
            )=> ReturnStatement::one(
                TypeCastExpression::new(
                    create_identifier("var", 7, 1),
                    IntersectionType::new(
                        FunctionType::new(
                            GenericTypePack::new(create_identifier("zmTaj", 32, 0))
                                .with_token(token_at_first_line(37, 40))
                        )
                        .with_argument(
                            FunctionArgumentType::new(Type::False(Some(token_at_first_line(18, 23))))
                                .with_name(create_identifier("Ox", 15, 0))
                                .with_token(token_at_first_line(17, 18))
                        )
                        .with_argument(
                            FunctionArgumentType::new(TypeName::new(create_identifier("fX", 27, 0)))
                                .with_name(create_identifier("qv", 24, 0))
                                .with_token(token_at_first_line(26, 27))
                        )
                        .with_tokens(FunctionTypeTokens {
                            opening_parenthese: token_at_first_line(14, 15),
                            closing_parenthese: token_at_first_line(29, 30),
                            arrow: token_at_first_line(30, 32),
                            commas: vec![token_at_first_line(23, 24)],
                        }),
                        TypeName::new(create_identifier("T", 41, 0)),
                    ).with_tokens(IntersectionTypeTokens {
                        leading_token: None,
                        separators: vec![token_at_first_line(40, 41)],
                    })
                ).with_token(spaced_token(11, 13))
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function("return function  ( --[[params]]) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15)
                            .with_trailing_trivia(TriviaKind::Whitespace.at(15, 17, 1)),
                        opening_parenthese: token_at_first_line(17, 18)
                            .with_trailing_trivia(TriviaKind::Whitespace.at(18, 19, 1))
                            .with_trailing_trivia(TriviaKind::Comment.at(19, 31, 1)),
                        closing_parenthese: spaced_token(31, 32),
                        end: token_at_first_line(33, 36),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_boolean_return_type("return function(): boolean end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypeName::new(create_identifier("boolean", 19, 1))
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(27, 30),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_void_return_type("return function(): () end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19,20),
                                right_parenthese: spaced_token(20,21),
                                commas:Vec::new(),
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(22, 25),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_type_pack_with_one_type("return function(): (true) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_type(Type::True(Some(token_at_first_line(20, 24))))
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19, 20),
                                right_parenthese: spaced_token(24, 25),
                                commas: Vec::new(),
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(26, 29),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_variadic_pack("return function(): ...string end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        VariadicTypePack::new(TypeName::new(create_identifier("string", 22, 1)))
                            .with_token(token_at_first_line(19, 22))
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(29, 32),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_generic_pack("return function(): T... end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        GenericTypePack::new(create_identifier("T", 19, 0))
                            .with_token(spaced_token(20, 23))
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(24, 27),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_type_pack_with_variadic_pack("return function(): (...string) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_variadic_type(
                                VariadicTypePack::new(TypeName::new(create_identifier("string", 23, 0)))
                                    .with_token(token_at_first_line(20, 23))
                            )
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19, 20),
                                right_parenthese: spaced_token(29, 30),
                                commas: Vec::new()
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(31, 34),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_type_pack_with_generic_pack("return function(): (T...) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_variadic_type(
                                GenericTypePack::new(create_identifier("T", 20, 0))
                                    .with_token(token_at_first_line(21, 24))
                            )
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19, 20),
                                right_parenthese: spaced_token(24, 25),
                                commas: Vec::new()
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(26, 29),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_type_pack_with_two_types("return function(): (true, false) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_type(Type::True(Some(token_at_first_line(20, 24))))
                            .with_type(Type::False(Some(token_at_first_line(26, 31))))
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19, 20),
                                right_parenthese: spaced_token(31, 32),
                                commas: vec![spaced_token(24, 25)],
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(33, 36),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_return_type_pack_with_two_types_and_variadic_pack("return function(): (true, false, ...string) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypePack::default()
                            .with_type(Type::True(Some(token_at_first_line(20, 24))))
                            .with_type(Type::False(Some(token_at_first_line(26, 31))))
                            .with_variadic_type(
                                VariadicTypePack::new(TypeName::new(create_identifier("string", 36, 0)))
                                    .with_token(token_at_first_line(33, 36))
                            )
                            .with_tokens(TypePackTokens {
                                left_parenthese: token_at_first_line(19, 20),
                                right_parenthese: spaced_token(42, 43),
                                commas: vec![spaced_token(24, 25), spaced_token(31, 32)],
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(16, 17),
                        end: token_at_first_line(44, 47),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(17, 18)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_one_param("return function(a )end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block()).with_parameter(
                    create_identifier("a", 16, 1)
                ).with_tokens(FunctionBodyTokens {
                    function: token_at_first_line(7, 15),
                    opening_parenthese: token_at_first_line(15, 16),
                    closing_parenthese: token_at_first_line(18, 19),
                    end: token_at_first_line(19, 22),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_one_typed_param("return function(a : string)end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_parameter(
                        TypedIdentifier::from(create_identifier("a", 16, 1))
                            .with_colon_token(spaced_token(18, 19))
                            .with_type(TypeName::new(create_identifier("string", 20, 0))),
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: token_at_first_line(26, 27),
                        end: token_at_first_line(27, 30),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_two_params("return function(a, b--[[foo]]) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_parameter(Identifier::new("a").with_token(token_at_first_line(16, 17)))
                    .with_parameter(
                        Identifier::new("b").with_token(
                            token_at_first_line(19, 20).with_trailing_trivia(TriviaKind::Comment.at(20, 29, 1))
                        )
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: spaced_token(29, 30),
                        end: token_at_first_line(31, 34),
                        parameter_commas: vec![spaced_token(17, 18)],
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_variadic_function("return function(... ) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .variadic()
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: spaced_token(20, 21),
                        end: token_at_first_line(22, 25),
                        parameter_commas: Vec::new(),
                        variable_arguments: Some(spaced_token(16, 19)),
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_typed_variadic_function("return function(... : string ) end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_variadic_type(
                        TypeName::new(create_identifier("string", 22, 1))
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: spaced_token(29, 30),
                        end: token_at_first_line(31, 34),
                        parameter_commas: Vec::new(),
                        variable_arguments: Some(spaced_token(16, 19)),
                        variable_arguments_colon: Some(spaced_token(20, 21)),
                        return_type_colon: None,
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_empty_function_with_generic_return_type("return function<T>(): T end") => ReturnStatement::one(
                FunctionExpression::from_block(default_block())
                    .with_return_type(
                        TypeName::new(create_identifier("T", 22, 1))
                    )
                    .with_generic_parameters(
                        GenericParameters::from_type_variable(create_identifier("T", 16, 0))
                            .with_tokens(GenericParametersTokens {
                                opening_list: token_at_first_line(15, 16),
                                closing_list: token_at_first_line(17, 18),
                                commas: Vec::new(),
                            })
                    )
                    .with_tokens(FunctionBodyTokens {
                        function: token_at_first_line(7, 15),
                        opening_parenthese: token_at_first_line(18, 19),
                        closing_parenthese: token_at_first_line(19, 20),
                        end: token_at_first_line(24, 27),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(20, 21)),
                    }),
            ).with_tokens(ReturnTokens {
                r#return: spaced_token(0, 6),
                commas: Vec::new(),
            }),
            return_two_values("return true ,  true--end") => ReturnStatement::default()
                .with_expression(create_true(7, 1))
                .with_expression(Expression::True(Some(
                    token_at_first_line(15, 19).with_trailing_trivia(TriviaKind::Comment.at(19, 24, 1))
                )))
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: vec![
                        token_at_first_line(12, 13).with_trailing_trivia(TriviaKind::Whitespace.at(13, 15, 1))
                    ],
                }),
            return_variable("return var") => ReturnStatement::default()
                .with_expression(
                    Identifier::new("var").with_token(token_at_first_line(7, 10))
                )
                .with_tokens(ReturnTokens {
                    r#return: spaced_token(0, 6),
                    commas: Vec::new(),
                }),
            break_statement("break") => LastStatement::Break(Some(token_at_first_line(0, 5))),
            break_statement_with_comment("break-- bye") => LastStatement::Break(Some(
                token_at_first_line(0, 5).with_trailing_trivia(TriviaKind::Comment.at(5, 11, 1))
            )),
            continue_statement("continue") => LastStatement::Continue(Some(token_at_first_line(0, 8))),
            continue_statement_with_comment("continue-- bye") => LastStatement::Continue(Some(
                token_at_first_line(0, 8).with_trailing_trivia(TriviaKind::Comment.at(8, 14, 1))
            )),
        );

        test_parse_statement_with_tokens!(
            empty_local_function("local function name ()end") => LocalFunctionStatement::from_name(
                create_identifier("name", 15, 1),
                default_block()
            ).with_tokens(LocalFunctionTokens {
                local: spaced_token(0, 5),
                function_body: FunctionBodyTokens {
                    function: spaced_token(6, 14),
                    opening_parenthese: token_at_first_line(20, 21),
                    closing_parenthese: token_at_first_line(21, 22),
                    end: token_at_first_line(22, 25),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                },
            }),
            empty_local_function_variadic("local function name(...)end") => LocalFunctionStatement::from_name(
                Identifier::new("name").with_token(token_at_first_line(15, 19)),
                default_block(),
            )
            .variadic()
            .with_tokens(LocalFunctionTokens {
                local: spaced_token(0, 5),
                function_body: FunctionBodyTokens {
                    function: spaced_token(6, 14),
                    opening_parenthese: token_at_first_line(19, 20),
                    closing_parenthese: token_at_first_line(23, 24),
                    end: token_at_first_line(24, 27),
                    parameter_commas: Vec::new(),
                    variable_arguments: Some(token_at_first_line(20, 23)),
                    variable_arguments_colon: None,
                    return_type_colon: None,
                },
            }),
            empty_local_function_with_two_parameters("local function name(a,b) end")
                => LocalFunctionStatement::from_name(
                    Identifier::new("name").with_token(token_at_first_line(15, 19)),
                    default_block(),
                )
                .with_parameter(Identifier::new("a").with_token(token_at_first_line(20, 21)))
                .with_parameter(Identifier::new("b").with_token(token_at_first_line(22, 23)))
                .with_tokens(LocalFunctionTokens {
                    local: spaced_token(0, 5),
                    function_body: FunctionBodyTokens {
                        function: spaced_token(6, 14),
                        opening_parenthese: token_at_first_line(19, 20),
                        closing_parenthese: spaced_token(23, 24),
                        end: token_at_first_line(25, 28),
                        parameter_commas: vec![token_at_first_line(21, 22)],
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    },
                }),
            empty_local_function_with_generic_return_type("local function fn<T>(): T end")
                => LocalFunctionStatement::from_name(create_identifier("fn", 15, 0), default_block())
                .with_return_type(
                    TypeName::new(create_identifier("T", 24, 1))
                )
                .with_generic_parameters(
                    GenericParameters::from_type_variable(create_identifier("T", 18, 0))
                        .with_tokens(GenericParametersTokens {
                            opening_list: token_at_first_line(17, 18),
                            closing_list: token_at_first_line(19, 20),
                            commas: Vec::new(),
                        })
                )
                .with_tokens(LocalFunctionTokens {
                    local: spaced_token(0, 5),
                    function_body: FunctionBodyTokens {
                        function: spaced_token(6, 14),
                        opening_parenthese: token_at_first_line(20, 21),
                        closing_parenthese: token_at_first_line(21, 22),
                        end: token_at_first_line(26, 29),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: Some(spaced_token(22, 23)),
                    }
                }),
            empty_local_function_with_two_generic_type("local function fn<T, U>() end")
                => LocalFunctionStatement::from_name(create_identifier("fn", 15, 0), default_block())
                .with_generic_parameters(
                    GenericParameters::from_type_variable(create_identifier("T", 18, 0))
                        .with_type_variable(create_identifier("U", 21, 0))
                        .with_tokens(GenericParametersTokens {
                            opening_list: token_at_first_line(17, 18),
                            closing_list: token_at_first_line(22, 23),
                            commas: vec![spaced_token(19, 20)],
                        })
                )
                .with_tokens(LocalFunctionTokens {
                    local: spaced_token(0, 5),
                    function_body: FunctionBodyTokens {
                        function: spaced_token(6, 14),
                        opening_parenthese: token_at_first_line(23, 24),
                        closing_parenthese: spaced_token(24, 25),
                        end: token_at_first_line(26, 29),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    }
                }),
            call_function("call()") => FunctionCall::from_name(
                create_identifier("call", 0, 0)
            ).with_arguments(TupleArguments::default().with_tokens(TupleArgumentsTokens {
                opening_parenthese: token_at_first_line(4, 5),
                closing_parenthese: token_at_first_line(5, 6),
                commas: Vec::new(),
            })).with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_indexed_table("foo.bar()") => FunctionCall::from_prefix(
                FieldExpression::new(
                    create_identifier("foo", 0, 0),
                    create_identifier("bar", 4, 0)
                ).with_token(token_at_first_line(3, 4))
            ).with_arguments(TupleArguments::default().with_tokens(TupleArgumentsTokens {
                opening_parenthese: token_at_first_line(7, 8),
                closing_parenthese: token_at_first_line(8, 9),
                commas: Vec::new(),
            })).with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_method("foo: bar()") => FunctionCall::from_name(create_identifier("foo", 0, 0))
                .with_method(create_identifier("bar", 5, 0))
                .with_arguments(TupleArguments::default().with_tokens(TupleArgumentsTokens {
                    opening_parenthese: token_at_first_line(8, 9),
                    closing_parenthese: token_at_first_line(9, 10),
                    commas: Vec::new(),
                }))
                .with_tokens(FunctionCallTokens {
                    colon: Some(spaced_token(3, 4)),
                }),
            call_method_with_one_argument("foo:bar( true )") => FunctionCall::from_name(
                create_identifier("foo", 0, 0)
            )
            .with_method(create_identifier("bar", 4, 0))
            .with_arguments(
                TupleArguments::default()
                    .with_argument(create_true(9, 1))
                    .with_tokens(TupleArgumentsTokens {
                        opening_parenthese: spaced_token(7, 8),
                        closing_parenthese: token_at_first_line(14, 15),
                        commas: Vec::new(),
                    })
                )
            .with_tokens(FunctionCallTokens {
                colon: Some(token_at_first_line(3, 4)),
            }),
            call_function_with_one_argument("call ( true ) ") =>  FunctionCall::from_name(
                create_identifier("call", 0, 1)
            )
            .with_arguments(
                TupleArguments::default()
                    .with_argument(create_true(7, 1))
                    .with_tokens(TupleArgumentsTokens {
                        opening_parenthese: spaced_token(5, 6),
                        closing_parenthese: spaced_token(12, 13),
                        commas: Vec::new(),
                    })
                )
            .with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_function_with_two_arguments("call(true, true)") =>  FunctionCall::from_name(
                create_identifier("call", 0, 0)
            )
            .with_arguments(
                TupleArguments::default()
                    .with_argument(create_true(5, 0))
                    .with_argument(create_true(11, 0))
                    .with_tokens(TupleArgumentsTokens {
                        opening_parenthese: token_at_first_line(4, 5),
                        closing_parenthese: token_at_first_line(15, 16),
                        commas: vec![spaced_token(9, 10)],
                    })
                )
            .with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_chain_with_args("call(true)( )") => FunctionCall::from_prefix(
                FunctionCall::from_name(create_identifier("call", 0, 0))
                    .with_arguments(
                        TupleArguments::default()
                            .with_argument(create_true(5, 0))
                            .with_tokens(TupleArgumentsTokens {
                                opening_parenthese: token_at_first_line(4, 5),
                                closing_parenthese: token_at_first_line(9, 10),
                                commas: Vec::new(),
                            })
                        )
                    .with_tokens(FunctionCallTokens {
                        colon: None,
                    }),
            )
            .with_arguments(TupleArguments::default().with_tokens(TupleArgumentsTokens {
                opening_parenthese: spaced_token(10, 11),
                closing_parenthese: token_at_first_line(12, 13),
                commas: Vec::new(),
            }))
            .with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_with_empty_table_argument("call{ }") => FunctionCall::from_name(
                create_identifier("call", 0, 0)
            ).with_arguments(TableExpression::default().with_tokens(TableTokens {
                opening_brace: spaced_token(4, 5),
                closing_brace: token_at_first_line(6, 7),
                separators: Vec::new(),
            })).with_tokens(FunctionCallTokens {
                colon: None,
            }),
            call_with_empty_string_argument("call ''") => FunctionCall::from_name(
                create_identifier("call", 0, 1)
            ).with_arguments(
                StringExpression::empty().with_token(token_at_first_line(5, 7))
            ).with_tokens(FunctionCallTokens {
                colon: None,
            }),
            empty_do("do end") => DoStatement::new(default_block())
                .with_tokens(DoTokens {
                    r#do: spaced_token(0, 2),
                    end: token_at_first_line(3, 6),
                }),
            empty_do_with_long_comment("do --[[ hello ]] end") => DoStatement::new(default_block())
                .with_tokens(DoTokens {
                    r#do: token_at_first_line(0, 2)
                        .with_trailing_trivia(TriviaKind::Whitespace.at(2, 3, 1))
                        .with_trailing_trivia(TriviaKind::Comment.at(3, 16, 1))
                        .with_trailing_trivia(TriviaKind::Whitespace.at(16, 17, 1)),
                    end: token_at_first_line(17, 20),
                }),
            assign_variable("var = true") => AssignStatement::from_variable(
                create_identifier("var", 0, 1),
                Expression::True(Some(token_at_first_line(6, 10))),
            ).with_tokens(AssignTokens {
                equal: spaced_token(4, 5),
                variable_commas: Vec::new(),
                value_commas: Vec::new(),
            }),
            assign_two_variables_with_two_values("var, var2 = true, true") => AssignStatement::from_variable(
                Identifier::new("var").with_token(token_at_first_line(0, 3)),
                create_true(12, 0),
            ).append_assignment(
                create_identifier("var2", 5, 1),
                Expression::True(Some(token_at_first_line(18, 22))),
            ).with_tokens(AssignTokens {
                equal: spaced_token(10, 11),
                variable_commas: vec![spaced_token(3, 4)],
                value_commas: vec![spaced_token(16, 17)],
            }),
            empty_function_statement("function name() end")
                => FunctionStatement::new(
                    FunctionName::from_name(
                        Identifier::new("name").with_token(token_at_first_line(9, 13))
                    ).with_tokens(FunctionNameTokens { periods: Vec::new(), colon: None }),
                    default_block(),
                    Vec::new(),
                    false,
                ).with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(13, 14),
                    closing_parenthese: spaced_token(14, 15),
                    end: token_at_first_line(16, 19),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            empty_function_statement_with_field("function name.field ()end")
                => FunctionStatement::new(
                    FunctionName::from_name(
                        Identifier::new("name").with_token(token_at_first_line(9, 13))
                    ).with_field(
                        Identifier::new("field").with_token(spaced_token(14, 19))
                    ).with_tokens(FunctionNameTokens {
                        periods: vec![token_at_first_line(13, 14)],
                        colon: None,
                    }),
                    default_block(),
                    Vec::new(),
                    false,
                ).with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(20, 21),
                    closing_parenthese: token_at_first_line(21, 22),
                    end: token_at_first_line(22, 25),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            empty_function_statement_with_method("function name:method ()end")
                => FunctionStatement::new(
                    FunctionName::from_name(
                        Identifier::new("name").with_token(token_at_first_line(9, 13))
                    )
                    .with_method(create_identifier("method", 14, 1))
                    .with_tokens(FunctionNameTokens {
                        periods: Vec::new(),
                        colon: Some(token_at_first_line(13, 14)),
                    }),
                    default_block(),
                    Vec::new(),
                    false,
                ).with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(21, 22),
                    closing_parenthese: token_at_first_line(22, 23),
                    end: token_at_first_line(23, 26),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            empty_function_statement_variadic("function name(...) end")
                => FunctionStatement::new(
                    FunctionName::from_name(
                        Identifier::new("name").with_token(token_at_first_line(9, 13))
                    ).with_tokens(FunctionNameTokens { periods: Vec::new(), colon: None }),
                    default_block(),
                    Vec::new(),
                    true,
                ).with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(13, 14),
                    closing_parenthese: token_at_first_line(17, 18)
                        .with_trailing_trivia(TriviaKind::Whitespace.at(18, 19, 1)),
                    end: token_at_first_line(19, 22),
                    parameter_commas: Vec::new(),
                    variable_arguments: Some(token_at_first_line(14, 17)),
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            empty_function_statement_variadic_with_one_parameter("function name(a,...)end")
                => FunctionStatement::new(
                    FunctionName::from_name(
                        Identifier::new("name").with_token(token_at_first_line(9, 13))
                    ).with_tokens(FunctionNameTokens { periods: Vec::new(), colon: None }),
                    default_block(),
                    vec![
                        Identifier::new("a").with_token(token_at_first_line(14, 15)).into()
                    ],
                    true,
                ).with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(13, 14),
                    closing_parenthese: token_at_first_line(19, 20),
                    end: token_at_first_line(20, 23),
                    parameter_commas: vec![
                        token_at_first_line(15, 16),
                    ],
                    variable_arguments: Some(token_at_first_line(16, 19)),
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }),
            empty_function_with_generic_return_type("function fn<T>(): T end")
                => FunctionStatement::new(
                    FunctionName::from_name(create_identifier("fn", 9, 0))
                        .with_tokens(FunctionNameTokens { periods: Vec::new(), colon: None }),
                    default_block(),
                    Vec::new(),
                    false
                )
                .with_return_type(TypeName::new(create_identifier("T", 18, 1)))
                .with_generic_parameters(
                    GenericParameters::from_type_variable(create_identifier("T", 12, 0))
                        .with_tokens(GenericParametersTokens {
                            opening_list: token_at_first_line(11, 12),
                            closing_list: token_at_first_line(13, 14),
                            commas: Vec::new(),
                        })
                )
                .with_tokens(FunctionBodyTokens {
                    function: spaced_token(0, 8),
                    opening_parenthese: token_at_first_line(14, 15),
                    closing_parenthese: token_at_first_line(15, 16),
                    end: token_at_first_line(20, 23),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: Some(spaced_token(16, 17)),
                }),
            empty_generic_for("for key in foo do end") => GenericForStatement::new(
                vec![
                    create_identifier("key", 4, 1).into(),
                ],
                vec![
                    create_identifier("foo", 11, 1).into(),
                ],
                default_block(),
            ).with_tokens(GenericForTokens {
                r#for: spaced_token(0, 3),
                r#in: spaced_token(8, 10),
                r#do: spaced_token(15, 17),
                end: token_at_first_line(18, 21),
                identifier_commas: Vec::new(),
                value_commas: Vec::new(),
            }),
            empty_generic_for_with_typed_key("for key: Key in foo do end") => GenericForStatement::new(
                vec![
                    create_identifier("key", 4, 0)
                        .with_type(TypeName::new(create_identifier("Key", 9, 1)))
                        .with_colon_token(spaced_token(7, 8)),
                ],
                vec![
                    create_identifier("foo", 16, 1).into(),
                ],
                default_block(),
            ).with_tokens(GenericForTokens {
                r#for: spaced_token(0, 3),
                r#in: spaced_token(13, 15),
                r#do: spaced_token(20, 22),
                end: token_at_first_line(23, 26),
                identifier_commas: Vec::new(),
                value_commas: Vec::new(),
            }),
            empty_generic_for_multiple_variables("for key, value in foo do end") => GenericForStatement::new(
                vec![
                    create_identifier("key", 4, 0).into(),
                    create_identifier("value", 9, 1).into(),
                ],
                vec![
                    create_identifier("foo", 18, 1).into(),
                ],
                default_block(),
            ).with_tokens(GenericForTokens {
                r#for: spaced_token(0, 3),
                r#in: spaced_token(15, 17),
                r#do: spaced_token(22, 24),
                end: token_at_first_line(25, 28),
                identifier_commas: vec![spaced_token(7, 8)],
                value_commas: Vec::new(),
            }),
            empty_generic_for_multiple_values("for key in next , t do end") => GenericForStatement::new(
                vec![create_identifier("key", 4, 1).into()],
                vec![
                    create_identifier("next", 11, 1).into(),
                    create_identifier("t", 18, 1).into(),
                ],
                default_block(),
            ).with_tokens(GenericForTokens {
                r#for: spaced_token(0, 3),
                r#in: spaced_token(8, 10),
                r#do: spaced_token(20, 22),
                end: token_at_first_line(23, 26),
                identifier_commas: Vec::new(),
                value_commas: vec![
                    token_at_first_line(16, 17).with_trailing_trivia(TriviaKind::Whitespace.at(17, 18, 1)),
                ],
            }),
            empty_if_statement("if true then end") => IfStatement::create(
                create_true(3, 1),
                default_block()
            ).with_tokens(IfStatementTokens {
                r#if: token_at_first_line(0, 2).with_trailing_trivia(TriviaKind::Whitespace.at(2, 3, 1)),
                then: token_at_first_line(8, 12).with_trailing_trivia(TriviaKind::Whitespace.at(12, 13, 1)),
                end: token_at_first_line(13, 16),
                r#else: None,
            }),
            empty_if_statement_with_empty_else("if true then else end") => IfStatement::create(
                create_true(3, 1),
                default_block()
            )
            .with_else_block(default_block())
            .with_tokens(IfStatementTokens {
                r#if: spaced_token(0, 2),
                then: spaced_token(8, 12),
                end: token_at_first_line(18, 21),
                r#else: Some(spaced_token(13, 17)),
            }),
            empty_if_statement_with_empty_elseif("if true then elseif true then end")
                => IfStatement::create(create_true(3, 1), default_block())
                .with_branch(
                    IfBranch::new(create_true(20, 1), default_block())
                        .with_tokens(IfBranchTokens {
                            elseif: spaced_token(13, 19),
                            then: spaced_token(25, 29),
                        })
                )
                .with_tokens(IfStatementTokens {
                    r#if: spaced_token(0, 2),
                    then: spaced_token(8, 12),
                    end: token_at_first_line(30, 33),
                    r#else: None,
                }),
            local_assignment_with_no_values("local var ") => LocalAssignStatement::from_variable(
                create_identifier("var", 6, 1),
            ).with_tokens(LocalAssignTokens {
                local: spaced_token(0, 5),
                equal: None,
                variable_commas: Vec::new(),
                value_commas: Vec::new(),
             }),
            local_assignment_typed_with_no_values("local var : string") => LocalAssignStatement::from_variable(
                create_identifier("var", 6, 1)
                    .with_type(TypeName::new(create_identifier("string", 12, 0)))
                    .with_colon_token(spaced_token(10, 11)),
            ).with_tokens(LocalAssignTokens {
                local: spaced_token(0, 5),
                equal: None,
                variable_commas: Vec::new(),
                value_commas: Vec::new(),
            }),
            local_assignment_intersection_typed_with_no_values("local var : &string") => LocalAssignStatement::from_variable(
                create_identifier("var", 6, 1)
                    .with_type(
                        IntersectionType::from(vec![
                            TypeName::new(create_identifier("string", 13, 0)).into(),
                        ])
                        .with_tokens(IntersectionTypeTokens {
                            leading_token: Some(token_at_first_line(12, 13)),
                            separators: Vec::new(),
                        })
                    )
                    .with_colon_token(spaced_token(10, 11)),
            ).with_tokens(LocalAssignTokens {
                local: spaced_token(0, 5),
                equal: None,
                variable_commas: Vec::new(),
                value_commas: Vec::new(),
            }),
            multiple_local_assignment_with_no_values("local foo, bar") => LocalAssignStatement::from_variable(
                create_identifier("foo", 6, 0)
            )
            .with_variable(create_identifier("bar", 11, 0))
            .with_tokens(LocalAssignTokens {
                local: spaced_token(0, 5),
                equal: None,
                variable_commas: vec![spaced_token(9, 10)],
                value_commas: Vec::new(),
            }),
            multiple_local_assignment_typed_with_no_values("local foo: T, bar: U") => LocalAssignStatement::from_variable(
                create_identifier("foo", 6, 0)
                    .with_type(TypeName::new(create_identifier("T", 11, 0)))
                    .with_colon_token(spaced_token(9, 10))
            )
            .with_variable(
                create_identifier("bar", 14, 0)
                    .with_type(TypeName::new(create_identifier("U", 19, 0)))
                    .with_colon_token(spaced_token(17, 18))
            )
            .with_tokens(LocalAssignTokens {
                local: spaced_token(0, 5),
                equal: None,
                variable_commas: vec![spaced_token(12, 13)],
                value_commas: Vec::new(),
            }),
            multiple_local_assignment_with_two_values("local foo, bar = true, true")
                => LocalAssignStatement::from_variable(
                    create_identifier("foo", 6, 0)
                )
                .with_variable(create_identifier("bar", 11, 1))
                .with_value(create_true(17, 0))
                .with_value(create_true(23, 0))
                .with_tokens(LocalAssignTokens {
                    local: spaced_token(0, 5),
                    equal: Some(spaced_token(15, 16)),
                    variable_commas: vec![spaced_token(9, 10)],
                    value_commas: vec![spaced_token(21, 22)],
                }),
            empty_numeric_for("for i = start,bound do end") => NumericForStatement::new(
                create_identifier("i", 4, 1),
                create_identifier("start", 8, 0),
                create_identifier("bound", 14, 1),
                None,
                default_block(),
            ).with_tokens(NumericForTokens {
                r#for: spaced_token(0, 3),
                equal: spaced_token(6, 7),
                r#do: spaced_token(20, 22),
                end: token_at_first_line(23, 26),
                end_comma: token_at_first_line(13, 14),
                step_comma: None,
            }),
            empty_numeric_for_with_typed_identifier("for i: number = start,bound do end") => NumericForStatement::new(
                create_identifier("i", 4, 0)
                    .with_type(TypeName::new(create_identifier("number", 7, 1)))
                    .with_colon_token(spaced_token(5, 6)),
                create_identifier("start", 16, 0),
                create_identifier("bound", 22, 1),
                None,
                default_block(),
            ).with_tokens(NumericForTokens {
                r#for: spaced_token(0, 3),
                equal: spaced_token(14, 15),
                r#do: spaced_token(28, 30),
                end: token_at_first_line(31, 34),
                end_comma: token_at_first_line(21, 22),
                step_comma: None,
            }),
            empty_numeric_for_with_step("for i = start , bound , step do end")
                => NumericForStatement::new(
                    create_identifier("i", 4, 1),
                    create_identifier("start", 8, 1),
                    create_identifier("bound", 16, 1),
                    Some(create_identifier("step", 24, 1).into()),
                    default_block(),
                ).with_tokens(NumericForTokens {
                    r#for: spaced_token(0, 3),
                    equal: spaced_token(6, 7),
                    r#do: spaced_token(29, 31),
                    end: token_at_first_line(32, 35),
                    end_comma: spaced_token(14, 15),
                    step_comma: Some(spaced_token(22, 23)),
                }),
            empty_repeat("repeat until true") => RepeatStatement::new(
                default_block(),
                create_true(13, 0),
            ).with_tokens(RepeatTokens {
                repeat: spaced_token(0, 6),
                until: spaced_token(7, 12),
            }),
            empty_while("while true do end") => WhileStatement::new(
                default_block(),
                create_true(6, 1),
            ).with_tokens(WhileTokens {
                r#while: token_at_first_line(0, 5)
                    .with_trailing_trivia(TriviaKind::Whitespace.at(5, 6, 1)),
                r#do: token_at_first_line(11, 13)
                    .with_trailing_trivia(TriviaKind::Whitespace.at(13, 14, 1)),
                end: token_at_first_line(14, 17),
            }),
            compound_increment("var += amount") => CompoundAssignStatement::new(
                CompoundOperator::Plus,
                create_identifier("var", 0, 1),
                create_identifier("amount", 7, 0),
            ).with_tokens(CompoundAssignTokens { operator: spaced_token(4, 6) }),
            type_declaration_to_boolean("type NewType = boolean") => TypeDeclarationStatement::new(
                create_identifier("NewType", 5, 1),
                TypeName::new(create_identifier("boolean", 15, 0))
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(13, 14),
                export: None,
            }),
            exported_type_declaration_to_boolean("export type NewType = boolean") => TypeDeclarationStatement::new(
                create_identifier("NewType", 12, 1),
                TypeName::new(create_identifier("boolean", 22, 0))
            )
            .export()
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(7, 11),
                equal: spaced_token(20, 21),
                export: Some(spaced_token(0, 6)),
            }),
            type_declaration_to_nil("type NewType = nil") => TypeDeclarationStatement::new(
                create_identifier("NewType", 5, 1),
                Type::Nil(Some(token_at_first_line(15, 18)))
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(13, 14),
                export: None,
            }),
            type_declaration_to_single_quote_string_type("type Key = 'key'") => TypeDeclarationStatement::new(
                create_identifier("Key", 5, 1),
                StringType::new("'key'").unwrap().with_token(token_at_first_line(11, 16)),
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(9, 10),
                export: None,
            }),
            type_declaration_to_double_quote_string_type("type Key = \"key\"") => TypeDeclarationStatement::new(
                create_identifier("Key", 5, 1),
                StringType::new("\"key\"").unwrap().with_token(token_at_first_line(11, 16)),
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(9, 10),
                export: None,
            }),
            type_declaration_to_long_string_type("type Key = [[key]]") => TypeDeclarationStatement::new(
                create_identifier("Key", 5, 1),
                StringType::new("[[key]]").unwrap().with_token(token_at_first_line(11, 18)),
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(9, 10),
                export: None,
            }),
            type_declaration_to_boolean_array("type Array = { boolean }") => TypeDeclarationStatement::new(
                create_identifier("Array", 5, 1),
                ArrayType::new(TypeName::new(create_identifier("boolean", 15, 1)))
                    .with_tokens(ArrayTypeTokens {
                        opening_brace: spaced_token(13, 14),
                        closing_brace: token_at_first_line(23, 24),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(11, 12),
                export: None,
            }),
            type_declaration_to_type_field_array("type Array = { Mod.Name }") => TypeDeclarationStatement::new(
                create_identifier("Array", 5, 1),
                ArrayType::new(
                    TypeField::new(
                        create_identifier("Mod", 15, 0),
                        TypeName::new(create_identifier("Name", 19, 1))
                    ).with_token(token_at_first_line(18, 19))
                )
                    .with_tokens(ArrayTypeTokens {
                        opening_brace: spaced_token(13, 14),
                        closing_brace: token_at_first_line(24, 25),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(11, 12),
                export: None,
            }),
            type_declaration_to_optional_boolean("type T = boolean?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                OptionalType::new(TypeName::new(create_identifier("boolean", 9, 0)))
                    .with_token(token_at_first_line(16, 17))
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_union_boolean_nil("type T = boolean | nil") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                UnionType::new(
                    TypeName::new(create_identifier("boolean", 9, 1)),
                    Type::Nil(Some(token_at_first_line(19, 22)))
                )
                .with_tokens(UnionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(17, 18)]
                })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_intersection_of_type_names("type T = U & V") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                IntersectionType::new(
                    TypeName::new(create_identifier("U", 9, 1)),
                    TypeName::new(create_identifier("V", 13, 0)),
                )
                .with_tokens(IntersectionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(11, 12)]
                })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_intersections_of_type_names("type T = U & V & W") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                IntersectionType::new(
                    TypeName::new(create_identifier("U", 9, 1)),
                    TypeName::new(create_identifier("V", 13, 1)),
                ).with_type(
                    TypeName::new(create_identifier("W", 17, 0)),
                )
                .with_tokens(IntersectionTypeTokens {
                    leading_token: None,
                    separators: vec![
                        spaced_token(11, 12),
                        spaced_token(15, 16),
                    ]
                })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_one_prop("type T = { key: string }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key", 11, 0),
                            TypeName::new(create_identifier("string", 16, 1)),
                        )
                        .with_token(spaced_token(14, 15))
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(23, 24),
                        separators: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_one_prop_and_separator("type T = { key: string, }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key", 11, 0),
                            TypeName::new(create_identifier("string", 16, 0)),
                        )
                        .with_token(spaced_token(14, 15))
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(24, 25),
                        separators: vec![spaced_token(22, 23)],
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_two_props("type T = { key: string, key2 : nil }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key", 11, 0),
                            TypeName::new(create_identifier("string", 16, 0)),
                        )
                        .with_token(spaced_token(14, 15))
                    )
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key2", 24, 1),
                            Type::Nil(Some(spaced_token(31, 34)))
                        )
                        .with_token(spaced_token(29, 30))
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(35, 36),
                        separators: vec![spaced_token(22, 23)],
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_two_props_using_semicolon("type T = { key: string; key2 : nil }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key", 11, 0),
                            TypeName::new(create_identifier("string", 16, 0)),
                        )
                        .with_token(spaced_token(14, 15))
                    )
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("key2", 24, 1),
                            Type::Nil(Some(spaced_token(31, 34)))
                        )
                        .with_token(spaced_token(29, 30))
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(35, 36),
                        separators: vec![spaced_token(22, 23)],
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_indexer_type_and_property("type T = { [number]: string, n: number }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_indexer_type(
                        TableIndexerType::new(
                            TypeName::new(create_identifier("number", 12, 0)),
                            TypeName::new(create_identifier("string", 21, 0)),
                        )
                        .with_tokens(TableIndexTypeTokens {
                            opening_bracket: token_at_first_line(11, 12),
                            closing_bracket: token_at_first_line(18, 19),
                            colon: spaced_token(19, 20),
                        })
                    )
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("n", 29, 0),
                            TypeName::new(create_identifier("number", 32, 1))
                        ).with_token(spaced_token(30, 31))
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(39, 40),
                        separators: vec![spaced_token(27, 28)],
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_property_and_indexer_type("type T = { n: number, [number]: string }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TablePropertyType::new(
                            create_identifier("n", 11, 0),
                            TypeName::new(create_identifier("number", 14, 0))
                        ).with_token(spaced_token(12, 13))
                    )
                    .with_indexer_type(
                        TableIndexerType::new(
                            TypeName::new(create_identifier("number", 23, 0)),
                            TypeName::new(create_identifier("string", 32, 1)),
                        )
                        .with_tokens(TableIndexTypeTokens {
                            opening_bracket: token_at_first_line(22, 23),
                            closing_bracket: token_at_first_line(29, 30),
                            colon: spaced_token(30, 31),
                        })
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(39, 40),
                        separators: vec![spaced_token(20, 21)],
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_literal_property("type T = { ['end']: boolean }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_property(
                        TableLiteralPropertyType::new(
                            StringType::from_value("end")
                                .with_token(token_at_first_line(12, 17)),
                            TypeName::new(create_identifier("boolean", 20, 1)),
                        )
                        .with_tokens(TableIndexTypeTokens {
                            opening_bracket: token_at_first_line(11, 12),
                            closing_bracket: token_at_first_line(17, 18),
                            colon: spaced_token(18, 19),
                        })
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(28, 29),
                        separators: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_table_with_indexer_type("type T = { [string]: boolean }") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TableType::default()
                    .with_indexer_type(
                        TableIndexerType::new(
                            TypeName::new(create_identifier("string", 12, 0)),
                            TypeName::new(create_identifier("boolean", 21, 1)),
                        )
                        .with_tokens(TableIndexTypeTokens {
                            opening_bracket: token_at_first_line(11, 12),
                            closing_bracket: token_at_first_line(18, 19),
                            colon: spaced_token(19, 20),
                        })
                    )
                    .with_tokens(TableTypeTokens {
                        opening_brace: spaced_token(9, 10),
                        closing_brace: token_at_first_line(29, 30),
                        separators: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_type_of_expression("type T = typeof( nil )") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                ExpressionType::new(Expression::Nil(Some(spaced_token(17, 20))))
                    .with_tokens(ExpressionTypeTokens {
                        r#typeof: token_at_first_line(9, 15),
                        opening_parenthese: spaced_token(15, 16),
                        closing_parenthese: token_at_first_line(21, 22),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_void_callback("type T = () -> ()") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    TypePack::default()
                        .with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(15, 16),
                            right_parenthese: token_at_first_line(16, 17),
                            commas: Vec::new(),
                        })
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_optional_void_callback("type T = () -> ()?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                OptionalType::new(
                    FunctionType::new(
                        TypePack::default().with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(15, 16),
                            right_parenthese: token_at_first_line(16, 17),
                            commas: Vec::new(),
                        })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
                ).with_token(token_at_first_line(17, 18))
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_intersection_of_void_callback_and_string("type T = () -> () & string") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                IntersectionType::new(
                    FunctionType::new(
                        TypePack::default().with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(15, 16),
                            right_parenthese: spaced_token(16, 17),
                            commas: Vec::new(),
                        })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    }),
                    TypeName::new(create_identifier("string", 20, 0))
                ).with_tokens(IntersectionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(18, 19)]
                })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_union_of_void_callback_and_string("type T = () -> () | string") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                UnionType::new(
                    FunctionType::new(
                        TypePack::default().with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(15, 16),
                            right_parenthese: spaced_token(16, 17),
                            commas: Vec::new(),
                        })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    }),
                    TypeName::new(create_identifier("string", 20, 0))
                ).with_tokens(UnionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(18, 19)]
                })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_type("type T = () -> boolean") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(TypeName::new(create_identifier("boolean", 15, 0)))
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_multiple_intersected_types("type T = () -> A & B & C") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    IntersectionType::new(
                        TypeName::new(create_identifier("A", 15, 1)),
                        TypeName::new(create_identifier("B", 19, 1)),
                    )
                    .with_type(TypeName::new(create_identifier("C", 23, 0)))
                    .with_tokens(IntersectionTypeTokens {
                        leading_token: None,
                        separators: vec![
                            spaced_token(17, 18),
                            spaced_token(21, 22),
                        ]
                    }),
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_optional_type("type T = () -> boolean?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    OptionalType::new(TypeName::new(create_identifier("boolean", 15, 0)))
                        .with_token(token_at_first_line(22, 23))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_type_name("type T = () -> ...string") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(TypeName::new(create_identifier("string", 18, 0)))
                        .with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_optional("type T = () -> ...string?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(
                        OptionalType::new(
                            TypeName::new(create_identifier("string", 18, 0))
                        ).with_token(token_at_first_line(24, 25))
                    ).with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_string_literal("type T = () -> ...'ok'") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(
                        StringType::from_value("ok").with_token(token_at_first_line(18, 22))
                    ).with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_false_type("type T = () -> ...false") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(Type::False(Some(token_at_first_line(18, 23))))
                        .with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_intersection_type("type T = () -> string & T") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                        IntersectionType::new(
                            TypeName::new(create_identifier("string", 15, 1)),
                            TypeName::new(create_identifier("T", 24, 0)),
                        ).with_tokens(IntersectionTypeTokens {
                            leading_token: None,
                            separators: vec![spaced_token(22, 23)]
                        })
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_union_type("type T = () -> string | T") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                        UnionType::new(
                            TypeName::new(create_identifier("string", 15, 1)),
                            TypeName::new(create_identifier("T", 24, 0)),
                        ).with_tokens(UnionTypeTokens {
                            leading_token: None,
                            separators: vec![spaced_token(22, 23)]
                        })
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_intersection_type("type T = () -> ...string & T") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(
                        IntersectionType::new(
                            TypeName::new(create_identifier("string", 18, 1)),
                            TypeName::new(create_identifier("T", 27, 0)),
                        ).with_tokens(IntersectionTypeTokens {
                            leading_token: None,
                            separators: vec![spaced_token(25, 26)]
                        })
                    )
                        .with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_variadic_union_type("type T = () -> ...string | boolean") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    VariadicTypePack::new(
                        UnionType::new(
                            TypeName::new(create_identifier("string", 18, 1)),
                            TypeName::new(create_identifier("boolean", 27, 0)),
                        ).with_tokens(UnionTypeTokens {
                            leading_token: None,
                            separators: vec![spaced_token(25, 26)]
                        })
                    )
                        .with_token(token_at_first_line(15, 18))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_returning_generic_type_pack("type T = () -> U...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("U", 15, 0))
                        .with_token(token_at_first_line(16, 19))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(10, 11),
                        arrow: spaced_token(12, 14),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_with_one_argument_returning_type("type T = (string) -> boolean") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(TypeName::new(create_identifier("boolean", 21, 0)))
                    .with_argument(TypeName::new(create_identifier("string", 10, 0)))
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(16, 17),
                        arrow: spaced_token(18, 20),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_with_variadic_type_returning_type("type T = (...string) -> boolean") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(TypeName::new(create_identifier("boolean", 24, 0)))
                    .with_variadic_type(
                        VariadicTypePack::new(TypeName::new(create_identifier("string", 13, 0)))
                            .with_token(token_at_first_line(10, 13))
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(19, 20),
                        arrow: spaced_token(21, 23),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_callback_with_variadic_optional_type_returning_type("type T = (...string?) -> boolean") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(TypeName::new(create_identifier("boolean", 25, 0)))
                    .with_variadic_type(
                        VariadicTypePack::new(
                            OptionalType::new(TypeName::new(create_identifier("string", 13, 0)))
                                .with_token(token_at_first_line(19, 20))
                        )
                            .with_token(token_at_first_line(10, 13))
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(9, 10),
                        closing_parenthese: spaced_token(20, 21),
                        arrow: spaced_token(22, 24),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_callback("type T = <R>() -> R") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    TypeName::new(create_identifier("R", 18, 0))
                )
                    .with_generic_parameters(
                        GenericParameters::from_type_variable(create_identifier("R", 10, 0))
                            .with_tokens(GenericParametersTokens {
                                opening_list: token_at_first_line(9, 10),
                                closing_list: token_at_first_line(11, 12),
                                commas: Vec::new(),
                            })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(12, 13),
                        closing_parenthese: spaced_token(13, 14),
                        arrow: spaced_token(15, 17),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_callback_with_two_types("type T = <R, R2>() -> R") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    TypeName::new(create_identifier("R", 22, 0))
                )
                    .with_generic_parameters(
                        GenericParameters::from_type_variable(create_identifier("R", 10, 0))
                            .with_type_variable(create_identifier("R2", 13, 0))
                            .with_tokens(GenericParametersTokens {
                                opening_list: token_at_first_line(9, 10),
                                closing_list: token_at_first_line(15, 16),
                                commas: vec![spaced_token(11, 12)],
                            })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(16, 17),
                        closing_parenthese: spaced_token(17, 18),
                        arrow: spaced_token(19, 21),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_callback_with_generic_type_pack("type T = <R...>() -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 21, 0))
                        .with_token(token_at_first_line(22, 25))
                )
                    .with_generic_parameters(
                        GenericParameters::from_generic_type_pack(
                            GenericTypePack::new(create_identifier("R", 10, 0))
                                .with_token(token_at_first_line(11, 14))
                        )
                            .with_tokens(GenericParametersTokens {
                                opening_list: token_at_first_line(9, 10),
                                closing_list: token_at_first_line(14, 15),
                                commas: Vec::new(),
                            })
                    )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: spaced_token(16, 17),
                        arrow: spaced_token(18, 20),
                        commas: Vec::new(),
                    })
            ).with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_array("type Array<T> = { T }") => TypeDeclarationStatement::new(
                create_identifier("Array", 5, 0),
                ArrayType::new(TypeName::new(create_identifier("T", 18, 1)))
                    .with_tokens(ArrayTypeTokens {
                        opening_brace: spaced_token(16, 17),
                        closing_brace: token_at_first_line(20, 21),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable(
                    create_identifier("T", 11, 0)
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(10, 11),
                    closing_list: spaced_token(12, 13),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(14, 15),
                export: None,
            }),
            type_declaration_to_generic_intersection("type T < U, V > = U & V") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                IntersectionType::new(
                    TypeName::new(create_identifier("U", 18, 1)),
                    TypeName::new(create_identifier("V", 22, 0)),
                ).with_tokens(IntersectionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(20, 21)]
                })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable(
                    create_identifier("U", 9, 0)
                )
                .with_type_variable(create_identifier("V", 12, 1))
                .with_tokens(GenericParametersTokens {
                    opening_list: spaced_token(7, 8),
                    closing_list: spaced_token(14, 15),
                    commas: vec![spaced_token(10, 11)],
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(16, 17),
                export: None,
            }),
            type_declaration_with_generic_param_with_boolean_default("type T<A=boolean> = A?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                OptionalType::new(
                    TypeName::new(create_identifier("A", 20, 0)),
                ).with_token(token_at_first_line(21, 22))
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable_with_default(
                    TypeVariableWithDefault::new(
                        create_identifier("A", 7, 0),
                        TypeName::new(create_identifier("boolean", 9, 0))
                    ).with_token(token_at_first_line(8, 9))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(16, 17),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(18, 19),
                export: None,
            }),
            type_declaration_with_generic_param_with_parenthese_default("type T<A=(boolean)> = A?") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                OptionalType::new(
                    TypeName::new(create_identifier("A", 22, 0)),
                ).with_token(token_at_first_line(23, 24))
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable_with_default(
                    TypeVariableWithDefault::new(
                        create_identifier("A", 7, 0),
                        ParentheseType::new(TypeName::new(create_identifier("boolean", 10, 0)))
                            .with_tokens(ParentheseTypeTokens {
                                left_parenthese: token_at_first_line(9, 10),
                                right_parenthese: token_at_first_line(17, 18),
                            })
                    ).with_token(token_at_first_line(8, 9))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(18, 19),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(20, 21),
                export: None,
            }),
            type_declaration_to_generic_union_with_default_type("type T<A, B=Error> = A | B") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                UnionType::new(
                    TypeName::new(create_identifier("A", 21, 1)),
                    TypeName::new(create_identifier("B", 25, 0)),
                ).with_tokens(UnionTypeTokens {
                    leading_token: None,
                    separators: vec![spaced_token(23, 24)]
                })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable(
                    create_identifier("A", 7, 0)
                )
                .with_type_variable_with_default(
                    TypeVariableWithDefault::new(
                        create_identifier("B", 10, 0),
                        TypeName::new(create_identifier("Error", 12, 0))
                    ).with_token(token_at_first_line(11, 12))
                ).unwrap()
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(17, 18),
                    commas: vec![spaced_token(8, 9)],
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(19, 20),
                export: None,
            }),
            type_declaration_with_generic_type_pack("type T<R...> = () -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 21, 0))
                        .with_token(token_at_first_line(22, 25))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(15, 16),
                        closing_parenthese: spaced_token(16, 17),
                        arrow: spaced_token(18, 20),
                        commas: Vec::new(),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_generic_type_pack(
                    GenericTypePack::new(
                        create_identifier("R", 7, 0),
                    ).with_token(token_at_first_line(8, 11))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(11, 12),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(13, 14),
                export: None,
            }),
            type_declaration_with_variable_and_generic_type_pack("type T<A, R...> = (A) -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 25, 0))
                        .with_token(token_at_first_line(26, 29))
                )
                    .with_argument(TypeName::new(create_identifier("A", 19, 0)))
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(18, 19),
                        closing_parenthese: spaced_token(20, 21),
                        arrow: spaced_token(22, 24),
                        commas: Vec::new(),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_type_variable(
                    create_identifier("A", 7,0 )
                )
                .with_generic_type_pack(
                    GenericTypePack::new(
                        create_identifier("R", 10, 0),
                    ).with_token(token_at_first_line(11, 14))
                ).unwrap()
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(14, 15),
                    commas: vec![spaced_token(8, 9)],
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(16, 17),
                export: None,
            }),
            type_declaration_with_generic_type_pack_with_default_tuple("type T<R...=()> = () -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 24, 0))
                        .with_token(token_at_first_line(25, 28))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(18, 19),
                        closing_parenthese: spaced_token(19, 20),
                        arrow: spaced_token(21, 23),
                        commas: Vec::new(),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                    GenericTypePackWithDefault::new(
                        GenericTypePack::new(
                            create_identifier("R", 7, 0),
                        ).with_token(token_at_first_line(8, 11)),
                        TypePack::default().with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(12, 13),
                            right_parenthese: token_at_first_line(13, 14),
                            commas: Vec::new(),
                        })
                    ).with_token(token_at_first_line(11, 12))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(14, 15),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(16, 17),
                export: None,
            }),
            type_declaration_with_generic_type_pack_with_default_variadic_pack("type T<R...=...string> = () -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 31, 0))
                        .with_token(token_at_first_line(32, 35))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(25, 26),
                        closing_parenthese: spaced_token(26, 27),
                        arrow: spaced_token(28, 30),
                        commas: Vec::new(),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                    GenericTypePackWithDefault::new(
                        GenericTypePack::new(
                            create_identifier("R", 7, 0),
                        ).with_token(token_at_first_line(8, 11)),
                        VariadicTypePack::new(
                            TypeName::new(create_identifier("string", 15, 0))
                        ).with_token(token_at_first_line(12, 15)),
                    ).with_token(token_at_first_line(11, 12))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(21, 22),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(23, 24),
                export: None,
            }),
            type_declaration_with_generic_type_pack_with_default_generic_pack("type T<R...=A...> = () -> R...") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 0),
                FunctionType::new(
                    GenericTypePack::new(create_identifier("R", 26, 0))
                        .with_token(token_at_first_line(27, 30))
                )
                    .with_tokens(FunctionTypeTokens {
                        opening_parenthese: token_at_first_line(20, 21),
                        closing_parenthese: spaced_token(21, 22),
                        arrow: spaced_token(23, 25),
                        commas: Vec::new(),
                    })
            )
            .with_generic_parameters(
                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                    GenericTypePackWithDefault::new(
                        GenericTypePack::new(
                            create_identifier("R", 7, 0),
                        ).with_token(token_at_first_line(8, 11)),
                        GenericTypePack::new(create_identifier("A", 12, 0))
                            .with_token(token_at_first_line(13, 16)),
                    ).with_token(token_at_first_line(11, 12))
                )
                .with_tokens(GenericParametersTokens {
                    opening_list: token_at_first_line(6, 7),
                    closing_list: spaced_token(16, 17),
                    commas: Vec::new(),
                })
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(18, 19),
                export: None,
            }),
            type_declaration_to_generic_type("type T = Array<string>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Array", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(TypeName::new(create_identifier("string", 15, 0)))
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(14, 15),
                            closing_list: token_at_first_line(21, 22),
                            commas: Vec::new(),
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_with_two_types("type T = Dict<string, boolean>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Dict", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(TypeName::new(create_identifier("string", 14, 0)))
                        .with_parameter(TypeName::new(create_identifier("boolean", 22, 0)))
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(13, 14),
                            closing_list: token_at_first_line(29, 30),
                            commas: vec![spaced_token(20, 21)],
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_with_type_pack("type T = Fn<()>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Fn", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(
                        TypePack::default().with_tokens(TypePackTokens {
                            left_parenthese: token_at_first_line(12, 13),
                            right_parenthese: token_at_first_line(13, 14),
                            commas: Vec::new(),
                        })
                    )
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(11, 12),
                            closing_list: token_at_first_line(14, 15),
                            commas: Vec::new(),
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_with_generic_type_pack("type T = Fn<A...>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Fn", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(
                        GenericTypePack::new(create_identifier("A", 12, 0))
                            .with_token(token_at_first_line(13, 16))
                    )
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(11, 12),
                            closing_list: token_at_first_line(16, 17),
                            commas: Vec::new(),
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_with_variadic_type_pack("type T = Fn<...A>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Fn", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(
                        VariadicTypePack::new(TypeName::new(create_identifier("A", 15, 0)))
                            .with_token(token_at_first_line(12, 15))
                    )
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(11, 12),
                            closing_list: token_at_first_line(16, 17),
                            commas: Vec::new(),
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_with_variadic_string_literal_type_pack("type T = Fn<...'ok'>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeName::new(create_identifier("Fn", 9, 0))
                .with_type_parameters(
                    TypeParameters::new(
                        VariadicTypePack::new(
                            StringType::from_value("ok").with_token(token_at_first_line(15, 19))
                        )
                            .with_token(token_at_first_line(12, 15))
                    )
                        .with_tokens(TypeParametersTokens {
                            opening_list: token_at_first_line(11, 12),
                            closing_list: token_at_first_line(19, 20),
                            commas: Vec::new(),
                        })
                )
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
            type_declaration_to_generic_type_in_namespace("type T = M.Array<string>") => TypeDeclarationStatement::new(
                create_identifier("T", 5, 1),
                TypeField::new(
                    create_identifier("M", 9, 0),
                    TypeName::new(create_identifier("Array", 11, 0))
                        .with_type_parameters(
                            TypeParameters::new(TypeName::new(create_identifier("string", 17, 0)))
                                .with_tokens(TypeParametersTokens {
                                    opening_list: token_at_first_line(16, 17),
                                    closing_list: token_at_first_line(23, 24),
                                    commas: Vec::new(),
                                })
                        )
                ).with_token(token_at_first_line(10, 11))
            )
            .with_tokens(TypeDeclarationTokens {
                r#type: spaced_token(0, 4),
                equal: spaced_token(7, 8),
                export: None,
            }),
        );

        test_parse_block_with_tokens!(
            empty_block("") => Block::default()
                .with_tokens(BlockTokens {
                    semicolons: vec![],
                    last_semicolon: None,
                    final_token: None,
                }),
            single_line("\n") => Block::default()
                .with_tokens(BlockTokens {
                    semicolons: vec![],
                    last_semicolon: None,
                    final_token: Some(Token::new_with_line(1, 1, 2)
                        .with_leading_trivia(TriviaKind::Whitespace.at(0, 1, 1))),
                }),
            single_line_comment("-- todo") => Block::default()
                .with_tokens(BlockTokens {
                    semicolons: vec![],
                    last_semicolon: None,
                    final_token: Some(token_at_first_line(7, 7)
                        .with_leading_trivia(TriviaKind::Comment.at(0, 7, 1))),
                }),
            multiple_line_comments("-- todo\n  -- one\n") => Block::default()
                .with_tokens(BlockTokens {
                    semicolons: vec![],
                    last_semicolon: None,
                    final_token: Some(
                        Token::new_with_line(17, 17, 3)
                            .with_leading_trivia(TriviaKind::Comment.at(0, 7, 1))
                            .with_leading_trivia(TriviaKind::Whitespace.at(7, 8, 1))
                            .with_leading_trivia(TriviaKind::Whitespace.at(8, 10, 2))
                            .with_leading_trivia(TriviaKind::Comment.at(10, 16, 2))
                            .with_leading_trivia(TriviaKind::Whitespace.at(16, 17, 2))
                    ),
                }),
            single_multiline_comment("--[[\n    todo\n]]") => Block::default()
                .with_tokens(BlockTokens {
                    semicolons: vec![],
                    last_semicolon: None,
                    final_token: Some(Token::new_with_line(16, 16, 3)
                        .with_leading_trivia(TriviaKind::Comment.at(0, 16, 1))),
                }),
            return_nothing_with_semicolon("return;") => Block::from(
                ReturnStatement::default()
                    .with_tokens(ReturnTokens {
                        r#return: token_at_first_line(0, 6),
                        commas: Vec::new(),
                    }),
            ).with_tokens(BlockTokens {
                semicolons: vec![],
                last_semicolon: Some(token_at_first_line(6, 7)),
                final_token: None,
            }),
            return_nothing_with_semicolon_and_comment("return; -- return nothing") => Block::from(
                ReturnStatement::default()
                    .with_tokens(ReturnTokens {
                        r#return: token_at_first_line(0, 6),
                        commas: Vec::new(),
                    }),
            ).with_tokens(BlockTokens {
                semicolons: vec![],
                last_semicolon: Some(
                    token_at_first_line(6, 7)
                        .with_trailing_trivia(TriviaKind::Whitespace.at(7, 8, 1))
                        .with_trailing_trivia(TriviaKind::Comment.at(8, 25, 1))
                ),
                final_token: None,
            }),
            two_local_declarations("local a;\nlocal b;\n") => Block::from(
                LocalAssignStatement::from_variable(create_identifier("a", 6, 0))
                    .with_tokens(LocalAssignTokens {
                        local: spaced_token(0, 5),
                        equal: None,
                        variable_commas: Vec::new(),
                        value_commas: Vec::new(),
                    })
            ).with_statement(
                LocalAssignStatement::from_variable(create_identifier_at_line("b", 15, 0, 2))
                    .with_tokens(LocalAssignTokens {
                        local: spaced_token_at_line(9, 14, 2),
                        equal: None,
                        variable_commas: Vec::new(),
                        value_commas: Vec::new(),
                    })
            ).with_tokens(BlockTokens {
                semicolons: vec![
                    Some(spaced_token(7, 8)),
                    Some(spaced_token_at_line(16, 17, 2)),
                ],
                last_semicolon: None,
                final_token: None,
            }),
        );
    }
}
