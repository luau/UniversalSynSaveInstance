use std::iter;

use crate::{
    generator::{utils, LuaGenerator},
    nodes::*,
};

/// This implementation of [LuaGenerator](trait.LuaGenerator.html) outputs the
/// AST nodes from the tokens associated with each of them.
#[derive(Debug, Clone)]
pub struct TokenBasedLuaGenerator<'a> {
    original_code: &'a str,
    output: String,
    currently_commenting: bool,
    current_line: usize,
}

impl<'a> TokenBasedLuaGenerator<'a> {
    pub fn new(original_code: &'a str) -> Self {
        Self {
            original_code,
            output: String::new(),
            currently_commenting: false,
            current_line: 1,
        }
    }

    fn push_str(&mut self, string: &str) {
        self.current_line += utils::count_new_lines(string.as_bytes());
        self.output.push_str(string);
    }

    fn write_trivia(&mut self, trivia: &Trivia) {
        let content = trivia.read(self.original_code);

        let is_comment = matches!(trivia.kind(), TriviaKind::Comment);
        let is_line_comment = is_comment && is_single_line_comment(content);
        let is_multiline_comment = is_comment && !is_line_comment;

        if is_multiline_comment && self.currently_commenting {
            self.uncomment();
        }

        self.push_str(content);

        match trivia.kind() {
            TriviaKind::Comment => {
                if is_line_comment {
                    self.currently_commenting = true;
                }
            }
            TriviaKind::Whitespace => {
                if self.currently_commenting && content.contains('\n') {
                    self.currently_commenting = false
                }
            }
        }
    }

    #[inline]
    fn write_token(&mut self, token: &Token) {
        self.write_token_options(token, true)
    }

    fn write_token_options(&mut self, token: &Token, space_check: bool) {
        for trivia in token.iter_leading_trivia() {
            self.write_trivia(trivia);
        }

        let content = token.read(self.original_code);

        if !content.is_empty() {
            if self.currently_commenting {
                self.uncomment();
            }

            if let Some(line_number) = token.get_line_number() {
                while line_number > self.current_line {
                    self.output.push('\n');
                    self.current_line += 1;
                }
            }

            if space_check {
                if let Some(next_character) = content.chars().next() {
                    if self.needs_space(next_character) {
                        self.output.push(' ');
                    }
                }
            }

            self.push_str(content);
        }

        for trivia in token.iter_trailing_trivia() {
            self.write_trivia(trivia);
        }
    }

    fn write_block_with_tokens(&mut self, block: &Block, tokens: &BlockTokens) {
        let mut iterator = block.iter_statements().enumerate().peekable();

        while let Some((index, statement)) = iterator.next() {
            self.write_statement(statement);

            if let Some(semicolon) = tokens.semicolons.get(index).unwrap_or(&None) {
                self.write_token(semicolon);
            } else if let Some((_, next_statement)) = iterator.peek() {
                if utils::starts_with_parenthese(next_statement)
                    && utils::ends_with_prefix(statement)
                {
                    self.write_symbol(";");
                }
            };
        }

        if let Some(statement) = block.get_last_statement() {
            self.write_last_statement(statement);
        }

        if let Some(token) = &tokens.final_token {
            self.write_token(token);
        }
    }

