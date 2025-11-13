mod budget;
pub mod combination;
mod fuzzer_work;
mod random;

pub use budget::FuzzBudget;
use fuzzer_work::*;
use rand::seq::SliceRandom;
use random::RandomAst;

use std::iter::{self, FromIterator};

use darklua_core::nodes::*;

pub struct AstFuzzer {
    budget: FuzzBudget,
    random: RandomAst,
    blocks: Vec<Block>,
    expressions: Vec<Expression>,
    statements: Vec<Statement>,
    last_statements: Vec<LastStatement>,
    calls: Vec<FunctionCall>,
    types: Vec<Type>,
    prefixes: Vec<Prefix>,
    variables: Vec<Variable>,
    arguments: Vec<Arguments>,
    tables: Vec<TableExpression>,
    typed_identifiers: Vec<TypedIdentifier>,
    function_return_types: Vec<FunctionReturnType>,
    type_packs: Vec<TypePack>,
    type_parameters: Vec<TypeParameter>,
    work_stack: Vec<AstFuzzerWork>,
}

impl AstFuzzer {
    pub fn new(budget: FuzzBudget) -> Self {
        Self {
            budget,
            work_stack: Vec::new(),
            blocks: Vec::new(),
            expressions: Vec::new(),
            statements: Vec::new(),
            last_statements: Vec::new(),
            calls: Vec::new(),
            types: Vec::new(),
            prefixes: Vec::new(),
            variables: Vec::new(),
            arguments: Vec::new(),
            tables: Vec::new(),
            typed_identifiers: Vec::new(),
            function_return_types: Vec::new(),
            type_packs: Vec::new(),
            type_parameters: Vec::new(),
            random: RandomAst::default(),
        }
    }

    pub fn fuzz_block(mut self) -> Block {
        self.work_stack.push(AstFuzzerWork::FuzzBlock);

        self.execute_work();

        let mut block = self.pop_block();

        while self.budget.take_statement() {
            self.push_work(AstFuzzerWork::FuzzStatement);
            self.execute_work();
            block.push_statement(self.pop_statement());
        }

        block
    }

    fn push_work(&mut self, work: AstFuzzerWork) {
        self.work_stack.push(work);
    }

    fn push_repeated_work(&mut self, work: AstFuzzerWork, amount: usize) {
        for _ in 0..amount {
            self.work_stack.push(work.clone());
        }
    }

