use std::marker::PhantomData;

use crate::nodes::*;

use super::node_processor::{NodePostProcessor, NodeProcessor};

/// Similar to the NodeVisitor, except that visits the AST using a NodePostVisitor, which
/// makes it possible to run transforms when leaving a node.
pub trait NodePostVisitor<T: NodeProcessor + NodePostProcessor> {
    fn visit_block(block: &mut Block, processor: &mut T) {
        processor.process_block(block);

        block
            .iter_mut_statements()
            .for_each(|statement| Self::visit_statement(statement, processor));

        if let Some(last_statement) = block.mutate_last_statement() {
            Self::visit_last_statement(last_statement, processor);
        };
        processor.process_after_block(block);
    }

    fn visit_statement(statement: &mut Statement, processor: &mut T) {
        processor.process_statement(statement);

        match statement {
            Statement::Assign(statement) => Self::visit_assign_statement(statement, processor),
            Statement::Do(statement) => Self::visit_do_statement(statement, processor),
            Statement::Call(statement) => Self::visit_function_call(statement, processor),
            Statement::CompoundAssign(statement) => {
                Self::visit_compound_assign(statement, processor)
            }
            Statement::Function(statement) => Self::visit_function_statement(statement, processor),
            Statement::GenericFor(statement) => Self::visit_generic_for(statement, processor),
            Statement::If(statement) => Self::visit_if_statement(statement, processor),
            Statement::LocalAssign(statement) => Self::visit_local_assign(statement, processor),
            Statement::LocalFunction(statement) => Self::visit_local_function(statement, processor),
            Statement::NumericFor(statement) => Self::visit_numeric_for(statement, processor),
            Statement::Repeat(statement) => Self::visit_repeat_statement(statement, processor),
            Statement::While(statement) => Self::visit_while_statement(statement, processor),
            Statement::TypeDeclaration(statement) => {
                Self::visit_type_declaration(statement, processor)
            }
        };
        processor.process_after_statement(statement);
    }

    fn visit_last_statement(last_statement: &mut LastStatement, processor: &mut T) {
        processor.process_last_statement(last_statement);

        if let LastStatement::Return(expressions) = last_statement {
            expressions
                .iter_mut_expressions()
                .for_each(|expression| Self::visit_expression(expression, processor));
        };
        processor.process_after_last_statement(last_statement);
    }

    fn visit_expression(expression: &mut Expression, processor: &mut T) {
        processor.process_expression(expression);

        match expression {
            Expression::Binary(expression) => {
                Self::visit_binary_expression(expression, processor);
            }
            Expression::Call(expression) => Self::visit_function_call(expression, processor),
            Expression::Field(field) => Self::visit_field_expression(field, processor),
            Expression::Function(function) => Self::visit_function_expression(function, processor),
            Expression::Identifier(identifier) => Self::visit_identifier(identifier, processor),
            Expression::If(if_expression) => Self::visit_if_expression(if_expression, processor),
            Expression::Index(index) => Self::visit_index_expression(index, processor),
            Expression::Number(number) => Self::visit_number_expression(number, processor),
            Expression::Parenthese(expression) => {
                Self::visit_parenthese_expression(expression, processor);
            }
            Expression::String(string) => {
                Self::visit_string_expression(string, processor);
            }
            Expression::InterpolatedString(interpolated_string) => {
                Self::visit_interpolated_string_expression(interpolated_string, processor);
            }
            Expression::Table(table) => Self::visit_table(table, processor),
            Expression::Unary(unary) => {
                Self::visit_unary_expression(unary, processor);
            }
            Expression::TypeCast(type_cast) => {
                Self::visit_type_cast_expression(type_cast, processor);
            }
            Expression::False(_)
            | Expression::Nil(_)
            | Expression::True(_)
            | Expression::VariableArguments(_) => {}
        }
        processor.process_after_expression(expression);
    }

