use crate::generator::{utils, LuaGenerator};
use crate::nodes;

/// This implementation of [LuaGenerator](trait.LuaGenerator.html) attempts to produce Lua code as
/// small as possible. It is not meant to be read by humans.
#[derive(Debug, Clone)]
pub struct DenseLuaGenerator {
    column_span: usize,
    current_line_length: usize,
    output: String,
    last_push_length: usize,
}

impl DenseLuaGenerator {
    /// Creates a generator that will wrap the code on a new line after the amount of
    /// characters given by the `column_span` argument.
    pub fn new(column_span: usize) -> Self {
        Self {
            column_span,
            current_line_length: 0,
            output: String::new(),
            last_push_length: 0,
        }
    }

    /// Appends a string to the current content of the DenseLuaGenerator. A space may be added
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

    /// This function pushes a character into the string, without appending a new line
    /// or a space between the last pushed content.
    fn merge_char(&mut self, character: char) {
        if self.fits_on_current_line(1) {
            self.raw_push_char(character);
        } else {
            let last_push_content = self.get_last_push_str().to_owned();
            (0..self.last_push_length).for_each(|_| {
                self.output.pop();
            });

            let mut last_char = self.output.pop();

            while let Some(' ') = last_char {
                last_char = self.output.pop();
            }

            if let Some(last_char) = last_char {
                self.output.push(last_char);
            }

            self.output.push('\n');
            self.output.push_str(&last_push_content);
            self.output.push(character);
            self.last_push_length += 1;
            self.current_line_length = self.last_push_length;
        }
    }

    fn push_new_line_if_needed(&mut self, pushed_length: usize) {
        if self.current_line_length >= self.column_span {
            self.push_new_line();
        } else {
            let total_length = self.current_line_length + pushed_length;

            if total_length > self.column_span {
                self.push_new_line();
            }
        }
    }

    fn push_space_if_needed(&mut self, next_character: char, pushed_length: usize) {
        if self.current_line_length >= self.column_span {
            self.push_new_line();
        } else {
            let total_length = self.current_line_length + pushed_length;

            if self.needs_space(next_character) {
                if total_length + 1 > self.column_span {
                    self.push_new_line();
                } else {
                    self.output.push(' ');
                    self.current_line_length += 1;
                }
            } else if total_length > self.column_span {
                self.push_new_line();
            }
        }
    }

    #[inline]
    fn push_new_line(&mut self) {
        self.output.push('\n');
        self.current_line_length = 0;
    }

    #[inline]
    fn push_space(&mut self) {
        self.output.push(' ');
        self.current_line_length += 1;
    }

    #[inline]
    fn fits_on_current_line(&self, length: usize) -> bool {
        self.current_line_length + length <= self.column_span
    }

    #[inline]
    fn needs_space(&self, next_character: char) -> bool {
        if let Some(previous) = self.output.chars().last() {
            utils::should_break_with_space(previous, next_character)
        } else {
            false
        }
    }

    /// Consumes the LuaGenerator and produce a String object.
    pub fn into_string(self) -> String {
        self.output
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

    /// Same as `push_str_and_break_if` but for a single character
    fn push_char_and_break_if<F>(&mut self, content: char, predicate: F)
    where
        F: Fn(&str) -> bool,
    {
        if predicate(self.get_last_push_str()) {
            if self.fits_on_current_line(2) {
                self.push_space();
            } else {
                self.push_new_line();
            }
        } else if !self.fits_on_current_line(1) {
            self.push_new_line();
        }
        self.raw_push_char(content);
    }

    fn get_last_push_str(&self) -> &str {
        self.output
            .get((self.output.len() - self.last_push_length)..)
            .unwrap_or("")
    }

    fn write_function_parameters(
        &mut self,
        parameters: &[nodes::TypedIdentifier],
        is_variadic: bool,
        variadic_type: Option<&nodes::FunctionVariadicType>,
    ) {
        let last_index = parameters.len().saturating_sub(1);

        parameters.iter().enumerate().for_each(|(index, variable)| {
            self.write_typed_identifier(variable);

            if index != last_index {
                self.push_char(',');
            }
        });

        if is_variadic {
            if !parameters.is_empty() {
                self.push_char(',');
            };
            self.push_str("...");

            if let Some(variadic_type) = variadic_type {
                self.push_char(':');
                self.write_function_variadic_type(variadic_type);
            }
        };
    }

    fn write_typed_identifier(&mut self, typed_identifier: &nodes::TypedIdentifier) {
        self.push_str(typed_identifier.get_name());

        if let Some(r#type) = typed_identifier.get_type() {
            self.push_char(':');
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
            } else {
                write_comma = true;
            }
            self.write_identifier(type_variable);
        }
        for generic_pack in generics.iter_generic_type_pack() {
            if write_comma {
                self.push_char(',');
            } else {
                write_comma = true;
            }
            self.write_generic_type_pack(generic_pack);
        }
        self.push_char('>');
    }
}

