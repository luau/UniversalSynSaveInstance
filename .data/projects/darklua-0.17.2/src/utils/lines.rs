use crate::nodes::{
    Arguments, Block, Expression, FunctionCall, FunctionReturnType, LastStatement, Prefix,
    Statement, Token, Type, Variable,
};

pub(crate) fn block_total(block: &Block) -> usize {
    last_block_token(block)
        .and_then(get_token_line)
        .unwrap_or(0)
}

pub(crate) fn statement_total(statement: &Statement) -> usize {
    last_statement_token(statement)
        .and_then(get_token_line)
        .unwrap_or(0)
}

pub(crate) fn statement_first(statement: &Statement) -> usize {
    first_statement_token(statement)
        .and_then(get_token_line)
        .unwrap_or(0)
}

fn get_token_line(token: &Token) -> Option<usize> {
    token
        .iter_trailing_trivia()
        .last()
        .and_then(|trivia| {
            trivia.get_line_number().map(|line| {
                line + trivia
                    .try_read()
                    .unwrap_or_default()
                    .chars()
                    .filter(|c| *c == '\n')
                    .count()
            })
        })
        .or_else(|| token.get_line_number())
}

fn last_block_token(block: &Block) -> Option<&Token> {
    block
        .get_tokens()
        .and_then(|tokens| tokens.final_token.as_ref())
        .or_else(|| {
            block
                .get_last_statement()
                .and_then(last_last_statement_token)
                .or_else(|| {
                    block
                        .iter_statements()
                        .last()
                        .and_then(last_statement_token)
                })
        })
}

fn last_statement_token(statement: &Statement) -> Option<&Token> {
    match statement {
        Statement::Assign(assign) => assign.last_value().and_then(last_expression_token),
        Statement::Do(do_statement) => do_statement.get_tokens().map(|tokens| &tokens.end),
        Statement::Call(call) => last_call_token(call),
        Statement::CompoundAssign(assign) => last_expression_token(assign.get_value()),
        Statement::Function(function) => function.get_tokens().map(|tokens| &tokens.end),
        Statement::GenericFor(generic_for) => generic_for.get_tokens().map(|tokens| &tokens.end),
        Statement::If(if_statement) => if_statement.get_tokens().map(|tokens| &tokens.end),
        Statement::LocalAssign(local_assign) => local_assign
            .iter_values()
            .last()
            .and_then(last_expression_token)
            .or_else(|| {
                local_assign
                    .iter_variables()
                    .last()
                    .and_then(|identifier| identifier.get_token())
            }),
        Statement::LocalFunction(local_function) => {
            local_function.get_tokens().map(|tokens| &tokens.end)
        }
        Statement::NumericFor(numeric_for) => numeric_for.get_tokens().map(|tokens| &tokens.end),
        Statement::Repeat(repeat) => last_expression_token(repeat.get_condition()),
        Statement::While(while_statement) => while_statement.get_tokens().map(|tokens| &tokens.end),
        Statement::TypeDeclaration(type_declaration) => {
            last_type_token(type_declaration.get_type())
        }
    }
}

