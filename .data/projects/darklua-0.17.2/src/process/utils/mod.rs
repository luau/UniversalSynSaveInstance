mod permutator;

pub(crate) use permutator::Permutator;

pub(crate) type CharPermutator = Permutator<std::str::Chars<'static>>;

pub(crate) fn identifier_permutator() -> CharPermutator {
    Permutator::new("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789".chars())
}

pub(crate) fn generate_identifier(permutator: &mut CharPermutator) -> String {
    permutator
        .find(|identifier| is_valid_identifier(identifier))
        .expect("the permutator should always ultimately return a valid identifier")
}

pub(crate) const KEYWORDS: [&str; 21] = [
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local",
    "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
];

macro_rules! matches_any_keyword {
    () => {
        "and"
            | "break"
            | "do"
            | "else"
            | "elseif"
            | "end"
            | "false"
            | "for"
            | "function"
            | "if"
            | "in"
            | "local"
            | "nil"
            | "not"
            | "or"
            | "repeat"
            | "return"
            | "then"
            | "true"
            | "until"
            | "while"
    };
}

pub(crate) fn is_valid_identifier(identifier: &str) -> bool {
    !identifier.is_empty()
        && identifier.is_ascii()
        && identifier
            .char_indices()
            .all(|(i, c)| c.is_alphabetic() || c == '_' || (c.is_ascii_digit() && i > 0))
        && !matches!(identifier, matches_any_keyword!())
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn is_valid_identifier_is_true() {
        assert!(is_valid_identifier("hello"));
        assert!(is_valid_identifier("foo"));
        assert!(is_valid_identifier("bar"));
        assert!(is_valid_identifier("VAR"));
        assert!(is_valid_identifier("_VAR"));
        assert!(is_valid_identifier("_0"));
    }

    #[test]
    fn is_valid_identifier_is_false() {
        assert!(!is_valid_identifier(""));
        assert!(!is_valid_identifier("$hello"));
        assert!(!is_valid_identifier(" "));
        assert!(!is_valid_identifier("5"));
        assert!(!is_valid_identifier("1bar"));
        assert!(!is_valid_identifier("var "));
        assert!(!is_valid_identifier("sp ace"));
    }

    #[test]
    fn keywords_are_not_valid_identifiers() {
        for keyword in KEYWORDS {
            assert!(!is_valid_identifier(keyword));
        }
    }
}
