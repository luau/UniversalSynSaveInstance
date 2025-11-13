use std::collections::HashMap;
use std::hash::Hash;

#[derive(Debug, Default, Clone)]
pub(crate) struct ScopedHashMap<Key, Value> {
    stack: Vec<HashMap<Key, Value>>,
}

impl<Key: Eq + Hash, Value> ScopedHashMap<Key, Value> {
    pub(crate) fn get(&self, key: &Key) -> Option<&Value> {
        self.stack.iter().rev().find_map(|map| map.get(key))
    }

    pub(crate) fn insert(&mut self, key: Key, value: Value) {
        if let Some(hash_map) = self.stack.last_mut() {
            hash_map.insert(key, value);
        } else {
            let mut hash_map = HashMap::new();
            hash_map.insert(key, value);
            self.stack.push(hash_map);
        }
    }

    pub(crate) fn push(&mut self) {
        self.stack.push(Default::default())
    }

    pub(crate) fn pop(&mut self) {
        self.stack.pop();
    }
}
