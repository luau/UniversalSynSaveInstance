use crate::nodes::*;
use crate::process::NodeProcessor;

use std::marker::PhantomData;

/// A trait that defines method that iterates on nodes and process them using a NodeProcessor.
pub trait NodeVisitor<T: NodeProcessor> {
    fn visit_block(block: &mut Block, processor: &mut T) {
        processor.process_block(block);

        block
            .iter_mut_statements()
            .for_each(|statement| Self::visit_statement(statement, processor));

        if let Some(last_statement) = block.mutate_last_statement() {
            Self::visit_last_statement(last_statement, processor);
        };
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
    }

    fn visit_last_statement(last_statement: &mut LastStatement, processor: &mut T) {
        processor.process_last_statement(last_statement);

        if let LastStatement::Return(expressions) = last_statement {
            expressions
                .iter_mut_expressions()
                .for_each(|expression| Self::visit_expression(expression, processor));
        };
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
    }

    fn visit_binary_expression(binary: &mut BinaryExpression, processor: &mut T) {
        processor.process_binary_expression(binary);
        Self::visit_expression(binary.mutate_left(), processor);
        Self::visit_expression(binary.mutate_right(), processor);
    }

    fn visit_number_expression(number: &mut NumberExpression, processor: &mut T) {
        processor.process_number_expression(number);
    }

    fn visit_parenthese_expression(parenthese: &mut ParentheseExpression, processor: &mut T) {
        processor.process_parenthese_expression(parenthese);
        Self::visit_expression(parenthese.mutate_inner_expression(), processor)
    }

    fn visit_string_expression(string: &mut StringExpression, processor: &mut T) {
        processor.process_string_expression(string);
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
    }

    fn visit_unary_expression(unary: &mut UnaryExpression, processor: &mut T) {
        processor.process_unary_expression(unary);
        Self::visit_expression(unary.mutate_expression(), processor);
    }

    fn visit_type_cast_expression(type_cast: &mut TypeCastExpression, processor: &mut T) {
        processor.process_type_cast_expression(type_cast);

        Self::visit_expression(type_cast.mutate_expression(), processor);
        Self::visit_type(type_cast.mutate_type(), processor);
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
    }

