use crate::generator::{utils, LuaGenerator};
use crate::nodes;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum StatementType {
    Assign,
    Do,
    Call,
    CompoundAssign,
    Function,
    GenericFor,
    If,
    LocalAssign,
    LocalFunction,
    NumericFor,
    Repeat,
    While,
    TypeDeclaration,
    Return,
    Break,
    Continue,
}

impl From<&nodes::Statement> for StatementType {
    fn from(statement: &nodes::Statement) -> Self {
        use nodes::Statement::*;
        match statement {
            Assign(_) => Self::Assign,
            Do(_) => Self::Do,
            Call(_) => Self::Call,
            CompoundAssign(_) => Self::CompoundAssign,
            Function(_) => Self::Function,
            GenericFor(_) => Self::GenericFor,
            If(_) => Self::If,
            LocalAssign(_) => Self::LocalAssign,
            LocalFunction(_) => Self::LocalFunction,
            NumericFor(_) => Self::NumericFor,
            Repeat(_) => Self::Repeat,
            While(_) => Self::While,
            TypeDeclaration(_) => Self::TypeDeclaration,
        }
    }
}

impl From<&nodes::LastStatement> for StatementType {
    fn from(statement: &nodes::LastStatement) -> Self {
        use nodes::LastStatement::*;
        match statement {
            Break(_) => Self::Break,
            Continue(_) => Self::Continue,
            Return(_) => Self::Return,
        }
    }
}

/// This implementation of [LuaGenerator](trait.LuaGenerator.html) attempts to produce Lua code as
/// readable as possible.
#[derive(Debug, Clone)]
pub struct ReadableLuaGenerator {
    column_span: usize,
    indentation: usize,
    current_line_length: usize,
    current_indentation: usize,
    output: String,
    last_push_length: usize,
    can_add_new_line_stack: Vec<bool>,
}

impl ReadableLuaGenerator {
    pub fn new(column_span: usize) -> Self {
        Self {
            column_span,
            indentation: 4,
            current_line_length: 0,
            current_indentation: 0,
            output: String::new(),
            last_push_length: 0,
            can_add_new_line_stack: Vec::new(),
        }
    }

    #[inline]
    fn can_add_new_line(&self) -> bool {
        self.can_add_new_line_stack.last().copied().unwrap_or(true)
    }

    #[inline]
    fn push_can_add_new_line(&mut self, value: bool) {
        self.can_add_new_line_stack.push(value);
    }

    #[inline]
    fn pop_can_add_new_line(&mut self) {
        self.can_add_new_line_stack.pop();
    }

    #[inline]
    fn push_indentation(&mut self) {
        self.current_indentation += 1;
    }

    #[inline]
    fn pop_indentation(&mut self) {
        self.current_indentation -= 1;
    }

    #[inline]
    fn write_indentation(&mut self) {
        let indentation = " ".repeat(self.indentation * self.current_indentation);
        self.raw_push_str(&indentation);
    }

    #[inline]
    fn push_new_line(&mut self) {
        self.output.push('\n');
        self.current_line_length = 0;
    }

    #[inline]
    fn fits_on_current_line(&self, length: usize) -> bool {
        self.current_line_length + length <= self.column_span
    }

    #[inline]
    fn push_space(&mut self) {
        self.output.push(' ');
        self.current_line_length += 1;
    }

    /// Appends a string to the current content of the LuaGenerator. A space may be added
    /// depending of the last character of the current content and the first character pushed.
    fn push_str(&mut self, content: &str) {
        if let Some(next_char) = content.chars().next() {
            self.push_space_if_needed(next_char, content.len());
            self.raw_push_str(content);
        }
    }

    /// Same as the `push_str` function, but for a single character.
    fn push_char(&mut self, character: char) {
        self.push_space_if_needed(character, 1);

        self.output.push(character);
        self.current_line_length += 1;
        self.last_push_length = 1;
    }

    #[inline]
    fn raw_push_str(&mut self, content: &str) {
        self.output.push_str(content);
        self.last_push_length = content.len();
        self.current_line_length += self.last_push_length;
    }

    #[inline]
    fn raw_push_char(&mut self, character: char) {
        self.output.push(character);
        self.last_push_length = 1;
        self.current_line_length += 1;
    }

    #[inline]
    fn needs_space(&self, next_character: char) -> bool {
        if let Some(previous) = self.output.chars().last() {
            utils::should_break_with_space(previous, next_character)
        } else {
            false
        }
    }

    #[inline]
    fn indent_and_write_block(&mut self, block: &nodes::Block) {
        self.push_indentation();
        self.write_block(block);
        self.pop_indentation();
    }

