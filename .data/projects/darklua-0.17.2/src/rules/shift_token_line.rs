use crate::nodes::*;
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug)]
pub(crate) struct ShiftTokenLineProcessor {
    shift_amount: isize,
}

impl ShiftTokenLineProcessor {
    pub(crate) fn new(shift_amount: isize) -> Self {
        Self { shift_amount }
    }
}

impl NodeProcessor for ShiftTokenLineProcessor {
    fn process_block(&mut self, block: &mut Block) {
        block.shift_token_line(self.shift_amount);
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        call.shift_token_line(self.shift_amount);
        call.mutate_arguments().shift_token_line(self.shift_amount);
    }

    fn process_assign_statement(&mut self, assign: &mut AssignStatement) {
        assign.shift_token_line(self.shift_amount);
    }

    fn process_compound_assign_statement(&mut self, assign: &mut CompoundAssignStatement) {
        assign.shift_token_line(self.shift_amount);
    }

    fn process_do_statement(&mut self, statement: &mut DoStatement) {
        statement.shift_token_line(self.shift_amount);
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.shift_token_line(self.shift_amount);
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.shift_token_line(self.shift_amount);
    }

    fn process_if_statement(&mut self, if_statement: &mut IfStatement) {
        if_statement.shift_token_line(self.shift_amount);
    }

    fn process_last_statement(&mut self, statement: &mut LastStatement) {
        match statement {
            LastStatement::Break(token) | LastStatement::Continue(token) => {
                if let Some(token) = token {
                    token.shift_token_line(self.shift_amount);
                }
            }
            LastStatement::Return(statement) => statement.shift_token_line(self.shift_amount),
        }
    }

    fn process_local_assign_statement(&mut self, assign: &mut LocalAssignStatement) {
        assign.shift_token_line(self.shift_amount);
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.shift_token_line(self.shift_amount);
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.shift_token_line(self.shift_amount);
    }

    fn process_repeat_statement(&mut self, repeat: &mut RepeatStatement) {
        repeat.shift_token_line(self.shift_amount);
    }

    fn process_while_statement(&mut self, statement: &mut WhileStatement) {
        statement.shift_token_line(self.shift_amount);
    }

    fn process_type_declaration(&mut self, type_declaration: &mut TypeDeclarationStatement) {
        type_declaration.shift_token_line(self.shift_amount);
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::False(token)
            | Expression::Nil(token)
            | Expression::True(token)
            | Expression::VariableArguments(token) => {
                if let Some(token) = token {
                    token.shift_token_line(self.shift_amount)
                }
            }
            Expression::Binary(_)
            | Expression::Call(_)
            | Expression::Field(_)
            | Expression::Function(_)
            | Expression::Identifier(_)
            | Expression::If(_)
            | Expression::Index(_)
            | Expression::Number(_)
            | Expression::Parenthese(_)
            | Expression::String(_)
            | Expression::InterpolatedString(_)
            | Expression::Table(_)
            | Expression::Unary(_)
            | Expression::TypeCast(_) => {}
        }
    }

    fn process_binary_expression(&mut self, binary: &mut BinaryExpression) {
        binary.shift_token_line(self.shift_amount);
    }

    fn process_field_expression(&mut self, field: &mut FieldExpression) {
        field.shift_token_line(self.shift_amount);
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.shift_token_line(self.shift_amount);
    }

    fn process_if_expression(&mut self, if_expression: &mut IfExpression) {
        if_expression.shift_token_line(self.shift_amount);
    }

    fn process_variable_expression(&mut self, identifier: &mut Identifier) {
        identifier.shift_token_line(self.shift_amount);
    }

    fn process_index_expression(&mut self, index: &mut IndexExpression) {
        index.shift_token_line(self.shift_amount);
    }

    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        number.shift_token_line(self.shift_amount);
    }

    fn process_parenthese_expression(&mut self, expression: &mut ParentheseExpression) {
        expression.shift_token_line(self.shift_amount);
    }

    fn process_string_expression(&mut self, string: &mut StringExpression) {
        string.shift_token_line(self.shift_amount);
    }

    fn process_interpolated_string_expression(
        &mut self,
        string: &mut InterpolatedStringExpression,
    ) {
        string.shift_token_line(self.shift_amount);
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        table.shift_token_line(self.shift_amount);
    }

    fn process_unary_expression(&mut self, unary: &mut UnaryExpression) {
        unary.shift_token_line(self.shift_amount);
    }

    fn process_type_cast_expression(&mut self, type_cast: &mut TypeCastExpression) {
        type_cast.shift_token_line(self.shift_amount);
    }

    fn process_prefix_expression(&mut self, _: &mut Prefix) {}

    fn process_type(&mut self, r#type: &mut Type) {
        match r#type {
            Type::True(token) | Type::False(token) | Type::Nil(token) => {
                if let Some(token) = token {
                    token.shift_token_line(self.shift_amount);
                }
            }
            _ => {}
        }
    }

    fn process_type_name(&mut self, type_name: &mut TypeName) {
        type_name.shift_token_line(self.shift_amount);
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        type_field.shift_token_line(self.shift_amount);
    }

    fn process_string_type(&mut self, string_type: &mut StringType) {
        string_type.shift_token_line(self.shift_amount);
    }

    fn process_array_type(&mut self, array: &mut ArrayType) {
        array.shift_token_line(self.shift_amount);
    }

    fn process_table_type(&mut self, table: &mut TableType) {
        table.shift_token_line(self.shift_amount);
    }

    fn process_expression_type(&mut self, expression_type: &mut ExpressionType) {
        expression_type.shift_token_line(self.shift_amount);
    }

    fn process_parenthese_type(&mut self, parenthese_type: &mut ParentheseType) {
        parenthese_type.shift_token_line(self.shift_amount);
    }

    fn process_function_type(&mut self, function_type: &mut FunctionType) {
        function_type.shift_token_line(self.shift_amount);
    }

    fn process_optional_type(&mut self, optional: &mut OptionalType) {
        optional.shift_token_line(self.shift_amount);
    }

    fn process_intersection_type(&mut self, intersection: &mut IntersectionType) {
        intersection.shift_token_line(self.shift_amount);
    }

    fn process_union_type(&mut self, union: &mut UnionType) {
        union.shift_token_line(self.shift_amount);
    }

    fn process_type_pack(&mut self, type_pack: &mut TypePack) {
        type_pack.shift_token_line(self.shift_amount);
    }

    fn process_generic_type_pack(&mut self, generic_type_pack: &mut GenericTypePack) {
        generic_type_pack.shift_token_line(self.shift_amount);
    }

    fn process_variadic_type_pack(&mut self, variadic_type_pack: &mut VariadicTypePack) {
        variadic_type_pack.shift_token_line(self.shift_amount);
    }
}

pub const SHIFT_TOKEN_LINE: &str = "shift_token_line";

#[derive(Debug, PartialEq, Eq)]
pub(crate) struct ShiftTokenLine {
    shift_amount: isize,
}

impl ShiftTokenLine {
    pub(crate) fn new(shift_amount: isize) -> Self {
        Self { shift_amount }
    }
}

impl FlawlessRule for ShiftTokenLine {
    fn flawless_process(&self, block: &mut Block, _context: &Context) {
        if self.shift_amount != 0 {
            let mut processor = ShiftTokenLineProcessor::new(self.shift_amount);
            DefaultVisitor::visit_block(block, &mut processor);
        }
    }
}

impl RuleConfiguration for ShiftTokenLine {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        SHIFT_TOKEN_LINE
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> ShiftTokenLine {
        ShiftTokenLine::new(1)
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_replace_referenced_tokens", rule);
    }
}