    fn execute_work(&mut self) {
        while let Some(work) = self.work_stack.pop() {
            match work {
                AstFuzzerWork::FuzzBlock => {
                    let has_last_statement =
                        self.random.last_statement() && self.budget.take_statement();
                    let statement_count =
                        self.budget.try_take_statements(self.random.block_length());

                    self.push_work(AstFuzzerWork::MakeBlock {
                        has_last_statement,
                        statement_count,
                    });

                    if has_last_statement {
                        self.push_work(AstFuzzerWork::FuzzLastStatement);
                    }

                    self.push_repeated_work(AstFuzzerWork::FuzzStatement, statement_count);
                }
                AstFuzzerWork::FuzzStatement => {
                    match self
                        .random
                        .range(if self.budget.has_types() { 12 } else { 11 })
                    {
                        0 => {
                            let variables = self.random.assignment_variables();
                            let expressions = self
                                .budget
                                .try_take_expressions(self.random.assignment_expressions())
                                .max(1);
                            self.push_work(AstFuzzerWork::MakeAssignStatement {
                                variables,
                                expressions,
                            });

                            self.push_repeated_work(AstFuzzerWork::FuzzVariable, variables);
                            self.fuzz_multiple_expression(expressions);
                        }
                        1 => {
                            self.push_work(AstFuzzerWork::MakeDoStatement);
                            self.push_work(AstFuzzerWork::FuzzBlock);
                        }
                        2 => {
                            self.push_work(AstFuzzerWork::MakeCallStatement);
                            self.push_work(AstFuzzerWork::MakeFunctionCall);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.push_work(AstFuzzerWork::FuzzArguments);
                        }
                        3 => {
                            self.generate_function(
                                |parameters, has_return_type, has_variadic_type| {
                                    AstFuzzerWork::MakeFunctionStatement {
                                        parameters,
                                        has_return_type,
                                        has_variadic_type,
                                    }
                                },
                            );
                        }
                        4 => {
                            let variables = self.random.generic_for_variables();
                            let expressions = self
                                .budget
                                .try_take_expressions(self.random.generic_for_expressions())
                                .max(1);

                            self.push_work(AstFuzzerWork::MakeGenericForStatement {
                                variables,
                                expressions,
                            });

                            self.push_repeated_work(AstFuzzerWork::FuzzTypedIdentifier, variables);
                            self.fuzz_multiple_expression(expressions);
                            self.push_work(AstFuzzerWork::FuzzBlock);
                        }
                        5 => {
                            self.budget.take_expression();
                            let branches = self
                                .budget
                                .try_take_expressions(self.random.if_statement_branches())
                                .max(1);
                            let else_branch = self.random.if_statement_else_branch();

                            self.push_work(AstFuzzerWork::MakeIfStatement {
                                branches,
                                else_branch,
                            });

                            for _ in 0..branches {
                                self.fuzz_expression();
                                self.push_work(AstFuzzerWork::FuzzBlock);
                            }

                            if else_branch {
                                self.push_work(AstFuzzerWork::FuzzBlock);
                            }
                        }
                        6 => {
                            let variables = self.random.assignment_variables();
                            let expressions = self
                                .budget
                                .try_take_expressions(self.random.assignment_expressions());

                            self.push_work(AstFuzzerWork::MakeLocalAssignStatement {
                                variables,
                                expressions,
                            });

                            self.push_repeated_work(AstFuzzerWork::FuzzTypedIdentifier, variables);
                            self.fuzz_multiple_expression(expressions);
                        }
                        7 => {
                            self.generate_function(
                                |parameters, has_return_type, has_variadic_type| {
                                    AstFuzzerWork::MakeLocalFunctionStatement {
                                        parameters,
                                        has_return_type,
                                        has_variadic_type,
                                    }
                                },
                            );
                        }
                        8 => {
                            self.budget.try_take_expressions(2);
                            let has_step =
                                self.budget.take_expression() && self.random.numeric_for_step();

                            self.push_work(AstFuzzerWork::MakeNumericForStatement { has_step });
                            self.push_work(AstFuzzerWork::FuzzBlock);
                            self.push_work(AstFuzzerWork::FuzzTypedIdentifier);
                            self.fuzz_expression();
                            self.fuzz_expression();

                            if has_step {
                                self.fuzz_expression();
                            }
                        }
                        9 => {
                            self.push_work(AstFuzzerWork::MakeRepeatStatement);
                            self.push_work(AstFuzzerWork::FuzzBlock);
                            self.budget.take_expression();
                            self.fuzz_expression();
                        }
                        10 => {
                            self.push_work(AstFuzzerWork::MakeWhileStatement);
                            self.push_work(AstFuzzerWork::FuzzBlock);
                            self.budget.take_expression();
                            self.fuzz_expression();
                        }
                        11 => {
                            self.push_work(AstFuzzerWork::MakeCompoundAssignStatement);
                            self.push_work(AstFuzzerWork::FuzzVariable);
                            self.budget.take_expression();
                            self.fuzz_expression();
                        }
                        _ => {
                            // take type for declared type
                            self.budget.take_type();

                            let type_parameter_with_defaults = if self.budget.has_types()
                                && self.random.generic_type_declaration()
                            {
                                let length = self
                                    .budget
                                    .try_take_types(self.random.generic_type_declaration_length())
                                    .max(1);

                                let middle = match self.random.range(2) {
                                    0 => TypeParameterWithDefaultKind::GenericPack,
                                    _ => TypeParameterWithDefaultKind::VariableWithType,
                                };

                                iter::repeat_with(|| match self.random.range(if self.budget.has_types() {4} else {0}) {
                                    0 => TypeParameterWithDefaultKind::Variable,
                                    1 => TypeParameterWithDefaultKind::GenericPackWithTypePack,
                                    2 => TypeParameterWithDefaultKind::GenericPackWithVariadicPack,
                                    3 => TypeParameterWithDefaultKind::GenericPackWithGenericPack,
                                    _ => middle,
                                })
                                .take(length)
                                .collect()
                            } else {
                                Vec::new()
                            };

                            self.push_work(AstFuzzerWork::MakeTypeDeclaration {
                                type_parameter_with_defaults: type_parameter_with_defaults.clone(),
                            });

                            self.fuzz_type();

                            for parameter in type_parameter_with_defaults {
                                match parameter {
                                    TypeParameterWithDefaultKind::Variable => {}
                                    TypeParameterWithDefaultKind::VariableWithType => {
                                        self.fuzz_type();
                                    }
                                    TypeParameterWithDefaultKind::GenericPack => {}
                                    TypeParameterWithDefaultKind::GenericPackWithTypePack => {
                                        self.push_work(AstFuzzerWork::FuzzTypePack);
                                    }
                                    TypeParameterWithDefaultKind::GenericPackWithVariadicPack => {
                                        self.fuzz_type();
                                    }
                                    TypeParameterWithDefaultKind::GenericPackWithGenericPack => {}
                                }
                            }
                        }
                    }
                }
                AstFuzzerWork::MakeTypeDeclaration {
                    type_parameter_with_defaults,
                } => {
                    let mut type_declaration =
                        TypeDeclarationStatement::new(self.random.identifier(), self.pop_type());

                    if self.random.export_type_declaration() {
                        type_declaration.set_exported();
                    }

                    let mut iter_parameters = type_parameter_with_defaults.into_iter();

                    if let Some(parameter) = iter_parameters.next() {
                        let mut parameter_list = match parameter {
                            TypeParameterWithDefaultKind::Variable => {
                                GenericParametersWithDefaults::from_type_variable(
                                    self.random.identifier(),
                                )
                            }
                            TypeParameterWithDefaultKind::VariableWithType => {
                                GenericParametersWithDefaults::from_type_variable_with_default(
                                    TypeVariableWithDefault::new(
                                        self.random.identifier(),
                                        self.pop_type(),
                                    ),
                                )
                            }
                            TypeParameterWithDefaultKind::GenericPack => {
                                GenericParametersWithDefaults::from_generic_type_pack(
                                    GenericTypePack::new(self.random.identifier()),
                                )
                            }
                            TypeParameterWithDefaultKind::GenericPackWithTypePack => {
                                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                                    GenericTypePackWithDefault::new(
                                        GenericTypePack::new(self.random.identifier()),
                                        self.pop_type_pack(),
                                    ),
                                )
                            }
                            TypeParameterWithDefaultKind::GenericPackWithVariadicPack => {
                                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                                    GenericTypePackWithDefault::new(
                                        GenericTypePack::new(self.random.identifier()),
                                        self.pop_variadic_type_pack(),
                                    ),
                                )
                            }
                            TypeParameterWithDefaultKind::GenericPackWithGenericPack => {
                                GenericParametersWithDefaults::from_generic_type_pack_with_default(
                                    GenericTypePackWithDefault::new(
                                        GenericTypePack::new(self.random.identifier()),
                                        GenericTypePack::new(self.random.identifier()),
                                    ),
                                )
                            }
                        };

                        for parameter in iter_parameters {
                            let identifier = self.random.identifier();
                            match parameter {
                                TypeParameterWithDefaultKind::Variable => {
                                    parameter_list.push_type_variable(identifier);
                                }
                                TypeParameterWithDefaultKind::VariableWithType => {
                                    parameter_list.push_type_variable_with_default(
                                        TypeVariableWithDefault::new(identifier, self.pop_type()),
                                    );
                                }
                                TypeParameterWithDefaultKind::GenericPack => {
                                    parameter_list
                                        .push_generic_type_pack(GenericTypePack::new(identifier));
                                }
                                TypeParameterWithDefaultKind::GenericPackWithTypePack => {
                                    parameter_list.push_generic_type_pack_with_default(
                                        GenericTypePackWithDefault::new(
                                            GenericTypePack::new(identifier),
                                            self.pop_type_pack(),
                                        ),
                                    );
                                }
                                TypeParameterWithDefaultKind::GenericPackWithVariadicPack => {
                                    parameter_list.push_generic_type_pack_with_default(
                                        GenericTypePackWithDefault::new(
                                            GenericTypePack::new(identifier),
                                            self.pop_variadic_type_pack(),
                                        ),
                                    );
                                }
                                TypeParameterWithDefaultKind::GenericPackWithGenericPack => {
                                    parameter_list.push_generic_type_pack_with_default(
                                        GenericTypePackWithDefault::new(
                                            GenericTypePack::new(identifier),
                                            GenericTypePack::new(self.random.identifier()),
                                        ),
                                    );
                                }
                            }
                        }

                        type_declaration.set_generic_parameters(parameter_list);
                    }

                    self.statements.push(type_declaration.into());
                }
                AstFuzzerWork::FuzzLastStatement => match self.random.range(2) {
                    0 => {
                        self.last_statements.push(LastStatement::new_break());
                    }
                    1 => {
                        self.last_statements.push(LastStatement::new_continue());
                    }
                    _ => {
                        let expressions = self
                            .budget
                            .try_take_expressions(self.random.return_length());
                        self.push_work(AstFuzzerWork::MakeReturnStatement { expressions });
                        self.fuzz_multiple_expression(expressions);
                    }
                },
                AstFuzzerWork::FuzzExpression { depth } => {
                    let start = if !self.random.nested_expression(depth) {
                        6
                    } else if self.budget.can_have_expression(3) {
                        0
                    } else if self.budget.can_have_expression(2) {
                        1
                    } else if self.budget.has_expressions() {
                        4
                    } else {
                        6
                    };
                    let bound = if self.budget.has_types() && self.budget.has_expressions() {
                        16
                    } else {
                        15
                    };
                    match self.random.full_range(start, bound) {
                        0 => {
                            self.budget.try_take_expressions(3);
                            let elseifs = self
                                .random
                                .if_expression_branches()
                                .min(self.budget.remaining_expressions() / 2);
                            self.budget.try_take_expressions(elseifs * 2);

                            self.push_work(AstFuzzerWork::MakeIfExpression { elseifs });
                            self.fuzz_multiple_nested_expression(depth, 3 + 2 * elseifs)
                        }
                        1 => {
                            self.budget.try_take_expressions(2);

                            self.push_work(AstFuzzerWork::MakeBinaryExpression);
                            self.fuzz_nested_expression(depth);
                            self.fuzz_nested_expression(depth);
                        }
                        2 => {
                            self.budget.try_take_expressions(2);
                            self.push_work(AstFuzzerWork::MakeIndexExpression);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.fuzz_nested_expression(depth);
                        }
                        3 => {
                            self.budget.try_take_expressions(2);
                            self.push_work(AstFuzzerWork::MakeFieldExpression);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.fuzz_nested_expression(depth);
                        }
                        4 => {
                            self.budget.try_take_expressions(1);
                            self.push_work(AstFuzzerWork::MakeParentheseExpression);
                            self.fuzz_nested_expression(depth);
                        }
                        5 => {
                            self.budget.try_take_expressions(1);
                            self.push_work(AstFuzzerWork::MakeUnaryExpression);
                            self.fuzz_nested_expression(depth);
                        }

                        6 => {
                            self.expressions.push(true.into());
                        }
                        7 => {
                            self.expressions.push(true.into());
                        }
                        8 => {
                            self.expressions.push(Expression::nil());
                        }
                        9 => {
                            self.expressions.push(Expression::variable_arguments());
                        }
                        10 => {
                            self.push_work(AstFuzzerWork::MakeCallExpression);
                            self.push_work(AstFuzzerWork::MakeFunctionCall);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.push_work(AstFuzzerWork::FuzzArguments);
                        }
                        11 => {
                            self.generate_function(
                                |parameters, has_return_type, has_variadic_type| {
                                    AstFuzzerWork::MakeFunctionExpression {
                                        parameters,
                                        has_return_type,
                                        has_variadic_type,
                                    }
                                },
                            );
                        }
                        12 => {
                            self.expressions.push(self.random.identifier().into());
                        }
                        13 => {
                            let number = match self.random.range(2) {
                                0 => DecimalNumber::new(self.random.decimal_number()).into(),
                                1 => HexNumber::new(
                                    self.random.hexadecimal_number(),
                                    self.random.number_exponent_uppercase(),
                                )
                                .into(),
                                _ => BinaryNumber::new(
                                    self.random.binary_number(),
                                    self.random.number_exponent_uppercase(),
                                )
                                .into(),
                            };
                            self.expressions.push(number);
                        }
                        14 => {
                            self.expressions.push(
                                StringExpression::from_value(self.random.string_content()).into(),
                            );
                        }
                        15 => {
                            self.push_work(AstFuzzerWork::MakeTableExpression);
                            self.push_work(AstFuzzerWork::FuzzTable);
                        }
                        16 => {
                            let length = self.random.interpolated_string_segments();
                            let segment_is_expression: Vec<_> = iter::repeat_with(|| {
                                self.random.interpolated_segment_is_expression()
                                    && self.budget.take_expression()
                            })
                            .take(length)
                            .collect();

                            let expression_count =
                                segment_is_expression.iter().filter(|v| **v).count();

                            self.push_work(AstFuzzerWork::MakeInterpolatedString {
                                segment_is_expression,
                            });
                            self.fuzz_multiple_nested_expression(depth, expression_count);
                        }
                        _ => {
                            self.budget.try_take_expressions(1);

                            self.push_work(AstFuzzerWork::MakeTypeCastExpression);
                            self.fuzz_nested_expression(depth);
                            self.fuzz_type();
                        }
                    }
                }
                AstFuzzerWork::FuzzPrefix => {
                    let bound = if self.budget.can_have_expression(2) {
                        4
                    } else if self.budget.has_expressions() {
                        3
                    } else {
                        0
                    };
                    match self.random.range(bound) {
                        0 => {
                            self.prefixes.push(self.random.identifier().into());
                        }
                        1 => {
                            self.budget.take_expression();
                            self.push_work(AstFuzzerWork::MakeFieldPrefix);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                        }
                        2 => {
                            self.budget.take_expression();
                            self.push_work(AstFuzzerWork::MakeParenthesePrefix);
                            self.fuzz_nested_expression(0);
                        }
                        3 => {
                            self.budget.take_expression();
                            self.push_work(AstFuzzerWork::MakeCallPrefix);
                            self.push_work(AstFuzzerWork::MakeFunctionCall);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.push_work(AstFuzzerWork::FuzzArguments);
                        }
                        _ => {
                            self.budget.try_take_expressions(2);
                            self.push_work(AstFuzzerWork::MakeIndexPrefix);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.fuzz_nested_expression(0);
                        }
                    }
                }
                AstFuzzerWork::FuzzVariable => {
                    let bound = if self.budget.can_have_expression(2) {
                        2
                    } else if self.budget.has_expressions() {
                        1
                    } else {
                        0
                    };
                    match self.random.range(bound) {
                        0 => {
                            self.variables.push(self.random.identifier().into());
                        }
                        1 => {
                            self.push_work(AstFuzzerWork::MakeVariable {
                                kind: VariableKind::Field,
                            });
                            self.budget.try_take_expressions(1);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                        }
                        _ => {
                            self.push_work(AstFuzzerWork::MakeVariable {
                                kind: VariableKind::Index,
                            });
                            self.budget.try_take_expressions(2);
                            self.push_work(AstFuzzerWork::FuzzPrefix);
                            self.fuzz_expression();
                        }
                    }
                }
                AstFuzzerWork::FuzzArguments => {
                    let bound = if self.budget.can_have_expression(1) {
                        2
                    } else {
                        0
                    };
                    match self.random.range(bound) {
                        0 => {
                            let expressions = self
                                .budget
                                .try_take_expressions(self.random.call_arguments());
                            self.push_work(AstFuzzerWork::MakeTupleArguments { expressions });
                            self.fuzz_multiple_expression(expressions);
                        }
                        1 => {
                            self.budget.take_expression();
                            self.push_work(AstFuzzerWork::MakeTableArguments);
                            self.push_work(AstFuzzerWork::FuzzTable);
                        }
                        _ => {
                            self.budget.take_expression();
                            self.arguments
                                .push(Arguments::String(StringExpression::from_value(
                                    self.random.string_content(),
                                )));
                        }
                    }
                }
                AstFuzzerWork::FuzzTable => {
                    let mut entries = Vec::new();

                    for _ in 0..self.random.table_length() {
                        if !self.budget.has_expressions() {
                            break;
                        }
                        let bound = if self.budget.can_have_expression(2) {
                            2
                        } else {
                            1
                        };

                        self.budget.take_expression();

                        let entry = match self.random.range(bound) {
                            0 => TableEntryKind::Value,
                            1 => TableEntryKind::Field,
                            _ => {
                                self.budget.take_expression();
                                TableEntryKind::Index
                            }
                        };

                        entries.push(entry);
                    }

                    let expressions = entries
                        .iter()
                        .map(|entry| match entry {
                            TableEntryKind::Value | TableEntryKind::Field => 1,
                            TableEntryKind::Index => 2,
                        })
                        .sum();

                    self.push_work(AstFuzzerWork::MakeTable { entries });

                    self.fuzz_multiple_nested_expression(0, expressions);
                }
                AstFuzzerWork::FuzzType { depth } => {
                    let start = if !self.random.nested_type(depth) {
                        7
                    } else if self.budget.can_have_type(2) {
                        0
                    } else if self.budget.has_types() {
                        2
                    } else {
                        7
                    };
                    let bound = if self.budget.has_expressions() {
                        14
                    } else {
                        13
                    };
                    match self.random.full_range(start, bound) {
                        0 => {
                            let length = self
                                .budget
                                .try_take_types(self.random.intersection_type_length())
                                .max(1);
                            self.push_work(AstFuzzerWork::MakeIntersectionType {
                                has_leading_token: length == 1
                                    || self.random.leading_intersection_or_union_operator(),
                                length,
                            });
                            self.fuzz_multiple_nested_type(depth, length);
                        }
                        1 => {
                            let length = self
                                .budget
                                .try_take_types(self.random.union_type_length())
                                .max(1);
                            self.push_work(AstFuzzerWork::MakeUnionType {
                                has_leading_token: length == 1
                                    || self.random.leading_intersection_or_union_operator(),
                                length,
                            });
                            self.budget.try_take_types(2);
                            self.fuzz_multiple_nested_type(depth, length);
                        }

                        2 => {
                            self.push_work(AstFuzzerWork::MakeOptionalType);
                            self.budget.take_type();
                            self.fuzz_nested_type(depth);
                        }
                        3 => {
                            self.push_work(AstFuzzerWork::MakeParentheseType);
                            self.budget.take_type();
                            self.fuzz_nested_type(depth);
                        }
                        4 => {
                            self.push_work(AstFuzzerWork::MakeArrayType);
                            self.budget.take_type();
                            self.fuzz_nested_type(depth);
                        }
                        5 => {
                            let properties = self.budget.try_take_types(self.random.table_length());
                            let literal_properties = self.random.range(properties);
                            let has_indexer =
                                self.budget.can_have_type(2) && self.random.table_type_indexer();

                            self.push_work(AstFuzzerWork::MakeTableType {
                                properties,
                                literal_properties,
                                has_indexer,
                            });

                            let indexer_types = if has_indexer {
                                self.budget.try_take_types(2);
                                2
                            } else {
                                0
                            };

                            self.fuzz_multiple_nested_type(depth, properties + indexer_types);
                        }
                        6 => {
                            // take return type
                            self.budget.take_type();

                            let parameters = self
                                .budget
                                .try_take_types(self.random.function_parameters());

                            let variadic_type = if self.random.function_has_variadic_type()
                                && self.budget.take_type()
                            {
                                match self.random.range(1) {
                                    0 => VariadicArgumentTypeKind::GenericPack,
                                    _ => VariadicArgumentTypeKind::VariadicPack,
                                }
                            } else {
                                VariadicArgumentTypeKind::None
                            };

                            self.push_work(AstFuzzerWork::MakeFunctionType {
                                parameters,
                                variadic_type,
                            });

                            self.fuzz_multiple_nested_type(depth, parameters);

                            self.push_work(AstFuzzerWork::FuzzFunctionReturnType);

                            if matches!(variadic_type, VariadicArgumentTypeKind::VariadicPack) {
                                self.fuzz_nested_type(depth);
                            }
                        }

                        7 => {
                            if self.random.has_type_parameters() && self.budget.has_types() {
                                let type_parameters = self
                                    .budget
                                    .try_take_types(self.random.type_parameters())
                                    .max(1);
                                self.push_work(AstFuzzerWork::MakeTypeName { type_parameters });

                                self.push_repeated_work(
                                    AstFuzzerWork::FuzzTypeParameter,
                                    type_parameters,
                                );
                            } else {
                                self.types
                                    .push(TypeName::new(self.random.identifier()).into());
                            }
                        }
                        8 => {
                            if self.random.has_type_parameters() && self.budget.has_types() {
                                let type_parameters = self.random.type_parameters();
                                self.push_work(AstFuzzerWork::MakeTypeField { type_parameters });

                                self.push_repeated_work(
                                    AstFuzzerWork::FuzzTypeParameter,
                                    type_parameters,
                                );
                            } else {
                                let type_field = TypeField::new(
                                    self.random.identifier(),
                                    TypeName::new(self.random.identifier()),
                                );
                                self.types.push(type_field.into());
                            }
                        }
                        9 => {
                            self.types.push(Type::from(true));
                        }
                        10 => {
                            self.types.push(Type::from(false));
                        }
                        11 => {
                            self.types.push(Type::nil());
                        }
                        12 => {
                            self.types
                                .push(StringType::from_value(self.random.string_content()).into());
                        }
                        _ => {
                            self.push_work(AstFuzzerWork::MakeExpressionType);
                            self.fuzz_expression();
                        }
                    }
                }
                AstFuzzerWork::MakeTableType {
                    properties,
                    literal_properties,
                    has_indexer,
                } => {
                    let mut table_type = TableType::default();

                    let mut table_properties: Vec<TableEntryType> = self
                        .pop_types(properties)
                        .into_iter()
                        .enumerate()
                        .map(|(i, r#type)| {
                            if i < literal_properties {
                                TableLiteralPropertyType::new(
                                    StringType::from_value(self.random.string_content()),
                                    r#type,
                                )
                                .into()
                            } else {
                                TablePropertyType::new(self.random.identifier(), r#type).into()
                            }
                        })
                        .collect();

                    if has_indexer {
                        let mut key_type = self.pop_type();
                        if matches!(
                            key_type,
                            Type::Optional(_) | Type::Union(_) | Type::Intersection(_)
                        ) {
                            key_type = ParentheseType::new(key_type).into();
                        }
                        table_properties
                            .push(TableIndexerType::new(key_type, self.pop_type()).into());
                    }

                    table_properties.shuffle(&mut rand::rng());

                    for property in table_properties {
                        table_type.push_property(property);
                    }

                    self.types.push(table_type.into());
                }
                AstFuzzerWork::FuzzFunctionReturnType => match self.random.range(3) {
                    0 => {
                        self.push_work(AstFuzzerWork::MakeReturnFunctionType);
                        self.fuzz_type();
                    }
                    1 => {
                        self.push_work(AstFuzzerWork::MakeReturnFunctionTypePack);
                        self.push_work(AstFuzzerWork::FuzzTypePack);
                    }
                    2 => {
                        self.function_return_types
                            .push(GenericTypePack::new(self.random.identifier()).into());
                    }
                    _ => {
                        self.push_work(AstFuzzerWork::MakeReturnFunctionVariadicPack);
                        self.fuzz_type();
                    }
                },
                AstFuzzerWork::FuzzTypePack => {
                    let types = self.budget.try_take_types(self.random.type_pack_length());
                    let variadic_type =
                        if self.random.type_pack_variadic() && self.budget.take_type() {
                            match self.random.range(1) {
                                0 => VariadicArgumentTypeKind::GenericPack,
                                _ => VariadicArgumentTypeKind::VariadicPack,
                            }
                        } else {
                            VariadicArgumentTypeKind::None
                        };

                    self.push_work(AstFuzzerWork::MakeTypePack {
                        types,
                        variadic_type,
                    });
                    self.fuzz_multiple_type(types);

                    if matches!(variadic_type, VariadicArgumentTypeKind::VariadicPack) {
                        self.fuzz_type();
                    }
                }
                AstFuzzerWork::FuzzTypedIdentifier => {
                    if self.budget.can_have_type(1) && self.random.typed_identifier() {
                        self.budget.take_type();
                        self.push_work(AstFuzzerWork::MakeTypedIdentifier);
                        self.fuzz_type();
                    } else {
                        self.typed_identifiers.push(self.random.identifier().into());
                    }
                }
                AstFuzzerWork::MakeBlock {
                    has_last_statement,
                    statement_count,
                } => {
                    let statements = self.pop_statements(statement_count);
                    let last_statement = if has_last_statement {
                        Some(self.pop_last_statement())
                    } else {
                        None
                    };
                    self.blocks.push(Block::new(statements, last_statement));
                }
                AstFuzzerWork::MakeAssignStatement {
                    variables,
                    expressions,
                } => {
                    let variables = self.pop_variables(variables);
                    let values = self.pop_expressions(expressions);
                    self.statements
                        .push(AssignStatement::new(variables, values).into());
                }
                AstFuzzerWork::MakeDoStatement => {
                    let block = self.pop_block();
                    self.statements.push(DoStatement::new(block).into());
                }
                AstFuzzerWork::MakeCallStatement => {
                    let pop_call = self.pop_call();
                    self.statements.push(pop_call.into());
                }
                AstFuzzerWork::MakeFunctionCall => {
                    let prefix = self.pop_prefix();
                    let arguments = self.pop_arguments();
                    self.calls.push(FunctionCall::new(
                        prefix,
                        arguments,
                        if self.random.method_call() {
                            Some(self.random.identifier())
                        } else {
                            None
                        },
                    ));
                }
                AstFuzzerWork::MakeVariable { kind } => match kind {
                    VariableKind::Field => {
                        let prefix = self.pop_prefix();
                        self.variables
                            .push(FieldExpression::new(prefix, self.random.identifier()).into());
                    }
                    VariableKind::Index => {
                        let prefix = self.pop_prefix();
                        let expression = self.pop_expression();
                        self.variables
                            .push(IndexExpression::new(prefix, expression).into());
                    }
                },
                AstFuzzerWork::MakeTupleArguments { expressions } => {
                    let values = self.pop_expressions(expressions);
                    self.arguments.push(TupleArguments::new(values).into())
                }
                AstFuzzerWork::MakeTableArguments => {
                    let table = self.pop_table();
                    self.arguments.push(Arguments::Table(table));
                }
                AstFuzzerWork::MakeTable { entries } => {
                    let table = TableExpression::new(
                        entries
                            .into_iter()
                            .map(|entry| match entry {
                                TableEntryKind::Value => {
                                    TableEntry::from_value(self.pop_expression())
                                }
                                TableEntryKind::Field => TableFieldEntry::new(
                                    self.random.identifier(),
                                    self.pop_expression(),
                                )
                                .into(),
                                TableEntryKind::Index => TableIndexEntry::new(
                                    self.pop_expression(),
                                    self.pop_expression(),
                                )
                                .into(),
                            })
                            .collect(),
                    );
                    self.tables.push(table);
                }
                AstFuzzerWork::MakeFunctionStatement {
                    parameters,
                    has_return_type,
                    has_variadic_type,
                } => {
                    let name = FunctionName::new(
                        self.random.identifier(),
                        iter::repeat_with(|| self.random.identifier())
                            .take(self.random.function_name_fields())
                            .collect(),
                        if self.random.method_definition() {
                            Some(self.random.identifier())
                        } else {
                            None
                        },
                    );

                    let block = self.pop_block();
                    let parameters = self.pop_typed_identifiers(parameters);

                    let mut function = FunctionStatement::new(
                        name,
                        block,
                        parameters,
                        has_variadic_type || self.random.function_is_variadic(),
                    );

                    if let Some(generics) = self.generate_function_generics() {
                        function.set_generic_parameters(generics);
                    }

                    if has_return_type {
                        function.set_return_type(self.pop_return_type());
                    }

                    if has_variadic_type {
                        let variadic_type = self.pop_type();
                        if self.random.function_variadic_type_is_generic_pack() {
                            function
                                .set_variadic_type(GenericTypePack::new(self.random.identifier()));
                        } else {
                            function.set_variadic_type(variadic_type);
                        }
                    }

                    self.statements.push(function.into());
                }
                AstFuzzerWork::MakeLocalFunctionStatement {
                    parameters,
                    has_return_type,
                    has_variadic_type,
                } => {
                    let block = self.pop_block();
                    let parameters = self.pop_typed_identifiers(parameters);

                    let mut function = LocalFunctionStatement::new(
                        self.random.identifier(),
                        block,
                        parameters,
                        has_variadic_type || self.random.function_is_variadic(),
                    );

                    if let Some(generics) = self.generate_function_generics() {
                        function.set_generic_parameters(generics);
                    }

                    if has_return_type {
                        function.set_return_type(self.pop_return_type());
                    }

                    if has_variadic_type {
                        function.set_variadic_type(self.pop_type());
                    }

                    self.statements.push(function.into());
                }
                AstFuzzerWork::MakeFunctionExpression {
                    parameters,
                    has_return_type,
                    has_variadic_type,
                } => {
                    let block = self.pop_block();
                    let parameters = self.pop_typed_identifiers(parameters);

                    let mut function = FunctionExpression::new(
                        block,
                        parameters,
                        has_variadic_type || self.random.function_is_variadic(),
                    );

                    if let Some(generics) = self.generate_function_generics() {
                        function.set_generic_parameters(generics);
                    }

                    if has_return_type {
                        function.set_return_type(self.pop_return_type());
                    }

                    if has_variadic_type {
                        function.set_variadic_type(self.pop_type());
                    }

                    self.expressions.push(function.into());
                }
                AstFuzzerWork::MakeTypedIdentifier => {
                    let typed_identifier = self.random.identifier().with_type(self.pop_type());
                    self.typed_identifiers.push(typed_identifier);
                }
                AstFuzzerWork::MakeReturnStatement { expressions } => {
                    let return_statement = ReturnStatement::new(self.pop_expressions(expressions));
                    self.last_statements.push(return_statement.into())
                }
                AstFuzzerWork::MakeRepeatStatement => {
                    let block = self.pop_block();
                    let condition = self.pop_expression();
                    self.statements
                        .push(RepeatStatement::new(block, condition).into());
                }
                AstFuzzerWork::MakeWhileStatement => {
                    let block = self.pop_block();
                    let condition = self.pop_expression();
                    self.statements
                        .push(WhileStatement::new(block, condition).into());
                }
                AstFuzzerWork::MakeNumericForStatement { has_step } => {
                    let block = self.pop_block();
                    let identifier = self.pop_typed_identifier();
                    let start = self.pop_expression();
                    let end = self.pop_expression();
                    let step = if has_step {
                        Some(self.pop_expression())
                    } else {
                        None
                    };
                    self.statements
                        .push(NumericForStatement::new(identifier, start, end, step, block).into());
                }
                AstFuzzerWork::MakeCompoundAssignStatement => {
                    let variable = self.pop_variable();
                    let value = self.pop_expression();
                    self.statements.push(
                        CompoundAssignStatement::new(
                            self.random.compound_operator(),
                            variable,
                            value,
                        )
                        .into(),
                    );
                }
                AstFuzzerWork::MakeLocalAssignStatement {
                    variables,
                    expressions,
                } => {
                    let variables = self.pop_typed_identifiers(variables);
                    let values = self.pop_expressions(expressions);
                    self.statements
                        .push(LocalAssignStatement::new(variables, values).into());
                }
                AstFuzzerWork::MakeGenericForStatement {
                    variables,
                    expressions,
                } => {
                    let variables = self.pop_typed_identifiers(variables);
                    let values = self.pop_expressions(expressions);
                    let block = self.pop_block();
                    self.statements
                        .push(GenericForStatement::new(variables, values, block).into());
                }
                AstFuzzerWork::MakeIfStatement {
                    branches,
                    else_branch,
                } => {
                    let statement = IfStatement::new(
                        iter::repeat_with(|| {
                            let condition = self.pop_expression();
                            let block = self.pop_block();
                            IfBranch::new(condition, block)
                        })
                        .take(branches)
                        .collect(),
                        if else_branch {
                            Some(self.pop_block())
                        } else {
                            None
                        },
                    );

                    self.statements.push(statement.into());
                }
                AstFuzzerWork::MakeTableExpression => {
                    let table = self.pop_table().into();
                    self.expressions.push(table);
                }
                AstFuzzerWork::MakeCallExpression => {
                    let call = self.pop_call().into();
                    self.expressions.push(call);
                }
                AstFuzzerWork::MakeIfExpression { elseifs } => {
                    let mut if_expression = IfExpression::new(
                        self.pop_expression(),
                        self.pop_expression(),
                        self.pop_expression(),
                    );

                    for _ in 0..elseifs {
                        if_expression.push_branch(ElseIfExpressionBranch::new(
                            self.pop_expression(),
                            self.pop_expression(),
                        ));
                    }

                    self.expressions.push(if_expression.into());
                }
                AstFuzzerWork::MakeBinaryExpression => {
                    let operator = self.random.binary_operator();
                    let mut left = self.pop_expression();
                    let mut right = self.pop_expression();

                    if operator.left_needs_parentheses(&left) {
                        left = left.in_parentheses();
                    }

                    if operator.right_needs_parentheses(&right) {
                        right = right.in_parentheses();
                    }

                    self.expressions
                        .push(BinaryExpression::new(operator, left, right).into());
                }
                AstFuzzerWork::MakeIndexExpression => {
                    let prefix = self.pop_prefix();
                    let expression = self.pop_expression();
                    self.expressions
                        .push(IndexExpression::new(prefix, expression).into());
                }
                AstFuzzerWork::MakeFieldExpression => {
                    let prefix = self.pop_prefix();
                    self.expressions
                        .push(FieldExpression::new(prefix, self.random.identifier()).into());
                }
                AstFuzzerWork::MakeParentheseExpression => {
                    let expression = self.pop_expression().in_parentheses();
                    self.expressions.push(expression);
                }
                AstFuzzerWork::MakeUnaryExpression => {
                    let mut expression = self.pop_expression();

                    if let Expression::Binary(binary) = &expression {
                        if !binary.operator().precedes_unary_expression() {
                            expression = expression.in_parentheses();
                        }
                    }

                    self.expressions.push(
                        UnaryExpression::new(self.random.unary_operator(), expression).into(),
                    );
                }
                AstFuzzerWork::MakeInterpolatedString {
                    segment_is_expression,
                } => {
                    let mut string = InterpolatedStringExpression::empty();

                    for is_expression in segment_is_expression {
                        if is_expression {
                            string.push_segment(self.pop_expression());
                        } else {
                            string.push_segment(self.random.string_content());
                        }
                    }

                    self.expressions.push(string.into());
                }
                AstFuzzerWork::MakeTypeCastExpression => {
                    let mut expression = self.pop_expression();

                    if TypeCastExpression::needs_parentheses(&expression) {
                        expression = expression.in_parentheses();
                    }

                    let r#type = self.pop_type();
                    self.expressions
                        .push(TypeCastExpression::new(expression, r#type).into());
                }
                AstFuzzerWork::MakeFieldPrefix => {
                    let prefix = self.pop_prefix();
                    self.prefixes
                        .push(FieldExpression::new(prefix, self.random.identifier()).into());
                }
                AstFuzzerWork::MakeParenthesePrefix => {
                    let expression = self.pop_expression();
                    self.prefixes
                        .push(ParentheseExpression::new(expression).into());
                }
                AstFuzzerWork::MakeIndexPrefix => {
                    let prefix = self.pop_prefix();
                    let expression = self.pop_expression();
                    self.prefixes
                        .push(IndexExpression::new(prefix, expression).into());
                }
                AstFuzzerWork::MakeCallPrefix => {
                    let call = self.pop_call();
                    self.prefixes.push(call.into());
                }
                AstFuzzerWork::MakeIntersectionType {
                    has_leading_token,
                    length,
                } => {
                    let mut intersection = IntersectionType::from_iter(
                        self.pop_types(length)
                            .into_iter()
                            .enumerate()
                            .map(|(i, inner_type)| {
                                let needs_parentheses = if i == length.saturating_sub(1) {
                                    IntersectionType::last_needs_parentheses(&inner_type)
                                } else {
                                    IntersectionType::intermediate_needs_parentheses(&inner_type)
                                };
                                if needs_parentheses {
                                    inner_type.in_parentheses()
                                } else {
                                    inner_type
                                }
                            }),
                    );

                    if has_leading_token {
                        intersection.put_leading_token();
                    }

                    self.types.push(intersection.into());
                }
                AstFuzzerWork::MakeUnionType {
                    has_leading_token,
                    length,
                } => {
                    let mut union_type =
                        UnionType::from_iter(self.pop_types(length).into_iter().enumerate().map(
                            |(i, inner_type)| {
                                let needs_parentheses = if i == length.saturating_sub(1) {
                                    UnionType::last_needs_parentheses(&inner_type)
                                } else {
                                    UnionType::intermediate_needs_parentheses(&inner_type)
                                };
                                if needs_parentheses {
                                    inner_type.in_parentheses()
                                } else {
                                    inner_type
                                }
                            },
                        ));

                    if has_leading_token {
                        union_type.put_leading_token();
                    }

                    self.types.push(union_type.into());
                }
                AstFuzzerWork::MakeOptionalType => {
                    let r#type = self.pop_type();
                    let optional = OptionalType::new(if OptionalType::needs_parentheses(&r#type) {
                        r#type.in_parentheses()
                    } else {
                        r#type
                    });
                    self.types.push(optional.into());
                }
                AstFuzzerWork::MakeParentheseType => {
                    let optional = ParentheseType::new(self.pop_type());
                    self.types.push(optional.into());
                }
                AstFuzzerWork::MakeArrayType => {
                    let array = ArrayType::new(self.pop_type());
                    self.types.push(array.into());
                }
                AstFuzzerWork::MakeExpressionType => {
                    let expression = ExpressionType::new(self.pop_expression());
                    self.types.push(expression.into());
                }
                AstFuzzerWork::MakeReturnFunctionType => {
                    let r#type = self.pop_type();

                    self.function_return_types
                        .push(if let Type::Parenthese(inner_type) = r#type {
                            TypePack::default().with_type(inner_type).into()
                        } else {
                            r#type.into()
                        });
                }
                AstFuzzerWork::MakeReturnFunctionTypePack => {
                    let type_pack = self.pop_type_pack();
                    self.function_return_types.push(type_pack.into());
                }
                AstFuzzerWork::MakeReturnFunctionVariadicPack => {
                    let variadic_type = self.pop_variadic_type_pack();
                    self.function_return_types.push(variadic_type.into());
                }
                AstFuzzerWork::MakeTypePack {
                    types,
                    variadic_type,
                } => {
                    let mut type_pack: TypePack = self.pop_types(types).into_iter().collect();

                    match variadic_type {
                        VariadicArgumentTypeKind::None => {}
                        VariadicArgumentTypeKind::GenericPack => {
                            let generic_pack = GenericTypePack::new(self.random.identifier());
                            type_pack.set_variadic_type(generic_pack);
                        }
                        VariadicArgumentTypeKind::VariadicPack => {
                            type_pack.set_variadic_type(self.pop_variadic_type_pack());
                        }
                    }

                    self.type_packs.push(type_pack);
                }
                AstFuzzerWork::MakeFunctionType {
                    parameters,
                    variadic_type,
                } => {
                    let arguments = self.pop_types(parameters);

                    let mut function_type = FunctionType::new(self.pop_return_type());

                    if let Some(generics) = self.generate_function_generics() {
                        function_type.set_generic_parameters(generics);
                    }

                    for argument in
                        arguments
                            .into_iter()
                            .map(FunctionArgumentType::new)
                            .map(|argument| {
                                if self.random.function_type_argument_name() {
                                    argument.with_name(self.random.identifier())
                                } else {
                                    argument
                                }
                            })
                    {
                        function_type.push_argument(argument);
                    }

                    match variadic_type {
                        VariadicArgumentTypeKind::None => {}
                        VariadicArgumentTypeKind::GenericPack => {
                            let generic_pack = GenericTypePack::new(self.random.identifier());
                            function_type.set_variadic_type(generic_pack);
                        }
                        VariadicArgumentTypeKind::VariadicPack => {
                            function_type.set_variadic_type(self.pop_variadic_type_pack());
                        }
                    }

                    self.types.push(function_type.into());
                }
                AstFuzzerWork::FuzzTypeParameter => {
                    let type_parameter_kind = match self.random.range(3) {
                        0 => TypeParameterKind::Type,
                        1 => TypeParameterKind::TypePack,
                        2 => TypeParameterKind::VariadicTypePack,
                        _ => TypeParameterKind::GenericTypePack,
                    };
                    self.push_work(AstFuzzerWork::MakeTypeParameter {
                        type_parameter_kind,
                    });

                    match type_parameter_kind {
                        TypeParameterKind::Type => {
                            self.fuzz_type();
                        }
                        TypeParameterKind::TypePack => {
                            self.push_work(AstFuzzerWork::FuzzTypePack);
                        }
                        TypeParameterKind::VariadicTypePack => {
                            self.fuzz_type();
                        }
                        TypeParameterKind::GenericTypePack => {}
                    }
                }
                AstFuzzerWork::MakeTypeParameter {
                    type_parameter_kind,
                } => {
                    let type_parameter = match type_parameter_kind {
                        TypeParameterKind::Type => {
                            let r#type = self.pop_type();

                            if let Type::Parenthese(inner_type) = r#type {
                                TypePack::default().with_type(inner_type).into()
                            } else {
                                r#type.into()
                            }
                        }
                        TypeParameterKind::TypePack => self.pop_type_pack().into(),
                        TypeParameterKind::VariadicTypePack => self.pop_variadic_type_pack().into(),
                        TypeParameterKind::GenericTypePack => {
                            GenericTypePack::new(self.random.identifier()).into()
                        }
                    };
                    self.type_parameters.push(type_parameter);
                }
                AstFuzzerWork::MakeTypeName { type_parameters } => {
                    let parameters = self.pop_type_parameters(type_parameters);
                    self.types.push(
                        TypeName::new(self.random.identifier())
                            .with_type_parameters(parameters.into_iter().collect())
                            .into(),
                    );
                }
                AstFuzzerWork::MakeTypeField { type_parameters } => {
                    let parameters = self.pop_type_parameters(type_parameters);
                    self.types.push(
                        TypeField::new(
                            self.random.identifier(),
                            TypeName::new(self.random.identifier())
                                .with_type_parameters(parameters.into_iter().collect()),
                        )
                        .into(),
                    );
                }
            }
        }
    }

    fn pop_variadic_type_pack(&mut self) -> VariadicTypePack {
        // fix: once full-moon supports leading operators for union and
        // intersection type, simply replace with `self.pop_type()`
        // https://github.com/Kampfkarren/full-moon/issues/311
        VariadicTypePack::new(wrap_in_parenthese_if_leading_union_or_intersection(
            self.pop_type(),
        ))
    }

    fn generate_function_generics(&mut self) -> Option<GenericParameters> {
        let generic_types_count = self.random.function_generic_types();
        if generic_types_count > 0 {
            let mut generics = if self.random.function_generic_type_is_generic_pack() {
                GenericParameters::from_generic_type_pack(GenericTypePack::new(
                    self.random.identifier(),
                ))
            } else {
                GenericParameters::from_type_variable(self.random.identifier())
            };

            for _ in 1..generic_types_count {
                if self.random.function_generic_type_is_generic_pack() {
                    generics.push_generic_type_pack(GenericTypePack::new(self.random.identifier()))
                } else {
                    generics.push_type_variable(self.random.identifier())
                }
            }

            Some(generics)
        } else {
            None
        }
    }

    fn generate_function(&mut self, function_work: impl Fn(usize, bool, bool) -> AstFuzzerWork) {
        let parameters = self.random.function_parameters();
        let has_return_type = self.random.function_return_type() && self.budget.take_type();
        let has_variadic_type = self.random.function_has_variadic_type() && self.budget.take_type();

        self.push_work(function_work(
            parameters,
            has_return_type,
            has_variadic_type,
        ));

        self.push_work(AstFuzzerWork::FuzzBlock);
        self.push_repeated_work(AstFuzzerWork::FuzzTypedIdentifier, parameters);

        if has_return_type {
            self.push_work(AstFuzzerWork::FuzzFunctionReturnType);
        }

        if has_variadic_type {
            self.fuzz_type();
        }
    }

    fn pop_block(&mut self) -> Block {
        self.blocks.pop().expect("expected block")
    }

    fn pop_expression(&mut self) -> Expression {
        self.expressions.pop().expect("expected expression")
    }

    fn pop_expressions(&mut self, n: usize) -> Vec<Expression> {
        iter::repeat_with(|| self.pop_expression())
            .take(n)
            .collect()
    }

    fn pop_statement(&mut self) -> Statement {
        self.statements.pop().expect("expected statement")
    }

    fn pop_statements(&mut self, n: usize) -> Vec<Statement> {
        iter::repeat_with(|| self.pop_statement()).take(n).collect()
    }

    fn pop_last_statement(&mut self) -> LastStatement {
        self.last_statements.pop().expect("expected last statement")
    }

    fn pop_type(&mut self) -> Type {
        self.types.pop().expect("expected type")
    }

    fn pop_types(&mut self, n: usize) -> Vec<Type> {
        iter::repeat_with(|| self.pop_type()).take(n).collect()
    }

    fn pop_prefix(&mut self) -> Prefix {
        self.prefixes.pop().expect("expected prefix")
    }

    fn pop_variable(&mut self) -> Variable {
        self.variables.pop().expect("expected variable")
    }

    fn pop_variables(&mut self, n: usize) -> Vec<Variable> {
        iter::repeat_with(|| self.pop_variable()).take(n).collect()
    }

    fn pop_type_parameter(&mut self) -> TypeParameter {
        // fix: once full-moon supports leading operators for union and
        // intersection type, simply replace with `self.type_parameters.pop()`
        // https://github.com/Kampfkarren/full-moon/issues/311
        let parameter = self.type_parameters.pop().expect("expected type parameter");

        match parameter {
            TypeParameter::Type(r#type) => {
                wrap_in_parenthese_if_leading_union_or_intersection(r#type).into()
            }
            parameter => parameter,
        }
    }

    fn pop_type_parameters(&mut self, n: usize) -> Vec<TypeParameter> {
        iter::repeat_with(|| self.pop_type_parameter())
            .take(n)
            .collect()
    }

    fn pop_arguments(&mut self) -> Arguments {
        self.arguments.pop().expect("expected arguments")
    }

    fn pop_call(&mut self) -> FunctionCall {
        self.calls.pop().expect("expected function call")
    }

    fn pop_table(&mut self) -> TableExpression {
        self.tables.pop().expect("expected table expression")
    }

    fn pop_typed_identifier(&mut self) -> TypedIdentifier {
        self.typed_identifiers
            .pop()
            .expect("expected typed identifier")
    }

    fn pop_typed_identifiers(&mut self, n: usize) -> Vec<TypedIdentifier> {
        iter::repeat_with(|| self.pop_typed_identifier())
            .take(n)
            .collect()
    }

    fn pop_return_type(&mut self) -> FunctionReturnType {
        let return_type = self
            .function_return_types
            .pop()
            .expect("expected function return type");

        // fix: once full-moon supports leading operators for union and
        // intersection type, simply replace with `self.function_return_types.pop()`
        // https://github.com/Kampfkarren/full-moon/issues/311
        match return_type {
            FunctionReturnType::Type(r#type) => FunctionReturnType::from(
                wrap_in_parenthese_if_leading_union_or_intersection(*r#type),
            ),
            return_type => return_type,
        }
    }

    fn pop_type_pack(&mut self) -> TypePack {
        self.type_packs.pop().expect("expected type pack")
    }

    fn fuzz_expression(&mut self) {
        self.work_stack
            .push(AstFuzzerWork::FuzzExpression { depth: 0 });
    }

    fn fuzz_multiple_expression(&mut self, amount: usize) {
        self.push_repeated_work(AstFuzzerWork::FuzzExpression { depth: 0 }, amount);
    }

    fn fuzz_nested_expression(&mut self, current_depth: usize) {
        self.work_stack.push(AstFuzzerWork::FuzzExpression {
            depth: current_depth + 1,
        });
    }

    fn fuzz_multiple_nested_expression(&mut self, current_depth: usize, amount: usize) {
        self.push_repeated_work(
            AstFuzzerWork::FuzzExpression {
                depth: current_depth + 1,
            },
            amount,
        );
    }

    fn fuzz_type(&mut self) {
        self.work_stack.push(AstFuzzerWork::FuzzType { depth: 0 });
    }

    fn fuzz_multiple_type(&mut self, amount: usize) {
        self.push_repeated_work(AstFuzzerWork::FuzzType { depth: 0 }, amount);
    }

    fn fuzz_nested_type(&mut self, current_depth: usize) {
        self.work_stack.push(AstFuzzerWork::FuzzType {
            depth: current_depth + 1,
        });
    }

    fn fuzz_multiple_nested_type(&mut self, current_depth: usize, amount: usize) {
        self.push_repeated_work(
            AstFuzzerWork::FuzzType {
                depth: current_depth + 1,
            },
            amount,
        );
    }
}

fn wrap_in_parenthese_if_leading_union_or_intersection(r#type: Type) -> Type {
    match r#type {
        Type::Intersection(intersection_type) => {
            if intersection_type.has_leading_token() {
                Type::from(intersection_type).in_parentheses()
            } else {
                intersection_type.into()
            }
        }
        Type::Union(union_type) => {
            if union_type.has_leading_token() {
                Type::from(union_type).in_parentheses()
            } else {
                union_type.into()
            }
        }
        r#type => r#type,
    }
}
