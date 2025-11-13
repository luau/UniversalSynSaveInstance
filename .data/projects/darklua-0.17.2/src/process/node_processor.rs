use crate::nodes::*;

/// Used by the NodeVisitor trait, a NodeProcessor object is passed to each node to
/// perform mutations.
pub trait NodeProcessor {
    fn process_block(&mut self, _: &mut Block) {}
    fn process_scope(&mut self, _block: &mut Block, _extra: Option<&mut Expression>) {}
    fn process_statement(&mut self, _: &mut Statement) {}

    fn process_function_call(&mut self, _: &mut FunctionCall) {}

    fn process_assign_statement(&mut self, _: &mut AssignStatement) {}
    fn process_compound_assign_statement(&mut self, _: &mut CompoundAssignStatement) {}
    fn process_do_statement(&mut self, _: &mut DoStatement) {}
    fn process_function_statement(&mut self, _: &mut FunctionStatement) {}
    fn process_generic_for_statement(&mut self, _: &mut GenericForStatement) {}
    fn process_if_statement(&mut self, _: &mut IfStatement) {}
    fn process_last_statement(&mut self, _: &mut LastStatement) {}
    fn process_local_assign_statement(&mut self, _: &mut LocalAssignStatement) {}
    fn process_local_function_statement(&mut self, _: &mut LocalFunctionStatement) {}
    fn process_numeric_for_statement(&mut self, _: &mut NumericForStatement) {}
    fn process_repeat_statement(&mut self, _: &mut RepeatStatement) {}
    fn process_while_statement(&mut self, _: &mut WhileStatement) {}
    fn process_type_declaration(&mut self, _: &mut TypeDeclarationStatement) {}

    fn process_variable(&mut self, _: &mut Variable) {}

    fn process_expression(&mut self, _: &mut Expression) {}

    fn process_binary_expression(&mut self, _: &mut BinaryExpression) {}
    fn process_field_expression(&mut self, _: &mut FieldExpression) {}
    fn process_function_expression(&mut self, _: &mut FunctionExpression) {}
    fn process_variable_expression(&mut self, _: &mut Identifier) {}
    fn process_index_expression(&mut self, _: &mut IndexExpression) {}
    fn process_if_expression(&mut self, _: &mut IfExpression) {}
    fn process_number_expression(&mut self, _: &mut NumberExpression) {}
    fn process_prefix_expression(&mut self, _: &mut Prefix) {}
    fn process_parenthese_expression(&mut self, _: &mut ParentheseExpression) {}
    fn process_string_expression(&mut self, _: &mut StringExpression) {}
    fn process_interpolated_string_expression(&mut self, _: &mut InterpolatedStringExpression) {}
    fn process_table_expression(&mut self, _: &mut TableExpression) {}
    fn process_unary_expression(&mut self, _: &mut UnaryExpression) {}
    fn process_type_cast_expression(&mut self, _: &mut TypeCastExpression) {}

    fn process_type(&mut self, _: &mut Type) {}

    fn process_type_name(&mut self, _: &mut TypeName) {}
    fn process_type_field(&mut self, _: &mut TypeField) {}
    fn process_string_type(&mut self, _: &mut StringType) {}
    fn process_array_type(&mut self, _: &mut ArrayType) {}
    fn process_table_type(&mut self, _: &mut TableType) {}
    fn process_expression_type(&mut self, _: &mut ExpressionType) {}
    fn process_parenthese_type(&mut self, _: &mut ParentheseType) {}
    fn process_function_type(&mut self, _: &mut FunctionType) {}
    fn process_optional_type(&mut self, _: &mut OptionalType) {}
    fn process_intersection_type(&mut self, _: &mut IntersectionType) {}
    fn process_union_type(&mut self, _: &mut UnionType) {}

    fn process_type_pack(&mut self, _: &mut TypePack) {}
    fn process_generic_type_pack(&mut self, _: &mut GenericTypePack) {}
    fn process_variadic_type_pack(&mut self, _: &mut VariadicTypePack) {}
}

