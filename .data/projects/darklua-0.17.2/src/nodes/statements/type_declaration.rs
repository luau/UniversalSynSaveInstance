use crate::nodes::{
    GenericParameterMutRef, GenericParametersWithDefaults, Identifier, Token, Trivia, Type,
};

/// Tokens associated with a type declaration statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeDeclarationTokens {
    pub r#type: Token,
    pub equal: Token,
    pub export: Option<Token>,
}

impl TypeDeclarationTokens {
    super::impl_token_fns!(
        target = [r#type, equal]
        iter = [export]
    );
}

/// Represents a type declaration statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeDeclarationStatement {
    name: Identifier,
    r#type: Box<Type>,
    exported: bool,
    generic_parameters: Option<GenericParametersWithDefaults>,
    tokens: Option<TypeDeclarationTokens>,
}

impl TypeDeclarationStatement {
    /// Creates a new type declaration with the given name and type.
    pub fn new(name: impl Into<Identifier>, r#type: impl Into<Type>) -> Self {
        Self {
            name: name.into(),
            r#type: Box::new(r#type.into()),
            exported: false,
            generic_parameters: None,
            tokens: None,
        }
    }

    /// Sets the generic parameters for this type declaration.
    pub fn with_generic_parameters(
        mut self,
        generic_parameters: GenericParametersWithDefaults,
    ) -> Self {
        self.generic_parameters = Some(generic_parameters);
        self
    }

    /// Sets the generic parameters for this type declaration.
    #[inline]
    pub fn set_generic_parameters(&mut self, generic_parameters: GenericParametersWithDefaults) {
        self.generic_parameters = Some(generic_parameters);
    }

    /// Returns the generic parameters, if any.
    #[inline]
    pub fn get_generic_parameters(&self) -> Option<&GenericParametersWithDefaults> {
        self.generic_parameters.as_ref()
    }

    /// Returns a mutable reference to the generic parameters, if any.
    #[inline]
    pub fn mutate_generic_parameters(&mut self) -> Option<&mut GenericParametersWithDefaults> {
        self.generic_parameters.as_mut()
    }

    /// Marks this type declaration as exported.
    pub fn export(mut self) -> Self {
        self.exported = true;
        self
    }

    /// Marks this type declaration as exported.
    #[inline]
    pub fn set_exported(&mut self) {
        self.exported = true;
    }

    /// Removes the exported status from this type declaration.
    #[inline]
    pub fn remove_exported(&mut self) {
        self.exported = false;
        if let Some(tokens) = self.tokens.as_mut() {
            tokens.export.take();
        }
    }

    /// Returns whether this type declaration is exported.
    #[inline]
    pub fn is_exported(&self) -> bool {
        self.exported
    }

    /// Returns the declared type.
    #[inline]
    pub fn get_type(&self) -> &Type {
        &self.r#type
    }

    /// Returns a mutable reference to the declared type.
    #[inline]
    pub fn mutate_type(&mut self) -> &mut Type {
        &mut self.r#type
    }

    /// Returns the name of this type declaration.
    #[inline]
    pub fn get_name(&self) -> &Identifier {
        &self.name
    }

    /// Returns a mutable reference to the name.
    #[inline]
    pub fn mutate_name(&mut self) -> &mut Identifier {
        &mut self.name
    }

    /// Sets the tokens for this type declaration.
    pub fn with_tokens(mut self, tokens: TypeDeclarationTokens) -> Self {
        self.tokens = Some(tokens);
        self
    }

    /// Sets the tokens for this type declaration.
    #[inline]
    pub fn set_tokens(&mut self, tokens: TypeDeclarationTokens) {
        self.tokens = Some(tokens);
    }

    /// Returns the tokens for this type declaration, if any.
    #[inline]
    pub fn get_tokens(&self) -> Option<&TypeDeclarationTokens> {
        self.tokens.as_ref()
    }

    /// Returns a mutable reference to the tokens, if any.
    #[inline]
    pub fn mutate_tokens(&mut self) -> Option<&mut TypeDeclarationTokens> {
        self.tokens.as_mut()
    }

