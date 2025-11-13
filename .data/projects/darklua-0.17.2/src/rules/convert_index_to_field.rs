use crate::nodes::{
    Block, Expression, FieldExpression, Identifier, IndexExpression, Prefix, TableEntry,
    TableExpression, TableFieldEntry, Variable,
};
use crate::process::utils::is_valid_identifier;
use crate::process::{DefaultVisitor, Evaluator, LuaValue, NodeProcessor, NodeVisitor};
use crate::rules::{
    Context, FlawlessRule, RuleConfiguration, RuleConfigurationError, RuleProperties,
};

use super::verify_no_rule_properties;

use std::mem;

#[derive(Debug, Clone, Default)]
struct Converter {
    evaluator: Evaluator,
}

impl Converter {
    #[inline]
    fn convert_index_to_field(&self, index: &IndexExpression) -> Option<FieldExpression> {
        self.convert_to_field(index.get_index())
            .map(|key| FieldExpression::new(index.get_prefix().clone(), Identifier::new(key)))
    }

    fn convert_to_field(&self, key_expression: &Expression) -> Option<String> {
        if let LuaValue::String(string) = self.evaluator.evaluate(key_expression) {
            String::from_utf8(string)
                .ok()
                .filter(|string| is_valid_identifier(string))
        } else {
            None
        }
    }
}

impl NodeProcessor for Converter {
    fn process_expression(&mut self, expression: &mut Expression) {
        let field: Option<Expression> = if let Expression::Index(index) = expression {
            self.convert_index_to_field(index).map(Into::into)
        } else {
            None
        };
        if let Some(mut field) = field {
            mem::swap(expression, &mut field);
        }
    }

    fn process_prefix_expression(&mut self, prefix: &mut Prefix) {
        let field: Option<Prefix> = if let Prefix::Index(index) = prefix {
            self.convert_index_to_field(index).map(Into::into)
        } else {
            None
        };
        if let Some(mut field) = field {
            mem::swap(prefix, &mut field);
        }
    }

    fn process_variable(&mut self, variable: &mut Variable) {
        let field: Option<Variable> = if let Variable::Index(index) = variable {
            self.convert_index_to_field(index).map(Into::into)
        } else {
            None
        };
        if let Some(mut field) = field {
            mem::swap(variable, &mut field);
        }
    }

    fn process_table_expression(&mut self, table: &mut TableExpression) {
        for entry in table.iter_mut_entries() {
            let replace_with = match entry {
                TableEntry::Index(entry) => self
                    .convert_to_field(entry.get_key())
                    .map(|key| TableFieldEntry::new(key, entry.get_value().clone()))
                    .map(TableEntry::from),

                TableEntry::Field(_) | TableEntry::Value(_) => None,
            };
            if let Some(new_entry) = replace_with {
                *entry = new_entry;
            }
        }
    }
}

pub const CONVERT_INDEX_TO_FIELD_RULE_NAME: &str = "convert_index_to_field";

/// A rule that converts index expression into field expression.
#[derive(Debug, Default, PartialEq, Eq)]
pub struct ConvertIndexToField {}

impl FlawlessRule for ConvertIndexToField {
    fn flawless_process(&self, block: &mut Block, _: &Context) {
        let mut processor = Converter::default();
        DefaultVisitor::visit_block(block, &mut processor);
    }
}

impl RuleConfiguration for ConvertIndexToField {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_no_rule_properties(&properties)?;

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        CONVERT_INDEX_TO_FIELD_RULE_NAME
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

    fn new_rule() -> ConvertIndexToField {
        ConvertIndexToField::default()
    }

    #[test]
    fn serialize_default_rule() {
        let rule: Box<dyn Rule> = Box::new(new_rule());

        assert_json_snapshot!("default_convert_index_to_field", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'convert_index_to_field',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }
}
