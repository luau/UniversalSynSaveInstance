use crate::nodes::{
    BinaryExpression, BinaryOperator, Block, Expression, FunctionCall, Prefix, Statement,
};
use crate::process::{Evaluator, IdentifierTracker, NodeProcessor, NodeVisitor, ScopeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};
use crate::utils::{expressions_as_statement, preserve_arguments_side_effects};

use super::verify_no_rule_properties;

pub const CONVERT_SQUARE_ROOT_CALL_RULE_NAME: &str = "convert_square_root_call";

const DEFAULT_MATH_LIBRARY: &str = "math";
const DEFAULT_MATH_SQRT_NAME: &str = "sqrt";

#[derive(Default)]
struct Processor {
    evaluator: Evaluator,
    identifier_tracker: IdentifierTracker,
}

impl Processor {
    fn new() -> Self {
        Self::default()
    }

    fn is_math_sqrt_call(&self, call: &FunctionCall) -> bool {
        if call.has_method() {
            return false;
        }

        if call.get_arguments().len() != 1 {
            return false;
        }

        if let Prefix::Field(field_expr) = call.get_prefix() {
            if field_expr.get_field().get_name() != DEFAULT_MATH_SQRT_NAME {
                return false;
            }

            if let Prefix::Identifier(identifier) = field_expr.get_prefix() {
                if identifier.get_name() == DEFAULT_MATH_LIBRARY
                    && !self
                        .identifier_tracker
                        .is_identifier_used(DEFAULT_MATH_LIBRARY)
                {
                    return true;
                }
            }
        }

        false
    }
}

impl std::ops::Deref for Processor {
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl std::ops::DerefMut for Processor {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

impl NodeProcessor for Processor {
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::Call(call) = expression {
            if self.is_math_sqrt_call(call) {
                let arguments = call.get_arguments();
                let expressions = arguments.clone().to_expressions();
                if let Some(argument) = expressions.first() {
                    *expression = BinaryExpression::new(
                        BinaryOperator::Caret,
                        argument.clone(),
                        Expression::from(0.5),
                    )
                    .into();
                }
            }
        }
    }

    fn process_statement(&mut self, statement: &mut Statement) {
        if let Statement::Call(call) = statement {
            if self.is_math_sqrt_call(call) {
                let values = preserve_arguments_side_effects(&self.evaluator, call.get_arguments());

                *statement = expressions_as_statement(values);
            }
        }
    }
}

/// A rule that converts square root calls (`math.sqrt(x)`) to exponentiation calls (`x ^ 0.5`).
#[derive(Debug, Default)]
pub struct ConvertSquareRootCall {}

impl FlawlessRule for ConvertSquareRootCall {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::new();
        ScopeVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ConvertSquareRootCall {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)
    }

    fn get_name(&self) -> &'static str {
        CONVERT_SQUARE_ROOT_CALL_RULE_NAME
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

    fn new_rule() -> ConvertSquareRootCall {
        ConvertSquareRootCall::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!(rule, @r###""convert_square_root_call""###);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_square_root_call',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
