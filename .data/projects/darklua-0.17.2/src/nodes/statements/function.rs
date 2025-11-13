use crate::nodes::{
    Block, FunctionBodyTokens, FunctionReturnType, FunctionVariadicType, GenericParameters,
    Identifier, Token, TypedIdentifier,
};

/// Tokens associated with a function name.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionNameTokens {
    /// The tokens for the periods in the function name.
    pub periods: Vec<Token>,
    /// The token for the colon in the function name when a method is present.
    pub colon: Option<Token>,
}

impl FunctionNameTokens {
    super::impl_token_fns!(iter = [periods, colon]);
}

/// Represents the name portion of a function statement.
///
/// Function names can include table fields and methods
/// ([e.g., `module.table:method`]).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionName {
    name: Identifier,
    field_names: Vec<Identifier>,
    method: Option<Identifier>,
    tokens: Option<FunctionNameTokens>,
}

impl FunctionName {
    /// Creates a new function name with fields and an optional method.
    pub fn new(name: Identifier, field_names: Vec<Identifier>, method: Option<Identifier>) -> Self {
        Self {
            name,
            field_names,
            method,
            tokens: None,
        }
    }

    /// Creates a new function name from a single identifier.
    pub fn from_name<S: Into<Identifier>>(name: S) -> Self {
        Self {
            name: name.into(),
            field_names: Vec::new(),
            method: None,
            tokens: None,
        }
    }