    fn write_return_with_tokens(&mut self, statement: &ReturnStatement, tokens: &ReturnTokens) {
        self.write_token(&tokens.r#return);

        let last_index = statement.len().saturating_sub(1);
        statement
            .iter_expressions()
            .enumerate()
            .for_each(|(i, expression)| {
                self.write_expression(expression);
                if i < last_index {
                    if let Some(comma) = tokens.commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });
    }

    fn write_assign_with_tokens(&mut self, assign: &AssignStatement, tokens: &AssignTokens) {
        let last_variable_index = assign.variables_len().saturating_sub(1);
        assign
            .iter_variables()
            .enumerate()
            .for_each(|(i, variable)| {
                self.write_variable(variable);
                if i < last_variable_index {
                    if let Some(comma) = tokens.variable_commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });

        self.write_token(&tokens.equal);
        let last_value_index = assign.values_len().saturating_sub(1);
        assign.iter_values().enumerate().for_each(|(i, value)| {
            self.write_expression(value);
            if i < last_value_index {
                if let Some(comma) = tokens.value_commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        });
    }

    fn write_do_with_tokens(&mut self, do_statement: &DoStatement, tokens: &DoTokens) {
        self.write_token(&tokens.r#do);
        self.write_block(do_statement.get_block());
        self.write_token(&tokens.end);
    }

    fn write_function_call_with_tokens(
        &mut self,
        call: &FunctionCall,
        tokens: &FunctionCallTokens,
    ) {
        self.write_prefix(call.get_prefix());
        if let Some(method) = call.get_method() {
            if let Some(colon) = &tokens.colon {
                self.write_token(colon);
            } else {
                self.write_symbol(":");
            }
            self.write_identifier(method);
        }
        self.write_arguments(call.get_arguments());
    }

    fn write_parenthese_with_tokens(
        &mut self,
        parenthese: &ParentheseExpression,
        tokens: &ParentheseTokens,
    ) {
        self.write_token(&tokens.left_parenthese);
        self.write_expression(parenthese.inner_expression());
        self.write_token(&tokens.right_parenthese);
    }

    fn write_type_cast_with_tokens(&mut self, type_cast: &TypeCastExpression, token: &Token) {
        let inner_expression = type_cast.get_expression();

        if TypeCastExpression::needs_parentheses(inner_expression) {
            self.write_symbol("(");
            self.write_expression(inner_expression);
            self.write_symbol(")");
        } else {
            self.write_expression(inner_expression);
        }

        self.write_token(token);
        self.write_type(type_cast.get_type());
    }

    fn write_tuple_arguments_with_tokens(
        &mut self,
        arguments: &TupleArguments,
        tokens: &TupleArgumentsTokens,
    ) {
        self.write_token(&tokens.opening_parenthese);

        let last_value_index = arguments.len().saturating_sub(1);
        arguments.iter_values().enumerate().for_each(|(i, value)| {
            self.write_expression(value);
            if i < last_value_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        });

        self.write_token(&tokens.closing_parenthese);
    }

    fn write_table_with_tokens(&mut self, table: &TableExpression, tokens: &TableTokens) {
        self.write_token(&tokens.opening_brace);

        let last_index = table.len().saturating_sub(1);
        table.iter_entries().enumerate().for_each(|(i, entry)| {
            self.write_table_entry(entry);
            if let Some(separator) = tokens.separators.get(i) {
                self.write_token(separator);
            } else if i < last_index {
                self.write_symbol(",");
            }
        });

        self.write_token(&tokens.closing_brace);
    }

    fn write_table_field_with_tokens(&mut self, entry: &TableFieldEntry, token: &Token) {
        self.write_identifier(entry.get_field());
        self.write_token(token);
        self.write_expression(entry.get_value());
    }

    fn write_table_index_with_tokens(
        &mut self,
        entry: &TableIndexEntry,
        tokens: &TableIndexEntryTokens,
    ) {
        self.write_token(&tokens.opening_bracket);
        self.write_expression(entry.get_key());
        self.write_token(&tokens.closing_bracket);
        self.write_token(&tokens.equal);
        self.write_expression(entry.get_value());
    }

    fn write_field_with_token(&mut self, field: &FieldExpression, token: &Token) {
        self.write_prefix(field.get_prefix());
        self.write_token_options(token, false);
        self.write_identifier(field.get_field());
    }

    fn write_index_with_tokens(&mut self, index: &IndexExpression, tokens: &IndexExpressionTokens) {
        self.write_prefix(index.get_prefix());
        self.write_token(&tokens.opening_bracket);
        self.write_expression(index.get_index());
        self.write_token(&tokens.closing_bracket);
    }

    fn write_if_expression_with_token(
        &mut self,
        if_expression: &IfExpression,
        tokens: &IfExpressionTokens,
    ) {
        self.write_token(&tokens.r#if);
        self.write_expression(if_expression.get_condition());
        self.write_token(&tokens.then);
        self.write_expression(if_expression.get_result());

        for branch in if_expression.iter_branches() {
            if let Some(tokens) = branch.get_tokens() {
                self.write_if_expression_branch_with_tokens(branch, tokens);
            } else {
                self.write_if_expression_branch_with_tokens(
                    branch,
                    &self.generate_if_expression_branch_tokens(branch),
                );
            }
        }

        self.write_token(&tokens.r#else);
        self.write_expression(if_expression.get_else_result());
    }

    fn write_if_expression_branch_with_tokens(
        &mut self,
        branch: &ElseIfExpressionBranch,
        tokens: &ElseIfExpressionBranchTokens,
    ) {
        self.write_token(&tokens.elseif);
        self.write_expression(branch.get_condition());
        self.write_token(&tokens.then);
        self.write_expression(branch.get_result());
    }

    fn write_compound_assign_with_tokens(
        &mut self,
        assign: &CompoundAssignStatement,
        tokens: &CompoundAssignTokens,
    ) {
        self.write_variable(assign.get_variable());
        self.write_token(&tokens.operator);
        self.write_expression(assign.get_value());
    }

    #[allow(clippy::too_many_arguments)]
    fn write_function_attributes<'b>(
        &mut self,
        tokens: &FunctionBodyTokens,
        generic_parameters: Option<&GenericParameters>,
        parameter_count: usize,
        parameters: impl Iterator<Item = &'b TypedIdentifier>,
        is_variadic: bool,
        variadic_type: Option<&FunctionVariadicType>,
        return_type: Option<&FunctionReturnType>,
        block: &Block,
    ) {
        if let Some(generics) = generic_parameters {
            self.write_function_generics(generics);
        }

        self.write_token(&tokens.opening_parenthese);

        let last_parameter_index = parameter_count.saturating_sub(1);
        parameters.enumerate().for_each(|(i, param)| {
            self.write_typed_identifier(param);
            if i < last_parameter_index {
                if let Some(comma) = tokens.parameter_commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        });

        if is_variadic {
            if parameter_count > 0 {
                if let Some(comma) = tokens.parameter_commas.get(last_parameter_index) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }

            if let Some(token) = &tokens.variable_arguments {
                self.write_token(token);
            } else {
                self.write_symbol("...");
            }

            if let Some(variadic_type) = variadic_type {
                if let Some(colon) = &tokens.variable_arguments_colon {
                    self.write_token(colon);
                } else {
                    self.write_symbol(":")
                }
                self.write_function_variadic_type(variadic_type);
            }
        }

        self.write_token(&tokens.closing_parenthese);

        if let Some(return_type) = return_type {
            if let Some(colon) = &tokens.return_type_colon {
                self.write_token(colon);
            } else {
                self.write_symbol(":")
            }

            self.write_function_return_type(return_type);
        }

        self.write_block(block);

        self.write_token(&tokens.end);
    }

    fn write_function_statement_with_tokens(
        &mut self,
        function: &FunctionStatement,
        tokens: &FunctionBodyTokens,
    ) {
        self.write_token(&tokens.function);

        let name = function.get_name();
        if let Some(tokens) = name.get_tokens() {
            self.write_function_name_with_tokens(name, tokens);
        } else {
            self.write_function_name_with_tokens(name, &self.generate_function_name_tokens(name));
        }

        self.write_function_attributes(
            tokens,
            function.get_generic_parameters(),
            function.parameters_count(),
            function.iter_parameters(),
            function.is_variadic(),
            function.get_variadic_type(),
            function.get_return_type(),
            function.get_block(),
        );
    }

    fn write_function_name_with_tokens(
        &mut self,
        name: &FunctionName,
        tokens: &FunctionNameTokens,
    ) {
        self.write_identifier(name.get_name());

        name.get_field_names()
            .iter()
            .enumerate()
            .for_each(|(i, field)| {
                if let Some(period) = tokens.periods.get(i) {
                    self.write_token_options(period, false);
                } else {
                    self.write_symbol_without_space_check(".");
                }
                self.write_identifier(field);
            });

        if let Some(method) = name.get_method() {
            if let Some(colon) = &tokens.colon {
                self.write_token(colon);
            } else {
                self.write_symbol(":");
            }
            self.write_identifier(method);
        }
    }

    fn write_generic_for_with_tokens(
        &mut self,
        generic_for: &GenericForStatement,
        tokens: &GenericForTokens,
    ) {
        self.write_token(&tokens.r#for);

        let last_identifier_index = generic_for.identifiers_len().saturating_sub(1);
        generic_for
            .iter_identifiers()
            .enumerate()
            .for_each(|(i, identifier)| {
                self.write_typed_identifier(identifier);
                if i < last_identifier_index {
                    if let Some(comma) = tokens.identifier_commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });

        self.write_token(&tokens.r#in);

        let last_expression_index = generic_for.expressions_len().saturating_sub(1);
        generic_for
            .iter_expressions()
            .enumerate()
            .for_each(|(i, expression)| {
                self.write_expression(expression);
                if i < last_expression_index {
                    if let Some(comma) = tokens.value_commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });

        self.write_token(&tokens.r#do);
        self.write_block(generic_for.get_block());
        self.write_token(&tokens.end);
    }

    fn write_if_statement_with_tokens(
        &mut self,
        if_statement: &IfStatement,
        tokens: &IfStatementTokens,
    ) {
        let mut branches = if_statement.iter_branches();
        if let Some(branch) = branches.next() {
            self.write_token(&tokens.r#if);
            self.write_expression(branch.get_condition());
            self.write_token(&tokens.then);
            self.write_block(branch.get_block());

            for branch in branches {
                if let Some(tokens) = branch.get_tokens() {
                    self.write_if_branch_with_tokens(branch, tokens);
                } else {
                    self.write_if_branch_with_tokens(
                        branch,
                        &self.generate_if_branch_tokens(branch),
                    );
                }
            }

            if let Some(else_block) = if_statement.get_else_block() {
                if let Some(token) = &tokens.r#else {
                    self.write_token(token);
                } else {
                    self.write_symbol("else");
                }
                self.write_block(else_block);
            }

            self.write_token(&tokens.end);
        }
    }

    fn write_if_branch_with_tokens(&mut self, branch: &IfBranch, tokens: &IfBranchTokens) {
        self.write_token(&tokens.elseif);
        self.write_expression(branch.get_condition());
        self.write_token(&tokens.then);
        self.write_block(branch.get_block());
    }

    fn write_local_assign_with_tokens(
        &mut self,
        assign: &LocalAssignStatement,
        tokens: &LocalAssignTokens,
    ) {
        self.write_token(&tokens.local);
        let last_variable_index = assign.variables_len().saturating_sub(1);
        assign
            .iter_variables()
            .enumerate()
            .for_each(|(i, identifier)| {
                self.write_typed_identifier(identifier);
                if i < last_variable_index {
                    if let Some(comma) = tokens.variable_commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });

        if assign.has_values() {
            if let Some(token) = &tokens.equal {
                self.write_token(token);
            } else {
                self.write_symbol("=");
            }
            let last_value_index = assign.values_len().saturating_sub(1);
            assign.iter_values().enumerate().for_each(|(i, value)| {
                self.write_expression(value);
                if i < last_value_index {
                    if let Some(comma) = tokens.value_commas.get(i) {
                        self.write_token(comma);
                    } else {
                        self.write_symbol(",");
                    }
                }
            });
        }
    }

    fn write_local_function_with_tokens(
        &mut self,
        function: &LocalFunctionStatement,
        tokens: &LocalFunctionTokens,
    ) {
        self.write_token(&tokens.local);
        self.write_token(&tokens.function);
        self.write_identifier(function.get_identifier());

        self.write_function_attributes(
            tokens,
            function.get_generic_parameters(),
            function.parameters_count(),
            function.iter_parameters(),
            function.is_variadic(),
            function.get_variadic_type(),
            function.get_return_type(),
            function.get_block(),
        );
    }

    fn write_numeric_for_with_tokens(
        &mut self,
        numeric_for: &NumericForStatement,
        tokens: &NumericForTokens,
    ) {
        self.write_token(&tokens.r#for);
        self.write_typed_identifier(numeric_for.get_identifier());
        self.write_token(&tokens.equal);
        self.write_expression(numeric_for.get_start());
        self.write_token(&tokens.end_comma);
        self.write_expression(numeric_for.get_end());

        if let Some(step) = numeric_for.get_step() {
            if let Some(comma) = &tokens.step_comma {
                self.write_token(comma);
            } else {
                self.write_symbol(",");
            }
            self.write_expression(step);
        }

        self.write_token(&tokens.r#do);
        self.write_block(numeric_for.get_block());
        self.write_token(&tokens.end);
    }

    fn write_repeat_with_tokens(&mut self, repeat: &RepeatStatement, tokens: &RepeatTokens) {
        self.write_token(&tokens.repeat);
        self.write_block(repeat.get_block());
        self.write_token(&tokens.until);
        self.write_expression(repeat.get_condition());
    }

    fn write_while_with_tokens(&mut self, while_statement: &WhileStatement, tokens: &WhileTokens) {
        self.write_token(&tokens.r#while);
        self.write_expression(while_statement.get_condition());
        self.write_token(&tokens.r#do);
        self.write_block(while_statement.get_block());
        self.write_token(&tokens.end);
    }

    fn write_type_declaration_with_tokens(
        &mut self,
        statement: &TypeDeclarationStatement,
        tokens: &TypeDeclarationTokens,
    ) {
        if statement.is_exported() {
            if let Some(export_token) = &tokens.export {
                self.write_token(export_token);
            } else {
                self.write_symbol("export");
            }
        }
        self.write_token(&tokens.r#type);

        self.write_identifier(statement.get_name());

        if let Some(generic_parameters) = statement
            .get_generic_parameters()
            .filter(|generic_parameters| !generic_parameters.is_empty())
        {
            if let Some(tokens) = generic_parameters.get_tokens() {
                self.write_generic_parameters_with_default_with_tokens(generic_parameters, tokens);
            } else {
                self.write_generic_parameters_with_default_with_tokens(
                    generic_parameters,
                    &self.generate_generic_parameters_with_defaults_tokens(generic_parameters),
                );
            }
        }

        self.write_token(&tokens.equal);

        self.write_type(statement.get_type());
    }

    fn write_generic_parameters_with_default_with_tokens(
        &mut self,
        generic_parameters: &GenericParametersWithDefaults,
        tokens: &GenericParametersTokens,
    ) {
        self.write_token(&tokens.opening_list);

        let last_index = generic_parameters.len().saturating_sub(1);

        for (i, parameter) in generic_parameters.iter().enumerate() {
            match parameter {
                GenericParameterRef::TypeVariable(identifier) => {
                    self.write_identifier(identifier);
                }
                GenericParameterRef::TypeVariableWithDefault(identifier_with_default) => {
                    self.write_identifier(identifier_with_default.get_type_variable());
                    if let Some(token) = identifier_with_default.get_token() {
                        self.write_token(token);
                    } else {
                        self.write_symbol("=");
                    }
                    self.write_type(identifier_with_default.get_default_type());
                }
                GenericParameterRef::GenericTypePack(generic_type_pack) => {
                    self.write_generic_type_pack(generic_type_pack);
                }
                GenericParameterRef::GenericTypePackWithDefault(generic_pack_with_default) => {
                    self.write_generic_type_pack(generic_pack_with_default.get_generic_type_pack());
                    if let Some(token) = generic_pack_with_default.get_token() {
                        self.write_token(token);
                    } else {
                        self.write_symbol("=");
                    }
                    self.write_generic_type_pack_default(
                        generic_pack_with_default.get_default_type(),
                    );
                }
            }

            if i < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        self.write_token(&tokens.closing_list);
    }

    fn write_function_with_tokens(
        &mut self,
        function: &FunctionExpression,
        tokens: &FunctionBodyTokens,
    ) {
        self.write_token(&tokens.function);

        self.write_function_attributes(
            tokens,
            function.get_generic_parameters(),
            function.parameters_count(),
            function.iter_parameters(),
            function.is_variadic(),
            function.get_variadic_type(),
            function.get_return_type(),
            function.get_block(),
        );
    }

    fn write_type_parameters_with_tokens(
        &mut self,
        parameters: &TypeParameters,
        tokens: &TypeParametersTokens,
    ) {
        self.write_token(&tokens.opening_list);
        let last_index = parameters.len().saturating_sub(1);

        for (i, parameter) in parameters.iter().enumerate() {
            self.write_type_parameter(parameter);

            if i < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        self.write_token(&tokens.closing_list);
    }

    fn write_type_field_with_token(&mut self, type_field: &TypeField, token: &Token) {
        self.write_identifier(type_field.get_namespace());
        self.write_token_options(token, false);
        self.write_type_name(type_field.get_type_name());
    }

    fn write_array_type_with_tokens(&mut self, array_type: &ArrayType, tokens: &ArrayTypeTokens) {
        self.write_token(&tokens.opening_brace);
        self.write_type(array_type.get_element_type());
        self.write_token(&tokens.closing_brace);
    }

    fn write_table_type_with_tokens(&mut self, table_type: &TableType, tokens: &TableTypeTokens) {
        self.write_token(&tokens.opening_brace);

        let last_index = table_type.len().saturating_sub(1);

        for (i, property) in table_type.iter_entries().enumerate() {
            match property {
                TableEntryType::Property(property) => {
                    self.write_identifier(property.get_identifier());

                    if let Some(colon) = property.get_token() {
                        self.write_token(colon);
                    } else {
                        self.write_symbol(":");
                    }

                    self.write_type(property.get_type());
                }
                TableEntryType::Literal(property) => {
                    if let Some(tokens) = property.get_tokens() {
                        self.write_table_literal_property_type_with_tokens(property, tokens);
                    } else {
                        self.write_table_literal_property_type_with_tokens(
                            property,
                            &self.generate_table_indexer_type_tokens(),
                        );
                    }
                }
                TableEntryType::Indexer(indexer) => {
                    if let Some(tokens) = indexer.get_tokens() {
                        self.write_table_indexer_type_with_tokens(indexer, tokens);
                    } else {
                        self.write_table_indexer_type_with_tokens(
                            indexer,
                            &self.generate_table_indexer_type_tokens(),
                        );
                    }
                }
            }

            if let Some(comma) = tokens.separators.get(i) {
                self.write_token(comma);
            } else if i < last_index {
                self.write_symbol(",");
            }
        }

        self.write_token(&tokens.closing_brace);
    }

    fn write_table_indexer_type_with_tokens(
        &mut self,
        indexer_type: &TableIndexerType,
        tokens: &TableIndexTypeTokens,
    ) {
        self.write_token(&tokens.opening_bracket);

        let key_type = indexer_type.get_key_type();

        let need_parentheses = matches!(
            key_type,
            Type::Optional(_) | Type::Intersection(_) | Type::Union(_)
        );

        if need_parentheses {
            self.write_symbol("(");
            self.write_type(key_type);
            self.write_symbol(")");
        } else {
            self.write_type(key_type);
        }

        self.write_token(&tokens.closing_bracket);
        self.write_token(&tokens.colon);
        self.write_type(indexer_type.get_value_type());
    }

    fn write_table_literal_property_type_with_tokens(
        &mut self,
        property: &TableLiteralPropertyType,
        tokens: &TableIndexTypeTokens,
    ) {
        self.write_token(&tokens.opening_bracket);
        self.write_string_type(property.get_string());
        self.write_token(&tokens.closing_bracket);
        self.write_token(&tokens.colon);
        self.write_type(property.get_type());
    }

    fn write_expression_type_with_tokens(
        &mut self,
        expression_type: &ExpressionType,
        tokens: &ExpressionTypeTokens,
    ) {
        self.write_token(&tokens.r#typeof);
        self.write_token(&tokens.opening_parenthese);
        self.write_expression(expression_type.get_expression());
        self.write_token(&tokens.closing_parenthese);
    }

    fn write_parenthese_type_with_tokens(
        &mut self,
        parenthese_type: &ParentheseType,
        tokens: &ParentheseTypeTokens,
    ) {
        self.write_token(&tokens.left_parenthese);
        self.write_type(parenthese_type.get_inner_type());
        self.write_token(&tokens.right_parenthese);
    }

    fn write_function_type_with_tokens(
        &mut self,
        function_type: &FunctionType,
        tokens: &FunctionTypeTokens,
    ) {
        if let Some(generic_parameters) = function_type.get_generic_parameters() {
            self.write_function_generics(generic_parameters);
        }

        self.write_token(&tokens.opening_parenthese);

        let argument_len = function_type.argument_len();
        let last_index = argument_len.saturating_sub(1);

        for (i, argument) in function_type.iter_arguments().enumerate() {
            if let Some(name) = argument.get_name() {
                self.write_identifier(name);

                if let Some(token) = argument.get_token() {
                    self.write_token(token);
                } else {
                    self.write_symbol(":");
                }
            }

            self.write_type(argument.get_type());

            if i < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        if let Some(variadic_argument_type) = function_type.get_variadic_argument_type() {
            if argument_len > 0 {
                if let Some(comma) = tokens.commas.get(argument_len) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
            self.write_variadic_argument_type(variadic_argument_type);
        }

        self.write_token(&tokens.closing_parenthese);
        self.write_token(&tokens.arrow);
        self.write_function_return_type(function_type.get_return_type());
    }

    fn write_function_generics(&mut self, generic_parameters: &GenericParameters) {
        if generic_parameters.is_empty() {
            return;
        }
        if let Some(generic_tokens) = generic_parameters.get_tokens() {
            self.write_generic_parameters_with_tokens(generic_parameters, generic_tokens);
        } else {
            self.write_generic_parameters_with_tokens(
                generic_parameters,
                &self.generate_generic_parameters_tokens(generic_parameters),
            );
        }
    }

    fn write_generic_parameters_with_tokens(
        &mut self,
        generic_parameters: &GenericParameters,
        tokens: &GenericParametersTokens,
    ) {
        self.write_token(&tokens.opening_list);

        let last_index = generic_parameters.len().saturating_sub(1);

        for (i, type_variable) in generic_parameters.iter_type_variable().enumerate() {
            self.write_identifier(type_variable);

            if i < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        let type_variables_len = generic_parameters.type_variables_len();

        for (i, generic_type_pack) in generic_parameters.iter_generic_type_pack().enumerate() {
            self.write_generic_type_pack(generic_type_pack);

            if (i + type_variables_len) < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        self.write_token(&tokens.closing_list);
    }

    fn write_type_pack_with_tokens(&mut self, type_pack: &TypePack, tokens: &TypePackTokens) {
        self.write_token(&tokens.left_parenthese);

        let last_index = type_pack
            .len()
            .saturating_sub(if type_pack.has_variadic_type() { 0 } else { 1 });

        for (i, r#type) in type_pack.iter().enumerate() {
            self.write_type(r#type);

            if i < last_index {
                if let Some(comma) = tokens.commas.get(i) {
                    self.write_token(comma);
                } else {
                    self.write_symbol(",");
                }
            }
        }

        if let Some(variadic_argument_type) = type_pack.get_variadic_type() {
            self.write_variadic_argument_type(variadic_argument_type);
        }

        self.write_token(&tokens.right_parenthese);
    }

    fn write_optional_type_with_token(&mut self, optional: &OptionalType, token: &Token) {
        let inner_type = optional.get_inner_type();
        if OptionalType::needs_parentheses(inner_type) {
            self.write_symbol("(");
            self.write_type(inner_type);
            self.write_symbol(")");
        } else {
            self.write_type(inner_type);
        }
        self.write_token(token);
    }

    fn write_intersection_type_with_token(
        &mut self,
        intersection: &IntersectionType,
        tokens: &IntersectionTypeTokens,
    ) {
        let length = intersection.len();
        let last_index = length.saturating_sub(1);

        for (i, r#type) in intersection.iter_types().enumerate() {
            if i == 0 {
                if let Some(leading) = &tokens.leading_token {
                    self.write_token(leading);
                }
            } else if let Some(token) = tokens.separators.get(i.saturating_sub(1)) {
                self.write_token(token);
            } else {
                self.write_symbol("&");
            }

            let need_parentheses = if i == last_index {
                IntersectionType::last_needs_parentheses(r#type)
            } else {
                IntersectionType::intermediate_needs_parentheses(r#type)
            };

            if need_parentheses {
                self.write_symbol("(");
                self.write_type(r#type);
                self.write_symbol(")");
            } else {
                self.write_type(r#type);
            }
        }
    }

    fn write_union_type_with_token(&mut self, union: &UnionType, tokens: &UnionTypeTokens) {
        let length = union.len();
        let last_index = length.saturating_sub(1);

        for (i, r#type) in union.iter_types().enumerate() {
            if i == 0 {
                if let Some(leading) = &tokens.leading_token {
                    self.write_token(leading);
                }
            } else if let Some(token) = tokens.separators.get(i.saturating_sub(1)) {
                self.write_token(token);
            } else {
                self.write_symbol("|");
            }

            let need_parentheses = if i == last_index {
                UnionType::last_needs_parentheses(r#type)
            } else {
                UnionType::intermediate_needs_parentheses(r#type)
            };

            if need_parentheses {
                self.write_symbol("(");
                self.write_type(r#type);
                self.write_symbol(")");
            } else {
                self.write_type(r#type);
            }
        }
    }

    fn write_interpolated_string_with_tokens(
        &mut self,
        interpolated_string: &InterpolatedStringExpression,
        tokens: &InterpolatedStringTokens,
    ) {
        self.write_token(&tokens.opening_tick);

        for segment in interpolated_string.iter_segments() {
            match segment {
                InterpolationSegment::String(string_segment) => {
                    if let Some(token) = string_segment.get_token() {
                        self.write_token(token);
                    } else {
                        self.write_symbol(&utils::write_interpolated_string_segment(string_segment))
                    }
                }
                InterpolationSegment::Value(value) => {
                    if let Some(tokens) = value.get_tokens() {
                        self.write_string_value_segment_with_tokens(value, tokens);
                    } else {
                        self.write_string_value_segment_with_tokens(
                            value,
                            &self.generate_string_value_segment_tokens(value),
                        );
                    }
                }
            }
        }

        self.write_token(&tokens.closing_tick);
    }

    fn write_string_value_segment_with_tokens(
        &mut self,
        value: &ValueSegment,
        tokens: &ValueSegmentTokens,
    ) {
        self.write_token(&tokens.opening_brace);
        let expression = value.get_expression();
        if self.output.ends_with('{') {
            if let Some(table) = utils::starts_with_table(expression) {
                if table
                    .get_tokens()
                    .and_then(|tokens| {
                        tokens
                            .opening_brace
                            .iter_leading_trivia()
                            .next()
                            .filter(|trivia| !trivia.read(self.original_code).is_empty())
                    })
                    .is_none()
                {
                    self.output.push(' ');
                }
            }
        }
        self.write_expression(expression);
        self.write_token(&tokens.closing_brace);
    }

    fn generate_block_tokens(&self, _block: &Block) -> BlockTokens {
        BlockTokens {
            semicolons: Vec::new(),
            last_semicolon: None,
            final_token: None,
        }
    }

    fn generate_assign_tokens(&self, assign: &AssignStatement) -> AssignTokens {
        AssignTokens {
            equal: Token::from_content("="),
            variable_commas: intersect_with_token(comma_token(), assign.variables_len()),
            value_commas: intersect_with_token(comma_token(), assign.values_len()),
        }
    }

    fn generate_do_tokens(&self, _do_statement: &DoStatement) -> DoTokens {
        DoTokens {
            r#do: Token::from_content("do"),
            end: Token::from_content("end"),
        }
    }

    fn generate_compound_assign_tokens(
        &self,
        assign: &CompoundAssignStatement,
    ) -> CompoundAssignTokens {
        CompoundAssignTokens {
            operator: Token::from_content(assign.get_operator().to_str()),
        }
    }

    fn generate_generic_for_tokens(&self, generic_for: &GenericForStatement) -> GenericForTokens {
        GenericForTokens {
            r#for: Token::from_content("for"),
            r#in: Token::from_content("in"),
            r#do: Token::from_content("do"),
            end: Token::from_content("end"),
            identifier_commas: intersect_with_token(comma_token(), generic_for.identifiers_len()),
            value_commas: intersect_with_token(comma_token(), generic_for.expressions_len()),
        }
    }

    fn generate_if_statement_tokens(&self, if_statement: &IfStatement) -> IfStatementTokens {
        IfStatementTokens {
            r#if: Token::from_content("if"),
            then: Token::from_content("then"),
            end: Token::from_content("end"),
            r#else: if_statement
                .get_else_block()
                .map(|_| Token::from_content("else")),
        }
    }

    fn generate_if_branch_tokens(&self, _branch: &IfBranch) -> IfBranchTokens {
        IfBranchTokens {
            elseif: Token::from_content("elseif"),
            then: Token::from_content("then"),
        }
    }

    fn generate_function_statement_tokens(
        &self,
        function: &FunctionStatement,
    ) -> FunctionBodyTokens {
        FunctionBodyTokens {
            function: Token::from_content("function"),
            opening_parenthese: Token::from_content("("),
            closing_parenthese: Token::from_content(")"),
            end: Token::from_content("end"),
            parameter_commas: intersect_with_token(
                comma_token(),
                function.parameters_count() + usize::from(function.is_variadic()),
            ),
            variable_arguments: if function.is_variadic() {
                Some(Token::from_content("..."))
            } else {
                None
            },
            variable_arguments_colon: if function.has_variadic_type() {
                Some(Token::from_content(":"))
            } else {
                None
            },
            return_type_colon: if function.has_return_type() {
                Some(Token::from_content(":"))
            } else {
                None
            },
        }
    }

    fn generate_function_name_tokens(&self, name: &FunctionName) -> FunctionNameTokens {
        FunctionNameTokens {
            periods: iter::repeat_with(|| Token::from_content("."))
                .take(name.get_field_names().len())
                .collect(),
            colon: name.get_method().map(|_| Token::from_content(":")),
        }
    }

    fn generate_return_tokens(&self, return_statement: &ReturnStatement) -> ReturnTokens {
        ReturnTokens {
            r#return: Token::from_content("return")
                .with_trailing_trivia(TriviaKind::Whitespace.with_content(" ")),
            commas: intersect_with_token(comma_token(), return_statement.len()),
        }
    }

    fn generate_local_assign_tokens(&self, assign: &LocalAssignStatement) -> LocalAssignTokens {
        LocalAssignTokens {
            local: Token::from_content("local"),
            equal: if assign.has_values() {
                Some(Token::from_content("="))
            } else {
                None
            },
            variable_commas: intersect_with_token(comma_token(), assign.variables_len()),
            value_commas: intersect_with_token(comma_token(), assign.values_len()),
        }
    }

    fn generate_local_function_tokens(
        &self,
        function: &LocalFunctionStatement,
    ) -> LocalFunctionTokens {
        LocalFunctionTokens {
            local: Token::from_content("local"),
            function_body: FunctionBodyTokens {
                function: Token::from_content("function"),
                opening_parenthese: Token::from_content("("),
                closing_parenthese: Token::from_content(")"),
                end: Token::from_content("end"),
                parameter_commas: intersect_with_token(
                    comma_token(),
                    function.parameters_count() + usize::from(function.is_variadic()),
                ),
                variable_arguments: if function.is_variadic() {
                    Some(Token::from_content("..."))
                } else {
                    None
                },
                variable_arguments_colon: if function.has_variadic_type() {
                    Some(Token::from_content(":"))
                } else {
                    None
                },
                return_type_colon: if function.has_return_type() {
                    Some(Token::from_content(":"))
                } else {
                    None
                },
            },
        }
    }

    fn generate_numeric_for_tokens(&self, numeric_for: &NumericForStatement) -> NumericForTokens {
        NumericForTokens {
            r#for: Token::from_content("for"),
            equal: Token::from_content("="),
            r#do: Token::from_content("do"),
            end: Token::from_content("end"),
            end_comma: Token::from_content(","),
            step_comma: numeric_for.get_step().map(|_| Token::from_content(",")),
        }
    }

    fn generate_repeat_tokens(&self, _repeat: &RepeatStatement) -> RepeatTokens {
        RepeatTokens {
            repeat: Token::from_content("repeat"),
            until: Token::from_content("until"),
        }
    }

    fn generate_while_tokens(&self, _while_statement: &WhileStatement) -> WhileTokens {
        WhileTokens {
            r#while: Token::from_content("while"),
            r#do: Token::from_content("do"),
            end: Token::from_content("end"),
        }
    }

    fn generate_type_declaration_tokens(
        &self,
        statement: &TypeDeclarationStatement,
    ) -> TypeDeclarationTokens {
        TypeDeclarationTokens {
            r#type: Token::from_content("type"),
            equal: Token::from_content("="),
            export: if statement.is_exported() {
                Some(Token::from_content("export"))
            } else {
                None
            },
        }
    }

    fn generate_function_tokens(&self, function: &FunctionExpression) -> FunctionBodyTokens {
        FunctionBodyTokens {
            function: Token::from_content("function"),
            opening_parenthese: Token::from_content("("),
            closing_parenthese: Token::from_content(")"),
            end: Token::from_content("end"),
            parameter_commas: intersect_with_token(
                comma_token(),
                function.parameters_count() + usize::from(function.is_variadic()),
            ),
            variable_arguments: if function.is_variadic() {
                Some(Token::from_content("..."))
            } else {
                None
            },
            variable_arguments_colon: if function.has_variadic_type() {
                Some(Token::from_content(":"))
            } else {
                None
            },
            return_type_colon: if function.has_return_type() {
                Some(Token::from_content(":"))
            } else {
                None
            },
        }
    }

    fn generate_function_call_tokens(&self, call: &FunctionCall) -> FunctionCallTokens {
        FunctionCallTokens {
            colon: call.get_method().map(|_| Token::from_content(":")),
        }
    }

    fn generate_field_token(&self, _field: &FieldExpression) -> Token {
        Token::from_content(".")
    }

    fn generate_index_tokens(&self, _index: &IndexExpression) -> IndexExpressionTokens {
        IndexExpressionTokens {
            opening_bracket: Token::from_content("["),
            closing_bracket: Token::from_content("]"),
        }
    }

    fn generate_if_tokens(&self, _if_expression: &IfExpression) -> IfExpressionTokens {
        IfExpressionTokens {
            r#if: Token::from_content("if"),
            then: Token::from_content("then"),
            r#else: Token::from_content("else"),
        }
    }

    fn generate_if_expression_branch_tokens(
        &self,
        _branch: &ElseIfExpressionBranch,
    ) -> ElseIfExpressionBranchTokens {
        ElseIfExpressionBranchTokens {
            elseif: Token::from_content("elseif"),
            then: Token::from_content("then"),
        }
    }

    fn generate_table_tokens(&self, table: &TableExpression) -> TableTokens {
        TableTokens {
            opening_brace: Token::from_content("{"),
            closing_brace: Token::from_content("}"),
            separators: intersect_with_token(comma_token(), table.len()),
        }
    }

    fn generate_table_field_tokens(&self, _entry: &TableFieldEntry) -> Token {
        Token::from_content("=")
    }

    fn generate_table_index_tokens(&self, _entry: &TableIndexEntry) -> TableIndexEntryTokens {
        TableIndexEntryTokens {
            opening_bracket: Token::from_content("["),
            closing_bracket: Token::from_content("]"),
            equal: Token::from_content("="),
        }
    }

    fn generate_tuple_arguments_tokens(&self, arguments: &TupleArguments) -> TupleArgumentsTokens {
        TupleArgumentsTokens {
            opening_parenthese: Token::from_content("("),
            closing_parenthese: Token::from_content(")"),
            commas: intersect_with_token(comma_token(), arguments.len()),
        }
    }

    fn generate_parenthese_tokens(&self, _parenthese: &ParentheseExpression) -> ParentheseTokens {
        ParentheseTokens {
            left_parenthese: Token::from_content("("),
            right_parenthese: Token::from_content(")"),
        }
    }

    fn generate_type_cast_token(&self, _type_cast: &TypeCastExpression) -> Token {
        Token::from_content("::")
    }

    fn generate_type_parameters_tokens(&self, parameters: &TypeParameters) -> TypeParametersTokens {
        TypeParametersTokens {
            opening_list: Token::from_content("<"),
            closing_list: Token::from_content(">"),
            commas: intersect_with_token(comma_token(), parameters.len()),
        }
    }

    fn generate_type_field_token(&self, _type_field: &TypeField) -> Token {
        Token::from_content(".")
    }

    fn generate_array_type_tokens(&self, _array: &ArrayType) -> ArrayTypeTokens {
        ArrayTypeTokens {
            opening_brace: Token::from_content("{"),
            closing_brace: Token::from_content("}"),
        }
    }

    fn generate_table_type_tokens(&self, table_type: &TableType) -> TableTypeTokens {
        TableTypeTokens {
            opening_brace: Token::from_content("{"),
            closing_brace: Token::from_content("}"),
            separators: intersect_with_token(comma_token(), table_type.len()),
        }
    }

    fn generate_table_indexer_type_tokens(&self) -> TableIndexTypeTokens {
        TableIndexTypeTokens {
            opening_bracket: Token::from_content("["),
            closing_bracket: Token::from_content("]"),
            colon: Token::from_content(":"),
        }
    }

    fn generate_expression_type_tokens(
        &self,
        _expression_type: &ExpressionType,
    ) -> ExpressionTypeTokens {
        ExpressionTypeTokens {
            r#typeof: Token::from_content("typeof"),
            opening_parenthese: Token::from_content("("),
            closing_parenthese: Token::from_content(")"),
        }
    }

    fn generate_parenthese_type_tokens(
        &self,
        _parenthese_type: &ParentheseType,
    ) -> ParentheseTypeTokens {
        ParentheseTypeTokens {
            left_parenthese: Token::from_content("("),
            right_parenthese: Token::from_content(")"),
        }
    }

    fn generate_function_type_tokens(&self, function_type: &FunctionType) -> FunctionTypeTokens {
        FunctionTypeTokens {
            opening_parenthese: Token::from_content("("),
            closing_parenthese: Token::from_content(")"),
            arrow: Token::from_content("->"),
            commas: intersect_with_token(
                comma_token(),
                function_type.argument_len()
                    + usize::from(function_type.has_variadic_argument_type()),
            ),
        }
    }

    fn generate_optional_type_token(&self, _optional: &OptionalType) -> Token {
        Token::from_content("?")
    }

    fn generate_intersection_type_token(
        &self,
        intersection: &IntersectionType,
    ) -> IntersectionTypeTokens {
        IntersectionTypeTokens {
            leading_token: intersection
                .has_leading_token()
                .then(|| Token::from_content("&")),
            separators: intersect_with_token(Token::from_content("&"), intersection.len()),
        }
    }

    fn generate_union_type_token(&self, union: &UnionType) -> UnionTypeTokens {
        UnionTypeTokens {
            leading_token: union.has_leading_token().then(|| Token::from_content("|")),
            separators: intersect_with_token(Token::from_content("|"), union.len()),
        }
    }

    fn generate_type_pack_tokens(&self, type_pack: &TypePack) -> TypePackTokens {
        TypePackTokens {
            left_parenthese: Token::from_content("("),
            right_parenthese: Token::from_content(")"),
            commas: intersect_with_token(
                comma_token(),
                type_pack.len() + usize::from(type_pack.has_variadic_type()),
            ),
        }
    }

    fn generate_generic_parameters_tokens(
        &self,
        generic_parameters: &GenericParameters,
    ) -> GenericParametersTokens {
        GenericParametersTokens {
            opening_list: Token::from_content("<"),
            closing_list: Token::from_content(">"),
            commas: intersect_with_token(comma_token(), generic_parameters.len()),
        }
    }

    fn generate_generic_parameters_with_defaults_tokens(
        &self,
        generic_parameters: &GenericParametersWithDefaults,
    ) -> GenericParametersTokens {
        GenericParametersTokens {
            opening_list: Token::from_content("<"),
            closing_list: Token::from_content(">"),
            commas: intersect_with_token(comma_token(), generic_parameters.len()),
        }
    }

    fn generate_interpolated_string_tokens(
        &self,
        _interpolated_string: &InterpolatedStringExpression,
    ) -> InterpolatedStringTokens {
        InterpolatedStringTokens {
            opening_tick: Token::from_content("`"),
            closing_tick: Token::from_content("`"),
        }
    }

    fn generate_string_value_segment_tokens(
        &self,
        _value_segment: &ValueSegment,
    ) -> ValueSegmentTokens {
        ValueSegmentTokens {
            opening_brace: Token::from_content("{"),
            closing_brace: Token::from_content("}"),
        }
    }

    fn write_symbol(&mut self, symbol: &str) {
        if self.currently_commenting {
            self.uncomment();
        } else if self.needs_space(symbol.chars().next().expect("symbol cannot be empty")) {
            self.output.push(' ');
        }
        self.push_str(symbol);
    }

    fn write_symbol_without_space_check(&mut self, symbol: &str) {
        if self.currently_commenting {
            self.uncomment();
        }
        self.push_str(symbol);
    }

    fn write_typed_identifier(&mut self, typed_identifier: &TypedIdentifier) {
        if let Some(token) = typed_identifier.get_token() {
            let name_in_token = token.read(self.original_code);

            if name_in_token == typed_identifier.get_name() {
                self.write_token(token);
            } else {
                let mut new_token = token.clone();
                new_token.replace_with_content(typed_identifier.get_name().clone());
                self.write_token(&new_token);
            }
        } else {
            let name = typed_identifier.get_name();
            self.write_symbol(name);
        }

        if let Some(r#type) = typed_identifier.get_type() {
            if let Some(colon) = typed_identifier.get_colon_token() {
                self.write_token(colon);
            } else {
                self.write_symbol(":");
            }
            self.write_type(r#type);
        }
    }

    #[inline]
    fn needs_space(&self, next_character: char) -> bool {
        if let Some(last) = self.output.chars().last() {
            utils::should_break_with_space(last, next_character)
        } else {
            false
        }
    }

    #[inline]
    fn uncomment(&mut self) {
        self.output.push('\n');
        self.current_line += 1;
        self.currently_commenting = false;
    }
}

fn is_single_line_comment(content: &str) -> bool {
    let is_multiline_comment = content.starts_with("--[") && {
        if let Some((closing_bracket_index, _)) =
            content.chars().skip(3).enumerate().find(|(_, c)| *c == '[')
        {
            content
                .get(3..closing_bracket_index)
                .map(|substring| substring.chars().all(|c| c == '='))
                .unwrap_or(true)
        } else {
            false
        }
    };

    !is_multiline_comment
}

#[inline]
fn comma_token() -> Token {
    Token::from_content(",").with_trailing_trivia(TriviaKind::Whitespace.with_content(" "))
}

impl LuaGenerator for TokenBasedLuaGenerator<'_> {
    fn into_string(self) -> String {
        self.output
    }

    fn write_block(&mut self, block: &Block) {
        if let Some(tokens) = block.get_tokens() {
            self.write_block_with_tokens(block, tokens);
        } else {
            self.write_block_with_tokens(block, &self.generate_block_tokens(block));
        }
    }

    fn write_assign_statement(&mut self, assign: &AssignStatement) {
        if let Some(tokens) = assign.get_tokens() {
            self.write_assign_with_tokens(assign, tokens);
        } else {
            self.write_assign_with_tokens(assign, &self.generate_assign_tokens(assign));
        }
    }

    fn write_do_statement(&mut self, do_statement: &DoStatement) {
        if let Some(tokens) = do_statement.get_tokens() {
            self.write_do_with_tokens(do_statement, tokens);
        } else {
            self.write_do_with_tokens(do_statement, &self.generate_do_tokens(do_statement));
        }
    }

    fn write_compound_assign(&mut self, assign: &CompoundAssignStatement) {
        if let Some(tokens) = assign.get_tokens() {
            self.write_compound_assign_with_tokens(assign, tokens);
        } else {
            self.write_compound_assign_with_tokens(
                assign,
                &self.generate_compound_assign_tokens(assign),
            );
        }
    }

    fn write_generic_for(&mut self, generic_for: &GenericForStatement) {
        if let Some(tokens) = generic_for.get_tokens() {
            self.write_generic_for_with_tokens(generic_for, tokens);
        } else {
            self.write_generic_for_with_tokens(
                generic_for,
                &self.generate_generic_for_tokens(generic_for),
            );
        }
    }

    fn write_if_statement(&mut self, if_statement: &IfStatement) {
        if let Some(tokens) = if_statement.get_tokens() {
            self.write_if_statement_with_tokens(if_statement, tokens);
        } else {
            self.write_if_statement_with_tokens(
                if_statement,
                &self.generate_if_statement_tokens(if_statement),
            );
        }
    }

    fn write_function_statement(&mut self, function: &FunctionStatement) {
        if let Some(tokens) = function.get_tokens() {
            self.write_function_statement_with_tokens(function, tokens);
        } else {
            self.write_function_statement_with_tokens(
                function,
                &self.generate_function_statement_tokens(function),
            );
        }
    }

    fn write_last_statement(&mut self, statement: &LastStatement) {
        match statement {
            LastStatement::Break(token) => {
                if let Some(token) = token {
                    self.write_token(token);
                } else {
                    self.write_symbol("break");
                }
            }
            LastStatement::Continue(token) => {
                if let Some(token) = token {
                    self.write_token(token);
                } else {
                    self.write_symbol("continue");
                }
            }
            LastStatement::Return(return_statement) => {
                if let Some(tokens) = return_statement.get_tokens() {
                    self.write_return_with_tokens(return_statement, tokens);
                } else {
                    self.write_return_with_tokens(
                        return_statement,
                        &self.generate_return_tokens(return_statement),
                    );
                }
            }
        }
    }

    fn write_local_assign(&mut self, assign: &LocalAssignStatement) {
        if let Some(tokens) = assign.get_tokens() {
            self.write_local_assign_with_tokens(assign, tokens);
        } else {
            self.write_local_assign_with_tokens(assign, &self.generate_local_assign_tokens(assign));
        }
    }

    fn write_local_function(&mut self, function: &LocalFunctionStatement) {
        if let Some(tokens) = function.get_tokens() {
            self.write_local_function_with_tokens(function, tokens);
        } else {
            self.write_local_function_with_tokens(
                function,
                &self.generate_local_function_tokens(function),
            );
        }
    }

    fn write_numeric_for(&mut self, numeric_for: &NumericForStatement) {
        if let Some(tokens) = numeric_for.get_tokens() {
            self.write_numeric_for_with_tokens(numeric_for, tokens);
        } else {
            self.write_numeric_for_with_tokens(
                numeric_for,
                &self.generate_numeric_for_tokens(numeric_for),
            );
        }
    }

    fn write_repeat_statement(&mut self, repeat: &RepeatStatement) {
        if let Some(tokens) = repeat.get_tokens() {
            self.write_repeat_with_tokens(repeat, tokens);
        } else {
            self.write_repeat_with_tokens(repeat, &self.generate_repeat_tokens(repeat));
        }
    }

    fn write_while_statement(&mut self, while_statement: &WhileStatement) {
        if let Some(tokens) = while_statement.get_tokens() {
            self.write_while_with_tokens(while_statement, tokens);
        } else {
            self.write_while_with_tokens(
                while_statement,
                &self.generate_while_tokens(while_statement),
            );
        }
    }

    fn write_type_declaration_statement(&mut self, statement: &TypeDeclarationStatement) {
        if let Some(tokens) = statement.get_tokens() {
            self.write_type_declaration_with_tokens(statement, tokens);
        } else {
            self.write_type_declaration_with_tokens(
                statement,
                &self.generate_type_declaration_tokens(statement),
            );
        }
    }

    fn write_false_expression(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("false");
        }
    }

    fn write_true_expression(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("true");
        }
    }

    fn write_nil_expression(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("nil");
        }
    }

    fn write_variable_arguments_expression(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("...");
        }
    }

    fn write_binary_expression(&mut self, binary: &BinaryExpression) {
        let operator = binary.operator();
        let left = binary.left();
        let right = binary.right();

        if operator.left_needs_parentheses(left) {
            self.write_symbol("(");
            self.write_expression(left);
            self.write_symbol(")");
        } else {
            self.write_expression(left);
        }

        if let Some(operator) = binary.get_token() {
            self.write_token(operator);
        } else {
            self.write_token(&Token::from_content(binary.operator().to_str()));
        }

        if operator.right_needs_parentheses(right) {
            self.write_symbol("(");
            self.write_expression(right);
            self.write_symbol(")");
        } else {
            self.write_expression(right);
        }
    }

    fn write_unary_expression(&mut self, unary: &UnaryExpression) {
        if let Some(operator) = unary.get_token() {
            self.write_token(operator);
        } else {
            self.write_token(&Token::from_content(unary.operator().to_str()));
        }

        let expression = unary.get_expression();
        match expression {
            Expression::Binary(binary) if !binary.operator().precedes_unary_expression() => {
                self.write_symbol("(");
                self.write_expression(expression);
                self.write_symbol(")");
            }
            _ => self.write_expression(expression),
        }
    }

    fn write_function(&mut self, function: &FunctionExpression) {
        if let Some(tokens) = function.get_tokens() {
            self.write_function_with_tokens(function, tokens);
        } else {
            self.write_function_with_tokens(function, &self.generate_function_tokens(function));
        }
    }

    fn write_function_call(&mut self, call: &FunctionCall) {
        if let Some(tokens) = call.get_tokens() {
            self.write_function_call_with_tokens(call, tokens);
        } else {
            self.write_function_call_with_tokens(call, &self.generate_function_call_tokens(call));
        }
    }

    fn write_field(&mut self, field: &FieldExpression) {
        if let Some(token) = field.get_token() {
            self.write_field_with_token(field, token);
        } else {
            self.write_field_with_token(field, &self.generate_field_token(field));
        }
    }

    fn write_index(&mut self, index: &IndexExpression) {
        if let Some(tokens) = index.get_tokens() {
            self.write_index_with_tokens(index, tokens);
        } else {
            self.write_index_with_tokens(index, &self.generate_index_tokens(index));
        }
    }

    fn write_if_expression(&mut self, if_expression: &IfExpression) {
        if let Some(token) = if_expression.get_tokens() {
            self.write_if_expression_with_token(if_expression, token);
        } else {
            self.write_if_expression_with_token(
                if_expression,
                &self.generate_if_tokens(if_expression),
            );
        }
    }

    fn write_table(&mut self, table: &TableExpression) {
        if let Some(tokens) = table.get_tokens() {
            self.write_table_with_tokens(table, tokens);
        } else {
            self.write_table_with_tokens(table, &self.generate_table_tokens(table));
        }
    }

    fn write_table_entry(&mut self, entry: &TableEntry) {
        match entry {
            TableEntry::Field(entry) => {
                if let Some(tokens) = entry.get_token() {
                    self.write_table_field_with_tokens(entry, tokens);
                } else {
                    self.write_table_field_with_tokens(
                        entry,
                        &self.generate_table_field_tokens(entry),
                    );
                }
            }
            TableEntry::Index(entry) => {
                if let Some(tokens) = entry.get_tokens() {
                    self.write_table_index_with_tokens(entry, tokens);
                } else {
                    self.write_table_index_with_tokens(
                        entry,
                        &self.generate_table_index_tokens(entry),
                    );
                }
            }
            TableEntry::Value(expression) => self.write_expression(expression),
        }
    }

    fn write_number(&mut self, number: &NumberExpression) {
        if let Some(token) = number.get_token() {
            self.write_token(token);
        } else {
            self.write_token(&Token::from_content(utils::write_number(number)));
        }
    }

    fn write_tuple_arguments(&mut self, arguments: &TupleArguments) {
        if let Some(tokens) = arguments.get_tokens() {
            self.write_tuple_arguments_with_tokens(arguments, tokens);
        } else {
            self.write_tuple_arguments_with_tokens(
                arguments,
                &self.generate_tuple_arguments_tokens(arguments),
            );
        }
    }

    fn write_string(&mut self, string: &StringExpression) {
        if let Some(token) = string.get_token() {
            self.write_token(token);
        } else {
            self.write_symbol(&utils::write_string(string.get_value()));
        }
    }

    fn write_interpolated_string(&mut self, interpolated_string: &InterpolatedStringExpression) {
        if let Some(tokens) = interpolated_string.get_tokens() {
            self.write_interpolated_string_with_tokens(interpolated_string, tokens);
        } else {
            self.write_interpolated_string_with_tokens(
                interpolated_string,
                &self.generate_interpolated_string_tokens(interpolated_string),
            );
        }
    }

    fn write_identifier(&mut self, identifier: &Identifier) {
        if let Some(token) = identifier.get_token() {
            let name_in_token = token.read(self.original_code);

            if name_in_token == identifier.get_name() {
                self.write_token(token);
            } else {
                let mut new_token = token.clone();
                new_token.replace_with_content(identifier.get_name().clone());
                self.write_token(&new_token);
            }
        } else {
            let name = identifier.get_name();
            self.write_symbol(name);
        }
    }

    fn write_parenthese(&mut self, parenthese: &ParentheseExpression) {
        if let Some(tokens) = parenthese.get_tokens() {
            self.write_parenthese_with_tokens(parenthese, tokens);
        } else {
            self.write_parenthese_with_tokens(
                parenthese,
                &self.generate_parenthese_tokens(parenthese),
            );
        }
    }

    fn write_type_cast(&mut self, type_cast: &TypeCastExpression) {
        if let Some(token) = type_cast.get_token() {
            self.write_type_cast_with_tokens(type_cast, token);
        } else {
            self.write_type_cast_with_tokens(type_cast, &self.generate_type_cast_token(type_cast));
        }
    }

    fn write_type_name(&mut self, type_name: &TypeName) {
        self.write_identifier(type_name.get_type_name());
        if let Some(parameters) = type_name.get_type_parameters() {
            if let Some(tokens) = parameters.get_tokens() {
                self.write_type_parameters_with_tokens(parameters, tokens);
            } else {
                self.write_type_parameters_with_tokens(
                    parameters,
                    &self.generate_type_parameters_tokens(parameters),
                );
            }
        }
    }

    fn write_type_field(&mut self, type_field: &TypeField) {
        if let Some(tokens) = type_field.get_token() {
            self.write_type_field_with_token(type_field, tokens);
        } else {
            self.write_type_field_with_token(
                type_field,
                &self.generate_type_field_token(type_field),
            );
        }
    }

    fn write_true_type(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("true");
        }
    }

    fn write_false_type(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("false");
        }
    }

    fn write_nil_type(&mut self, token: &Option<Token>) {
        if let Some(token) = token {
            self.write_token(token);
        } else {
            self.write_symbol("nil");
        }
    }

    fn write_string_type(&mut self, string_type: &StringType) {
        if let Some(token) = string_type.get_token() {
            self.write_token(token);
        } else {
            self.write_symbol(&utils::write_string(string_type.get_value()));
        }
    }

    fn write_array_type(&mut self, array: &ArrayType) {
        if let Some(tokens) = array.get_tokens() {
            self.write_array_type_with_tokens(array, tokens);
        } else {
            self.write_array_type_with_tokens(array, &self.generate_array_type_tokens(array));
        }
    }

    fn write_table_type(&mut self, table_type: &TableType) {
        if let Some(tokens) = table_type.get_tokens() {
            self.write_table_type_with_tokens(table_type, tokens);
        } else {
            self.write_table_type_with_tokens(
                table_type,
                &self.generate_table_type_tokens(table_type),
            );
        }
    }

    fn write_expression_type(&mut self, expression_type: &ExpressionType) {
        if let Some(tokens) = expression_type.get_tokens() {
            self.write_expression_type_with_tokens(expression_type, tokens);
        } else {
            self.write_expression_type_with_tokens(
                expression_type,
                &self.generate_expression_type_tokens(expression_type),
            );
        }
    }

    fn write_parenthese_type(&mut self, parenthese_type: &ParentheseType) {
        if let Some(tokens) = parenthese_type.get_tokens() {
            self.write_parenthese_type_with_tokens(parenthese_type, tokens);
        } else {
            self.write_parenthese_type_with_tokens(
                parenthese_type,
                &self.generate_parenthese_type_tokens(parenthese_type),
            );
        }
    }

    fn write_function_type(&mut self, function_type: &FunctionType) {
        if let Some(tokens) = function_type.get_tokens() {
            self.write_function_type_with_tokens(function_type, tokens);
        } else {
            self.write_function_type_with_tokens(
                function_type,
                &self.generate_function_type_tokens(function_type),
            );
        }
    }

    fn write_optional_type(&mut self, optional: &OptionalType) {
        if let Some(token) = optional.get_token() {
            self.write_optional_type_with_token(optional, token);
        } else {
            self.write_optional_type_with_token(
                optional,
                &self.generate_optional_type_token(optional),
            );
        }
    }

    fn write_intersection_type(&mut self, intersection: &IntersectionType) {
        if let Some(token) = intersection.get_token() {
            self.write_intersection_type_with_token(intersection, token);
        } else {
            self.write_intersection_type_with_token(
                intersection,
                &self.generate_intersection_type_token(intersection),
            );
        }
    }

    fn write_union_type(&mut self, union: &UnionType) {
        if let Some(token) = union.get_token() {
            self.write_union_type_with_token(union, token);
        } else {
            self.write_union_type_with_token(union, &self.generate_union_type_token(union));
        }
    }

    fn write_type_pack(&mut self, type_pack: &TypePack) {
        if let Some(tokens) = type_pack.get_tokens() {
            self.write_type_pack_with_tokens(type_pack, tokens);
        } else {
            self.write_type_pack_with_tokens(type_pack, &self.generate_type_pack_tokens(type_pack));
        }
    }

    fn write_variadic_type_pack(&mut self, variadic_type_pack: &VariadicTypePack) {
        self.push_str("...");
        self.write_type(variadic_type_pack.get_type());
    }

    fn write_generic_type_pack(&mut self, generic_type_pack: &GenericTypePack) {
        self.write_identifier(generic_type_pack.get_name());
        self.push_str("...");
    }
}

fn intersect_with_token(token: Token, list_length: usize) -> Vec<Token> {
    iter::repeat_with(|| token.clone())
        .take(list_length.saturating_sub(1))
        .collect()
}

#[cfg(test)]
mod test {
    use super::*;

    macro_rules! test_output {
        ($($name:ident => $code:literal),* $(,)?) => {
            $(
                #[test]
                fn $name() {
                    let parser = crate::Parser::default().preserve_tokens();
                    let block = parser.parse($code)
                        .expect(&format!("failed to parse `{}`", $code));

                    let mut generator = TokenBasedLuaGenerator::new($code);

                    generator.write_block(&block);

                    let output = generator.into_string();

                    assert_eq!($code, &output);
                }
            )*

            mod without_tokens {
                use super::*;
                $(
                    #[test]
                    fn $name() {
                        let parser = crate::Parser::default();
                        let block = parser.parse($code)
                            .expect(&format!("failed to parse `{}`", $code));

                        let mut generator = TokenBasedLuaGenerator::new($code);

                        generator.write_block(&block);

                        let output = generator.into_string();

                        let parsed_output_block = parser.parse(&output)
                            .expect(&format!("failed to parse generated code `{}`", &output));

                        pretty_assertions::assert_eq!(block, parsed_output_block);
                    }
                )*
            }
        };
    }

    test_output!(
        // statements
        assign => "var = true",
        assign_multiple => "var, var2 =\n\ttrue,\tfalse\n",
        empty_do => "do end\n",
        nested_do => "do\n    do end\nend\n",
        call_without_arguments => "call()",
        call_print => "print('hi')",
        call_print_with_string_argument => "print 'hi' -- no parentheses",
        call_function_with_table_multiline => "process {\n\targ = true,\n\tflag = false,\n}\n",
        call_method_without_arguments => "foo:bar()",
        call_method_with_arguments => "foo:bar(true, false)",
        call_string_format => "('foo'):rep(3)",
        call_math_floor => "math.floor(value)",
        call_with_index => "object[ key ](i)",
        compound_increment => "i += 1\n",
        empty_function_declaration => "function process()\nend",
        empty_static_function_declaration => "function Class .new()\nend",
        empty_method_function_declaration => "function Class : process()\nend",
        empty_nested_method_function_declaration => "function Class . foo.bar : help ()\nend",
        empty_function_declaration_with_params => "function process(a, b --[[ optional ]]) end",
        empty_variadic_function_declaration => "function process (...) end",
        empty_variadic_function_declaration_with_one_param => "function format (str, ... --[[ optional strings ]]) end",
        variadic_function_returns => "function identity(...)\n\treturn ...\nend\n",
        empty_generic_for => "for key, value in pairs(result) do\n\t-- help\nend",
        empty_generic_for_key_only => "for key in pairs(dict) do end",
        generic_for_with_next => "for key,value in next, dict do\n\tprint(key, value)\nend\n",
        empty_if => "if true then\nend",
        if_condition_return => "if condition then\n\treturn\nend",
        empty_if_with_empty_elseif => "if true then\nelseif false then\nend\n",
        empty_if_with_two_empty_elseif => "if a then\nelseif b then\nelseif c then\n\tprint(c)\nend\n",
        empty_if_with_empty_else => "if true then\nelse\nend\n",
        empty_if_with_else_block => "if true then\n\t-- help\nelse\n\treturn\nend\n",
        declare_one_variable => "local var\n",
        declare_two_variables => "local var, var2\n",
        local_assign_one_variable => "local var = true",
        local_assign_two_variables => "local var, var2 = true, false",
        local_empty_function => "local function process()\nend",
        local_empty_variadic_function => "local function process(...)\nend",
        local_empty_function_with_one_argument => "local function process( a )\nend",
        local_empty_function_with_two_arguments => "local function process(a, b)\nend",
        local_empty_variadic_function_with_two_arguments => "local function process(a, b, ...)\nend",
        local_identity_function => "local function identity(...)\n\treturn ...\nend",
        empty_numeric_for => "for i = 1, final do\nend\n",
        empty_numeric_for_with_step => "for i = 1, final, step do\nend\n",
        numeric_for => "for i = 1, #list do\n\tprocess(list[i])\nend",
        empty_repeat => "repeat until false",
        repeat_break_immediately => "repeat break until false",
        empty_while => "while true do end",
        while_break_immediately => "while true do\n\tbreak\nend",

        // last statements
        break_with_comment => "break -- exit loop",
        continue_with_comment => "continue -- skip to next iteration",
        empty_return => "return\n",

        // expressions
        return_true => "return true",
        return_false => "return false",
        return_nil => "return nil",
        return_single_quote_string => "return 'ok'",
        return_double_quote_string => "return \"ok\"",
        return_identifier => "return var",
        return_bracket_string => "return [[   [ok]   ]]",
        return_empty_interpolated_string => "return ``",
        return_interpolated_string_escape_curly_brace => "return `Open: \\{`",
        return_interpolated_string_followed_by_comment => "return `ok` -- comment",
        return_interpolated_string_with_true_value => "return `{ true }`",
        return_interpolated_string_with_true_value_and_prefix => "return `Result = { true }`",
        return_interpolated_string_with_true_value_and_suffix => "return `{ variable } !`",
        return_interpolated_string_with_various_segments => "return `Variable = { variable } ({ --[[len]] #variable })` -- display",
        return_empty_table => "return { }",
        return_table_with_field => "return { field = {} }",
        return_table_with_index => "return { [field] = {} }",
        return_list_of_one_element => "return { true, }",
        return_list_of_two_elements => "return { true, false }",
        return_mixed_table => "return { true, field = false, [\"hello\"] = true }",
        return_parenthese_call => "return ( call() )",
        return_variable_arguments => "return ...",
        return_unary_minus => "return - number",
        return_unary_length => "return #list\n",
        return_unary_not => "return not condition\n",
        return_binary_and => "return a and b",
        return_binary_or => "return a or b",
        return_binary_plus => "return 10 + 15",
        return_empty_function => "return function() end",
        return_empty_variadic_function => "return function(...)\nend",
        return_empty_function_with_one_argument => "return function( a )\nend",
        return_empty_function_with_two_arguments => "return function(a, b)\nend",
        return_empty_variadic_function_with_two_arguments => "return function(a, b, ...)\nend",
        return_identity_function => "return function(...)\n\treturn ...\nend",
        return_field => "return math.huge",
        return_field_ending_with_number => "return UDim2.new",
        return_field_split_on_lines => "return value.\n\tproperty\n\t.name",
    );

    #[test]
    fn inserts_a_new_line_after_a_comment_for_a_token() {
        let statement = RepeatStatement::new(Block::default(), true).with_tokens(RepeatTokens {
            repeat: Token::from_content("repeat")
                .with_trailing_trivia(TriviaKind::Comment.with_content("-- hello")),
            until: Token::from_content("until"),
        });

        let mut generator = TokenBasedLuaGenerator::new("");

        generator.write_repeat_statement(&statement);

        let output = generator.into_string();

        crate::Parser::default()
            .parse(&output)
            .unwrap_or_else(|_| panic!("failed to parse generated code `{}`", &output));
    }

    #[test]
    fn inserts_a_new_line_after_custom_added_comments() {
        let code = "call(a--comment\n\t,b\n)";
        let mut block = crate::Parser::default()
            .preserve_tokens()
            .parse(code)
            .unwrap();

        let call = match block.iter_mut_statements().last().unwrap() {
            Statement::Call(call) => call,
            _ => panic!("unexpected statement"),
        };
        let tuple = match call.mutate_arguments() {
            Arguments::Tuple(tuple) => tuple,
            _ => panic!("unexpected arguments"),
        };
        let mut tokens = tuple.get_tokens().unwrap().clone();

        tuple.iter_mut_values().for_each(|value| match value {
            Expression::Identifier(identifier) => {
                let name = identifier.mutate_name();
                let new_token = {
                    Token::from_content(name.to_owned())
                        .with_trailing_trivia(TriviaKind::Comment.with_content("--new comment"))
                };
                identifier.set_token(new_token);
            }
            _ => panic!("unexpected expression"),
        });

        // drop a comma and verify that the generator does not screw things up
        tokens.commas.pop();
        tuple.set_tokens(tokens);

        let mut generator = TokenBasedLuaGenerator::new(code);

        generator.write_block(&block);

        let output = generator.into_string();

        crate::Parser::default()
            .parse(&output)
            .unwrap_or_else(|_| panic!("failed to parse generated code `{}`", &output));

        insta::assert_snapshot!("inserts_a_new_line_after_custom_added_comments", output);
    }

    #[test]
    fn break_long_comments_on_new_lines() {
        let token = Token::from_content("")
            .with_leading_trivia(TriviaKind::Comment.with_content("-- first line"))
            .with_leading_trivia(TriviaKind::Comment.with_content("--[[\nnext comment ]]"));
        let block = Block::default().with_tokens(BlockTokens {
            semicolons: Default::default(),
            last_semicolon: Default::default(),
            final_token: Some(token),
        });

        let mut generator = TokenBasedLuaGenerator::new("");
        generator.write_block(&block);

        insta::assert_snapshot!(generator.into_string(), @r###"
        -- first line
        --[[
        next comment ]]
        "###);
    }
}
