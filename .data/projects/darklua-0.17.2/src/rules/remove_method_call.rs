use crate::nodes::{Block, Expression, FieldExpression, FunctionCall, Prefix};
use crate::process::{DefaultVisitor, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

#[derive(Debug, Default)]
struct Processor {}

impl NodeProcessor for Processor {
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::Call(call) = expression {
            self.process_function_call(call);
        }
    }

    fn process_function_call(&mut self, call: &mut FunctionCall) {
        if !call.has_method() {
            return;
        }

        let replace_with: Option<Prefix> = match call.get_prefix() {
            Prefix::Identifier(identifier) => Some(identifier.clone().into()),
            Prefix::Parenthese(parenthese) => match *parenthese.inner_expression() {
                Expression::If(_)
                | Expression::Index(_)
                | Expression::Field(_)
                | Expression::Function(_)
                | Expression::Binary(_)
                | Expression::Table(_)
                | Expression::Unary(_)
                | Expression::VariableArguments(_)
                | Expression::TypeCast(_)
                | Expression::InterpolatedString(_)
                | Expression::Parenthese(_)
                | Expression::Call(_) => None,

                Expression::Nil(_)
                | Expression::True(_)
                | Expression::False(_)
                | Expression::String(_)
                | Expression::Number(_)
                | Expression::Identifier(_) => Some(parenthese.inner_expression().clone().into()),
            },
            _ => None,
        };

        if let Some(new_prefix) = replace_with {
            let method_name = call
                .take_method()
                .expect("method name is expected to exist");

            *call.mutate_prefix() = FieldExpression::new(new_prefix.clone(), method_name).into();
            call.mutate_arguments()
                .insert(0, Expression::from(new_prefix));
        }
    }
}

pub const REMOVE_METHOD_CALL_RULE_NAME: &str = "remove_method_call";

/// A rule that converts method calls with identifier prefixes to regular function calls.
///
/// This rule transforms calls like `obj:method()` to `obj.method()` when the prefix
/// is a simple identifier.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct RemoveMethodCall {}

impl FlawlessRule for RemoveMethodCall {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Processor::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for RemoveMethodCall {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;
        Ok(())
    }

    fn get_name(&self) -> &'static str {
        REMOVE_METHOD_CALL_RULE_NAME
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

    fn new_rule() -> RemoveMethodCall {
        RemoveMethodCall::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_remove_method_call", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'remove_method_call',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