    /// Clears all comments from the tokens in this node.
    pub fn clear_comments(&mut self) {
        self.name.clear_comments();
        if let Some(tokens) = &mut self.tokens {
            tokens.clear_comments();
        }
        if let Some(parameters) = self.generic_parameters.as_mut() {
            parameters.clear_comments();

            for parameter in parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(variable) => {
                        variable.clear_comments();
                    }
                    GenericParameterMutRef::TypeVariableWithDefault(variable_with_default) => {
                        variable_with_default.clear_comments();
                    }
                    GenericParameterMutRef::GenericTypePack(_) => {}
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_pack_with_default,
                    ) => {
                        generic_pack_with_default.clear_comments();
                    }
                }
            }
        }
    }

    /// Clears all whitespaces information from the tokens in this node.
    pub fn clear_whitespaces(&mut self) {
        self.name.clear_whitespaces();
        if let Some(tokens) = &mut self.tokens {
            tokens.clear_whitespaces();
        }
        if let Some(parameters) = self.generic_parameters.as_mut() {
            parameters.clear_whitespaces();

            for parameter in parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(variable) => {
                        variable.clear_whitespaces();
                    }
                    GenericParameterMutRef::TypeVariableWithDefault(variable_with_default) => {
                        variable_with_default.clear_whitespaces();
                    }
                    GenericParameterMutRef::GenericTypePack(_) => {}
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_pack_with_default,
                    ) => {
                        generic_pack_with_default.clear_whitespaces();
                    }
                }
            }
        }
    }

    pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
        self.name.replace_referenced_tokens(code);
        if let Some(tokens) = &mut self.tokens {
            tokens.replace_referenced_tokens(code);
        }
        if let Some(parameters) = self.generic_parameters.as_mut() {
            parameters.replace_referenced_tokens(code);

            for parameter in parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(variable) => {
                        variable.replace_referenced_tokens(code);
                    }
                    GenericParameterMutRef::TypeVariableWithDefault(variable_with_default) => {
                        variable_with_default.replace_referenced_tokens(code);
                    }
                    GenericParameterMutRef::GenericTypePack(_) => {}
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_pack_with_default,
                    ) => {
                        generic_pack_with_default.replace_referenced_tokens(code);
                    }
                }
            }
        }
    }

    pub(crate) fn shift_token_line(&mut self, amount: isize) {
        self.name.shift_token_line(amount);
        if let Some(tokens) = &mut self.tokens {
            tokens.shift_token_line(amount);
        }
        if let Some(parameters) = self.generic_parameters.as_mut() {
            parameters.shift_token_line(amount);

            for parameter in parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(variable) => {
                        variable.shift_token_line(amount);
                    }
                    GenericParameterMutRef::TypeVariableWithDefault(variable_with_default) => {
                        variable_with_default.shift_token_line(amount);
                    }
                    GenericParameterMutRef::GenericTypePack(_) => {}
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_pack_with_default,
                    ) => {
                        generic_pack_with_default.shift_token_line(amount);
                    }
                }
            }
        }
    }

    pub(crate) fn filter_comments(&mut self, filter: impl Fn(&Trivia) -> bool) {
        self.name.filter_comments(&filter);
        if let Some(tokens) = &mut self.tokens {
            tokens.filter_comments(&filter);
        }
        if let Some(parameters) = self.generic_parameters.as_mut() {
            parameters.filter_comments(&filter);

            for parameter in parameters {
                match parameter {
                    GenericParameterMutRef::TypeVariable(variable) => {
                        variable.filter_comments(&filter);
                    }
                    GenericParameterMutRef::TypeVariableWithDefault(variable_with_default) => {
                        variable_with_default.filter_comments(&filter);
                    }
                    GenericParameterMutRef::GenericTypePack(_) => {}
                    GenericParameterMutRef::GenericTypePackWithDefault(
                        generic_pack_with_default,
                    ) => {
                        generic_pack_with_default.filter_comments(&filter);
                    }
                }
            }
        }
    }

    /// Returns a mutable reference to the first token for this statement, creating it if missing.
    pub fn mutate_first_token(&mut self) -> &mut Token {
        let is_exported = self.is_exported();
        if self.tokens.is_none() {
            self.tokens = Some(TypeDeclarationTokens {
                r#type: Token::from_content("type"),
                equal: Token::from_content("="),
                export: is_exported.then(|| Token::from_content("export")),
            });
        }
        let tokens = self.tokens.as_mut().unwrap();
        if is_exported {
            if tokens.export.is_none() {
                tokens.export = Some(Token::from_content("export"));
            }
            tokens.export.as_mut().unwrap()
        } else {
            &mut tokens.r#type
        }
    }

    /// Returns a mutable reference to the last token for this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut Token {
        // Use '=' as structural tail; avoid walking type tree
        if self.tokens.is_none() {
            self.mutate_first_token();
        }
        &mut self.tokens.as_mut().unwrap().equal
    }
}