impl Default for DenseLuaGenerator {
    fn default() -> Self {
        Self::new(80)
    }
}

impl LuaGenerator for DenseLuaGenerator {
    /// Consumes the LuaGenerator and produce a String object.
    fn into_string(self) -> String {
        self.output
    }

    fn write_block(&mut self, block: &nodes::Block) {
        let mut statements = block.iter_statements().peekable();

        while let Some(statement) = statements.next() {
            self.write_statement(statement);

            if let Some(next_statement) = statements.peek() {
                if utils::starts_with_parenthese(next_statement)
                    && utils::ends_with_prefix(statement)
                {
                    self.push_char(';');
                }
            }
        }

        if let Some(last_statement) = block.get_last_statement() {
            self.write_last_statement(last_statement);
        }
    }

    fn write_assign_statement(&mut self, assign: &nodes::AssignStatement) {
        let variables = assign.get_variables();
        let last_variable_index = variables.len().saturating_sub(1);

        variables.iter().enumerate().for_each(|(index, variable)| {
            self.write_variable(variable);

            if index != last_variable_index {
                self.push_char(',');
            }
        });

        self.push_char_and_break_if('=', utils::break_equal);

        let last_value_index = assign.values_len().saturating_sub(1);

        assign.iter_values().enumerate().for_each(|(index, value)| {
            self.write_expression(value);

            if index != last_value_index {
                self.push_char(',');
            }
        });
    }

    fn write_do_statement(&mut self, do_statement: &nodes::DoStatement) {
        self.push_str("do");
        self.write_block(do_statement.get_block());
        self.push_str("end");
    }

    fn write_generic_for(&mut self, generic_for: &nodes::GenericForStatement) {
        self.push_str("for");

        let identifiers = generic_for.get_identifiers();
        let last_identifier_index = identifiers.len().saturating_sub(1);
        identifiers
            .iter()
            .enumerate()
            .for_each(|(index, identifier)| {
                self.write_typed_identifier(identifier);

                if index != last_identifier_index {
                    self.push_char(',');
                }
            });
        self.push_str("in");

        let expressions = generic_for.get_expressions();
        let last_expression_index = expressions.len().saturating_sub(1);
        expressions
            .iter()
            .enumerate()
            .for_each(|(index, expression)| {
                self.write_expression(expression);

                if index != last_expression_index {
                    self.push_char(',');
                }
            });

        self.push_str("do");
        self.write_block(generic_for.get_block());
        self.push_str("end");
    }

    fn write_if_statement(&mut self, if_statement: &nodes::IfStatement) {
        let branches = if_statement.get_branches();

        branches.iter().enumerate().for_each(|(index, branch)| {
            if index == 0 {
                self.push_str("if");
            } else {
                self.push_str("elseif");
            }

            self.write_expression(branch.get_condition());
            self.push_str("then");
            self.write_block(branch.get_block());
        });

        if let Some(else_block) = if_statement.get_else_block() {
            self.push_str("else");
            self.write_block(else_block)
        }

        self.push_str("end");
    }

    fn write_function_statement(&mut self, function: &nodes::FunctionStatement) {
        self.push_str("function");
        let name = function.get_name();

        self.push_str(name.get_name().get_name());
        name.get_field_names().iter().for_each(|field| {
            self.push_new_line_if_needed(1);
            self.raw_push_char('.');
            self.push_str(field.get_name());
        });

        if let Some(method) = name.get_method() {
            self.push_char(':');
            self.push_str(method.get_name());
        }

        if let Some(generics) = function.get_generic_parameters() {
            self.write_function_generics(generics);
        }

        self.push_char('(');
        self.write_function_parameters(
            function.get_parameters(),
            function.is_variadic(),
            function.get_variadic_type(),
        );
        self.push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.push_char(':');
            self.write_function_return_type(return_type);
        }

        let block = function.get_block();