    fn push_new_line_if_needed(&mut self, pushed_length: usize) {
        if self.current_line_length == 0 && self.current_indentation != 0 {
            self.write_indentation();
        }

        if self.can_add_new_line() {
            if self.current_line_length >= self.column_span {
                self.push_new_line();
            } else {
                let total_length = self.current_line_length + pushed_length;

                if total_length > self.column_span {
                    self.push_new_line();
                }
            }
        }
    }

    fn push_space_if_needed(&mut self, next_character: char, pushed_length: usize) {
        if self.current_line_length == 0 && self.current_indentation != 0 {
            self.write_indentation();
        }

        if self.can_add_new_line() {
            if self.current_line_length >= self.column_span {
                self.push_new_line();
            } else {
                let total_length = self.current_line_length + pushed_length;

                if self.needs_space(next_character) {
                    if total_length + 1 > self.column_span {
                        self.push_new_line();
                    } else {
                        self.push_space();
                    }
                } else if total_length > self.column_span {
                    self.push_new_line();
                }
            }
        } else if self.needs_space(next_character) {
            self.push_space();
        }
    }

    /// This function only insert a space or a new line if the given predicate returns true. In
    /// the other case, the string is added to the current generator content.
    fn push_str_and_break_if<F>(&mut self, content: &str, predicate: F)
    where
        F: Fn(&str) -> bool,
    {
        if predicate(self.get_last_push_str()) {
            if self.fits_on_current_line(1 + content.len()) {
                self.push_space();
            } else {
                self.push_new_line();
            }
        } else if !self.fits_on_current_line(content.len()) {
            self.push_new_line();
        }
        self.raw_push_str(content);
    }

    fn get_last_push_str(&self) -> &str {
        self.output
            .get((self.output.len() - self.last_push_length)..)
            .unwrap_or("")
    }

    fn table_fits_on_line(&self, entries: &[nodes::TableEntry], _width: usize) -> bool {
        use nodes::TableEntry;

        // small list of simple expressions
        entries.len() < 4
            && entries.iter().all(|entry| match entry {
                TableEntry::Value(value) => self.is_small_expression(value),
                _ => false,
            })
            || entries.len() == 1
                && entries.iter().all(|entry| match entry {
                    TableEntry::Field(entry) => self.is_small_expression(entry.get_value()),
                    TableEntry::Index(entry) => {
                        self.is_small_expression(entry.get_key())
                            && self.is_small_expression(entry.get_value())
                    }
                    _ => false,
                })
    }

    fn is_small_expression(&self, expression: &nodes::Expression) -> bool {
        use nodes::Expression::*;
        match expression {
            True(_) | False(_) | Nil(_) | Identifier(_) | VariableArguments(_) | Number(_) => true,
            Table(table) => table.is_empty(),
            _ => false,
        }
    }

