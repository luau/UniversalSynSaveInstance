use super::{
    Block, FunctionExpression, FunctionName, FunctionReturnType, FunctionStatement,
    FunctionVariadicType, GenericParameters, Identifier, LocalFunctionStatement,
    LocalFunctionTokens, Token, TypedIdentifier,
};

pub(crate) struct FunctionBuilder {
    block: Block,
    parameters: Vec<TypedIdentifier>,
    is_variadic: bool,
    variadic_type: Option<FunctionVariadicType>,
    return_type: Option<FunctionReturnType>,

    function: Option<Token>,
    opening_parenthese: Option<Token>,
    closing_parenthese: Option<Token>,
    end: Option<Token>,
    parameter_commas: Vec<Token>,

    variable_arguments: Option<Token>,
    variable_arguments_colon: Option<Token>,
    return_type_colon: Option<Token>,
    generic_parameters: Option<GenericParameters>,
}

impl FunctionBuilder {
    pub fn from_block(block: impl Into<Block>) -> Self {
        Self {
            block: block.into(),
            parameters: Vec::new(),
            is_variadic: false,
            variadic_type: None,
            return_type: None,

            function: None,
            opening_parenthese: None,
            closing_parenthese: None,
            end: None,
            parameter_commas: Vec::new(),

            variable_arguments: None,
            variable_arguments_colon: None,
            return_type_colon: None,
            generic_parameters: None,
        }
    }

    pub(crate) fn into_function_expression(self) -> FunctionExpression {
        let mut expression = FunctionExpression::new(self.block, self.parameters, self.is_variadic);

        if let Some(variadic_type) = self.variadic_type {
            expression.set_variadic_type(variadic_type);
        }

        if let Some(return_type) = self.return_type {
            expression.set_return_type(return_type);
        }

        if let Some(generic_parameters) = self.generic_parameters {
            expression.set_generic_parameters(generic_parameters);
        }

        if let (Some(function), Some(opening_parenthese), Some(closing_parenthese), Some(end)) = (
            self.function,
            self.opening_parenthese,
            self.closing_parenthese,
            self.end,
        ) {
            expression.set_tokens(FunctionBodyTokens {
                function,
                opening_parenthese,
                closing_parenthese,
                end,
                parameter_commas: self.parameter_commas,
                variable_arguments: self.variable_arguments,
                variable_arguments_colon: self.variable_arguments_colon,
                return_type_colon: self.return_type_colon,
            });
        }

        expression
    }

    pub(crate) fn into_function_statement(self, name: FunctionName) -> FunctionStatement {
        let mut statement =
            FunctionStatement::new(name, self.block, self.parameters, self.is_variadic);

        if let Some(variadic_type) = self.variadic_type {
            statement.set_variadic_type(variadic_type);
        }

        if let Some(return_type) = self.return_type {
            statement.set_return_type(return_type);
        }

        if let Some(generic_parameters) = self.generic_parameters {
            statement.set_generic_parameters(generic_parameters);
        }

        if let (Some(function), Some(opening_parenthese), Some(closing_parenthese), Some(end)) = (
            self.function,
            self.opening_parenthese,
            self.closing_parenthese,
            self.end,
        ) {
            statement.set_tokens(FunctionBodyTokens {
                function,
                opening_parenthese,
                closing_parenthese,
                end,
                parameter_commas: self.parameter_commas,
                variable_arguments: self.variable_arguments,
                variable_arguments_colon: self.variable_arguments_colon,
                return_type_colon: self.return_type_colon,
            });
        }

        statement
    }

    pub(crate) fn into_local_function_statement(
        self,
        name: Identifier,
        local_token: Option<Token>,
    ) -> LocalFunctionStatement {
        let mut statement =
            LocalFunctionStatement::new(name, self.block, self.parameters, self.is_variadic);

        if let Some(variadic_type) = self.variadic_type {
            statement.set_variadic_type(variadic_type);
        }

        if let Some(return_type) = self.return_type {
            statement.set_return_type(return_type);
        }

        if let Some(generic_parameters) = self.generic_parameters {
            statement.set_generic_parameters(generic_parameters);
        }

        if let (
            Some(local),
            Some(function),
            Some(opening_parenthese),
            Some(closing_parenthese),
            Some(end),
        ) = (
            local_token,
            self.function,
            self.opening_parenthese,
            self.closing_parenthese,
            self.end,
        ) {
            statement.set_tokens(LocalFunctionTokens {
                local,
                function_body: FunctionBodyTokens {
                    function,
                    opening_parenthese,
                    closing_parenthese,
                    end,
                    parameter_commas: self.parameter_commas,
                    variable_arguments: self.variable_arguments,
                    variable_arguments_colon: self.variable_arguments_colon,
                    return_type_colon: self.return_type_colon,
                },
            });
        }

        statement
    }

    pub(crate) fn is_variadic(&self) -> bool {
        self.is_variadic
    }

    pub(crate) fn set_return_type_colon(&mut self, token: Token) {
        self.return_type_colon = Some(token);
    }

    pub(crate) fn set_return_type(&mut self, r#type: FunctionReturnType) {
        self.return_type = Some(r#type);
    }

    pub(crate) fn set_variable_arguments_token(&mut self, token: Token) {
        self.variable_arguments = Some(token);
    }

    pub(crate) fn set_variadic(&mut self) {
        self.is_variadic = true;
    }

    pub(crate) fn set_variadic_type(&mut self, r#type: FunctionVariadicType) {
        self.is_variadic = true;
        self.variadic_type = Some(r#type);
    }

    pub(crate) fn set_variable_arguments_colon(&mut self, token: Token) {
        self.variable_arguments_colon = Some(token);
    }

    pub(crate) fn push_parameter(&mut self, typed_identifier: TypedIdentifier) {
        self.parameters.push(typed_identifier);
    }

    pub(crate) fn set_parentheses_tokens(&mut self, open: Token, close: Token) {
        self.opening_parenthese = Some(open);
        self.closing_parenthese = Some(close);
    }

    pub(crate) fn set_parameter_commas(&mut self, commas: Vec<Token>) {
        self.parameter_commas = commas;
    }

    pub(crate) fn set_function_token(&mut self, token: Token) {
        self.function = Some(token);
    }

    pub(crate) fn set_end_token(&mut self, token: Token) {
        self.end = Some(token);
    }

    pub(crate) fn set_generic_parameters(&mut self, generic_parameters: GenericParameters) {
        self.generic_parameters = Some(generic_parameters);
    }
}

/// Represents the token information associated with a function body.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionBodyTokens {
    /// The 'function' keyword token.
    pub function: Token,
    /// The opening parenthesis token for parameter list.
    pub opening_parenthese: Token,
    /// The closing parenthesis token for parameter list.
    pub closing_parenthese: Token,
    /// The 'end' keyword token that terminates the function definition.
    pub end: Token,
    /// Tokens for commas separating parameters.
    pub parameter_commas: Vec<Token>,
    /// The '...' token for variadic functions, if present.
    pub variable_arguments: Option<Token>,
    /// The colon token before the variadic type annotation, if present.
    pub variable_arguments_colon: Option<Token>,
    /// The colon token before the return type annotation, if present.
    pub return_type_colon: Option<Token>,
}

impl FunctionBodyTokens {
    super::impl_token_fns!(
        target = [function, opening_parenthese, closing_parenthese, end]
        iter = [
            variable_arguments,
            variable_arguments_colon,
            return_type_colon,
            parameter_commas,
        ]
    );
}
