use regex::Regex;

use crate::nodes::*;
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

#[derive(Debug, Default)]
pub(crate) struct RemoveCommentProcessor {}

impl NodeProcessor for RemoveCommentProcessor {
    fn process_block(&mut self, block: &mut Block) {
        block.clear_comments();
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        call.clear_comments();
        call.mutate_arguments().clear_comments();
    }

    fn process_assign_statement(&mut self, assign: &mut AssignStatement) {
        assign.clear_comments();
    }

    fn process_compound_assign_statement(&mut self, assign: &mut CompoundAssignStatement) {
        assign.clear_comments();
    }

    fn process_do_statement(&mut self, statement: &mut DoStatement) {
        statement.clear_comments();
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.clear_comments();
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.clear_comments();
    }

    fn process_if_statement(&mut self, if_statement: &mut IfStatement) {
        if_statement.clear_comments();
    }

    fn process_last_statement(&mut self, statement: &mut LastStatement) {
        match statement {
            LastStatement::Break(token) | LastStatement::Continue(token) => {
                if let Some(token) = token {
                    token.clear_comments();
                }
            }
            LastStatement::Return(statement) => statement.clear_comments(),
        }
    }

    fn process_local_assign_statement(&mut self, assign: &mut LocalAssignStatement) {
        assign.clear_comments();
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.clear_comments();
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.clear_comments();
    }

    fn process_repeat_statement(&mut self, repeat: &mut RepeatStatement) {
        repeat.clear_comments();
    }

    fn process_while_statement(&mut self, statement: &mut WhileStatement) {
        statement.clear_comments();
    }

    fn process_type_declaration(&mut self, type_declaration: &mut TypeDeclarationStatement) {
        type_declaration.clear_comments();
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::False(token)
            | Expression::Nil(token)
            | Expression::True(token)
            | Expression::VariableArguments(token) => {
                if let Some(token) = token {
                    token.clear_comments()
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
        binary.clear_comments();
    }

    fn process_field_expression(&mut self, field: &mut FieldExpression) {
        field.clear_comments();
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.clear_comments();
    }

    fn process_if_expression(&mut self, if_expression: &mut IfExpression) {
        if_expression.clear_comments();
    }

    fn process_variable_expression(&mut self, identifier: &mut Identifier) {
        identifier.clear_comments();
    }

    fn process_index_expression(&mut self, index: &mut IndexExpression) {
        index.clear_comments();
    }

    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        number.clear_comments();
    }

    fn process_parenthese_expression(&mut self, expression: &mut ParentheseExpression) {
        expression.clear_comments();
    }

    fn process_string_expression(&mut self, string: &mut StringExpression) {
        string.clear_comments();
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        table.clear_comments();
    }

    fn process_unary_expression(&mut self, unary: &mut UnaryExpression) {
        unary.clear_comments();
    }

    fn process_interpolated_string_expression(
        &mut self,
        string: &mut InterpolatedStringExpression,
    ) {
        string.clear_comments();
    }

    fn process_type_cast_expression(&mut self, type_cast: &mut TypeCastExpression) {
        type_cast.clear_comments();
    }

    fn process_prefix_expression(&mut self, _: &mut Prefix) {}

    fn process_type(&mut self, r#type: &mut Type) {
        match r#type {
            Type::True(token) | Type::False(token) | Type::Nil(token) => {
                if let Some(token) = token {
                    token.clear_comments();
                }
            }
            _ => {}
        }
    }

    fn process_type_name(&mut self, type_name: &mut TypeName) {
        type_name.clear_comments();
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        type_field.clear_comments();
    }

    fn process_string_type(&mut self, string_type: &mut StringType) {
        string_type.clear_comments();
    }

    fn process_array_type(&mut self, array: &mut ArrayType) {
        array.clear_comments();
    }

    fn process_table_type(&mut self, table: &mut TableType) {
        table.clear_comments();
    }

    fn process_expression_type(&mut self, expression_type: &mut ExpressionType) {
        expression_type.clear_comments();
    }

    fn process_parenthese_type(&mut self, parenthese_type: &mut ParentheseType) {
        parenthese_type.clear_comments();
    }

    fn process_function_type(&mut self, function_type: &mut FunctionType) {
        function_type.clear_comments();
    }

    fn process_optional_type(&mut self, optional: &mut OptionalType) {
        optional.clear_comments();
    }

