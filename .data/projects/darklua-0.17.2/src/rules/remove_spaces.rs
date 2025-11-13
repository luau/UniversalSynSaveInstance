use crate::nodes::*;
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Default)]
pub(crate) struct RemoveWhitespacesProcessor {}

impl NodeProcessor for RemoveWhitespacesProcessor {
    fn process_block(&mut self, block: &mut Block) {
        block.clear_whitespaces();
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        call.clear_whitespaces();
        call.mutate_arguments().clear_whitespaces();
    }

    fn process_assign_statement(&mut self, assign: &mut AssignStatement) {
        assign.clear_whitespaces();
    }

    fn process_compound_assign_statement(&mut self, assign: &mut CompoundAssignStatement) {
        assign.clear_whitespaces();
    }

    fn process_do_statement(&mut self, statement: &mut DoStatement) {
        statement.clear_whitespaces();
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.clear_whitespaces();
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.clear_whitespaces();
    }

    fn process_if_statement(&mut self, if_statement: &mut IfStatement) {
        if_statement.clear_whitespaces();
    }

    fn process_last_statement(&mut self, statement: &mut LastStatement) {
        match statement {
            LastStatement::Break(token) | LastStatement::Continue(token) => {
                if let Some(token) = token {
                    token.clear_whitespaces();
                }
            }
            LastStatement::Return(statement) => statement.clear_whitespaces(),
        }
    }

    fn process_local_assign_statement(&mut self, assign: &mut LocalAssignStatement) {
        assign.clear_whitespaces();
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.clear_whitespaces();
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.clear_whitespaces();
    }

    fn process_repeat_statement(&mut self, repeat: &mut RepeatStatement) {
        repeat.clear_whitespaces();
    }

    fn process_while_statement(&mut self, statement: &mut WhileStatement) {
        statement.clear_whitespaces();
    }

    fn process_type_declaration(&mut self, type_declaration: &mut TypeDeclarationStatement) {
        type_declaration.clear_whitespaces();
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::False(token)
            | Expression::Nil(token)
            | Expression::True(token)
            | Expression::VariableArguments(token) => {
                if let Some(token) = token {
                    token.clear_whitespaces()
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
        binary.clear_whitespaces();
    }

    fn process_field_expression(&mut self, field: &mut FieldExpression) {
        field.clear_whitespaces();
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.clear_whitespaces();
    }

    fn process_if_expression(&mut self, if_expression: &mut IfExpression) {
        if_expression.clear_whitespaces();
    }

    fn process_variable_expression(&mut self, identifier: &mut Identifier) {
        identifier.clear_whitespaces();
    }

    fn process_index_expression(&mut self, index: &mut IndexExpression) {
        index.clear_whitespaces();
    }

    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        number.clear_whitespaces();
    }

    fn process_parenthese_expression(&mut self, expression: &mut ParentheseExpression) {
        expression.clear_whitespaces();
    }

    fn process_string_expression(&mut self, string: &mut StringExpression) {
        string.clear_whitespaces();
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        table.clear_whitespaces();
    }

    fn process_unary_expression(&mut self, unary: &mut UnaryExpression) {
        unary.clear_whitespaces();
    }

    fn process_interpolated_string_expression(
        &mut self,
        string: &mut InterpolatedStringExpression,
    ) {
        string.clear_whitespaces();
    }

    fn process_type_cast_expression(&mut self, type_cast: &mut TypeCastExpression) {
        type_cast.clear_whitespaces();
    }

    fn process_prefix_expression(&mut self, _: &mut Prefix) {}

    fn process_type(&mut self, r#type: &mut Type) {
        match r#type {
            Type::True(token) | Type::False(token) | Type::Nil(token) => {
                if let Some(token) = token {
                    token.clear_whitespaces();
                }
            }
            _ => {}
        }
    }

    fn process_type_name(&mut self, type_name: &mut TypeName) {
        type_name.clear_whitespaces();
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        type_field.clear_whitespaces();
    }

    fn process_string_type(&mut self, string_type: &mut StringType) {
        string_type.clear_whitespaces();
    }

    fn process_array_type(&mut self, array: &mut ArrayType) {
        array.clear_whitespaces();
    }

    fn process_table_type(&mut self, table: &mut TableType) {
        table.clear_whitespaces();
    }

    fn process_expression_type(&mut self, expression_type: &mut ExpressionType) {
        expression_type.clear_whitespaces();
    }

    fn process_parenthese_type(&mut self, parenthese_type: &mut ParentheseType) {
        parenthese_type.clear_whitespaces();
    }

    fn process_function_type(&mut self, function_type: &mut FunctionType) {
        function_type.clear_whitespaces();
    }

    fn process_optional_type(&mut self, optional: &mut OptionalType) {
        optional.clear_whitespaces();
    }

    fn process_intersection_type(&mut self, intersection: &mut IntersectionType) {
        intersection.clear_whitespaces();
    }

    fn process_union_type(&mut self, union: &mut UnionType) {
        union.clear_whitespaces();
    }

    fn process_type_pack(&mut self, type_pack: &mut TypePack) {
        type_pack.clear_whitespaces();
    }

    fn process_generic_type_pack(&mut self, generic_type_pack: &mut GenericTypePack) {
        generic_type_pack.clear_whitespaces();
    }

    fn process_variadic_type_pack(&mut self, variadic_type_pack: &mut VariadicTypePack) {
        variadic_type_pack.clear_whitespaces();
    }
}

pub const REMOVE_SPACES_RULE_NAME: &str = "remove_spaces";

/// A rule that removes whitespaces associated with AST nodes.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveSpaces {}

impl FlawlessRule for RemoveSpaces {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = RemoveWhitespacesProcessor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveSpaces {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_SPACES_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::{
        generator::{LuaGenerator, TokenBasedLuaGenerator},
        rules::{ContextBuilder, Rule},
        Parser, Resources,
    };

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveSpaces {
        RemoveSpaces::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_spaces", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_spaces',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }

    #[test]
    fn remove_spaces_in_code() {
        let code = include_str!("../../tests/test_cases/spaces_and_comments.lua");

        let parser = Parser::default().preserve_tokens();

        let mut block = parser.parse(code).expect("unable to parse code");

        RemoveSpaces::default().flawless_process(
            &mut block,
            &ContextBuilder::new(".", &Resources::from_memory(), code).build(),
        );

        let mut generator = TokenBasedLuaGenerator::new(code);

        generator.write_block(&block);

        let code_output = &generator.into_string();

        insta::assert_snapshot!("remove_spaces_in_code", code_output);
    }
}
