use crate::{
    nodes::{Block, HexNumber, NumberExpression, Token},
    process::{DefaultVisitor, NodeProcessor, NodeVisitor},
    rules::{Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties},
};

use super::verify_no_rule_properties;

#[derive(Default)]
struct Processor<'a> {
    code: &'a str,
}

impl Processor<'_> {
    fn trim_underscores(&self, token: &mut Token) {
        let content = token.read(self.code);

        if content.contains('_') {
            token.replace_with_content(content.chars().filter(|c| *c != '_').collect::<String>());
        }
    }
}

impl NodeProcessor for Processor<'_> {
    fn process_number_expression(&mut self, number: &mut NumberExpression) {
        match number {
            NumberExpression::Binary(binary) => {
                let value = binary.get_raw_value();
                *number = HexNumber::new(value, false).into();
            }
            NumberExpression::Hex(hex_number) => {
                if let Some(token) = hex_number.mutate_token() {
                    self.trim_underscores(token);
                }
            }
            NumberExpression::Decimal(decimal_number) => {
                if let Some(token) = decimal_number.mutate_token() {
                    self.trim_underscores(token);
                }
            }
        }
    }
}

impl<'a> Processor<'a> {
    fn new(code: &'a str) -> Self {
        Self { code }
    }
}

pub const CONVERT_LUAU_NUMBER_RULE_NAME: &str = "convert_luau_number";

/// A rule that converts Luau number literals to regular Lua numbers.
#[derive(Default, Debug, PartialEq, Eq)]
pub struct ConvertLuauNumber {}

impl FlawlessRule for ConvertLuauNumber {
    fn flawless_process(&self, block: &mut Block, context: &Context) {
        let mut processor = Processor::new(context.original_code());
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ConvertLuauNumber {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        CONVERT_LUAU_NUMBER_RULE_NAME
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

    fn new_rule() -> ConvertLuauNumber {
        ConvertLuauNumber::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_convert_luau_number", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_luau_number',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