    fn write_function_parameters(
        &mut self,
        parameters: &[nodes::TypedIdentifier],
        is_variadic: bool,
        variadic_type: Option<&nodes::FunctionVariadicType>,
    ) {
        let mut parameters_length = parameters.iter().fold(0, |acc, parameter| {
            acc + parameter.get_name().len()
                + if parameter.has_type() {
                    // put a random estimation of the type probable length
                    10
                } else {
                    0
                }
        });
        // add a comma and a space between each parameter
        parameters_length += parameters.len() * 2;

        if is_variadic {
            // add the variadic argument symbol `...`
            parameters_length += 3;
            if parameters.len() > 1 {
                // add comma and space if needed
                parameters_length += 2;
            }
        }

        let last_index = parameters.len().saturating_sub(1);

        if self.fits_on_current_line(parameters_length) {
            parameters.iter().enumerate().for_each(|(index, variable)| {
                self.write_typed_identifier(variable);

                if index != last_index {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                }
            });

            if is_variadic {
                if !parameters.is_empty() {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                };
                self.raw_push_str("...");

                if let Some(variadic_type) = variadic_type {
                    self.raw_push_char(':');
                    self.raw_push_char(' ');
                    self.write_function_variadic_type(r#variadic_type);
                }
            };
        } else {
            self.push_indentation();

            parameters.iter().enumerate().for_each(|(index, variable)| {
                self.push_new_line();
                self.write_indentation();
                self.write_typed_identifier(variable);

                if index != last_index {
                    self.raw_push_char(',');
                }
            });

            if is_variadic {
                if !parameters.is_empty() {
                    self.raw_push_char(',');
                };
                self.push_new_line();
                self.write_indentation();
                self.raw_push_str("...");

                if let Some(variadic_type) = variadic_type {
                    self.raw_push_char(':');
                    self.raw_push_char(' ');
                    self.write_function_variadic_type(r#variadic_type);
                }
            };

            self.pop_indentation();
            self.push_new_line();
            self.write_indentation();
        }
    }

    fn write_variable(&mut self, variable: &nodes::Variable) {
        use nodes::Variable::*;
        match variable {
            Identifier(identifier) => self.push_str(identifier.get_name()),
            Field(field) => self.write_field(field),
            Index(index) => self.write_index(index),
        }
    }

    fn write_typed_identifier(&mut self, typed_identifier: &nodes::TypedIdentifier) {
        self.push_str(typed_identifier.get_name());

        if let Some(r#type) = typed_identifier.get_type() {
            self.push_char(':');
            self.push_space();
            self.write_type(r#type);
        }
    }

    fn write_function_return_type(&mut self, return_type: &nodes::FunctionReturnType) {
        match return_type {
            nodes::FunctionReturnType::Type(r#type) => self.write_type(r#type),
            nodes::FunctionReturnType::TypePack(type_pack) => self.write_type_pack(type_pack),
            nodes::FunctionReturnType::VariadicTypePack(variadic_type_pack) => {
                self.write_variadic_type_pack(variadic_type_pack);
            }
            nodes::FunctionReturnType::GenericTypePack(generic_type_pack) => {
                self.write_generic_type_pack(generic_type_pack);
            }
        }
    }

    fn write_function_return_type_suffix(&mut self, return_type: &nodes::FunctionReturnType) {
        self.raw_push_char(':');
        self.raw_push_char(' ');
        self.write_function_return_type(return_type);
    }

    fn write_expression_in_parentheses(&mut self, expression: &nodes::Expression) {
        self.push_char('(');
        self.write_expression(expression);
        self.push_char(')');
    }

    fn write_type_in_parentheses(&mut self, r#type: &nodes::Type) {
        self.push_char('(');
        self.write_type(r#type);
        self.push_char(')');
    }

    fn write_function_generics(&mut self, generics: &nodes::GenericParameters) {
        if generics.is_empty() {
            return;
        }
        self.push_char('<');
        let mut write_comma = false;
        for type_variable in generics.iter_type_variable() {
            if write_comma {
                self.push_char(',');
                self.push_char(' ');
            } else {
                write_comma = true;
            }
            self.write_identifier(type_variable);
        }
        for generic_pack in generics.iter_generic_type_pack() {
            if write_comma {
                self.push_char(',');
                self.push_char(' ');
            } else {
                write_comma = true;
            }
            self.write_generic_type_pack(generic_pack);
        }
        self.push_char('>');
    }
}

impl Default for ReadableLuaGenerator {
    fn default() -> Self {
        Self::new(80)
    }
}

impl LuaGenerator for ReadableLuaGenerator {
    fn into_string(self) -> String {
        self.output
    }

    fn write_block(&mut self, block: &nodes::Block) {
        let mut statements = block.iter_statements().peekable();

        while let Some(statement) = statements.next() {
            let current_type: StatementType = statement.into();

            self.push_can_add_new_line(false);
            self.write_statement(statement);

            if let Some(next_statement) = statements.peek() {
                if utils::starts_with_parenthese(next_statement)
                    && utils::ends_with_prefix(statement)
                {
                    self.push_char(';');
                }

                if current_type != (*next_statement).into() {
                    self.push_new_line();
                }
            }

            self.pop_can_add_new_line();
            self.push_new_line();
        }

        if let Some(last_statement) = block.get_last_statement() {
            if block.iter_statements().next().is_some() {
                self.push_new_line();
            }
            self.write_last_statement(last_statement);
            self.push_new_line();
        }
    }

    fn write_last_statement(&mut self, statement: &nodes::LastStatement) {
        use nodes::LastStatement::*;

        match statement {
            Break(_) => self.push_str("break"),
            Continue(_) => self.push_str("continue"),
            Return(expressions) => {
                self.push_str("return");
                self.push_can_add_new_line(false);
                let last_index = expressions.len().saturating_sub(1);

                if !expressions.is_empty() {
                    self.raw_push_char(' ');
                }

                expressions
                    .iter_expressions()
                    .enumerate()
                    .for_each(|(index, expression)| {
                        self.write_expression(expression);

                        if index != last_index {
                            self.raw_push_char(',');
                            self.raw_push_char(' ');
                        }
                    });

                self.pop_can_add_new_line();
            }
        }
    }

    fn write_assign_statement(&mut self, assign: &nodes::AssignStatement) {
        self.push_can_add_new_line(false);

        let variables = assign.get_variables();
        let last_variable_index = variables.len() - 1;
        variables.iter().enumerate().for_each(|(index, variable)| {
            self.write_variable(variable);

            if index != last_variable_index {
                self.raw_push_char(',');
                self.raw_push_char(' ');
            }
        });

        self.raw_push_str(" = ");

        let last_value_index = assign.values_len() - 1;
        assign.iter_values().enumerate().for_each(|(index, value)| {
            self.write_expression(value);

            if index != last_value_index {
                self.raw_push_char(',');
                self.raw_push_char(' ');
            }
        });

        self.pop_can_add_new_line();
    }

    fn write_local_assign(&mut self, assign: &nodes::LocalAssignStatement) {
        self.push_str("local ");

        self.push_can_add_new_line(false);

        let variables = assign.get_variables();
        let last_variable_index = variables.len().saturating_sub(1);

        variables.iter().enumerate().for_each(|(index, variable)| {
            self.write_typed_identifier(variable);

            if index != last_variable_index {
                self.raw_push_char(',');
                self.raw_push_char(' ');
            }
        });

        if assign.has_values() {
            self.raw_push_str(" = ");

            let last_value_index = assign.values_len() - 1;

            assign.iter_values().enumerate().for_each(|(index, value)| {
                self.write_expression(value);

                if index != last_value_index {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                }
            });
        };

        self.pop_can_add_new_line();
    }

    fn write_compound_assign(&mut self, assign: &nodes::CompoundAssignStatement) {
        self.push_can_add_new_line(false);

        self.write_variable(assign.get_variable());

        self.raw_push_char(' ');
        self.raw_push_str(assign.get_operator().to_str());
        self.push_space();

        self.write_expression(assign.get_value());

        self.pop_can_add_new_line();
    }

    fn write_local_function(&mut self, function: &nodes::LocalFunctionStatement) {
        self.push_str("local function ");
        self.raw_push_str(function.get_name());

        if let Some(generics) = function.get_generic_parameters() {
            self.write_function_generics(generics);
        }

        self.raw_push_char('(');

        let parameters = function.get_parameters();
        self.write_function_parameters(
            parameters,
            function.is_variadic(),
            function.get_variadic_type(),
        );
        self.raw_push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.write_function_return_type_suffix(return_type);
        }

        let block = function.get_block();

        if block.is_empty() {
            self.raw_push_str(" end");
        } else {
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_generic_for(&mut self, generic_for: &nodes::GenericForStatement) {
        self.push_str("for ");

        let identifiers = generic_for.get_identifiers();
        let last_identifier_index = identifiers.len().saturating_sub(1);
        identifiers
            .iter()
            .enumerate()
            .for_each(|(index, identifier)| {
                self.write_typed_identifier(identifier);

                if index != last_identifier_index {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                }
            });

        self.raw_push_str(" in ");

        let expressions = generic_for.get_expressions();
        let last_expression_index = expressions.len().saturating_sub(1);
        expressions
            .iter()
            .enumerate()
            .for_each(|(index, expression)| {
                self.write_expression(expression);

                if index != last_expression_index {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                }
            });

        let block = generic_for.get_block();

        if block.is_empty() {
            self.raw_push_str(" do end");
        } else {
            self.push_str("do");
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_numeric_for(&mut self, numeric_for: &nodes::NumericForStatement) {
        self.push_str("for ");

        self.write_typed_identifier(numeric_for.get_identifier());
        self.raw_push_char(' ');
        self.raw_push_char('=');
        self.raw_push_char(' ');
        self.write_expression(numeric_for.get_start());
        self.raw_push_char(',');
        self.raw_push_char(' ');
        self.write_expression(numeric_for.get_end());

        if let Some(step) = numeric_for.get_step() {
            self.raw_push_char(',');
            self.raw_push_char(' ');
            self.write_expression(step);
        }

        let block = numeric_for.get_block();

        if block.is_empty() {
            self.raw_push_str(" do end");
        } else {
            self.push_str("do");
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_if_statement(&mut self, if_statement: &nodes::IfStatement) {
        let branches = if_statement.get_branches();

        branches.iter().enumerate().for_each(|(index, branch)| {
            if index == 0 {
                self.push_str("if ");
            } else {
                self.push_str("elseif ");
            }

            self.write_expression(branch.get_condition());
            self.raw_push_str(" then");
            self.push_new_line();
            self.indent_and_write_block(branch.get_block());
        });

        if let Some(else_block) = if_statement.get_else_block() {
            self.push_str("else");
            self.push_new_line();
            self.indent_and_write_block(else_block);
        }

        self.push_str("end");
    }

    fn write_function_statement(&mut self, function: &nodes::FunctionStatement) {
        self.push_str("function ");
        let name = function.get_name();

        self.raw_push_str(name.get_name().get_name());
        name.get_field_names().iter().for_each(|field| {
            self.raw_push_char('.');
            self.raw_push_str(field.get_name());
        });

        if let Some(method) = name.get_method() {
            self.raw_push_char(':');
            self.raw_push_str(method.get_name());
        }

        if let Some(generics) = function.get_generic_parameters() {
            self.write_function_generics(generics);
        }

        self.raw_push_char('(');
        self.write_function_parameters(
            function.get_parameters(),
            function.is_variadic(),
            function.get_variadic_type(),
        );
        self.raw_push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.write_function_return_type_suffix(return_type);
        }

        let block = function.get_block();

        if block.is_empty() {
            self.raw_push_str(" end");
        } else {
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_do_statement(&mut self, do_statement: &nodes::DoStatement) {
        let block = do_statement.get_block();

        if block.is_empty() {
            self.push_str("do end");
        } else {
            self.push_str("do");
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_repeat_statement(&mut self, repeat: &nodes::RepeatStatement) {
        self.push_str("repeat");

        let block = repeat.get_block();

        if block.is_empty() {
            self.raw_push_str(" until ");
        } else {
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("until ");
        }

        self.write_expression(repeat.get_condition());
    }

    fn write_while_statement(&mut self, while_statement: &nodes::WhileStatement) {
        self.push_str("while");
        self.push_can_add_new_line(false);
        self.write_expression(while_statement.get_condition());
        self.pop_can_add_new_line();

        let block = while_statement.get_block();

        if block.is_empty() {
            self.raw_push_str(" do end");
        } else {
            self.raw_push_str(" do");
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_type_declaration_statement(&mut self, statement: &nodes::TypeDeclarationStatement) {
        if statement.is_exported() {
            self.push_str("export");
        }
        self.push_can_add_new_line(false);
        self.push_str("type");

        self.write_identifier(statement.get_name());

        if let Some(generic_parameters) = statement
            .get_generic_parameters()
            .filter(|generic_parameters| !generic_parameters.is_empty())
        {
            self.push_char('<');
            let last_index = generic_parameters.len().saturating_sub(1);
            for (i, parameter) in generic_parameters.iter().enumerate() {
                use nodes::GenericParameterRef;

                match parameter {
                    GenericParameterRef::TypeVariable(identifier) => {
                        self.write_identifier(identifier);
                    }
                    GenericParameterRef::TypeVariableWithDefault(identifier_with_default) => {
                        self.write_identifier(identifier_with_default.get_type_variable());
                        self.push_char('=');
                        self.write_type(identifier_with_default.get_default_type());
                    }
                    GenericParameterRef::GenericTypePack(generic_type_pack) => {
                        self.write_generic_type_pack(generic_type_pack);
                    }
                    GenericParameterRef::GenericTypePackWithDefault(generic_pack_with_default) => {
                        self.write_generic_type_pack(
                            generic_pack_with_default.get_generic_type_pack(),
                        );
                        self.push_char('=');
                        self.write_generic_type_pack_default(
                            generic_pack_with_default.get_default_type(),
                        );
                    }
                }

                if i != last_index {
                    self.push_char(',');
                    self.push_char(' ');
                }
            }
            self.push_char('>');
        }

        self.push_char(' ');
        self.push_char('=');
        self.push_char(' ');

        self.pop_can_add_new_line();

        self.write_type(statement.get_type());
    }

    fn write_false_expression(&mut self, _token: &Option<nodes::Token>) {
        self.push_str("false");
    }

    fn write_true_expression(&mut self, _token: &Option<nodes::Token>) {
        self.push_str("true");
    }

    fn write_nil_expression(&mut self, _token: &Option<nodes::Token>) {
        self.push_str("nil");
    }

    fn write_variable_arguments_expression(&mut self, _token: &Option<nodes::Token>) {
        self.push_str_and_break_if("...", utils::break_variable_arguments);
    }

    fn write_binary_expression(&mut self, binary: &nodes::BinaryExpression) {
        let operator = binary.operator();
        let left = binary.left();
        let right = binary.right();

        if operator.left_needs_parentheses(left) {
            self.write_expression_in_parentheses(left);
        } else {
            self.write_expression(left);
        }

        self.push_space();
        self.push_str(binary.operator().to_str());
        self.push_space();

        if operator.right_needs_parentheses(right) {
            self.write_expression_in_parentheses(right);
        } else {
            self.write_expression(right);
        }
    }

    fn write_unary_expression(&mut self, unary: &nodes::UnaryExpression) {
        use nodes::{Expression, UnaryOperator::*};

        match unary.operator() {
            Length => self.push_char('#'),
            Minus => self.push_str_and_break_if("-", utils::break_minus),
            Not => self.push_str("not "),
        }

        let expression = unary.get_expression();

        match expression {
            Expression::Binary(binary) if !binary.operator().precedes_unary_expression() => {
                self.write_expression_in_parentheses(expression);
            }
            _ => self.write_expression(expression),
        }
    }

    fn write_function(&mut self, function: &nodes::FunctionExpression) {
        self.push_str("function");

        if let Some(generics) = function.get_generic_parameters() {
            self.write_function_generics(generics);
        }

        self.push_char('(');

        let parameters = function.get_parameters();
        self.write_function_parameters(
            parameters,
            function.is_variadic(),
            function.get_variadic_type(),
        );
        self.raw_push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.write_function_return_type_suffix(return_type);
        }

        let block = function.get_block();

        if block.is_empty() {
            self.raw_push_str(" end");
        } else {
            self.push_new_line();
            self.indent_and_write_block(block);
            self.push_str("end");
        }
    }

    fn write_function_call(&mut self, call: &nodes::FunctionCall) {
        self.push_can_add_new_line(false);
        self.write_prefix(call.get_prefix());

        if let Some(method) = &call.get_method() {
            self.push_char(':');
            self.push_str(method.get_name());
        }

        self.write_arguments(call.get_arguments());

        self.pop_can_add_new_line();
    }

    fn write_tuple_arguments(&mut self, arguments: &nodes::TupleArguments) {
        self.raw_push_char('(');

        let last_index = arguments.len().saturating_sub(1);
        arguments
            .iter_values()
            .enumerate()
            .for_each(|(index, expression)| {
                self.write_expression(expression);

                if index != last_index {
                    self.raw_push_char(',');
                    self.raw_push_char(' ');
                }
            });

        self.push_char(')');
    }

    fn write_field(&mut self, field: &nodes::FieldExpression) {
        self.push_can_add_new_line(false);
        self.write_prefix(field.get_prefix());
        self.pop_can_add_new_line();

        self.push_new_line_if_needed(1);
        self.raw_push_char('.');
        self.raw_push_str(field.get_field().get_name());
    }

    fn write_index(&mut self, index: &nodes::IndexExpression) {
        self.push_can_add_new_line(false);

        self.write_prefix(index.get_prefix());

        self.push_char('[');
        self.write_expression(index.get_index());
        self.push_char(']');

        self.pop_can_add_new_line();
    }

    fn write_if_expression(&mut self, if_expression: &nodes::IfExpression) {
        self.push_str("if");
        self.write_expression(if_expression.get_condition());

        if if_expression.has_elseif_branch() {
            self.push_indentation();

            self.push_new_line();
            self.write_indentation();
            self.push_str("then");
            self.write_expression(if_expression.get_result());

            for branch in if_expression.iter_branches() {
                self.push_new_line();
                self.write_indentation();
                self.push_str("elseif");
                self.write_expression(branch.get_condition());

                self.push_new_line();
                self.write_indentation();
                self.push_str("then");
                self.write_expression(branch.get_result());
            }

            self.push_new_line();
            self.write_indentation();
            self.push_str("else");
            self.write_expression(if_expression.get_else_result());

            self.pop_indentation();
        } else {
            self.push_str("then");
            self.write_expression(if_expression.get_result());
            self.push_str("else");
            self.write_expression(if_expression.get_else_result());
        }
    }

    fn write_table(&mut self, table: &nodes::TableExpression) {
        self.push_char('{');

        let entries = table.get_entries();
        let table_len = entries.len();

        if table_len == 0 {
            self.raw_push_char('}');
        } else {
            let column_space = self.column_span.saturating_sub(self.current_line_length);
            if self.table_fits_on_line(entries, column_space) {
                let last_index = table_len.saturating_sub(1);

                entries.iter().enumerate().for_each(|(index, entry)| {
                    self.write_table_entry(entry);

                    if index != last_index {
                        self.raw_push_char(',');
                        self.raw_push_char(' ');
                    }
                });
            } else {
                self.push_indentation();

                entries.iter().for_each(|entry| {
                    self.push_new_line();
                    self.write_indentation();
                    self.write_table_entry(entry);

                    self.raw_push_char(',');
                });

                self.pop_indentation();
                self.push_new_line();
            }

            self.push_char('}');
        }
    }

    fn write_table_entry(&mut self, entry: &nodes::TableEntry) {
        match entry {
            nodes::TableEntry::Field(entry) => {
                self.raw_push_str(entry.get_field().get_name());
                self.raw_push_str(" = ");
                self.write_expression(entry.get_value());
            }
            nodes::TableEntry::Index(entry) => {
                self.raw_push_char('[');
                self.push_can_add_new_line(false);
                self.write_expression(entry.get_key());
                self.pop_can_add_new_line();
                self.raw_push_str("] = ");
                self.write_expression(entry.get_value());
            }
            nodes::TableEntry::Value(expression) => self.write_expression(expression),
        }
    }

    fn write_number(&mut self, number: &nodes::NumberExpression) {
        self.push_str(&utils::write_number(number));
    }

    fn write_string(&mut self, string: &nodes::StringExpression) {
        let result = utils::write_string(string.get_value());
        if result.starts_with('[') {
            self.push_str_and_break_if(&result, utils::break_long_string);
        } else {
            self.push_str(&result);
        }
    }

    fn write_interpolated_string(
        &mut self,
        interpolated_string: &nodes::InterpolatedStringExpression,
    ) {
        self.push_char('`');

        for segment in interpolated_string.iter_segments() {
            match segment {
                nodes::InterpolationSegment::String(string_segment) => {
                    self.raw_push_str(&utils::write_interpolated_string_segment(string_segment));
                }
                nodes::InterpolationSegment::Value(value) => {
                    self.raw_push_char('{');
                    // add space when value segment is a table
                    let expression = value.get_expression();
                    if utils::starts_with_table(expression).is_some() {
                        self.raw_push_char(' ');
                    }
                    self.write_expression(expression);
                    self.push_char('}');
                }
            }
        }

        self.raw_push_char('`');
    }

    fn write_identifier(&mut self, identifier: &nodes::Identifier) {
        self.push_str(identifier.get_name());
    }

    fn write_parenthese(&mut self, parenthese: &nodes::ParentheseExpression) {
        self.push_char('(');
        self.push_can_add_new_line(false);

        self.write_expression(parenthese.inner_expression());

        self.pop_can_add_new_line();
        self.push_char(')');
    }

    fn write_type_cast(&mut self, type_cast: &nodes::TypeCastExpression) {
        let inner_expression = type_cast.get_expression();

        if nodes::TypeCastExpression::needs_parentheses(inner_expression) {
            self.push_char('(');
            self.push_can_add_new_line(false);
            self.write_expression(inner_expression);
            self.pop_can_add_new_line();
            self.push_char(')');
        } else {
            self.write_expression(inner_expression);
        }

        self.push_can_add_new_line(false);
        self.push_str("::");
        self.write_type(type_cast.get_type());
        self.pop_can_add_new_line();
    }

    fn write_type_name(&mut self, type_name: &nodes::TypeName) {
        self.write_identifier(type_name.get_type_name());
        if let Some(parameters) = type_name.get_type_parameters() {
            self.push_char('<');
            self.push_can_add_new_line(false);
            let last_index = parameters.len().saturating_sub(1);
            for (index, parameter) in parameters.iter().enumerate() {
                self.write_type_parameter(parameter);
                if index != last_index {
                    self.push_char(',');
                    self.push_char(' ');
                }
            }

            self.pop_can_add_new_line();
            self.push_char('>');
        }
    }

    fn write_type_field(&mut self, type_field: &nodes::TypeField) {
        self.write_identifier(type_field.get_namespace());
        self.push_new_line_if_needed(1);
        self.raw_push_char('.');
        self.write_type_name(type_field.get_type_name());
    }

    fn write_true_type(&mut self, _: &Option<nodes::Token>) {
        self.push_str("true");
    }

    fn write_false_type(&mut self, _: &Option<nodes::Token>) {
        self.push_str("false");
    }

    fn write_nil_type(&mut self, _: &Option<nodes::Token>) {
        self.push_str("nil");
    }

    fn write_string_type(&mut self, string_type: &nodes::StringType) {
        let result = utils::write_string(string_type.get_value());
        if result.starts_with('[') {
            self.push_str_and_break_if(&result, utils::break_long_string);
        } else {
            self.push_str(&result);
        }
    }

    fn write_array_type(&mut self, array: &nodes::ArrayType) {
        self.push_char('{');
        self.write_type(array.get_element_type());
        self.push_char('}');
    }

    fn write_table_type(&mut self, table_type: &nodes::TableType) {
        self.push_char('{');

        let last_index = table_type.len().saturating_sub(1);
        for (index, property) in table_type.iter_entries().enumerate() {
            match property {
                nodes::TableEntryType::Property(property) => {
                    self.write_identifier(property.get_identifier());
                    self.push_char(':');
                    self.push_char(' ');
                    self.write_type(property.get_type());
                }
                nodes::TableEntryType::Literal(property) => {
                    self.push_char('[');
                    self.write_string_type(property.get_string());
                    self.push_char(']');
                    self.push_char(':');
                    self.push_char(' ');
                    self.write_type(property.get_type());
                }
                nodes::TableEntryType::Indexer(indexer) => {
                    self.push_char('[');

                    let key_type = indexer.get_key_type();

                    let need_parentheses = matches!(
                        key_type,
                        nodes::Type::Optional(_)
                            | nodes::Type::Intersection(_)
                            | nodes::Type::Union(_)
                    );

                    if need_parentheses {
                        self.push_char('(');
                        self.write_type(key_type);
                        self.push_char(')');
                    } else {
                        self.write_type(key_type);
                    }

                    self.push_char(']');
                    self.push_char(':');
                    self.push_char(' ');
                    self.write_type(indexer.get_value_type());
                }
            }
            if index != last_index {
                self.push_char(',');
                self.push_char(' ');
            }
        }

        self.push_char('}');
    }

    fn write_expression_type(&mut self, expression_type: &nodes::ExpressionType) {
        self.push_str("typeof(");
        self.write_expression(expression_type.get_expression());
        self.push_char(')');
    }

    fn write_parenthese_type(&mut self, parenthese_type: &nodes::ParentheseType) {
        self.write_type_in_parentheses(parenthese_type.get_inner_type());
    }

    fn write_function_type(&mut self, function_type: &nodes::FunctionType) {
        if let Some(generics) = function_type.get_generic_parameters() {
            self.write_function_generics(generics);
        }

        self.push_char('(');

        let last_index = function_type.argument_len().saturating_sub(1);

        for (index, argument) in function_type.iter_arguments().enumerate() {
            if let Some(name) = argument.get_name() {
                self.write_identifier(name);
                self.push_char(':');
            }
            self.write_type(argument.get_type());

            if index != last_index {
                self.push_char(',');
                self.push_space();
            }
        }

        if let Some(variadic_argument_type) = function_type.get_variadic_argument_type() {
            if function_type.argument_len() > 0 {
                self.push_char(',');
                self.push_space();
            }
            self.write_variadic_argument_type(variadic_argument_type);
        }

        self.push_str(") -> ");
        self.write_function_return_type(function_type.get_return_type());
    }

    fn write_optional_type(&mut self, optional: &nodes::OptionalType) {
        let inner_type = optional.get_inner_type();
        if nodes::OptionalType::needs_parentheses(inner_type) {
            self.write_type_in_parentheses(inner_type);
        } else {
            self.write_type(inner_type);
        }
        self.push_char('?');
    }

    fn write_intersection_type(&mut self, intersection: &nodes::IntersectionType) {
        if intersection.has_leading_token() {
            self.push_char('&');
        }

        let length = intersection.len();
        let last_index = length.saturating_sub(1);

        for (i, r#type) in intersection.iter_types().enumerate() {
            if i != 0 {
                self.push_char('&');
            }

            let need_parentheses = if i == last_index {
                nodes::IntersectionType::last_needs_parentheses(r#type)
            } else {
                nodes::IntersectionType::intermediate_needs_parentheses(r#type)
            };

            if need_parentheses {
                self.write_type_in_parentheses(r#type);
            } else {
                self.write_type(r#type);
            }
        }
    }

    fn write_union_type(&mut self, union: &nodes::UnionType) {
        let length = union.len();
        let last_index = length.saturating_sub(1);

        if union.has_leading_token() {
            self.push_char('|');
            self.push_space();
        }

        for (i, r#type) in union.iter_types().enumerate() {
            if i != 0 {
                self.push_space();
                self.push_char('|');
                self.push_space();
            }

            let need_parentheses = if i == last_index {
                nodes::UnionType::last_needs_parentheses(r#type)
            } else {
                nodes::UnionType::intermediate_needs_parentheses(r#type)
            };

            if need_parentheses {
                self.write_type_in_parentheses(r#type);
            } else {
                self.write_type(r#type);
            }
        }
    }

    fn write_type_pack(&mut self, type_pack: &nodes::TypePack) {
        self.push_char('(');

        let last_index = type_pack.len().saturating_sub(1);

        for (index, r#type) in type_pack.into_iter().enumerate() {
            self.write_type(r#type);
            if index != last_index {
                self.push_char(',');
            }
        }

        if let Some(variadic_argument_type) = type_pack.get_variadic_type() {
            if !type_pack.is_empty() {
                self.push_char(',');
            }
            self.write_variadic_argument_type(variadic_argument_type);
        }

        self.push_char(')');
    }

    fn write_variadic_type_pack(&mut self, variadic_type_pack: &nodes::VariadicTypePack) {
        self.push_str("...");
        self.write_type(variadic_type_pack.get_type());
    }

    fn write_generic_type_pack(&mut self, generic_type_pack: &nodes::GenericTypePack) {
        self.write_identifier(generic_type_pack.get_name());
        self.push_str("...");
    }
}