    fn visit_do_statement(statement: &mut DoStatement, processor: &mut T) {
        processor.process_do_statement(statement);
        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);
    }

    fn visit_compound_assign(statement: &mut CompoundAssignStatement, processor: &mut T) {
        processor.process_compound_assign_statement(statement);
        Self::visit_variable(statement.mutate_variable(), processor);
        Self::visit_expression(statement.mutate_value(), processor);
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
    }

    fn visit_repeat_statement(statement: &mut RepeatStatement, processor: &mut T) {
        processor.process_repeat_statement(statement);

        let (block, condition) = statement.mutate_block_and_condition();
        processor.process_scope(block, Some(condition));

        Self::visit_expression(statement.mutate_condition(), processor);
        Self::visit_block(statement.mutate_block(), processor);
    }

    fn visit_while_statement(statement: &mut WhileStatement, processor: &mut T) {
        processor.process_while_statement(statement);

        Self::visit_expression(statement.mutate_condition(), processor);

        processor.process_scope(statement.mutate_block(), None);
        Self::visit_block(statement.mutate_block(), processor);
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
    }

    fn visit_variable(variable: &mut Variable, processor: &mut T) {
        processor.process_variable(variable);

        match variable {
            Variable::Identifier(identifier) => Self::visit_identifier(identifier, processor),
            Variable::Field(field) => Self::visit_field_expression(field, processor),
            Variable::Index(index) => Self::visit_index_expression(index, processor),
        }
    }

    fn visit_identifier(identifier: &mut Identifier, processor: &mut T) {
        processor.process_variable_expression(identifier);
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
    }

    fn visit_field_expression(field: &mut FieldExpression, processor: &mut T) {
        processor.process_field_expression(field);

        Self::visit_prefix_expression(field.mutate_prefix(), processor);
    }

    fn visit_index_expression(index: &mut IndexExpression, processor: &mut T) {
        processor.process_index_expression(index);

        Self::visit_prefix_expression(index.mutate_prefix(), processor);
        Self::visit_expression(index.mutate_index(), processor);
    }

    fn visit_function_call(call: &mut FunctionCall, processor: &mut T) {
        processor.process_function_call(call);

        Self::visit_prefix_expression(call.mutate_prefix(), processor);
        Self::visit_arguments(call.mutate_arguments(), processor);
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
    }

    fn visit_type_field(type_field: &mut TypeField, processor: &mut T) {
        processor.process_type_field(type_field);
        Self::visit_type_name(type_field.mutate_type_name(), processor);
    }

    fn visit_array_type(array: &mut ArrayType, processor: &mut T) {
        processor.process_array_type(array);
        Self::visit_type(array.mutate_element_type(), processor);
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
    }

    fn visit_expression_type(expression_type: &mut ExpressionType, processor: &mut T) {
        processor.process_expression_type(expression_type);
        Self::visit_expression(expression_type.mutate_expression(), processor);
    }

    fn visit_parenthese_type(parenthese: &mut ParentheseType, processor: &mut T) {
        processor.process_parenthese_type(parenthese);
        Self::visit_type(parenthese.mutate_inner_type(), processor);
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
    }

    fn visit_optional_type(optional: &mut OptionalType, processor: &mut T) {
        processor.process_optional_type(optional);
        Self::visit_type(optional.mutate_inner_type(), processor);
    }

    fn visit_intersection_type(intersection: &mut IntersectionType, processor: &mut T) {
        processor.process_intersection_type(intersection);

        for r#type in intersection.iter_mut_types() {
            Self::visit_type(r#type, processor);
        }
    }

    fn visit_union_type(union: &mut UnionType, processor: &mut T) {
        processor.process_union_type(union);

        for r#type in union.iter_mut_types() {
            Self::visit_type(r#type, processor);
        }
    }

    fn visit_string_type(string: &mut StringType, processor: &mut T) {
        processor.process_string_type(string);
    }

    fn visit_type_pack(type_pack: &mut TypePack, processor: &mut T) {
        processor.process_type_pack(type_pack);

        for next_type in type_pack.into_iter() {
            Self::visit_type(next_type, processor)
        }
        if let Some(variadic_type) = type_pack.mutate_variadic_type() {
            Self::visit_variadic_argument_type(variadic_type, processor);
        }
    }

    fn visit_variadic_type_pack(variadic_type_pack: &mut VariadicTypePack, processor: &mut T) {
        processor.process_variadic_type_pack(variadic_type_pack);
        Self::visit_type(variadic_type_pack.mutate_type(), processor);
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

/// The default node visitor.
pub struct DefaultVisitor<T> {
    _phantom: PhantomData<T>,
}

impl<T: NodeProcessor> NodeVisitor<T> for DefaultVisitor<T> {}

#[cfg(test)]
mod test {
    use super::*;
    use crate::process::NodeCounter;

    #[test]
    fn visit_do_statement() {
        let mut counter = NodeCounter::new();
        let mut block = Block::default().with_statement(DoStatement::default());

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.do_count, 1);
    }

    #[test]
    fn visit_numeric_for_statement() {
        let mut counter = NodeCounter::new();
        let mut block = Block::default().with_statement(NumericForStatement::new(
            "i".to_owned(),
            Expression::from(true),
            Expression::from(true),
            None,
            Block::default(),
        ));

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.expression_count, 2);
        assert_eq!(counter.numeric_for_count, 1);
    }

    #[test]
    fn visit_generic_for_statement() {
        let mut counter = NodeCounter::new();
        let mut block = Block::default().with_statement(GenericForStatement::new(
            vec!["k".into()],
            vec![Expression::from(true)],
            Block::default(),
        ));

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.generic_for_count, 1);
    }

    #[test]
    fn visit_repeat_statement() {
        let mut counter = NodeCounter::new();
        let mut block =
            Block::default().with_statement(RepeatStatement::new(Block::default(), true));

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.repeat_count, 1);
    }

    #[test]
    fn visit_while_statement() {
        let mut counter = NodeCounter::new();
        let mut block =
            Block::default().with_statement(WhileStatement::new(Block::default(), true));

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.while_count, 1);
    }

    #[test]
    fn visit_if_statement() {
        let mut counter = NodeCounter::new();
        let mut block =
            Block::default().with_statement(IfStatement::create(true, Block::default()));

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 2);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.if_count, 1);
    }

    #[test]
    fn visit_if_statement_with_else() {
        let mut counter = NodeCounter::new();
        let if_statement =
            IfStatement::create(true, Block::default()).with_else_block(Block::default());

        let mut block = Block::default().with_statement(if_statement);

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 3);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.if_count, 1);
    }

    #[test]
    fn visit_if_statement_with_elseif_and_else() {
        let mut counter = NodeCounter::new();
        let if_statement = IfStatement::create(true, Block::default())
            .with_new_branch(false, Block::default())
            .with_else_block(Block::default());

        let mut block = Block::default().with_statement(if_statement);

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.block_count, 4);
        assert_eq!(counter.expression_count, 2);
        assert_eq!(counter.if_count, 1);
    }

    #[test]
    fn visit_compound_assign_statement() {
        let mut counter = NodeCounter::new();
        let statement =
            CompoundAssignStatement::new(CompoundOperator::Plus, Variable::new("var"), 1_f64);

        let mut block = statement.into();

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.compound_assign, 1);
        assert_eq!(counter.expression_count, 1);
        assert_eq!(counter.variable_count, 1);
    }

    #[test]
    fn visit_interpolated_string() {
        let mut counter = NodeCounter::new();
        let statement = LocalAssignStatement::from_variable("value")
            .with_value(InterpolatedStringExpression::empty().with_segment(Expression::from(true)));

        let mut block = statement.into();

        DefaultVisitor::visit_block(&mut block, &mut counter);

        assert_eq!(counter.interpolated_string_count, 1);
        assert_eq!(counter.expression_count, 2);
    }
}
