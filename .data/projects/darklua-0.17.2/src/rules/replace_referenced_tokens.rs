use crate::nodes::*;
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug)]
struct Processor<'a> {
    code: &'a str,
}

impl<'a> Processor<'a> {
    fn new(code: &'a str) -> Self {
        Self { code }
    }
}

impl NodeProcessor for Processor<'_> {
    fn process_block(&mut self, block: &mut Block) {
        block.replace_referenced_tokens(self.code);
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        call.replace_referenced_tokens(self.code);
        call.mutate_arguments().replace_referenced_tokens(self.code);
    }

    fn process_assign_statement(&mut self, assign: &mut AssignStatement) {
        assign.replace_referenced_tokens(self.code);
    }

    fn process_compound_assign_statement(&mut self, assign: &mut CompoundAssignStatement) {
        assign.replace_referenced_tokens(self.code);
    }

    fn process_do_statement(&mut self, statement: &mut DoStatement) {
        statement.replace_referenced_tokens(self.code);
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.replace_referenced_tokens(self.code);
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.replace_referenced_tokens(self.code);
    }

    fn process_if_statement(&mut self, if_statement: &mut IfStatement) {
        if_statement.replace_referenced_tokens(self.code);
    }

    fn process_last_statement(&mut self, statement: &mut LastStatement) {
        match statement {
            LastStatement::Break(token) | LastStatement::Continue(token) => {
                if let Some(token) = token {
                    token.replace_referenced_tokens(self.code);
                }
            }
            LastStatement::Return(statement) => statement.replace_referenced_tokens(self.code),
        }
    }

    fn process_local_assign_statement(&mut self, assign: &mut LocalAssignStatement) {
        assign.replace_referenced_tokens(self.code);
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.replace_referenced_tokens(self.code);
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.replace_referenced_tokens(self.code);
    }

    fn process_repeat_statement(&mut self, repeat: &mut RepeatStatement) {
        repeat.replace_referenced_tokens(self.code);
    }

    fn process_while_statement(&mut self, statement: &mut WhileStatement) {
        statement.replace_referenced_tokens(self.code);
    }

    fn process_type_declaration(&mut self, type_declaration: &mut TypeDeclarationStatement) {
        type_declaration.replace_referenced_tokens(self.code);
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::False(token)
            | Expression::Nil(token)
            | Expression::True(token)
            | Expression::VariableArguments(token) => {
                if let Some(token) = token {
                    token.replace_referenced_tokens(self.code);
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
        binary.replace_referenced_tokens(self.code);
    }

    fn process_field_expression(&mut self, field: &mut FieldExpression) {
        field.replace_referenced_tokens(self.code);
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.replace_referenced_tokens(self.code);
    }

    fn process_if_expression(&mut self, if_expression: &mut IfExpression) {
        if_expression.replace_referenced_tokens(self.code);
    }

    fn process_variable_expression(&mut self, identifier: &mut Identifier) {
        identifier.replace_referenced_tokens(self.code);
    }

    fn process_index_expression(&mut self, index: &mut IndexExpression) {
        index.replace_referenced_tokens(self.code);
    }

    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        number.replace_referenced_tokens(self.code);
    }

    fn process_parenthese_expression(&mut self, expression: &mut ParentheseExpression) {
        expression.replace_referenced_tokens(self.code);
    }

    fn process_string_expression(&mut self, string: &mut StringExpression) {
        string.replace_referenced_tokens(self.code);
    }

    fn process_interpolated_string_expression(
        &mut self,
        string: &mut InterpolatedStringExpression,
    ) {
        string.replace_referenced_tokens(self.code);
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        table.replace_referenced_tokens(self.code);
    }

    fn process_unary_expression(&mut self, unary: &mut UnaryExpression) {
        unary.replace_referenced_tokens(self.code);
    }

    fn process_type_cast_expression(&mut self, type_cast: &mut TypeCastExpression) {
        type_cast.replace_referenced_tokens(self.code);
    }

    fn process_prefix_expression(&mut self, _: &mut Prefix) {}

    fn process_type(&mut self, r#type: &mut Type) {
        match r#type {
            Type::True(token) | Type::False(token) | Type::Nil(token) => {
                if let Some(token) = token {
                    token.replace_referenced_tokens(self.code)
                }
            }
            _ => {}
        }
    }

    fn process_type_name(&mut self, type_name: &mut TypeName) {
        type_name.replace_referenced_tokens(self.code);
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        type_field.replace_referenced_tokens(self.code);
    }

    fn process_string_type(&mut self, string_type: &mut StringType) {
        string_type.replace_referenced_tokens(self.code);
    }

    fn process_array_type(&mut self, array: &mut ArrayType) {
        array.replace_referenced_tokens(self.code);
    }

    fn process_table_type(&mut self, table: &mut TableType) {
        table.replace_referenced_tokens(self.code);
    }

    fn process_expression_type(&mut self, expression_type: &mut ExpressionType) {
        expression_type.replace_referenced_tokens(self.code);
    }

    fn process_parenthese_type(&mut self, parenthese_type: &mut ParentheseType) {
        parenthese_type.replace_referenced_tokens(self.code);
    }

    fn process_function_type(&mut self, function_type: &mut FunctionType) {
        function_type.replace_referenced_tokens(self.code);
    }

    fn process_optional_type(&mut self, optional: &mut OptionalType) {
        optional.replace_referenced_tokens(self.code);
    }

    fn process_intersection_type(&mut self, intersection: &mut IntersectionType) {
        intersection.replace_referenced_tokens(self.code);
    }

    fn process_union_type(&mut self, union: &mut UnionType) {
        union.replace_referenced_tokens(self.code);
    }

    fn process_type_pack(&mut self, type_pack: &mut TypePack) {
        type_pack.replace_referenced_tokens(self.code);
    }

    fn process_generic_type_pack(&mut self, generic_type_pack: &mut GenericTypePack) {
        generic_type_pack.replace_referenced_tokens(self.code);
    }

    fn process_variadic_type_pack(&mut self, variadic_type_pack: &mut VariadicTypePack) {
        variadic_type_pack.replace_referenced_tokens(self.code);
    }
}

