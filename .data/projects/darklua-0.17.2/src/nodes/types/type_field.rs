use crate::nodes::{Identifier, Token};

use super::TypeName;

/// Represents a field access on a type.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypeField {
    namespace: Identifier,
    name: TypeName,
    token: Option<Token>,
}

impl TypeField {
    /// Creates a new type field with the specified namespace and type name.
    pub fn new(namespace: impl Into<Identifier>, type_name: TypeName) -> Self {
        Self {
            namespace: namespace.into(),
            name: type_name,
            token: None,
        }
    }

    /// Returns the type name part of this field access.
    pub fn get_type_name(&self) -> &TypeName {
        &self.name
    }

    /// Returns a mutable reference to the type name part of this field access.
    pub fn mutate_type_name(&mut self) -> &mut TypeName {
        &mut self.name
    }

    /// Returns the namespace identifier of this field access.
    pub fn get_namespace(&self) -> &Identifier {
        &self.namespace
    }

    /// Returns a mutable reference to the namespace identifier of this field access.
    pub fn mutate_namespace(&mut self) -> &mut Identifier {
        &mut self.namespace
    }

    /// Associates a token with this type field and returns the modified field.
    pub fn with_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the token associated with this type field.
    #[inline]
    pub fn set_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns the token associated with this type field, if any.
    #[inline]
    pub fn get_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    pub fn mutate_last_token(&mut self) -> &mut Token {
        self.name.mutate_last_token()
    }

    super::impl_token_fns!(target = [namespace] iter = [token]);
}
