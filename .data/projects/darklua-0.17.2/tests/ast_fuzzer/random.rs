use std::iter;

use darklua_core::nodes::{BinaryOperator, CompoundOperator, Identifier, UnaryOperator};
use rand::{rng, Rng};

pub struct RandomAst {
    block_mean: f64,
    block_std_dev: f64,
    last_statement_prob: f64,
    method_call_prob: f64,
    table_mean: f64,
    table_std_dev: f64,
    function_return_type_prob: f64,
    function_is_variadic_prob: f64,
    function_has_variadic_type_prob: f64,
    function_parameters_mean: f64,
    function_parameters_std_dev: f64,
    typed_identifier_prob: f64,
    method_definition_prob: f64,
    return_length_mean: f64,
    return_length_std_dev: f64,
    numeric_for_step_prob: f64,
    function_type_argument_name_prob: f64,
    interpolated_string_segments_mean: f64,
    interpolated_string_segments_std_def: f64,
    interpolated_segment_is_expression_prob: f64,
    intersection_type_length_mean: f64,
    intersection_type_length_std_dev: f64,
    union_type_length_mean: f64,
    union_type_length_std_dev: f64,
}

impl Default for RandomAst {
    fn default() -> Self {
        Self {
            block_mean: 6.0,
            block_std_dev: 4.0,
            last_statement_prob: 0.5,
            method_call_prob: 0.3,
            table_mean: 1.0,
            table_std_dev: 1.5,
            function_return_type_prob: 0.5,
            function_is_variadic_prob: 0.3,
            function_has_variadic_type_prob: 0.3,
            function_parameters_mean: 0.0,
            function_parameters_std_dev: 2.5,
            typed_identifier_prob: 0.3,
            method_definition_prob: 0.4,
            return_length_mean: 0.0,
            return_length_std_dev: 2.5,
            numeric_for_step_prob: 0.3,
            function_type_argument_name_prob: 0.4,
            interpolated_string_segments_mean: 1.5,
            interpolated_string_segments_std_def: 2.5,
            interpolated_segment_is_expression_prob: 0.5,
            intersection_type_length_mean: 2.0,
            intersection_type_length_std_dev: 0.5,
            union_type_length_mean: 2.0,
            union_type_length_std_dev: 0.5,
        }
    }
}

impl RandomAst {
    pub fn range(&self, bound: usize) -> usize {
        if bound == 0 {
            return 0;
        }
        rng().random_range(0..=bound)
    }

    pub fn full_range(&self, start: usize, bound: usize) -> usize {
        if start == bound {
            return 0;
        }
        rng().random_range(start..=bound)
    }

    pub fn block_length(&self) -> usize {
        normal_sample(self.block_mean, self.block_std_dev)
    }

    pub fn last_statement(&self) -> bool {
        rng().random_bool(self.last_statement_prob)
    }

    pub fn assignment_variables(&self) -> usize {
        1 + normal_sample(0.0, 1.0)
    }

    pub fn assignment_expressions(&self) -> usize {
        1 + normal_sample(0.0, 1.0)
    }

    pub fn identifier(&self) -> Identifier {
        Identifier::new(generate_identifier_content(3.0))
    }

    pub fn method_call(&self) -> bool {
        rng().random_bool(self.method_call_prob)
    }

    pub fn call_arguments(&self) -> usize {
        normal_sample(0.0, 2.5)
    }

    pub fn string_content(&self) -> String {
        generate_string_content(3.0)
    }

    pub fn interpolated_string_segments(&self) -> usize {
        1 + normal_sample(
            self.interpolated_string_segments_mean,
            self.interpolated_string_segments_std_def,
        )
    }

    pub fn interpolated_segment_is_expression(&self) -> bool {
        rng().random_bool(self.interpolated_segment_is_expression_prob)
    }

    pub fn table_length(&self) -> usize {
        normal_sample(self.table_mean, self.table_std_dev)
    }

    pub fn function_return_type(&self) -> bool {
        rng().random_bool(self.function_return_type_prob)
    }

    pub fn function_is_variadic(&self) -> bool {
        rng().random_bool(self.function_is_variadic_prob)
    }

    pub fn function_has_variadic_type(&self) -> bool {
        rng().random_bool(self.function_has_variadic_type_prob)
    }

    pub fn function_parameters(&self) -> usize {
        normal_sample(
            self.function_parameters_mean,
            self.function_parameters_std_dev,
        )
    }

    pub fn typed_identifier(&self) -> bool {
        rng().random_bool(self.typed_identifier_prob)
    }

    pub fn function_name_fields(&self) -> usize {
        normal_sample(0.0, 1.0)
    }

    pub fn method_definition(&self) -> bool {
        rng().random_bool(self.method_definition_prob)
    }

    pub fn return_length(&self) -> usize {
        normal_sample(self.return_length_mean, self.return_length_std_dev)
    }

    pub fn intersection_type_length(&self) -> usize {
        normal_sample(
            self.intersection_type_length_mean,
            self.intersection_type_length_std_dev,
        )
    }

    pub fn union_type_length(&self) -> usize {
        normal_sample(self.union_type_length_mean, self.union_type_length_std_dev)
    }

    pub fn numeric_for_step(&self) -> bool {
        rng().random_bool(self.numeric_for_step_prob)
    }

    pub fn decimal_number(&self) -> f64 {
        rng().random()
    }

    pub fn hexadecimal_number(&self) -> u64 {
        rng().random_range(0..100_000)
    }

    pub fn binary_number(&self) -> u64 {
        rng().random_range(0..1_000_000)
    }

    pub fn number_exponent_uppercase(&self) -> bool {
        rng().random_bool(0.5)
    }

