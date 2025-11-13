use crate::{
    nodes::{Arguments, Expression, TableEntry},
    process::Evaluator,
};

pub(crate) fn preserve_arguments_side_effects(
    evaluator: &Evaluator,
    arguments: &Arguments,
) -> Vec<Expression> {
    match arguments {
        Arguments::Tuple(tuple) => tuple
            .iter_values()
            .filter(|value| evaluator.has_side_effects(value))
            .cloned()
            .collect(),
        Arguments::Table(table) => {
            let mut expressions = Vec::new();

            for entry in table.iter_entries() {
                match entry {
                    TableEntry::Field(field) => {
                        let expression = field.get_value();
                        if evaluator.has_side_effects(expression) {
                            expressions.push(expression.clone());
                        }
                    }
                    TableEntry::Index(index) => {
                        let key = index.get_key();
                        let value = index.get_value();

                        if evaluator.has_side_effects(key) {
                            expressions.push(key.clone());
                        }
                        if evaluator.has_side_effects(value) {
                            expressions.push(value.clone());
                        }
                    }
                    TableEntry::Value(value) => {
                        if evaluator.has_side_effects(value) {
                            expressions.push(*value.clone());
                        }
                    }
                }
            }

            expressions
        }
        Arguments::String(_) => Vec::new(),
    }
}
