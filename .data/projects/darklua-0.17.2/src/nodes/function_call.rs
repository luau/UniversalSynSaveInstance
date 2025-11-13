use crate::nodes::{Arguments, Expression, Identifier, Prefix, Token};

/// Tokens associated with a function call.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionCallTokens {
    pub colon: Option<Token>,
}

impl FunctionCallTokens {
    super::impl_token_fns!(iter = [colon]);
}

/// Represents a function call expression (e.g., `func()`, `obj:method()`, `a.b.c()`).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct FunctionCall {
    prefix: Box<Prefix>,
    arguments: Arguments,
    method: Option<Identifier>,
    tokens: Option<FunctionCallTokens>,
}

impl FunctionCall {
    /// Creates a new function call with the given prefix, arguments, and optional method.
    pub fn new(prefix: Prefix, arguments: Arguments, method: Option<Identifier>) -> Self {
        Self {
            prefix: Box::new(prefix),
            arguments,
            method,
            tokens: None,
        }
    }

    /// Creates a new function call with the given name.
    pub fn from_name<T: Into<Identifier>>(name: T) -> Self {
        Self {
            prefix: Box::new(name.into().into()),
            arguments: Arguments::default(),
            method: None,
            tokens: None,
        }
    }

    /// Creates a new function call with the given prefix.
    pub fn from_prefix<T: Into<Prefix>>(prefix: T) -> Self {
        Self {
            prefix: Box::new(prefix.into()),
            arguments: Arguments::default(),
            method: None,
            tokens: None,
        }
    }

    /// Sets the tokens for this function call.
    pub fn with_tokens(mut self, tokens: FunctionCallTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this function call.
    #[inline]
    pub fn set_tokens(&mut self, tokens: FunctionCallTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this function call, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&FunctionCallTokens> {
        self.tokens.as_ref()
    }

    /// Sets the arguments for this function call.
    pub fn with_arguments<A: Into<Arguments>>(mut self, arguments: A) -> Self {
        self.arguments = arguments.into();
        self
    }

    /// Adds an argument to this function call.
    pub fn with_argument<T: Into<Expression>>(mut self, argument: T) -> Self {
        self.arguments = self.arguments.with_argument(argument);
        self
    }

    /// Sets the method name for this function call (for method calls like `obj:method()`).
    pub fn with_method<IntoString: Into<Identifier>>(mut self, method: IntoString) -> Self {
        self.method.replace(method.into());
        self
    }

    /// Returns the arguments of this function call.
    #[inline]
    pub fn get_arguments(&self) -> &Arguments {
        &self.arguments
    }

    /// Returns the method name, if this is a method call.
    #[inline]
    pub fn get_method(&self) -> Option<&Identifier> {
        self.method.as_ref()
    }

    /// Returns if this call uses a method.
    #[inline]
    pub fn has_method(&self) -> bool {
        self.method.is_some()
    }

    /// Returns the prefix (what is being called) of this function call.
    #[inline]
    pub fn get_prefix(&self) -> &Prefix {
        &self.prefix
    }

    /// Removes and returns the method name, if any.
    #[inline]
    pub fn take_method(&mut self) -> Option<Identifier> {
        let method = self.method.take();
        if let Some(tokens) = self.tokens.as_mut() {
            tokens.colon = None;
        }
        method
    }

    /// Sets the arguments for this function call.
    #[inline]
    pub fn set_arguments(&mut self, arguments: Arguments) {
        self.arguments = arguments;
    }

    /// Sets the method name for this function call.
    #[inline]
    pub fn set_method(&mut self, method: Identifier) {
        self.method.replace(method);
    }

    /// Returns a mutable reference to the arguments.
    #[inline]
    pub fn mutate_arguments(&mut self) -> &mut Arguments {
        &mut self.arguments
    }

    /// Returns a mutable reference to the prefix.
    #[inline]
    pub fn mutate_prefix(&mut self) -> &mut Prefix {
        &mut self.prefix
    }

    /// Returns a mutable reference to the first token of this function call,
    /// creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        self.prefix.mutate_first_token()
    }

    /// Returns a mutable reference to the last token of this function call,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.arguments.mutate_last_token()
    }

    super::impl_token_fns!(iter = [tokens, method]);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{nodes::Statement, Parser};

    fn parse_call(code: &str) -> FunctionCall {
        let parser = Parser::default().preserve_tokens();
        let block = parser.parse(code).expect("code should parse");
        if let Some(Statement::Call(call)) = block.first_statement() {
            return call.clone();
        }
        panic!("failed to parse call from: {}", code);
    }

    #[test]
    fn test_take_method_removes_colon_token() {
        let mut call = parse_call("obj:method()");

        assert!(call.get_tokens().unwrap().colon.is_some());
        call.take_method();
        assert!(call.get_tokens().unwrap().colon.is_none());
    }
}