    fn visit_binary_expression(binary: &mut BinaryExpression, processor: &mut T) {
        processor.process_binary_expression(binary);
        Self::visit_expression(binary.mutate_left(), processor);
        Self::visit_expression(binary.mutate_right(), processor);
        processor.process_after_binary_expression(binary);
    }

    fn visit_number_expression(number: &mut NumberExpression, processor: &mut T) {
        processor.process_number_expression(number);
        processor.process_after_number_expression(number);
    }

    fn visit_parenthese_expression(parenthese: &mut ParentheseExpression, processor: &mut T) {
        processor.process_parenthese_expression(parenthese);
        Self::visit_expression(parenthese.mutate_inner_expression(), processor);
        processor.process_after_parenthese_expression(parenthese);
    }

    fn visit_string_expression(string: &mut StringExpression, processor: &mut T) {
        processor.process_string_expression(string);
        processor.process_after_string_expression(string);
    }

    fn visit_interpolated_string_expression(
        interpolated_string: &mut InterpolatedStringExpression,
        processor: &mut T,
    ) {
        processor.process_interpolated_string_expression(interpolated_string);

        for segment in interpolated_string.iter_mut_segments() {
            match segment {
                InterpolationSegment::String(_) => {}
                InterpolationSegment::Value(value) => {
                    Self::visit_expression(value.mutate_expression(), processor)
                }
            }
        }
        processor.process_after_interpolated_string_expression(interpolated_string);
    }

    fn visit_unary_expression(unary: &mut UnaryExpression, processor: &mut T) {
        processor.process_unary_expression(unary);
        Self::visit_expression(unary.mutate_expression(), processor);
        processor.process_after_unary_expression(unary);
    }

    fn visit_type_cast_expression(type_cast: &mut TypeCastExpression, processor: &mut T) {
        processor.process_type_cast_expression(type_cast);

        Self::visit_expression(type_cast.mutate_expression(), processor);
        Self::visit_type(type_cast.mutate_type(), processor);
        processor.process_after_type_cast_expression(type_cast);
    }

