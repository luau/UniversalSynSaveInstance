#[derive(Debug)]
pub struct Permutator<I> {
    original_producer: I,
    current_producers: Vec<I>,
    root: String,
}

impl<I: Iterator + Clone> Permutator<I> {
    pub fn new(producer: I) -> Self {
        Self {
            original_producer: producer.clone(),
            current_producers: vec![producer],
            root: String::new(),
        }
    }

    fn new_producer(&self) -> I {
        self.original_producer.clone()
    }
}

impl<I: Iterator<Item = char> + Clone> Iterator for Permutator<I> {
    type Item = String;

    fn next(&mut self) -> Option<String> {
        let next_char = self
            .current_producers
            .last_mut()
            .and_then(|producer| producer.next());

        if let Some(value) = next_char {
            let mut string = self.root.clone();
            string.push(value);
            Some(string)
        } else {
            let mut count_pop = 1;
            self.current_producers.pop();

            while let Some(previous_producer) = self.current_producers.last_mut() {
                self.root.pop();
                if let Some(next_root_char) = previous_producer.next() {
                    self.root.push(next_root_char);
                    count_pop -= 1;
                    break;
                } else {
                    self.current_producers.pop();
                    count_pop += 1;
                }
            }

            for _ in 0..count_pop {
                let mut new_producer = self.new_producer();
                self.root.push(new_producer.next().unwrap());
                self.current_producers.push(new_producer);
            }

            self.current_producers.push(self.original_producer.clone());

            self.next()
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use std::convert::TryInto;

    #[test]
    fn produce_all_permutations_with_single_char() {
        let mut permutate = Permutator::new("ab".chars());

        assert_eq!(permutate.next().unwrap(), "a");
        assert_eq!(permutate.next().unwrap(), "b");
    }

    #[test]
    fn produce_all_permutations_with_two_chars() {
        let mut permutate = Permutator::new("ab".chars());

        assert_eq!(permutate.next().unwrap(), "a");
        assert_eq!(permutate.next().unwrap(), "b");
        assert_eq!(permutate.next().unwrap(), "aa");
        assert_eq!(permutate.next().unwrap(), "ab");
        assert_eq!(permutate.next().unwrap(), "ba");
        assert_eq!(permutate.next().unwrap(), "bb");
    }

    #[test]
    fn produce_all_permutations_with_three_chars() {
        let mut permutate = Permutator::new("ab".chars());

        for _ in 0..(2 + 2) ^ 2 {
            permutate.next();
        }

        assert_eq!(permutate.next().unwrap(), "aaa");
        assert_eq!(permutate.next().unwrap(), "aab");
        assert_eq!(permutate.next().unwrap(), "aba");
        assert_eq!(permutate.next().unwrap(), "abb");
        assert_eq!(permutate.next().unwrap(), "baa");
        assert_eq!(permutate.next().unwrap(), "bab");
        assert_eq!(permutate.next().unwrap(), "bba");
        assert_eq!(permutate.next().unwrap(), "bbb");
    }

    #[test]
    fn produce_only_first_char_permutations() {
        let char_set = "01";
        let set_length = char_set.len();

        let mut permutate = Permutator::new(char_set.chars());

        for length in 1..9 {
            assert_eq!(permutate.next().unwrap(), char_set[0..1].repeat(length));

            for _ in 0..set_length.pow(length.try_into().unwrap()) - 1 {
                assert!(permutate.next().is_some());
            }
        }
    }
}
