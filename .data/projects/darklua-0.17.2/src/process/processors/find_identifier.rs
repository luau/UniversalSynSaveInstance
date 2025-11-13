use std::iter::FromIterator;

use crate::{nodes::Identifier, process::NodeProcessor};

/// A processor to find usage of a given set of identifiers.
///
/// # Example
/// The following example illustrate how you can use this processor to find usage of the
/// `foo` variable.
/// ```
/// # use darklua_core::nodes::Expression;
/// # use darklua_core::process::processors::FindVariables;
/// # use darklua_core::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
/// let variables = vec!["foo"];
/// let mut find_foo: FindVariables = variables.into_iter().collect();
///
/// let mut foo_expression = Expression::identifier("foo");
/// DefaultVisitor::visit_expression(&mut foo_expression, &mut find_foo);
///
/// assert!(find_foo.has_found_usage());
/// ```
/// If you pass a node that does not contain the given variable, the processor will return
/// false when calling the `has_found_usage()` method.
/// ```
/// # use darklua_core::nodes::Expression;
/// # use darklua_core::process::processors::FindVariables;
/// # use darklua_core::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
/// # let variables = vec!["foo"];
/// # let mut find_foo: FindVariables = variables.into_iter().collect();
/// let mut bar_expression = Expression::identifier("bar");
/// DefaultVisitor::visit_expression(&mut bar_expression, &mut find_foo);
///
/// assert!(!find_foo.has_found_usage());
/// ```
pub struct FindVariables<'a> {
    variables: Vec<&'a str>,
    usage_found: bool,
}

impl<'a> FindVariables<'a> {
    pub fn new(variable: &'a str) -> Self {
        Self {
            variables: vec![variable],
            usage_found: false,
        }
    }

    #[inline]
    pub fn has_found_usage(&self) -> bool {
        self.usage_found
    }
}

impl<'a> FromIterator<&'a str> for FindVariables<'a> {
    fn from_iter<T: IntoIterator<Item = &'a str>>(iter: T) -> Self {
        Self {
            variables: iter.into_iter().collect(),
            usage_found: false,
        }
    }
}

impl NodeProcessor for FindVariables<'_> {
    fn process_variable_expression(&mut self, variable: &mut Identifier) {
        if !self.usage_found {
            let name = variable.get_name();
            self.usage_found = self.variables.iter().any(|v| *v == name)
        }
    }
}