    /// Sets the tokens for this function name.
    pub fn with_tokens(mut self, tokens: FunctionNameTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this function name.
    #[inline]
    pub fn set_tokens(&mut self, tokens: FunctionNameTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this function name, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&FunctionNameTokens> {
        self.tokens.as_ref()
    }

    /// Adds a field to this function name.
    pub fn with_field<S: Into<Identifier>>(mut self, field: S) -> Self {
        self.field_names.push(field.into());
        self
    }

    /// Sets the field names for this function name.
    pub fn with_fields(mut self, field_names: Vec<Identifier>) -> Self {
        self.field_names = field_names;
        self
    }

    /// Sets a method for this function name.
    pub fn with_method<S: Into<Identifier>>(mut self, method: S) -> Self {
        self.method.replace(method.into());
        self
    }

    /// Adds a field to this function name.
    pub fn push_field<S: Into<Identifier>>(&mut self, field: S) {
        self.field_names.push(field.into());
    }

    /// Removes and returns the method, if any.
    #[inline]
    pub fn remove_method(&mut self) -> Option<Identifier> {
        self.method.take()
    }

    /// Returns the method, if any.
    #[inline]
    pub fn get_method(&self) -> Option<&Identifier> {
        self.method.as_ref()
    }

    /// Returns whether this function name has a method component.
    #[inline]
    pub fn has_method(&self) -> bool {
        self.method.is_some()
    }

    /// Returns the base name.
    #[inline]
    pub fn get_name(&self) -> &Identifier {
        &self.name
    }

    /// Sets the base name.
    #[inline]
    pub fn set_name(&mut self, name: Identifier) {
        self.name = name;
    }

    /// Returns the field names.
    #[inline]
    pub fn get_field_names(&self) -> &Vec<Identifier> {
        &self.field_names
    }

    /// Returns a mutable reference to the base identifier.
    #[inline]
    pub fn mutate_identifier(&mut self) -> &mut Identifier {
        &mut self.name
    }

    super::impl_token_fns!(iter = [tokens, field_names, method]);
}

/// Represents a function declaration statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionStatement {
    name: FunctionName,
    block: Block,
    parameters: Vec<TypedIdentifier>,
    is_variadic: bool,
    variadic_type: Option<FunctionVariadicType>,
    return_type: Option<FunctionReturnType>,
    generic_parameters: Option<GenericParameters>,
    tokens: Option<Box<FunctionBodyTokens>>,
}

impl FunctionStatement {
    /// Creates a new function statement with the given name, block, parameters, and variadic flag.
    pub fn new(
        name: FunctionName,
        block: Block,
        parameters: Vec<TypedIdentifier>,
        is_variadic: bool,
    ) -> Self {
        Self {
            name,
            block,
            parameters,
            is_variadic,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Creates a new function statement from a single identifier and a block.
    pub fn from_name<S: Into<String>, B: Into<Block>>(name: S, block: B) -> Self {
        Self {
            name: FunctionName::from_name(name),
            block: block.into(),
            parameters: Vec::new(),
            is_variadic: false,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Sets the tokens for this function statement.
    pub fn with_tokens(mut self, tokens: FunctionBodyTokens) -> Self {
        self.tokens = Some(tokens.into());
        self
    }

    /// Sets the tokens for this function statement.
    #[inline]
    pub fn set_tokens(&mut self, tokens: FunctionBodyTokens) {
        self.tokens = Some(tokens.into());
    }

    /// Returns the tokens for this function statement, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&FunctionBodyTokens> {
        self.tokens.as_deref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut FunctionBodyTokens> {
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
    pub fn with_variadic_type(mut self, r#type: impl Into<FunctionVariadicType>) -> Self {
        self.is_variadic = true;
        self.variadic_type = Some(r#type.into());
        self
    }

    /// Sets the variadic type for this function.
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

    /// Returns a reference to the function's block.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns a reference to the function's name.
    #[inline]
    pub fn get_name(&self) -> &FunctionName {
        &self.name
    }

    /// Returns the number of parameters in this function.
    #[inline]
    pub fn parameters_count(&self) -> usize {
        self.parameters.len()
    }

    /// Returns a reference to the function's parameters.
    #[inline]
    pub fn get_parameters(&self) -> &Vec<TypedIdentifier> {
        &self.parameters
    }

    /// Returns an iterator over the function's parameters.
    #[inline]
    pub fn iter_parameters(&self) -> impl Iterator<Item = &TypedIdentifier> {
        self.parameters.iter()
    }

    /// Returns a mutable iterator over the function's parameters.
    #[inline]
    pub fn iter_mut_parameters(&mut self) -> impl Iterator<Item = &mut TypedIdentifier> {
        self.parameters.iter_mut()
    }

    /// Returns whether this function is variadic.
    #[inline]
    pub fn is_variadic(&self) -> bool {
        self.is_variadic
    }

    /// Returns a mutable reference to the function's block.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns a mutable reference to the function's name.
    #[inline]
    pub fn mutate_function_name(&mut self) -> &mut FunctionName {
        &mut self.name
    }

    /// Returns a mutable reference to the function's parameters.
    #[inline]
    pub fn mutate_parameters(&mut self) -> &mut Vec<TypedIdentifier> {
        &mut self.parameters
    }

    /// Removes the method from the function name and adds it as a
    /// field, inserting 'self' as the first parameter.
    ///
    /// If the method is not present, this does nothing.
    pub fn remove_method(&mut self) {
        if let Some(method_name) = self.name.remove_method() {
            self.name.push_field(method_name);
            self.parameters.insert(0, TypedIdentifier::new("self"));
        }
    }

    /// Returns whether this function has any parameters.
    #[inline]
    pub fn has_parameters(&self) -> bool {
        !self.parameters.is_empty()
    }

    /// Removes all type information from the function, including return
    /// type, variadic type, generic parameters, and parameter types.
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
        &mut self.tokens.as_deref_mut().unwrap().function
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
                FunctionBodyTokens {
                    function: Token::from_content("function"),
                    opening_parenthese: Token::from_content("("),
                    closing_parenthese: Token::from_content(")"),
                    end: Token::from_content("end"),
                    parameter_commas: Vec::new(),
                    variable_arguments: None,
                    variable_arguments_colon: None,
                    return_type_colon: None,
                }
                .into(),
            );
        }
    }

    super::impl_token_fns!(
        target = [name]
        iter = [parameters, generic_parameters, tokens]
    );
}