pub trait NodePostProcessor {
    fn process_after_block(&mut self, _: &mut Block) {}
    fn process_after_scope(&mut self, _block: &mut Block, _extra: Option<&mut Expression>) {}
    fn process_after_statement(&mut self, _: &mut Statement) {}

    fn process_after_function_call(&mut self, _: &mut FunctionCall) {}

    fn process_after_assign_statement(&mut self, _: &mut AssignStatement) {}
    fn process_after_compound_assign_statement(&mut self, _: &mut CompoundAssignStatement) {}
    fn process_after_do_statement(&mut self, _: &mut DoStatement) {}
    fn process_after_function_statement(&mut self, _: &mut FunctionStatement) {}
    fn process_after_generic_for_statement(&mut self, _: &mut GenericForStatement) {}
    fn process_after_if_statement(&mut self, _: &mut IfStatement) {}
    fn process_after_last_statement(&mut self, _: &mut LastStatement) {}
    fn process_after_local_assign_statement(&mut self, _: &mut LocalAssignStatement) {}
    fn process_after_local_function_statement(&mut self, _: &mut LocalFunctionStatement) {}
    fn process_after_numeric_for_statement(&mut self, _: &mut NumericForStatement) {}
    fn process_after_repeat_statement(&mut self, _: &mut RepeatStatement) {}
    fn process_after_while_statement(&mut self, _: &mut WhileStatement) {}
    fn process_after_type_declaration(&mut self, _: &mut TypeDeclarationStatement) {}

    fn process_after_variable(&mut self, _: &mut Variable) {}

    fn process_after_expression(&mut self, _: &mut Expression) {}

    fn process_after_binary_expression(&mut self, _: &mut BinaryExpression) {}
    fn process_after_field_expression(&mut self, _: &mut FieldExpression) {}
    fn process_after_function_expression(&mut self, _: &mut FunctionExpression) {}
    fn process_after_variable_expression(&mut self, _: &mut Identifier) {}
    fn process_after_index_expression(&mut self, _: &mut IndexExpression) {}
    fn process_after_if_expression(&mut self, _: &mut IfExpression) {}
    fn process_after_number_expression(&mut self, _: &mut NumberExpression) {}
    fn process_after_prefix_expression(&mut self, _: &mut Prefix) {}
    fn process_after_parenthese_expression(&mut self, _: &mut ParentheseExpression) {}
    fn process_after_string_expression(&mut self, _: &mut StringExpression) {}
    fn process_after_interpolated_string_expression(
        &mut self,
        _: &mut InterpolatedStringExpression,
    ) {
    }
    fn process_after_table_expression(&mut self, _: &mut TableExpression) {}
    fn process_after_unary_expression(&mut self, _: &mut UnaryExpression) {}
    fn process_after_type_cast_expression(&mut self, _: &mut TypeCastExpression) {}

    fn process_after_type(&mut self, _: &mut Type) {}

    fn process_after_type_name(&mut self, _: &mut TypeName) {}
    fn process_after_type_field(&mut self, _: &mut TypeField) {}
    fn process_after_string_type(&mut self, _: &mut StringType) {}
    fn process_after_array_type(&mut self, _: &mut ArrayType) {}
    fn process_after_table_type(&mut self, _: &mut TableType) {}
    fn process_after_expression_type(&mut self, _: &mut ExpressionType) {}
    fn process_after_parenthese_type(&mut self, _: &mut ParentheseType) {}
    fn process_after_function_type(&mut self, _: &mut FunctionType) {}
    fn process_after_optional_type(&mut self, _: &mut OptionalType) {}
    fn process_after_intersection_type(&mut self, _: &mut IntersectionType) {}
    fn process_after_union_type(&mut self, _: &mut UnionType) {}

    fn process_after_type_pack(&mut self, _: &mut TypePack) {}
    fn process_after_generic_type_pack(&mut self, _: &mut GenericTypePack) {}
    fn process_after_variadic_type_pack(&mut self, _: &mut VariadicTypePack) {}
}