fn last_last_statement_token(last: &LastStatement) -> Option<&Token> {
    match last {
        LastStatement::Break(token) | LastStatement::Continue(token) => token.as_ref(),
        LastStatement::Return(return_statement) => return_statement
            .iter_expressions()
            .last()
            .and_then(last_expression_token)
            .or_else(|| return_statement.get_tokens().map(|tokens| &tokens.r#return)),
    }
}

fn last_expression_token(expression: &Expression) -> Option<&Token> {
    match expression {
        Expression::Binary(binary) => last_expression_token(binary.right()),
        Expression::Call(call) => last_call_token(call),
        Expression::Field(field) => field.get_field().get_token(),
        Expression::Function(function) => function.get_tokens().map(|tokens| &tokens.end),
        Expression::Identifier(identifier) => identifier.get_token(),
        Expression::If(if_expression) => last_expression_token(if_expression.get_else_result()),
        Expression::Index(index) => index.get_tokens().map(|tokens| &tokens.closing_bracket),
        Expression::Number(number) => number.get_token(),
        Expression::Parenthese(parentheses) => parentheses
            .get_tokens()
            .map(|tokens| &tokens.right_parenthese),
        Expression::String(string) => string.get_token(),
        Expression::InterpolatedString(string) => {
            string.get_tokens().map(|tokens| &tokens.closing_tick)
        }
        Expression::Table(table) => table.get_tokens().map(|tokens| &tokens.closing_brace),
        Expression::Nil(token)
        | Expression::False(token)
        | Expression::True(token)
        | Expression::VariableArguments(token) => token.as_ref(),
        Expression::Unary(unary) => last_expression_token(unary.get_expression()),
        Expression::TypeCast(type_cast) => last_type_token(type_cast.get_type()),
    }
}

fn last_type_token(r#type: &Type) -> Option<&Token> {
    match r#type {
        Type::Name(name) => {
            if let Some(type_params) = name.get_type_parameters() {
                type_params.get_tokens().map(|tokens| &tokens.closing_list)
            } else {
                name.get_type_name().get_token()
            }
        }
        Type::Field(field) => {
            if let Some(type_params) = field.get_type_name().get_type_parameters() {
                type_params.get_tokens().map(|tokens| &tokens.closing_list)
            } else {
                field.get_type_name().get_type_name().get_token()
            }
        }
        Type::True(token) | Type::False(token) | Type::Nil(token) => token.as_ref(),
        Type::String(string) => string.get_token(),
        Type::Array(array) => array.get_tokens().map(|tokens| &tokens.closing_brace),
        Type::Table(table) => table.get_tokens().map(|tokens| &tokens.closing_brace),
        Type::TypeOf(expression_type) => expression_type
            .get_tokens()
            .map(|tokens| &tokens.closing_parenthese),
        Type::Parenthese(parenthese) => parenthese
            .get_tokens()
            .map(|tokens| &tokens.right_parenthese),
        Type::Function(function) => match function.get_return_type() {
            FunctionReturnType::Type(return_type) => last_type_token(return_type),
            FunctionReturnType::TypePack(type_pack) => type_pack
                .get_tokens()
                .map(|tokens| &tokens.right_parenthese),
            FunctionReturnType::GenericTypePack(generic_pack) => generic_pack.get_token(),
            FunctionReturnType::VariadicTypePack(variadic_pack) => {
                last_type_token(variadic_pack.get_type())
            }
        },
        Type::Optional(optional) => optional.get_token(),
        Type::Intersection(intersection) => last_type_token(intersection.last_type()),
        Type::Union(union_type) => last_type_token(union_type.last_type()),
    }
}

fn last_call_token(call: &FunctionCall) -> Option<&Token> {
    match call.get_arguments() {
        Arguments::Tuple(tuple) => tuple.get_tokens().map(|tokens| &tokens.closing_parenthese),
        Arguments::String(string) => string.get_token(),
        Arguments::Table(table) => table.get_tokens().map(|tokens| &tokens.closing_brace),
    }
}

fn first_statement_token(statement: &Statement) -> Option<&Token> {
    match statement {
        Statement::Assign(assign) => assign
            .iter_variables()
            .next()
            .and_then(first_variable_token),
        Statement::Do(do_statement) => do_statement.get_tokens().map(|tokens| &tokens.r#do),
        Statement::Call(call) => first_prefix_token(call.get_prefix()),
        Statement::CompoundAssign(assign) => first_variable_token(assign.get_variable()),
        Statement::Function(function) => function.get_tokens().map(|tokens| &tokens.function),
        Statement::GenericFor(generic_for) => generic_for.get_tokens().map(|tokens| &tokens.r#for),
        Statement::If(if_statement) => if_statement.get_tokens().map(|tokens| &tokens.r#if),
        Statement::LocalAssign(local_assign) => {
            local_assign.get_tokens().map(|tokens| &tokens.local)
        }
        Statement::LocalFunction(local_function) => {
            local_function.get_tokens().map(|tokens| &tokens.local)
        }
        Statement::NumericFor(numeric_for) => numeric_for.get_tokens().map(|tokens| &tokens.r#for),
        Statement::Repeat(repeat) => repeat.get_tokens().map(|tokens| &tokens.repeat),
        Statement::While(while_statement) => {
            while_statement.get_tokens().map(|tokens| &tokens.r#while)
        }
        Statement::TypeDeclaration(type_declaration) => {
            type_declaration.get_tokens().and_then(|tokens| {
                if type_declaration.is_exported() {
                    tokens.export.as_ref()
                } else {
                    Some(&tokens.r#type)
                }
            })
        }
    }
}

fn first_variable_token(variable: &Variable) -> Option<&Token> {
    match variable {
        Variable::Identifier(identifier) => identifier.get_token(),
        Variable::Field(field_expression) => first_prefix_token(field_expression.get_prefix()),
        Variable::Index(index_expression) => first_prefix_token(index_expression.get_prefix()),
    }
}

fn first_prefix_token(prefix: &Prefix) -> Option<&Token> {
    match prefix {
        Prefix::Call(function_call) => first_prefix_token(function_call.get_prefix()),
        Prefix::Field(field_expression) => first_prefix_token(field_expression.get_prefix()),
        Prefix::Identifier(identifier) => identifier.get_token(),
        Prefix::Index(index_expression) => first_prefix_token(index_expression.get_prefix()),
        Prefix::Parenthese(parenthese_expression) => parenthese_expression
            .get_tokens()
            .map(|tokens| &tokens.left_parenthese),
    }
}

#[cfg(test)]
mod test {
    macro_rules! test_total_lines {
        (
            $($name:ident ($code:literal) => $value:expr),+,
        ) => {
            $(
                #[test]
                fn $name() {
                    use $crate::rules::FlawlessRule;

                    let code = $code;

                    let mut block = $crate::Parser::default().preserve_tokens().parse(&code).unwrap();

                    let resources = $crate::Resources::from_memory();
                    let context = $crate::rules::ContextBuilder::new(
                            "placeholder",
                            &resources,
                            &code
                        )
                        .build();

                    $crate::rules::ReplaceReferencedTokens::default()
                    .flawless_process(&mut block, &context);

                    let received_lines = super::block_total(&block);
                    assert_eq!(
                        received_lines,
                        $value,
                        "expected {} line{} but received {}.\n{:#?}",
                        $value,
                        if $value > 1 { "s" } else { "" },
                        received_lines,
                        block,
                    );
                }
            )*
        };
    }

    test_total_lines!(
        return_statement("return\n") => 2,
        return_one("return 1") => 1,
        return_true("return true") => 1,
        return_false("return true,\n\tfalse\n") => 3,
        return_nil("return nil\n") => 2,
        return_string("return 'hello' --end\n") => 2,
        return_not_variable("return not variable") => 1,
        return_function_call("return call()") => 1,
        return_variadic_args("return ... -- comment") => 1,
        return_parenthese("return (\ncall()\n)") => 3,
        return_table("return {\n\t}\n") => 3,
        return_function_expression("return function(arg1, ...)\nend -- ") => 2,
        return_function_call_with_table_arguments("return call {\nelement\n}") => 3,
        function_call_with_table_arguments("call {\nelement\n}") => 3,
        require_with_string_argument("require 'module.lua'\n") => 2,
        return_require_with_string_argument("return require 'module.lua'\n") => 2,
        return_if_expression("return if condition then\n\tok\nelse\n\terr") => 4,
        if_statement("if condition then\n\treturn ok\nelse\n\treturn err\nend -- end if") => 5,
        do_statement("do\n--comment\n\n\nend") => 5,
        compound_assign("\nvar += 10.5") => 2,
        assign_with_binary_expression("var = var + 2") => 1,
        local_assign_with_field_expression("local var =\n\tobject.prop\n-- end") => 3,
        local_assign_with_index_expression("local var =\n\tobject['prop']\n-- end") => 3,
        local_function_definition("local function fn()\nend\n") => 3,
        function_definition("function fn()\nend\n --comment\n") => 4,
        generic_for("for k, v in pairs({}) do\nend\n --comment") => 3,
        numeric_for("for i = 1, 10 do\n-- comment\nend\n") => 4,
        repeat_statement("\nrepeat\n-- do\nuntil condition\n") => 5,
        while_statement("\nwhile condition do\n-- do\nend\n") => 5,
        break_statement("break\n") => 2,
        continue_statement("continue\n") => 2,
    );
}