    fn process_intersection_type(&mut self, intersection: &mut IntersectionType) {
        intersection.clear_comments();
    }

    fn process_union_type(&mut self, union: &mut UnionType) {
        union.clear_comments();
    }

    fn process_type_pack(&mut self, type_pack: &mut TypePack) {
        type_pack.clear_comments();
    }

    fn process_generic_type_pack(&mut self, generic_type_pack: &mut GenericTypePack) {
        generic_type_pack.clear_comments();
    }

    fn process_variadic_type_pack(&mut self, variadic_type_pack: &mut VariadicTypePack) {
        variadic_type_pack.clear_comments();
    }
}

#[derive(Debug)]
pub(crate) struct FilterCommentProcessor<'a> {
    original_code: &'a str,
    except: &'a Vec<Regex>,
}

impl<'a> FilterCommentProcessor<'a> {
    pub(crate) fn new(original_code: &'a str, except: &'a Vec<Regex>) -> Self {
        Self {
            original_code,
            except,
        }
    }

    fn ignore_trivia(&self, trivia: &Trivia) -> bool {
        let content = trivia.read(self.original_code);
        self.except.iter().any(|pattern| pattern.is_match(content))
    }
}

impl NodeProcessor for FilterCommentProcessor<'_> {
    fn process_block(&mut self, block: &mut Block) {
        block.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        call.filter_comments(|trivia| self.ignore_trivia(trivia));
        call.mutate_arguments()
            .filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_assign_statement(&mut self, assign: &mut AssignStatement) {
        assign.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_compound_assign_statement(&mut self, assign: &mut CompoundAssignStatement) {
        assign.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_do_statement(&mut self, statement: &mut DoStatement) {
        statement.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_function_statement(&mut self, function: &mut FunctionStatement) {
        function.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_generic_for_statement(&mut self, generic_for: &mut GenericForStatement) {
        generic_for.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_if_statement(&mut self, if_statement: &mut IfStatement) {
        if_statement.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_last_statement(&mut self, statement: &mut LastStatement) {
        match statement {
            LastStatement::Break(token) | LastStatement::Continue(token) => {
                if let Some(token) = token {
                    token.filter_comments(|trivia| self.ignore_trivia(trivia));
                }
            }
            LastStatement::Return(statement) => {
                statement.filter_comments(|trivia| self.ignore_trivia(trivia))
            }
        }
    }

    fn process_local_assign_statement(&mut self, assign: &mut LocalAssignStatement) {
        assign.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        function.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_numeric_for_statement(&mut self, numeric_for: &mut NumericForStatement) {
        numeric_for.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_repeat_statement(&mut self, repeat: &mut RepeatStatement) {
        repeat.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_while_statement(&mut self, statement: &mut WhileStatement) {
        statement.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_type_declaration(&mut self, type_declaration: &mut TypeDeclarationStatement) {
        type_declaration.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        match expression {
            Expression::False(token)
            | Expression::Nil(token)
            | Expression::True(token)
            | Expression::VariableArguments(token) => {
                if let Some(token) = token {
                    token.filter_comments(|trivia| self.ignore_trivia(trivia))
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
        binary.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_field_expression(&mut self, field: &mut FieldExpression) {
        field.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_function_expression(&mut self, function: &mut FunctionExpression) {
        function.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_if_expression(&mut self, if_expression: &mut IfExpression) {
        if_expression.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_variable_expression(&mut self, identifier: &mut Identifier) {
        identifier.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_index_expression(&mut self, index: &mut IndexExpression) {
        index.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        number.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_parenthese_expression(&mut self, expression: &mut ParentheseExpression) {
        expression.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_string_expression(&mut self, string: &mut StringExpression) {
        string.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        table.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_unary_expression(&mut self, unary: &mut UnaryExpression) {
        unary.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_interpolated_string_expression(
        &mut self,
        string: &mut InterpolatedStringExpression,
    ) {
        string.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_type_cast_expression(&mut self, type_cast: &mut TypeCastExpression) {
        type_cast.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_prefix_expression(&mut self, _: &mut Prefix) {}

    fn process_type(&mut self, r#type: &mut Type) {
        match r#type {
            Type::True(token) | Type::False(token) | Type::Nil(token) => {
                if let Some(token) = token {
                    token.filter_comments(|trivia| self.ignore_trivia(trivia));
                }
            }
            _ => {}
        }
    }

    fn process_type_name(&mut self, type_name: &mut TypeName) {
        type_name.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        type_field.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_string_type(&mut self, string_type: &mut StringType) {
        string_type.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_array_type(&mut self, array: &mut ArrayType) {
        array.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_table_type(&mut self, table: &mut TableType) {
        table.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_expression_type(&mut self, expression_type: &mut ExpressionType) {
        expression_type.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_parenthese_type(&mut self, parenthese_type: &mut ParentheseType) {
        parenthese_type.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_function_type(&mut self, function_type: &mut FunctionType) {
        function_type.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_optional_type(&mut self, optional: &mut OptionalType) {
        optional.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_intersection_type(&mut self, intersection: &mut IntersectionType) {
        intersection.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_union_type(&mut self, union: &mut UnionType) {
        union.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_type_pack(&mut self, type_pack: &mut TypePack) {
        type_pack.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_generic_type_pack(&mut self, generic_type_pack: &mut GenericTypePack) {
        generic_type_pack.filter_comments(|trivia| self.ignore_trivia(trivia));
    }

    fn process_variadic_type_pack(&mut self, variadic_type_pack: &mut VariadicTypePack) {
        variadic_type_pack.filter_comments(|trivia| self.ignore_trivia(trivia));
    }
}

pub const REMOVE_COMMENTS_RULE_NAME: &str = "remove_comments";

/// A rule that removes comments associated with AST nodes.
#[derive(Debug, Default)]
pub struct RemoveComments {
    except: Vec<Regex>,
}

impl RemoveComments {
    pub fn with_exception(mut self, exception_pattern: &str) -> Self {
        match Regex::new(exception_pattern) {
            Ok(regex_value) => {
                self.except.push(regex_value);
            }
            Err(err) => {
                log::warn!(
                    "unable to compile regex pattern '{}': {}",
                    exception_pattern,
                    err
                );
            }
        };

        self
    }
}

impl FlawlessRule for RemoveComments {
    fn flawless_process(&self, block: &mut Block, context: &Context) {
        if self.except.is_empty() {
            let mut processor = RemoveCommentProcessor::default();
            DefaultVisitor::visit_block(block, &mut processor);
        } else {
            let mut processor = FilterCommentProcessor::new(context.original_code(), &self.except);
            DefaultVisitor::visit_block(block, &mut processor);
        }
    }
}

impl RuleConfiguration for RemoveComments {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        for (key, value) in properties {
            match key.as_str() {
                "except" => {
                    self.except = value.expect_regex_list(&key)?;
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_COMMENTS_RULE_NAME
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

    fn new_rule() -> RemoveComments {
        RemoveComments::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_comments", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_comments',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }

    #[test]
    fn configure_with_invalid_regex_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_comments',
            except: ["^[0-9"],
        }"#,
        );

        insta::assert_snapshot!(
            "remove_comments_configure_with_invalid_regex_error",
            result.unwrap_err().to_string()
        );
    }

    #[test]
    fn remove_comments_in_code() {
        let code = include_str!("../../tests/test_cases/spaces_and_comments.lua");

        let parser = Parser::default().preserve_tokens();

        let mut block = parser.parse(code).expect("unable to parse code");

        RemoveComments::default().flawless_process(
            &mut block,
            &ContextBuilder::new(".", &Resources::from_memory(), code).build(),
        );

        let mut generator = TokenBasedLuaGenerator::new(code);

        generator.write_block(&block);

        let code_output = &generator.into_string();

        insta::assert_snapshot!("remove_comments_in_code", code_output);
    }

    #[test]
    fn remove_comments_in_code_with_exception() {
        let code = include_str!("../../tests/test_cases/spaces_and_comments.lua");

        let parser = Parser::default().preserve_tokens();

        let mut block = parser.parse(code).expect("unable to parse code");

        RemoveComments::default()
            .with_exception("this.*")
            .flawless_process(
                &mut block,
                &ContextBuilder::new(".", &Resources::from_memory(), code).build(),
            );

        let mut generator = TokenBasedLuaGenerator::new(code);

        generator.write_block(&block);

        let code_output = &generator.into_string();

        insta::assert_snapshot!("remove_comments_in_code_with_exception", code_output);
    }
}
