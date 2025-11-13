use std::ops;

use crate::{
    nodes::{Identifier, TypeField},
    process::{IdentifierTracker, NodeProcessor},
};

/// A processor to find usage of a given variable.
pub(crate) struct FindUsage<'a> {
    variable: &'a str,
    usage_found: bool,
    identifier_tracker: IdentifierTracker,
}

impl ops::Deref for FindUsage<'_> {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl ops::DerefMut for FindUsage<'_> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

impl<'a> FindUsage<'a> {
    pub fn new(variable: &'a str) -> Self {
        Self {
            variable,
            usage_found: false,
            identifier_tracker: Default::default(),
        }
    }

    #[inline]
    pub fn has_found_usage(&self) -> bool {
        self.usage_found
    }

    fn verify_identifier(&mut self, variable: &Identifier) {
        if !self.usage_found && variable.get_name() == self.variable {
            self.usage_found = !self.is_identifier_used(self.variable);
        }
    }
}

impl NodeProcessor for FindUsage<'_> {
    fn process_variable_expression(&mut self, variable: &mut Identifier) {
        self.verify_identifier(variable);
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        self.verify_identifier(type_field.get_namespace());
    }
}
