use crate::nodes::{Expression, Identifier, LocalFunctionStatement, TypeField};
use crate::process::utils::{identifier_permutator, CharPermutator};
use crate::process::{utils::KEYWORDS, NodeProcessor, Scope};

use std::cmp::Ordering;
use std::collections::{HashMap, HashSet};
use std::iter::FromIterator;
use std::mem;

#[derive(Debug)]
pub struct RenameProcessor {
    real_to_obfuscated: Vec<HashMap<String, (String, bool)>>,
    permutator: CharPermutator,
    avoid_identifier: HashSet<String>,
    reuse_identifiers: Vec<String>,
    include_functions: bool,
}

impl RenameProcessor {
    pub fn new<I: IntoIterator<Item = String>>(iter: I, include_functions: bool) -> Self {
        let mut avoid_identifier = HashSet::from_iter(iter);
        avoid_identifier.extend(KEYWORDS.iter().map(|s| (*s).to_owned()));

        Self {
            real_to_obfuscated: Vec::new(),
            permutator: identifier_permutator(),
            avoid_identifier,
            reuse_identifiers: Vec::new(),
            include_functions,
        }
    }

    pub fn add(&mut self, real: String, obfuscated: String, reuse: bool) {
        if let Some(dictionary) = self.real_to_obfuscated.last_mut() {
            dictionary.insert(real, (obfuscated, reuse));
        } else {
            let mut dictionary = HashMap::new();
            dictionary.insert(real, (obfuscated, reuse));
            self.real_to_obfuscated.push(dictionary);
        }
    }

    pub fn get_obfuscated_name(&self, real: &str) -> Option<&String> {
        self.real_to_obfuscated
            .iter()
            .rev()
            .find_map(|dictionary| dictionary.get(real).map(|(name, _)| name))
    }

    pub fn generate_identifier(&mut self) -> String {
        if let Some(identifier) = self.reuse_identifiers.pop() {
            identifier
        } else {
            let generated = self.permutator.next().unwrap();

            if self.filter_identifier(&generated) {
                generated
            } else {
                self.generate_identifier()
            }
        }
    }

    fn filter_identifier(&self, identifier: &str) -> bool {
        !self.avoid_identifier.contains(identifier)
            && !identifier.chars().next().unwrap().is_ascii_digit()
    }

    fn replace_identifier(&mut self, identifier: &mut String) {
        let original = mem::take(identifier);
        let obfuscated_name = self.generate_identifier();

        identifier.push_str(&obfuscated_name);

        self.add(original, obfuscated_name, true);
    }
}

fn sort_char(a: char, b: char) -> Ordering {
    if a == b {
        Ordering::Equal
    } else if a.is_ascii_digit() && b.is_ascii_digit()
        || a.is_lowercase() && b.is_lowercase()
        || a.is_uppercase() && b.is_uppercase()
    {
        a.cmp(&b)
    } else {
        match (a, b) {
            (a, _) if a.is_ascii_digit() => Ordering::Greater,
            (_, b) if b.is_ascii_digit() => Ordering::Less,
            ('_', _) => Ordering::Greater,
            (_, '_') => Ordering::Less,
            (a, _) if a.is_lowercase() => Ordering::Less,
            (_, b) if b.is_lowercase() => Ordering::Greater,
            _ => Ordering::Equal,
        }
    }
}

fn sort_identifiers(a: &str, b: &str) -> Ordering {
    let mut b_chars = b.chars();

    for a_char in a.chars() {
        if let Some(b_char) = b_chars.next() {
            match sort_char(a_char, b_char) {
                Ordering::Less => return Ordering::Less,
                Ordering::Greater => return Ordering::Greater,
                Ordering::Equal => {}
            }
        } else {
            return Ordering::Greater;
        }
    }

    if b_chars.next().is_some() {
        Ordering::Less
    } else {
        Ordering::Equal
    }
}

impl Scope for RenameProcessor {
    fn push(&mut self) {
        self.real_to_obfuscated.push(HashMap::new())
    }

    fn pop(&mut self) {
        if let Some(dictionary) = self.real_to_obfuscated.pop() {
            self.reuse_identifiers.extend(
                dictionary
                    .into_values()
                    .filter_map(|(name, reuse)| reuse.then_some(name)),
            );
            self.reuse_identifiers
                .sort_by(|a, b| sort_identifiers(a, b).reverse());
        }
    }

    fn insert(&mut self, identifier: &mut String) {
        self.replace_identifier(identifier);
    }

    fn insert_self(&mut self) {
        self.add("self".to_owned(), "self".to_owned(), false);
    }

    fn insert_local(&mut self, identifier: &mut String, _value: Option<&mut Expression>) {
        self.replace_identifier(identifier);
    }

