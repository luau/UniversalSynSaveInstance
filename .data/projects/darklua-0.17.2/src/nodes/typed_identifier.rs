use crate::nodes::{Identifier, Token, Type};

/// Represents an identifier with an optional type annotation.
///
/// TypedIdentifier extends the basic Identifier to support Luau's type system, where
/// variables and parameters can have explicit type annotations. It stores the
/// identifier itself, the optional type, and the colon token for source preservation.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TypedIdentifier {
    name: Identifier,
    r#type: Option<Type>,
    token: Option<Token>,
}

impl TypedIdentifier {
    /// Creates a new TypedIdentifier with the given name and no type.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: Identifier::new(name.into()),
            r#type: None,
            token: None,
        }
    }

    /// Sets the type for this identifier and returns the updated typed identifier.
    pub fn with_type(mut self, type_value: impl Into<Type>) -> Self {
        self.r#type = Some(type_value.into());
        self
    }

    /// Attaches a colon token to this typed identifier and returns the updated identifier.
    pub fn with_colon_token(mut self, token: Token) -> Self {
        self.token = Some(token);
        self
    }

    /// Sets the colon token for this typed identifier.
    #[inline]
    pub fn set_colon_token(&mut self, token: Token) {
        self.token = Some(token);
    }

    /// Returns a reference to the colon token of this typed identifier, if any.
    #[inline]
    pub fn get_colon_token(&self) -> Option<&Token> {
        self.token.as_ref()
    }

    /// Returns a reference to the underlying identifier.
    #[inline]
    pub fn get_identifier(&self) -> &Identifier {
        &self.name
    }

    /// Returns a reference to the type of this identifier, if any.
    #[inline]
    pub fn get_type(&self) -> Option<&Type> {
        self.r#type.as_ref()
    }

    /// Checks if this identifier has a type annotation.
    #[inline]
    pub fn has_type(&self) -> bool {
        self.r#type.is_some()
    }

    /// Returns a mutable reference to the type of this identifier, if any.
    #[inline]
    pub fn mutate_type(&mut self) -> Option<&mut Type> {
        self.r#type.as_mut()
    }

    /// Removes and returns the type annotation of this identifier, if any.
    /// Also removes the colon token, if any.
    pub fn remove_type(&mut self) -> Option<Type> {
        self.token.take();
        self.r#type.take()
    }

    super::impl_token_fns!(
        target = [name]
        iter = [token]
    );
}

impl<IntoIdentifier: Into<Identifier>> From<IntoIdentifier> for TypedIdentifier {
    fn from(name: IntoIdentifier) -> Self {
        Self {
            name: name.into(),
            r#type: None,
            token: None,
        }
    }
}

impl std::ops::Deref for TypedIdentifier {
    type Target = Identifier;

    fn deref(&self) -> &Self::Target {
        &self.name
    }
}

impl std::ops::DerefMut for TypedIdentifier {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.name
    }
}

#[cfg(test)]
mod test {
    use crate::nodes::Position;

    use super::*;

    #[test]
    fn set_name_replaces_the_token_content() {
        let token = Token::new_with_line(7, 10, 1);
        let mut typed_identifier = TypedIdentifier::from(Identifier::new("var").with_token(token));

        typed_identifier.set_name("newVar");

        assert_eq!(
            typed_identifier.get_identifier().get_token().unwrap(),
            &Token::from_position(Position::LineNumber {
                line_number: 1,
                content: "newVar".into(),
            })
        );
    }
}