    fn visit_function_expression(function: &mut FunctionExpression, processor: &mut T) {
        processor.process_function_expression(function);

        processor.process_scope(function.mutate_block(), None);

        Self::visit_block(function.mutate_block(), processor);

        for r#type in function
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, processor);
        }

        if let Some(variadic_type) = function.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, processor);
        }

        if let Some(return_type) = function.mutate_return_type() {
            Self::visit_function_return_type(return_type, processor);
        }
        processor.process_after_function_expression(function);
    }

    fn visit_assign_statement(statement: &mut AssignStatement, processor: &mut T) {
        processor.process_assign_statement(statement);

        statement
            .mutate_variables()
            .iter_mut()
            .for_each(|variable| Self::visit_variable(variable, processor));

        statement
            .iter_mut_values()
            .for_each(|expression| Self::visit_expression(expression, processor));
        processor.process_after_assign_statement(statement);
    }

    fn visit_do_statement(statement: &mut DoStatement, processor: &mut T) {
        processor.process_do_statement(statement);
        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);
        processor.process_after_do_statement(statement);
    }

    fn visit_compound_assign(statement: &mut CompoundAssignStatement, processor: &mut T) {
        processor.process_compound_assign_statement(statement);
        Self::visit_variable(statement.mutate_variable(), processor);
        Self::visit_expression(statement.mutate_value(), processor);
        processor.process_after_compound_assign_statement(statement);
    }

    fn visit_function_statement(statement: &mut FunctionStatement, processor: &mut T) {
        processor.process_function_statement(statement);

        Self::visit_identifier(
            statement.mutate_function_name().mutate_identifier(),
            processor,
        );

        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, processor);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, processor);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, processor);
        }
        processor.process_after_function_statement(statement);
    }

    fn visit_generic_for(statement: &mut GenericForStatement, processor: &mut T) {
        processor.process_generic_for_statement(statement);

        statement
            .iter_mut_expressions()
            .for_each(|expression| Self::visit_expression(expression, processor));

        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);

        for r#type in statement
            .iter_mut_identifiers()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, processor);
        }
        processor.process_after_generic_for_statement(statement);
    }

    fn visit_if_statement(statement: &mut IfStatement, processor: &mut T) {
        processor.process_if_statement(statement);

        statement.mutate_branches().iter_mut().for_each(|branch| {
            Self::visit_expression(branch.mutate_condition(), processor);
            processor.process_scope(branch.mutate_block(), None);
            Self::visit_block(branch.mutate_block(), processor);
        });

        if let Some(block) = statement.mutate_else_block() {
            processor.process_scope(block, None);
            Self::visit_block(block, processor);
        }
        processor.process_after_if_statement(statement);
    }

    fn visit_local_assign(statement: &mut LocalAssignStatement, processor: &mut T) {
        processor.process_local_assign_statement(statement);

        statement
            .iter_mut_values()
            .for_each(|value| Self::visit_expression(value, processor));

        for r#type in statement
            .iter_mut_variables()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, processor);
        }
        processor.process_after_local_assign_statement(statement);
    }

    fn visit_local_function(statement: &mut LocalFunctionStatement, processor: &mut T) {
        processor.process_local_function_statement(statement);
        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);

        for r#type in statement
            .iter_mut_parameters()
            .filter_map(TypedIdentifier::mutate_type)
        {
            Self::visit_type(r#type, processor);
        }

        if let Some(variadic_type) = statement.mutate_variadic_type() {
            Self::visit_function_variadic_type(variadic_type, processor);
        }

        if let Some(return_type) = statement.mutate_return_type() {
            Self::visit_function_return_type(return_type, processor);
        }
        processor.process_after_local_function_statement(statement);
    }

    fn visit_function_variadic_type(variadic_type: &mut FunctionVariadicType, processor: &mut T) {
        match variadic_type {
            FunctionVariadicType::Type(r#type) => {
                Self::visit_type(r#type, processor);
            }
            FunctionVariadicType::GenericTypePack(generic) => {
                Self::visit_generic_type_pack(generic, processor);
            }
        }
    }

    fn visit_generic_type_pack(generic: &mut GenericTypePack, processor: &mut T) {
        processor.process_generic_type_pack(generic);
        processor.process_after_generic_type_pack(generic);
    }

    fn visit_numeric_for(statement: &mut NumericForStatement, processor: &mut T) {
        processor.process_numeric_for_statement(statement);

        Self::visit_expression(statement.mutate_start(), processor);
        Self::visit_expression(statement.mutate_end(), processor);

        if let Some(step) = statement.mutate_step() {
            Self::visit_expression(step, processor);
        };

        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);

        if let Some(r#type) = statement.mutate_identifier().mutate_type() {
            Self::visit_type(r#type, processor);
        }
        processor.process_after_numeric_for_statement(statement);
    }

    fn visit_repeat_statement(statement: &mut RepeatStatement, processor: &mut T) {
        processor.process_repeat_statement(statement);

        let (block, condition) = statement.mutate_block_and_condition();
        processor.process_scope(block, Some(condition));

        Self::visit_expression(statement.mutate_condition(), processor);
        Self::visit_block(statement.mutate_block(), processor);
        processor.process_after_repeat_statement(statement);
    }

    fn visit_while_statement(statement: &mut WhileStatement, processor: &mut T) {
        processor.process_while_statement(statement);

        Self::visit_expression(statement.mutate_condition(), processor);

        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);
        processor.process_after_while_statement(statement);
    }

    fn visit_type_declaration(statement: &mut TypeDeclarationStatement, processor: &mut T) {
        processor.process_type_declaration(statement);

        if let Some(generic_parameters) = statement.mutate_generic_parameters() {
            for parameter in generic_parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(_) => {}
                    GenericParameterMutRef::TypeVariableWithDefault(type_variable) => {
                        Self::visit_type(type_variable.mutate_default_type(), processor);
                    }
                    GenericParameterMutRef::GenericTypePack(generic_type_pack) => {
                        Self::visit_generic_type_pack(generic_type_pack, processor);
                    }
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_type_pack_with_default,
                    ) => {
                        Self::visit_generic_type_pack(
                            generic_type_pack_with_default.mutate_generic_type_pack(),
                            processor,
                        );

                        match generic_type_pack_with_default.mutate_default_type() {
                            GenericTypePackDefault::TypePack(type_pack) => {
                                Self::visit_type_pack(type_pack, processor);
                            }
                            GenericTypePackDefault::VariadicTypePack(variadic_type_pack) => {
                                Self::visit_variadic_type_pack(variadic_type_pack, processor);
                            }
                            GenericTypePackDefault::GenericTypePack(generic_type_pack) => {
                                Self::visit_generic_type_pack(generic_type_pack, processor);
                            }
                        }
                    }
                }
            }
        }

        Self::visit_type(statement.mutate_type(), processor);
        processor.process_after_type_declaration(statement);
    }

    fn visit_variable(variable: &mut Variable, processor: &mut T) {
        processor.process_variable(variable);

        match variable {
            Variable::Identifier(identifier) => Self::visit_identifier(identifier, processor),
            Variable::Field(field) => Self::visit_field_expression(field, processor),
            Variable::Index(index) => Self::visit_index_expression(index, processor),
        }
        processor.process_after_variable(variable);
    }

    fn visit_identifier(identifier: &mut Identifier, processor: &mut T) {
        processor.process_variable_expression(identifier);
        processor.process_after_variable_expression(identifier);
    }

    fn visit_if_expression(if_expression: &mut IfExpression, processor: &mut T) {
        processor.process_if_expression(if_expression);

        Self::visit_expression(if_expression.mutate_condition(), processor);
        Self::visit_expression(if_expression.mutate_result(), processor);

        for branch in if_expression.iter_mut_branches() {
            Self::visit_expression(branch.mutate_condition(), processor);
            Self::visit_expression(branch.mutate_result(), processor);
        }

        Self::visit_expression(if_expression.mutate_else_result(), processor);
        processor.process_after_if_expression(if_expression);
    }

    fn visit_field_expression(field: &mut FieldExpression, processor: &mut T) {
        processor.process_field_expression(field);

        Self::visit_prefix_expression(field.mutate_prefix(), processor);
        processor.process_after_field_expression(field);
    }

    fn visit_index_expression(index: &mut IndexExpression, processor: &mut T) {
        processor.process_index_expression(index);

        Self::visit_prefix_expression(index.mutate_prefix(), processor);
        Self::visit_expression(index.mutate_index(), processor);
        processor.process_after_index_expression(index);
    }

    fn visit_function_call(call: &mut FunctionCall, processor: &mut T) {
        processor.process_function_call(call);

        Self::visit_prefix_expression(call.mutate_prefix(), processor);
        Self::visit_arguments(call.mutate_arguments(), processor);
        processor.process_after_function_call(call);
    }

    fn visit_arguments(arguments: &mut Arguments, processor: &mut T) {
        match arguments {
            Arguments::String(string) => Self::visit_string_expression(string, processor),
            Arguments::Table(table) => Self::visit_table(table, processor),
            Arguments::Tuple(expressions) => expressions
                .iter_mut_values()
                .for_each(|expression| Self::visit_expression(expression, processor)),
        }
    }

    fn visit_table(table: &mut TableExpression, processor: &mut T) {
        processor.process_table_expression(table);

        table.iter_mut_entries().for_each(|entry| match entry {
            TableEntry::Field(entry) => Self::visit_expression(entry.mutate_value(), processor),
            TableEntry::Index(entry) => {
                Self::visit_expression(entry.mutate_key(), processor);
                Self::visit_expression(entry.mutate_value(), processor);
            }
            TableEntry::Value(value) => Self::visit_expression(value, processor),
        });
        processor.process_after_table_expression(table);
    }

    fn visit_prefix_expression(prefix: &mut Prefix, processor: &mut T) {
        processor.process_prefix_expression(prefix);

        match prefix {
            Prefix::Call(call) => Self::visit_function_call(call, processor),
            Prefix::Field(field) => Self::visit_field_expression(field, processor),
            Prefix::Identifier(identifier) => Self::visit_identifier(identifier, processor),
            Prefix::Index(index) => Self::visit_index_expression(index, processor),
            Prefix::Parenthese(expression) => {
                Self::visit_parenthese_expression(expression, processor)
            }
        };
        processor.process_after_prefix_expression(prefix);
    }

    fn visit_type(r#type: &mut Type, processor: &mut T) {
        processor.process_type(r#type);

        match r#type {
            Type::Name(type_name) => Self::visit_type_name(type_name, processor),
            Type::Field(type_field) => Self::visit_type_field(type_field, processor),
            Type::Array(array) => Self::visit_array_type(array, processor),
            Type::Table(table) => Self::visit_table_type(table, processor),
            Type::TypeOf(expression_type) => {
                Self::visit_expression_type(expression_type, processor)
            }
            Type::Parenthese(parenthese) => Self::visit_parenthese_type(parenthese, processor),
            Type::Function(function) => Self::visit_function_type(function, processor),
            Type::Optional(optional) => Self::visit_optional_type(optional, processor),
            Type::Intersection(intersection) => {
                Self::visit_intersection_type(intersection, processor)
            }
            Type::Union(union) => Self::visit_union_type(union, processor),
            Type::String(string) => Self::visit_string_type(string, processor),
            Type::True(_) | Type::False(_) | Type::Nil(_) => {}
        }
        processor.process_after_type(r#type);
    }

    fn visit_type_name(type_name: &mut TypeName, processor: &mut T) {
        processor.process_type_name(type_name);

        if let Some(type_parameters) = type_name.mutate_type_parameters() {
            for type_parameter in type_parameters {
                match type_parameter {
                    TypeParameter::Type(next_type) => {
                        Self::visit_type(next_type, processor);
                    }
                    TypeParameter::TypePack(type_pack) => {
                        Self::visit_type_pack(type_pack, processor);
                    }
                    TypeParameter::VariadicTypePack(variadic_type_pack) => {
                        Self::visit_variadic_type_pack(variadic_type_pack, processor);
                    }
                    TypeParameter::GenericTypePack(generic_type_pack) => {
                        Self::visit_generic_type_pack(generic_type_pack, processor);
                    }
                }
            }
        }
        processor.process_after_type_name(type_name);
    }

    fn visit_type_field(type_field: &mut TypeField, processor: &mut T) {
        processor.process_type_field(type_field);
        Self::visit_type_name(type_field.mutate_type_name(), processor);
        processor.process_after_type_field(type_field);
    }

    fn visit_array_type(array: &mut ArrayType, processor: &mut T) {
        processor.process_array_type(array);
        Self::visit_type(array.mutate_element_type(), processor);
        processor.process_after_array_type(array);
    }

    fn visit_table_type(table: &mut TableType, processor: &mut T) {
        processor.process_table_type(table);

        for entry in table.iter_mut_entries() {
            match entry {
                TableEntryType::Property(property) => {
                    Self::visit_type(property.mutate_type(), processor);
                }
                TableEntryType::Literal(property) => {
                    Self::visit_string_type(property.mutate_string(), processor);
                    Self::visit_type(property.mutate_type(), processor);
                }
                TableEntryType::Indexer(indexer) => {
                    Self::visit_type(indexer.mutate_key_type(), processor);
                    Self::visit_type(indexer.mutate_value_type(), processor);
                }
            }
        }
        processor.process_after_table_type(table);
    }

    fn visit_expression_type(expression_type: &mut ExpressionType, processor: &mut T) {
        processor.process_expression_type(expression_type);
        Self::visit_expression(expression_type.mutate_expression(), processor);
        processor.process_after_expression_type(expression_type);
    }

    fn visit_parenthese_type(parenthese: &mut ParentheseType, processor: &mut T) {
        processor.process_parenthese_type(parenthese);
        Self::visit_type(parenthese.mutate_inner_type(), processor);
        processor.process_after_parenthese_type(parenthese);
    }

    fn visit_function_type(function: &mut FunctionType, processor: &mut T) {
        processor.process_function_type(function);

        for argument in function.iter_mut_arguments() {
            Self::visit_type(argument.mutate_type(), processor);
        }

        if let Some(variadic_type) = function.mutate_variadic_argument_type() {
            Self::visit_variadic_argument_type(variadic_type, processor);
        }

        Self::visit_function_return_type(function.mutate_return_type(), processor);

        processor.process_after_function_type(function);
    }

    fn visit_optional_type(optional: &mut OptionalType, processor: &mut T) {
        processor.process_optional_type(optional);
        Self::visit_type(optional.mutate_inner_type(), processor);
        processor.process_after_optional_type(optional);
    }

    fn visit_intersection_type(intersection: &mut IntersectionType, processor: &mut T) {
        processor.process_intersection_type(intersection);

        for r#type in intersection.iter_mut_types() {
            Self::visit_type(r#type, processor);
        }
        processor.process_after_intersection_type(intersection);
    }

    fn visit_union_type(union: &mut UnionType, processor: &mut T) {
        processor.process_union_type(union);

        for r#type in union.iter_mut_types() {
            Self::visit_type(r#type, processor);
        }
        processor.process_after_union_type(union);
    }

    fn visit_string_type(string: &mut StringType, processor: &mut T) {
        processor.process_string_type(string);
        processor.process_after_string_type(string);
    }

    fn visit_type_pack(type_pack: &mut TypePack, processor: &mut T) {
        processor.process_type_pack(type_pack);

        for next_type in type_pack.into_iter() {
            Self::visit_type(next_type, processor)
        }
        if let Some(variadic_type) = type_pack.mutate_variadic_type() {
            Self::visit_variadic_argument_type(variadic_type, processor);
        }
        processor.process_after_type_pack(type_pack);
    }

    fn visit_variadic_type_pack(variadic_type_pack: &mut VariadicTypePack, processor: &mut T) {
        processor.process_variadic_type_pack(variadic_type_pack);
        Self::visit_type(variadic_type_pack.mutate_type(), processor);
        processor.process_after_variadic_type_pack(variadic_type_pack);
    }

    fn visit_variadic_argument_type(variadic_type: &mut VariadicArgumentType, processor: &mut T) {
        match variadic_type {
            VariadicArgumentType::VariadicTypePack(variadic_type_pack) => {
                Self::visit_variadic_type_pack(variadic_type_pack, processor);
            }
            VariadicArgumentType::GenericTypePack(generic_type_pack) => {
                Self::visit_generic_type_pack(generic_type_pack, processor);
            }
        }
    }

    fn visit_function_return_type(
        function_return_type: &mut FunctionReturnType,
        processor: &mut T,
    ) {
        match function_return_type {
            FunctionReturnType::Type(next_type) => {
                Self::visit_type(next_type, processor);
            }
            FunctionReturnType::TypePack(type_pack) => Self::visit_type_pack(type_pack, processor),
            FunctionReturnType::VariadicTypePack(variadic_type_pack) => {
                Self::visit_variadic_type_pack(variadic_type_pack, processor);
            }
            FunctionReturnType::GenericTypePack(generic_type_pack) => {
                Self::visit_generic_type_pack(generic_type_pack, processor);
            }
        }
    }
}

/// A node visitor for NodePostVisitor.
pub struct DefaultPostVisitor<T> {
    _phantom: PhantomData<T>,
}

impl<T: NodeProcessor + NodePostProcessor> NodePostVisitor<T> for DefaultPostVisitor<T> {}