    fn insert_local_function(&mut self, function: &mut LocalFunctionStatement) {
        if self.include_functions {
            self.replace_identifier(function.mutate_identifier().mutate_name());
        } else {
            let name = function.mutate_identifier().get_name();
            self.add(name.clone(), name.to_owned(), false);
        }
    }
}

impl NodeProcessor for RenameProcessor {
    fn process_variable_expression(&mut self, variable: &mut Identifier) {
        if let Some(obfuscated_name) = self.get_obfuscated_name(variable.get_name()) {
            variable.set_name(obfuscated_name);
        }
    }

    fn process_type_field(&mut self, type_field: &mut TypeField) {
        if let Some(obfuscated_name) =
            self.get_obfuscated_name(type_field.get_namespace().get_name())
        {
            type_field.mutate_namespace().set_name(obfuscated_name);
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn new_scope() -> RenameProcessor {
        RenameProcessor::new(Vec::new(), true)
    }

    #[test]
    fn pop_root_should_not_panic() {
        new_scope().pop();
    }

    #[test]
    fn should_get_mapped_name_from_inserted_names() {
        let mut scope = new_scope();
        let real = "a".to_owned();
        let obfuscated = "b".to_owned();

        scope.add(real.clone(), obfuscated.clone(), true);

        assert_eq!(&obfuscated, scope.get_obfuscated_name(&real).unwrap());
    }

    #[test]
    fn mapped_name_should_not_exist_after_pop() {
        let mut scope = new_scope();
        let real = "a".to_owned();
        let obfuscated = "def".to_owned();

        scope.push();
        scope.add(real.clone(), obfuscated, true);
        scope.pop();

        assert_eq!(None, scope.get_obfuscated_name(&real));
    }

    #[test]
    fn remapped_name_should_exist_after_pop() {
        let mut scope = new_scope();
        let real = "a".to_owned();
        let obfuscated = "b".to_owned();
        let other_obfuscated = "c".to_owned();

        scope.add(real.clone(), obfuscated.clone(), true);

        scope.push();
        scope.add(real.clone(), other_obfuscated, true);
        scope.pop();

        assert_eq!(&obfuscated, scope.get_obfuscated_name(&real).unwrap());
    }

    #[test]
    fn sort_char_digits() {
        assert_eq!(sort_char('0', '1'), Ordering::Less);
        assert_eq!(sort_char('1', '2'), Ordering::Less);
        assert_eq!(sort_char('4', '2'), Ordering::Greater);
        assert_eq!(sort_char('5', '5'), Ordering::Equal);
    }

    #[test]
    fn sort_char_lowercase_letters() {
        assert_eq!(sort_char('a', 'f'), Ordering::Less);
        assert_eq!(sort_char('y', 'i'), Ordering::Greater);
        assert_eq!(sort_char('t', 't'), Ordering::Equal);
    }

    #[test]
    fn sort_char_uppercase_letters() {
        assert_eq!(sort_char('A', 'F'), Ordering::Less);
        assert_eq!(sort_char('Y', 'I'), Ordering::Greater);
        assert_eq!(sort_char('T', 'T'), Ordering::Equal);
    }

    #[test]
    fn sort_char_underscore_is_less_than_digit() {
        for digit in "0123456789".chars() {
            assert_eq!(sort_char('_', digit), Ordering::Less);
        }
    }

    #[test]
    fn sort_char_underscore_is_greather_than_letters() {
        assert_eq!(sort_char('_', 'a'), Ordering::Greater);
        assert_eq!(sort_char('_', 'A'), Ordering::Greater);
        assert_eq!(sort_char('a', '_'), Ordering::Less);
        assert_eq!(sort_char('A', '_'), Ordering::Less);
    }

    #[test]
    fn sort_char_lowercase_is_less_than_uppercase() {
        assert_eq!(sort_char('a', 'A'), Ordering::Less);
        assert_eq!(sort_char('A', 'a'), Ordering::Greater);
        assert_eq!(sort_char('z', 'A'), Ordering::Less);
        assert_eq!(sort_char('A', 'z'), Ordering::Greater);
    }

    #[test]
    fn sort_identifiers_compare_chars() {
        assert_eq!(sort_identifiers("foo", "foo"), Ordering::Equal);
        assert_eq!(sort_identifiers("aA", "ab"), Ordering::Greater);
        assert_eq!(sort_identifiers("foo1", "foo9"), Ordering::Less);
    }

    #[test]
    fn sort_identifiers_shorter_is_less() {
        assert_eq!(sort_identifiers("foo", "fooo"), Ordering::Less);
    }

    #[test]
    fn sort_identifiers_longer_is_greather() {
        assert_eq!(sort_identifiers("foo", "fo"), Ordering::Greater);
    }
}
