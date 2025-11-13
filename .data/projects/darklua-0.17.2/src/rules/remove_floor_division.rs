use std::{mem, ops};

use crate::nodes::{
    BinaryOperator, Block, CompoundOperator, Expression, FieldExpression, FunctionCall,
    LocalAssignStatement, Prefix, Statement,
};
use crate::process::{IdentifierTracker, NodeProcessor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    verify_no_rule_properties, Context, FlawlessRule, RemoveCompoundAssignment, RuleConfiguration,
    RuleConfigurationError, RuleProperties,
};

struct RemoveFloorDivisionProcessor {
    math_floor_identifier: String,
    define_math_floor: bool,
    identifier_tracker: IdentifierTracker,
}

impl ops::Deref for RemoveFloorDivisionProcessor {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl ops::DerefMut for RemoveFloorDivisionProcessor {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

const DEFAULT_MATH_LIBRARY: &str = "math";
const DEFAULT_MATH_FLOOR_NAME: &str = "floor";

impl RemoveFloorDivisionProcessor {
    fn new(math_floor_identifier: impl Into<String>) -> Self {
        Self {
            math_floor_identifier: math_floor_identifier.into(),
            define_math_floor: false,
            identifier_tracker: Default::default(),
        }
    }

    fn build_math_floor_call(&mut self, value: Expression) -> Expression {
        FunctionCall::from_prefix(if self.is_identifier_used(DEFAULT_MATH_LIBRARY) {
            self.define_math_floor = true;
            Prefix::from_name(&self.math_floor_identifier)
        } else {
            FieldExpression::new(
                Prefix::from_name(DEFAULT_MATH_LIBRARY),
                DEFAULT_MATH_FLOOR_NAME,
            )
            .into()
        })
        .with_argument(value)
        .into()
    }
}

impl NodeProcessor for RemoveFloorDivisionProcessor {
    fn process_statement(&mut self, statement: &mut Statement) {
        match statement {
            Statement::CompoundAssign(assign_statement)
                if assign_statement.get_operator() == CompoundOperator::DoubleSlash =>
            {
                RemoveCompoundAssignment::default().replace_compound_assignment(statement);
            }
            _ => {}
        }
    }

    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::Binary(binary) = expression {
            if binary.operator() == BinaryOperator::DoubleSlash {
                binary.set_operator(BinaryOperator::Slash);

                let value = mem::replace(expression, Expression::nil());

                *expression = self.build_math_floor_call(value);
            }
        }
    }
}

pub const REMOVE_FLOOR_DIVISION_RULE_NAME: &str = "remove_floor_division";

/// A rule that removes interpolated strings.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveFloorDivision {}

impl FlawlessRule for RemoveFloorDivision {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        const MATH_FLOOR_IDENTIFIER: &str = "__DARKLUA_MATH_FLOOR";

        let mut processor = RemoveFloorDivisionProcessor::new(MATH_FLOOR_IDENTIFIER);
        ScopeVisitor::visit_block(block, &mut processor);

        if processor.define_math_floor {
            block.insert_statement(
                0,
                LocalAssignStatement::from_variable(MATH_FLOOR_IDENTIFIER).with_value(
                    FieldExpression::new(
                        Prefix::from_name(DEFAULT_MATH_LIBRARY),
                        DEFAULT_MATH_FLOOR_NAME,
                    ),
                ),
            );
        }
    }
}

impl RuleConfiguration for RemoveFloorDivision {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_FLOOR_DIVISION_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        RuleProperties::new()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    fn new_rule() -> RemoveFloorDivision {
        RemoveFloorDivision::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_floor_division", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_floor_division',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