    pub fn if_expression_branches(&self) -> usize {
        normal_sample(0.0, 1.0)
    }

    pub fn if_statement_branches(&self) -> usize {
        1 + normal_sample(0.0, 1.0)
    }

    pub fn if_statement_else_branch(&self) -> bool {
        rng().random_bool(0.3)
    }

    pub fn binary_operator(&self) -> BinaryOperator {
        match self.range(15) {
            0 => BinaryOperator::And,
            1 => BinaryOperator::Or,
            2 => BinaryOperator::Equal,
            3 => BinaryOperator::NotEqual,
            4 => BinaryOperator::LowerThan,
            5 => BinaryOperator::LowerOrEqualThan,
            6 => BinaryOperator::GreaterThan,
            7 => BinaryOperator::GreaterOrEqualThan,
            8 => BinaryOperator::Plus,
            9 => BinaryOperator::Minus,
            10 => BinaryOperator::Asterisk,
            11 => BinaryOperator::Slash,
            12 => BinaryOperator::DoubleSlash,
            13 => BinaryOperator::Percent,
            14 => BinaryOperator::Caret,
            _ => BinaryOperator::Concat,
        }
    }

    pub fn unary_operator(&self) -> UnaryOperator {
        match self.range(2) {
            0 => UnaryOperator::Length,
            1 => UnaryOperator::Minus,
            _ => UnaryOperator::Not,
        }
    }

    pub fn compound_operator(&self) -> CompoundOperator {
        match self.range(7) {
            0 => CompoundOperator::Plus,
            1 => CompoundOperator::Minus,
            2 => CompoundOperator::Asterisk,
            3 => CompoundOperator::Slash,
            4 => CompoundOperator::DoubleSlash,
            5 => CompoundOperator::Percent,
            6 => CompoundOperator::Caret,
            _ => CompoundOperator::Concat,
        }
    }

    pub fn generic_for_variables(&self) -> usize {
        1 + normal_sample(1.0, 0.5)
    }

    pub fn generic_for_expressions(&self) -> usize {
        1 + normal_sample(0.0, 0.3)
    }

    pub fn nested_expression(&self, depth: usize) -> bool {
        depth == 0 || {
            let depth_f = depth as f64;
            let probability = (1.0 / (depth_f + 1.0)) * (1.0 - depth_f / 6.0);
            rng().random_bool(probability.max(0.0))
        }
    }

    pub fn nested_type(&self, depth: usize) -> bool {
        depth == 0 || {
            let depth_f = depth as f64;
            let probability = (1.0 / (depth_f + 1.0)) * (1.0 - depth_f / 4.0);
            rng().random_bool(probability.max(0.0))
        }
    }

    pub fn type_pack_length(&self) -> usize {
        normal_sample(0.0, 1.3)
    }

    pub fn type_pack_variadic(&self) -> bool {
        rng().random_bool(0.35)
    }

    pub fn function_type_argument_name(&self) -> bool {
        rng().random_bool(self.function_type_argument_name_prob)
    }

    pub fn has_type_parameters(&self) -> bool {
        rng().random_bool(0.25)
    }

    pub fn type_parameters(&self) -> usize {
        normal_sample(0.0, 0.8)
    }

    pub fn generic_type_declaration(&self) -> bool {
        rng().random_bool(0.25)
    }

    pub fn generic_type_declaration_length(&self) -> usize {
        normal_sample(0.0, 1.3)
    }

    pub fn export_type_declaration(&self) -> bool {
        rng().random_bool(0.5)
    }

    pub fn table_type_indexer(&self) -> bool {
        rng().random_bool(0.25)
    }

    pub fn function_generic_types(&self) -> usize {
        normal_sample(0.0, 2.0)
    }

    pub fn function_generic_type_is_generic_pack(&self) -> bool {
        rng().random_bool(0.4)
    }

    pub fn function_variadic_type_is_generic_pack(&self) -> bool {
        rng().random_bool(0.2)
    }

    pub fn leading_intersection_or_union_operator(&self) -> bool {
        rng().random_bool(0.4)
    }
}

#[inline]
fn normal_sample(mean: f64, std_dev: f64) -> usize {
    rng()
        .sample(rand_distr::Normal::new(mean, std_dev).unwrap())
        .abs()
        .floor() as usize
}

fn generate_identifier_content(poisson_lambda: f64) -> String {
    let poisson = rand_distr::Poisson::new(poisson_lambda).unwrap();

    let mut rng = rng();
    let length = rng.sample::<f64, _>(poisson).round() as usize;

    let identifier: String = (0..1 + length)
        .map(|i| loop {
            let character = rng.sample(rand_distr::Alphanumeric);

            if i != 0 || !character.is_ascii_digit() {
                return character as char;
            }
        })
        .collect();

    match identifier.as_ref() {
        "and" | "break" | "do" | "else" | "elseif" | "end" | "false" | "for" | "function"
        | "if" | "in" | "local" | "nil" | "not" | "or" | "repeat" | "return" | "then" | "true"
        | "goto" | "until" | "while" => generate_identifier_content(poisson_lambda),
        _ => identifier,
    }
}

fn generate_string_content(poisson_lambda: f64) -> String {
    let poisson = rand_distr::Poisson::new(poisson_lambda).unwrap();

    let mut rng = rng();
    let length = rng.sample::<f64, _>(poisson).round() as usize;

    const GEN_CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ\
                abcdefghijklmnopqrstuvwxyz\
                0123456789\
                ()[]{}=<>.!?,:;+-*/%^|&#";

    iter::repeat_n((), length)
        .map(|()| GEN_CHARSET[rng.random_range(0..GEN_CHARSET.len())] as char)
        .collect()
}