        if !block.is_empty() {
            self.write_block(block);
        }
        self.push_str("end");
    }

    fn write_last_statement(&mut self, statement: &nodes::LastStatement) {
        use nodes::LastStatement::*;

        match statement {
            Break(_) => self.push_str("break"),
            Continue(_) => self.push_str("continue"),
            Return(expressions) => {
                self.push_str("return");
                let last_index = expressions.len().saturating_sub(1);

                expressions
                    .iter_expressions()
                    .enumerate()
                    .for_each(|(index, expression)| {
                        self.write_expression(expression);

                        if index != last_index {
                            self.push_char(',');
                        }
                    });
            }
        }
    }

    fn write_local_assign(&mut self, assign: &nodes::LocalAssignStatement) {
        self.push_str("local");

        let variables = assign.get_variables();
        let last_variable_index = variables.len().saturating_sub(1);

        variables.iter().enumerate().for_each(|(index, variable)| {
            self.write_typed_identifier(variable);

            if index != last_variable_index {
                self.push_char(',');
            }
        });

        if assign.has_values() {
            self.push_char_and_break_if('=', utils::break_equal);

            let last_value_index = assign.values_len() - 1;

            assign.iter_values().enumerate().for_each(|(index, value)| {
                self.write_expression(value);

                if index != last_value_index {
                    self.push_char(',');
                }
            });
        };
    }

    fn write_compound_assign(&mut self, assign: &nodes::CompoundAssignStatement) {
        self.write_variable(assign.get_variable());

        self.push_str(assign.get_operator().to_str());

        self.write_expression(assign.get_value());
    }

    fn write_local_function(&mut self, function: &nodes::LocalFunctionStatement) {
        self.push_str("local function");
        self.push_str(function.get_name());

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
        self.push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.push_char(':');
            self.write_function_return_type(return_type);
        }

        let block = function.get_block();

        if !block.is_empty() {
            self.write_block(block);
        }
        self.push_str("end");
    }

    fn write_numeric_for(&mut self, numeric_for: &nodes::NumericForStatement) {
        self.push_str("for");

        self.write_typed_identifier(numeric_for.get_identifier());

        self.push_char_and_break_if('=', utils::break_equal);

        self.write_expression(numeric_for.get_start());
        self.push_char(',');
        self.write_expression(numeric_for.get_end());

        if let Some(step) = numeric_for.get_step() {
            self.push_char(',');
            self.write_expression(step);
        }

        let block = numeric_for.get_block();

        if block.is_empty() {
            self.push_str("do end");
        } else {
            self.push_str("do");
            self.write_block(block);
            self.push_str("end");
        }
    }

    fn write_repeat_statement(&mut self, repeat: &nodes::RepeatStatement) {
        self.push_str("repeat");

        let block = repeat.get_block();

        if !block.is_empty() {
            self.write_block(block);
        }

        self.push_str("until");
        self.write_expression(repeat.get_condition());
    }

    fn write_while_statement(&mut self, while_statement: &nodes::WhileStatement) {
        self.push_str("while");
        self.write_expression(while_statement.get_condition());

        let block = while_statement.get_block();

        if block.is_empty() {
            self.push_str("do end");
        } else {
            self.push_str("do");
            self.write_block(block);
            self.push_str("end");
        }
    }

    fn write_type_declaration_statement(&mut self, statement: &nodes::TypeDeclarationStatement) {
        if statement.is_exported() {
            self.push_str("export");
        }
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
                }
            }

            self.push_char('>');
        }

        self.push_char_and_break_if('=', utils::break_equal);
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
        use nodes::BinaryOperator;

        let operator = binary.operator();
        let left = binary.left();
        let right = binary.right();

        if operator.left_needs_parentheses(left) {
            self.write_expression_in_parentheses(left);
        } else {
            self.write_expression(left);
        }

        match operator {
            BinaryOperator::Concat => self.push_str_and_break_if("..", utils::break_concat),
            _ => self.push_str(operator.to_str()),
        }

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
            Minus => self.push_char_and_break_if('-', utils::break_minus),
            Not => self.push_str("not"),
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
        self.push_char(')');

        if let Some(return_type) = function.get_return_type() {
            self.push_char(':');
            self.write_function_return_type(return_type);
        }

        let block = function.get_block();

        if !block.is_empty() {
            self.write_block(block);
        }
        self.push_str("end");
    }

    fn write_function_call(&mut self, call: &nodes::FunctionCall) {
        self.write_prefix(call.get_prefix());

        if let Some(method) = &call.get_method() {
            self.push_char(':');
            self.push_str(method.get_name());
        }

        self.write_arguments(call.get_arguments());
    }

    fn write_field(&mut self, field: &nodes::FieldExpression) {
        self.write_prefix(field.get_prefix());

        self.push_new_line_if_needed(1);
        self.raw_push_char('.');

        self.push_str(field.get_field().get_name());
    }

    fn write_index(&mut self, index: &nodes::IndexExpression) {
        self.write_prefix(index.get_prefix());

        self.push_char('[');
        self.write_expression(index.get_index());
        self.push_char(']');
    }

    fn write_if_expression(&mut self, if_expression: &nodes::IfExpression) {
        self.push_str("if");
        self.write_expression(if_expression.get_condition());
        self.push_str("then");
        self.write_expression(if_expression.get_result());

        for branch in if_expression.iter_branches() {
            self.push_str("elseif");
            self.write_expression(branch.get_condition());
            self.push_str("then");
            self.write_expression(branch.get_result());
        }

        self.push_str("else");
        self.write_expression(if_expression.get_else_result());
    }

    fn write_table(&mut self, table: &nodes::TableExpression) {
        self.push_char('{');

        let entries = table.get_entries();
        let last_index = entries.len().saturating_sub(1);

        entries.iter().enumerate().for_each(|(index, entry)| {
            self.write_table_entry(entry);

            if index != last_index {
                self.push_char(',');
            }
        });

        self.push_char('}');
    }

    fn write_table_entry(&mut self, entry: &nodes::TableEntry) {
        match entry {
            nodes::TableEntry::Field(entry) => {
                self.push_str(entry.get_field().get_name());
                self.push_char('=');
                self.write_expression(entry.get_value());
            }
            nodes::TableEntry::Index(entry) => {
                self.push_char('[');
                self.write_expression(entry.get_key());
                self.push_char(']');
                self.push_char('=');
                self.write_expression(entry.get_value());
            }
            nodes::TableEntry::Value(expression) => self.write_expression(expression),
        }
    }

    fn write_number(&mut self, number: &nodes::NumberExpression) {
        use nodes::NumberExpression::*;

        match number {
            Decimal(decimal) => {
                let float = decimal.get_raw_float();
                if float.is_nan() {
                    self.push_char('(');
                    self.push_char('0');
                    self.push_char('/');
                    self.push_char('0');
                    self.push_char(')');
                } else if float.is_infinite() {
                    self.push_char('(');
                    if float.is_sign_negative() {
                        self.push_char('-');
                    }
                    self.push_char('1');
                    self.push_char('/');
                    self.push_char('0');
                    self.push_char(')');
                } else {
                    let result = utils::write_number(number);

                    self.push_str(&result);
                }
            }
            Hex(number) => {
                let mut result = format!(
                    "0{}{:x}",
                    if number.is_x_uppercase() { 'X' } else { 'x' },
                    number.get_raw_integer()
                );

                if let Some(exponent) = number.get_exponent() {
                    let exponent_char = number
                        .is_exponent_uppercase()
                        .map(|is_uppercase| if is_uppercase { 'P' } else { 'p' })
                        .unwrap_or('p');

                    result.push(exponent_char);
                    result.push_str(&format!("{}", exponent));
                };

                self.push_str(&result);
            }
            Binary(number) => {
                self.push_str(&format!(
                    "0{}{:b}",
                    if number.is_b_uppercase() { 'B' } else { 'b' },
                    number.get_raw_value()
                ));
            }
        }
    }

    fn write_tuple_arguments(&mut self, arguments: &nodes::TupleArguments) {
        self.merge_char('(');

        let last_index = arguments.len().saturating_sub(1);
        arguments
            .iter_values()
            .enumerate()
            .for_each(|(index, expression)| {
                self.write_expression(expression);

                if index != last_index {
                    self.push_char(',');
                }
            });

        self.push_char(')');
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
        self.write_expression_in_parentheses(parenthese.inner_expression());
    }

    fn write_type_cast(&mut self, type_cast: &nodes::TypeCastExpression) {
        let inner_expression = type_cast.get_expression();

        if nodes::TypeCastExpression::needs_parentheses(inner_expression) {
            self.write_expression_in_parentheses(inner_expression);
        } else {
            self.write_expression(inner_expression);
        }

        self.push_str("::");
        self.write_type(type_cast.get_type());
    }

    fn write_type_name(&mut self, type_name: &nodes::TypeName) {
        self.write_identifier(type_name.get_type_name());
        if let Some(parameters) = type_name.get_type_parameters() {
            self.push_char('<');
            let last_index = parameters.len().saturating_sub(1);
            for (index, parameter) in parameters.iter().enumerate() {
                self.write_type_parameter(parameter);
                if index != last_index {
                    self.push_char(',');
                }
            }

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
                    self.write_type(property.get_type());
                }
                nodes::TableEntryType::Literal(property) => {
                    self.push_char('[');
                    self.write_string_type(property.get_string());
                    self.push_char(']');
                    self.push_char(':');
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
                    self.write_type(indexer.get_value_type());
                }
            }
            if index != last_index {
                self.push_char(',');
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
            }
        }

        if let Some(variadic_argument_type) = function_type.get_variadic_argument_type() {
            if function_type.argument_len() > 0 {
                self.push_char(',');
            }
            self.write_variadic_argument_type(variadic_argument_type);
        }

        self.push_str(")->");
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
        let length = intersection.len();
        let last_index = length.saturating_sub(1);
        for (i, r#type) in intersection.iter_types().enumerate() {
            if i != 0 || intersection.has_leading_token() {
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
        for (i, r#type) in union.iter_types().enumerate() {
            if i != 0 || union.has_leading_token() {
                self.push_char('|');
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
