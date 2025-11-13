#[derive(Clone)]
pub enum AstFuzzerWork {
    FuzzBlock,
    FuzzStatement,
    FuzzLastStatement,
    FuzzExpression {
        depth: usize,
    },
    FuzzVariable,
    FuzzPrefix,
    FuzzArguments,
    FuzzTable,
    FuzzType {
        depth: usize,
    },
    FuzzFunctionReturnType,
    FuzzTypedIdentifier,
    MakeBlock {
        has_last_statement: bool,
        statement_count: usize,
    },
    MakeAssignStatement {
        variables: usize,
        expressions: usize,
    },
    MakeDoStatement,
    MakeCallStatement,
    MakeFunctionCall,
    MakeVariable {
        kind: VariableKind,
    },
    MakeTupleArguments {
        expressions: usize,
    },
    MakeTableArguments,
    MakeTable {
        entries: Vec<TableEntryKind>,
    },
    MakeFunctionStatement {
        parameters: usize,
        has_return_type: bool,
        has_variadic_type: bool,
    },
    MakeTypedIdentifier,
    MakeReturnStatement {
        expressions: usize,
    },
    MakeRepeatStatement,
    MakeWhileStatement,
    MakeNumericForStatement {
        has_step: bool,
    },
    MakeCompoundAssignStatement,
    MakeTableExpression,
    MakeCallExpression,
    MakeIfExpression {
        elseifs: usize,
    },
    MakeBinaryExpression,
    MakeIndexExpression,
    MakeFieldExpression,
    MakeParentheseExpression,
    MakeUnaryExpression,
    MakeTypeCastExpression,
    MakeInterpolatedString {
        segment_is_expression: Vec<bool>,
    },
    MakeFunctionExpression {
        parameters: usize,
        has_return_type: bool,
        has_variadic_type: bool,
    },
    MakeLocalFunctionStatement {
        parameters: usize,
        has_return_type: bool,
        has_variadic_type: bool,
    },
    MakeLocalAssignStatement {
        variables: usize,
        expressions: usize,
    },
    MakeGenericForStatement {
        variables: usize,
        expressions: usize,
    },
    MakeIfStatement {
        branches: usize,
        else_branch: bool,
    },
    MakeFieldPrefix,
    MakeParenthesePrefix,
    MakeIndexPrefix,
    MakeCallPrefix,
    MakeIntersectionType {
        has_leading_token: bool,
        length: usize,
    },
    MakeUnionType {
        has_leading_token: bool,
        length: usize,
    },
    MakeOptionalType,
    MakeParentheseType,
    MakeArrayType,
    MakeExpressionType,
    MakeReturnFunctionType,
    MakeReturnFunctionTypePack,
    MakeReturnFunctionVariadicPack,
    FuzzTypePack,
    MakeTypePack {
        types: usize,
        variadic_type: VariadicArgumentTypeKind,
    },
    MakeFunctionType {
        parameters: usize,
        variadic_type: VariadicArgumentTypeKind,
    },
    FuzzTypeParameter,
    MakeTypeName {
        type_parameters: usize,
    },
    MakeTypeField {
        type_parameters: usize,
    },
    MakeTypeParameter {
        type_parameter_kind: TypeParameterKind,
    },
    MakeTypeDeclaration {
        type_parameter_with_defaults: Vec<TypeParameterWithDefaultKind>,
    },
    MakeTableType {
        properties: usize,
        literal_properties: usize,
        has_indexer: bool,
    },
}

#[derive(Clone)]
pub enum VariableKind {
    Field,
    Index,
}

#[derive(Copy, Clone)]
pub enum VariadicArgumentTypeKind {
    None,
    GenericPack,
    VariadicPack,
}

#[derive(Copy, Clone)]
pub enum TypeParameterKind {
    Type,
    TypePack,
    VariadicTypePack,
    GenericTypePack,
}

#[derive(Clone)]
pub enum TableEntryKind {
    Value,
    Field,
    Index,
}

#[derive(Copy, Clone)]
pub enum TypeParameterWithDefaultKind {
    Variable,
    VariableWithType,
    GenericPack,
    GenericPackWithTypePack,
    GenericPackWithVariadicPack,
    GenericPackWithGenericPack,
}
