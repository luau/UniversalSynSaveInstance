pub(crate) fn maybe_plural(count: usize) -> &'static str {
    if count > 1 {
        "s"
    } else {
        ""
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn maybe_plural_gives_s_when_size_is_above_one() {
        assert_eq!(maybe_plural(2), "s");
    }

    #[test]
    fn maybe_plural_gives_s_when_size_is_one() {
        assert_eq!(maybe_plural(1), "");
    }

    #[test]
    fn maybe_plural_gives_s_when_size_is_zero() {
        assert_eq!(maybe_plural(0), "");
    }
}