pub const REPLACE_REFERENCED_TOKENS: &str = "replace_referenced_tokens";

#[derive(Debug, Default, PartialEq, Eq)]
pub(crate) struct ReplaceReferencedTokens {}

impl FlawlessRule for ReplaceReferencedTokens {
    fn flawless_process(&self, block: &mut Block, context: &Context) {
        let mut processor = Processor::new(context.original_code());
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ReplaceReferencedTokens {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REPLACE_REFERENCED_TOKENS
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

    fn new_rule() -> ReplaceReferencedTokens {
        ReplaceReferencedTokens::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_replace_referenced_tokens", rule);
    }

    fn test_code(code: &str) {
        let parser = Parser::default().preserve_tokens();

        let mut block = parser.parse(code).expect("unable to parse code");

        ReplaceReferencedTokens::default().flawless_process(
            &mut block,
            &ContextBuilder::new(".", &Resources::from_memory(), code).build(),
        );

        // provide invalid code to verify if the ReplaceReferencedTokens left token
        // references, which will cause the TokenBasedLuaGenerator to panic
        let mut generator = TokenBasedLuaGenerator::new("");

        generator.write_block(&block);
    }

    #[test]
    fn test_fuzzed_case_a() {
        let code = include_str!("../../tests/fuzzed_test_cases/a.lua");
        test_code(code);
    }

    #[test]
    fn test_fuzzed_case_b() {
        let code = include_str!("../../tests/fuzzed_test_cases/b.lua");
        test_code(code);
    }

    #[test]
    fn test_fuzzed_case_c() {
        let code = include_str!("../../tests/fuzzed_test_cases/c.lua");
        test_code(code);
    }
}
