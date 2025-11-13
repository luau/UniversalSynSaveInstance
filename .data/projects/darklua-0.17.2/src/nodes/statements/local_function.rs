use crate::nodes::{
    Block, FunctionBodyTokens, FunctionReturnType, FunctionVariadicType, GenericParameters,
    Identifier, Token, TypedIdentifier,
};

/// Tokens associated with a local function statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LocalFunctionTokens {
    pub local: Token,
    pub function_body: FunctionBodyTokens,
}

impl LocalFunctionTokens {
    super::impl_token_fns!(target = [local, function_body]);
}

impl std::ops::Deref for LocalFunctionTokens {
    type Target = FunctionBodyTokens;

    fn deref(&self) -> &Self::Target {
        &self.function_body
    }
}

impl std::ops::DerefMut for LocalFunctionTokens {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.function_body
    }
}

/// Represents a local function declaration statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LocalFunctionStatement {
    identifier: Identifier,
    block: Block,
    parameters: Vec<TypedIdentifier>,
    is_variadic: bool,
    variadic_type: Option<FunctionVariadicType>,
    return_type: Option<FunctionReturnType>,
    generic_parameters: Option<GenericParameters>,
    tokens: Option<Box<LocalFunctionTokens>>,
}

impl LocalFunctionStatement {
    /// Creates a new local function statement.
    pub fn new(
        identifier: impl Into<Identifier>,
        block: Block,
        parameters: Vec<TypedIdentifier>,
        is_variadic: bool,
    ) -> Self {
        Self {
            identifier: identifier.into(),
            block,
            parameters,
            is_variadic,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Creates a new local function statement with a given name and block.
    pub fn from_name(identifier: impl Into<Identifier>, block: impl Into<Block>) -> Self {
        Self {
            identifier: identifier.into(),
            block: block.into(),
            parameters: Vec::new(),
            is_variadic: false,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Sets the tokens for this local function statement.
    pub fn with_tokens(mut self, tokens: LocalFunctionTokens) -> Self {
        self.tokens = Some(tokens.into());
        self
    }

    /// Sets the tokens for this local function statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: LocalFunctionTokens) {
        self.tokens = Some(tokens.into());
    }

    /// Returns the tokens for this local function statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&LocalFunctionTokens> {
        self.tokens.as_deref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut LocalFunctionTokens> {
        self.tokens.as_deref_mut()
    }

    /// Adds a parameter to this function.
    pub fn with_parameter(mut self, parameter: impl Into<TypedIdentifier>) -> Self {
        self.parameters.push(parameter.into());
        self
    }

    /// Marks this function as variadic.
    pub fn variadic(mut self) -> Self {
        self.is_variadic = true;
        self
    }

    /// Sets the variadic type for this function.
    ///
    /// If the function is not already variadic, this will make it variadic.
    pub fn with_variadic_type(mut self, r#type: impl Into<FunctionVariadicType>) -> Self {
        self.is_variadic = true;
        self.variadic_type = Some(r#type.into());
        self
    }

    /// Sets the variadic type for this function.
    ///
    /// If the function is not already variadic, this will make it variadic.
    pub fn set_variadic_type(&mut self, r#type: impl Into<FunctionVariadicType>) {
        self.is_variadic = true;
        self.variadic_type = Some(r#type.into());
    }

    /// Returns the variadic type, if any.
    #[inline]
    pub fn get_variadic_type(&self) -> Option<&FunctionVariadicType> {
        self.variadic_type.as_ref()
    }

    /// Returns whether this function has a variadic type.
    #[inline]
    pub fn has_variadic_type(&self) -> bool {
        self.variadic_type.is_some()
    }

    /// Returns a mutable reference to the variadic type, if any.
    #[inline]
    pub fn mutate_variadic_type(&mut self) -> Option<&mut FunctionVariadicType> {
        self.variadic_type.as_mut()
    }

    /// Sets the return type for this function.
    pub fn with_return_type(mut self, return_type: impl Into<FunctionReturnType>) -> Self {
        self.return_type = Some(return_type.into());
        self
    }

    /// Sets the return type for this function.
    pub fn set_return_type(&mut self, return_type: impl Into<FunctionReturnType>) {
        self.return_type = Some(return_type.into());
    }

    /// Returns the return type, if any.
    #[inline]
    pub fn get_return_type(&self) -> Option<&FunctionReturnType> {
        self.return_type.as_ref()
    }

    /// Returns whether this function has a return type.
    #[inline]
    pub fn has_return_type(&self) -> bool {
        self.return_type.is_some()
    }

    /// Returns a mutable reference to the return type, if any.
    #[inline]
    pub fn mutate_return_type(&mut self) -> Option<&mut FunctionReturnType> {
        self.return_type.as_mut()
    }

    /// Sets the generic parameters for this function.
    pub fn with_generic_parameters(mut self, generic_parameters: GenericParameters) -> Self {
        self.generic_parameters = Some(generic_parameters);
        self
    }

    /// Sets the generic parameters for this function.
    #[inline]
    pub fn set_generic_parameters(&mut self, generic_parameters: GenericParameters) {
        self.generic_parameters = Some(generic_parameters);
    }

    /// Returns the generic parameters, if any.
    #[inline]
    pub fn get_generic_parameters(&self) -> Option<&GenericParameters> {
        self.generic_parameters.as_ref()
    }

    /// Returns a mutable reference to the parameters.
    #[inline]
    pub fn mutate_parameters(&mut self) -> &mut Vec<TypedIdentifier> {
        &mut self.parameters
    }

    /// Returns a mutable reference to the block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns a mutable reference to the identifier.
    #[inline]
    pub fn mutate_identifier(&mut self) -> &mut Identifier {
        &mut self.identifier
    }

    /// Returns the function's block.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns the function's parameters.
    #[inline]
    pub fn get_parameters(&self) -> &Vec<TypedIdentifier> {
        &self.parameters
    }

    /// Returns an iterator over the parameters.
    #[inline]
    pub fn iter_parameters(&self) -> impl Iterator<Item = &TypedIdentifier> {
        self.parameters.iter()
    }

    /// Returns a mutable iterator over the parameters.
    #[inline]
    pub fn iter_mut_parameters(&mut self) -> impl Iterator<Item = &mut TypedIdentifier> {
        self.parameters.iter_mut()
    }

    /// Returns the function's identifier.
    #[inline]
    pub fn get_identifier(&self) -> &Identifier {
        &self.identifier
    }

    /// Returns the function's name.
    #[inline]
    pub fn get_name(&self) -> &str {
        self.identifier.get_name()
    }

    /// Returns whether this function has a parameter with the given name.
    #[inline]
    pub fn has_parameter(&self, name: &str) -> bool {
        self.parameters
            .iter()
            .any(|parameter| parameter.get_name() == name)
    }

    /// Returns whether this function has parameters.
    #[inline]
    pub fn has_parameters(&self) -> bool {
        !self.parameters.is_empty()
    }

    /// Returns whether this function is variadic.
    #[inline]
    pub fn is_variadic(&self) -> bool {
        self.is_variadic
    }

    /// Returns the number of parameters.
    #[inline]
    pub fn parameters_count(&self) -> usize {
        self.parameters.len()
    }

    /// Removes all type annotations from this function.
    pub fn clear_types(&mut self) {
        self.return_type.take();
        self.variadic_type.take();
        self.generic_parameters.take();
        for parameter in &mut self.parameters {
            parameter.remove_type();
        }
        if let Some(tokens) = &mut self.tokens {
            tokens.variable_arguments_colon.take();
        }
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_deref_mut().unwrap().local
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_deref_mut().unwrap().end
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.tokens = Some(
                LocalFunctionTokens {
                    local: Token::from_content("local"),
                    function_body: FunctionBodyTokens {
                        function: Token::from_content("function"),
                        opening_parenthese: Token::from_content("("),
                        closing_parenthese: Token::from_content(")"),
                        end: Token::from_content("end"),
                        parameter_commas: Vec::new(),
                        variable_arguments: None,
                        variable_arguments_colon: None,
                        return_type_colon: None,
                    },
                }
                .into(),
            );
        }
    }

    super::impl_token_fns!(
        target = [identifier]
        iter = [parameters, generic_parameters, tokens]
    );
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn has_parameter_is_true_when_single_param_matches() {
        let func = LocalFunctionStatement::from_name("foo", Block::default()).with_parameter("bar");

        assert!(func.has_parameter("bar"));
    }

    #[test]
    fn has_parameter_is_true_when_at_least_one_param_matches() {
        let func = LocalFunctionStatement::from_name("foo", Block::default())
            .with_parameter("bar")
            .with_parameter("baz");

        assert!(func.has_parameter("baz"));
    }

    #[test]
    fn has_parameter_is_false_when_none_matches() {
        let func = LocalFunctionStatement::from_name("foo", Block::default())
            .with_parameter("bar")
            .with_parameter("baz");

        assert!(!func.has_parameter("foo"));
    }
}
