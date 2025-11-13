use crate::nodes::{
    Block, FunctionBodyTokens, FunctionReturnType, FunctionVariadicType, GenericParameters, Token,
    TypedIdentifier,
};

/// Represents a function expression.
///
/// A function expression defines an anonymous function with parameters,
/// a body, and optional features like variadics, return types, and generic parameters.
///
/// ```lua
/// local add = function(a: number, b: number): number
///     return a + b
/// end
/// ```
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct FunctionExpression {
    block: Block,
    parameters: Vec<TypedIdentifier>,
    is_variadic: bool,
    variadic_type: Option<FunctionVariadicType>,
    return_type: Option<FunctionReturnType>,
    generic_parameters: Option<GenericParameters>,
    tokens: Option<Box<FunctionBodyTokens>>,
}

impl FunctionExpression {
    /// Creates a new function expression with the given block, parameters, and variadic flag.
    pub fn new(block: Block, parameters: Vec<TypedIdentifier>, is_variadic: bool) -> Self {
        Self {
            block,
            parameters,
            is_variadic,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Creates a new function expression from a block with no parameters.
    pub fn from_block<B: Into<Block>>(block: B) -> Self {
        Self {
            block: block.into(),
            parameters: Vec::new(),
            is_variadic: false,
            variadic_type: None,
            return_type: None,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Sets the parameters of this function expression.
    pub fn with_parameters(mut self, parameters: Vec<TypedIdentifier>) -> Self {
        self.parameters = parameters;
        self
    }

    /// Adds a parameter to this function expression.
    pub fn with_parameter(mut self, parameter: impl Into<TypedIdentifier>) -> Self {
        self.parameters.push(parameter.into());
        self
    }

    /// Sets the variadic type of this function expression.
    ///
    /// This also marks the function as variadic if it is not already.
    pub fn with_variadic_type(mut self, r#type: impl Into<FunctionVariadicType>) -> Self {
        self.is_variadic = true;
        self.variadic_type = Some(r#type.into());
        self
    }

    /// Sets the return type of this function expression.
    pub fn with_return_type(mut self, return_type: impl Into<FunctionReturnType>) -> Self {
        self.return_type = Some(return_type.into());
        self
    }

    /// Sets the return type of this function expression.
    #[inline]
    pub fn set_return_type(&mut self, return_type: impl Into<FunctionReturnType>) {
        self.return_type = Some(return_type.into());
    }

    /// Returns a reference to the return type of this function expression, if any.
    #[inline]
    pub fn get_return_type(&self) -> Option<&FunctionReturnType> {
        self.return_type.as_ref()
    }

    /// Returns whether this function expression has a return type.
    #[inline]
    pub fn has_return_type(&self) -> bool {
        self.return_type.is_some()
    }

    /// Returns a mutable reference to the return type of this function expression, if any.
    #[inline]
    pub fn mutate_return_type(&mut self) -> Option<&mut FunctionReturnType> {
        self.return_type.as_mut()
    }

    /// Marks this function expression as variadic and returns the updated expression.
    pub fn variadic(mut self) -> Self {
        self.is_variadic = true;
        self
    }

    /// Sets whether this function expression is variadic.
    ///
    /// If set to false, the variadic type is cleared if present.
    pub fn set_variadic(&mut self, is_variadic: bool) {
        self.is_variadic = is_variadic;
        if !is_variadic && self.variadic_type.is_some() {
            self.variadic_type.take();
        }
    }

    /// Sets the variadic type of this function expression.
    ///
    /// This also marks the function as variadic if it is not already.
    pub fn set_variadic_type(&mut self, r#type: impl Into<FunctionVariadicType>) {
        self.is_variadic = true;
        self.variadic_type = Some(r#type.into());
    }

    /// Returns a reference to the variadic type of this function expression, if any.
    #[inline]
    pub fn get_variadic_type(&self) -> Option<&FunctionVariadicType> {
        self.variadic_type.as_ref()
    }

    /// Returns whether this function expression has a variadic type.
    #[inline]
    pub fn has_variadic_type(&self) -> bool {
        self.variadic_type.is_some()
    }

    /// Returns a mutable reference to the variadic type of this function expression, if any.
    #[inline]
    pub fn mutate_variadic_type(&mut self) -> Option<&mut FunctionVariadicType> {
        self.variadic_type.as_mut()
    }

    /// Sets the generic parameters of this function expression and returns the updated expression.
    pub fn with_generic_parameters(mut self, generic_parameters: GenericParameters) -> Self {
        self.generic_parameters = Some(generic_parameters);
        self
    }

    /// Sets the generic parameters of this function expression.
    #[inline]
    pub fn set_generic_parameters(&mut self, generic_parameters: GenericParameters) {
        self.generic_parameters = Some(generic_parameters);
    }

    /// Returns a reference to the generic parameters of this function expression, if any.
    #[inline]
    pub fn get_generic_parameters(&self) -> Option<&GenericParameters> {
        self.generic_parameters.as_ref()
    }

    /// Returns whether this function expression has generic parameters.
    #[inline]
    pub fn is_generic(&self) -> bool {
        self.generic_parameters.is_some()
    }

    /// Associates a token with this function expression.
    pub fn with_tokens(mut self, tokens: FunctionBodyTokens) -> Self {
        self.tokens = Some(tokens.into());
        self
    }

    /// Associates a token with this function expression.
    #[inline]
    pub fn set_tokens(&mut self, tokens: FunctionBodyTokens) {
        self.tokens = Some(tokens.into());
    }

    /// Returns a reference to the token attached to this function expression, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&FunctionBodyTokens> {
        self.tokens.as_ref().map(|tokens| tokens.as_ref())
    }

    /// Returns a reference to the block of this function expression.
    #[inline]
    pub fn get_block(&self) -> &Block {
        &self.block
    }

    /// Returns a reference to the parameters of this function expression.
    #[inline]
    pub fn get_parameters(&self) -> &Vec<TypedIdentifier> {
        &self.parameters
    }

    /// Returns an iterator over the parameters of this function expression.
    #[inline]
    pub fn iter_parameters(&self) -> impl Iterator<Item = &TypedIdentifier> {
        self.parameters.iter()
    }

    /// Returns a mutable iterator over the parameters of this function expression.
    #[inline]
    pub fn iter_mut_parameters(&mut self) -> impl Iterator<Item = &mut TypedIdentifier> {
        self.parameters.iter_mut()
    }

    /// Returns whether this function expression is variadic.
    #[inline]
    pub fn is_variadic(&self) -> bool {
        self.is_variadic
    }

    /// Returns a mutable reference to the block of this function expression.
    #[inline]
    pub fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    /// Returns a mutable reference to the parameters of this function expression.
    #[inline]
    pub fn mutate_parameters(&mut self) -> &mut Vec<TypedIdentifier> {
        &mut self.parameters
    }

    /// Returns the number of parameters of this function expression.
    #[inline]
    pub fn parameters_count(&self) -> usize {
        self.parameters.len()
    }

    /// Returns whether this function expression has parameters.
    #[inline]
    pub fn has_parameters(&self) -> bool {
        !self.parameters.is_empty()
    }

    /// Removes all type information from this function expression.
    ///
    /// This includes return type, variadic type, generic parameters, and parameter types.
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

    /// Returns a mutable reference to the first token for this function expression,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().function
    }

    /// Returns a mutable reference to the last token for this function expression,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.set_default_tokens();
        &mut self.tokens.as_mut().unwrap().end
    }

    fn set_default_tokens(&mut self) {
        if self.tokens.is_none() {
            self.tokens = Some(Box::new(FunctionBodyTokens {
                function: Token::from_content("function"),
                opening_parenthese: Token::from_content("("),
                closing_parenthese: Token::from_content(")"),
                end: Token::from_content("end"),
                parameter_commas: Vec::new(),
                variable_arguments: self.is_variadic.then(|| Token::from_content("...")),
                variable_arguments_colon: self
                    .variadic_type
                    .as_ref()
                    .map(|_| Token::from_content(":")),
                return_type_colon: self.return_type.as_ref().map(|_| Token::from_content(":")),
            }));
        }
    }

    super::impl_token_fns!(iter = [parameters, generic_parameters, tokens]);
}
