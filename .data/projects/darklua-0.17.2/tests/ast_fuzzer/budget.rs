pub struct FuzzBudget {
    statements: usize,
    expressions: usize,
    types: usize,
}

impl FuzzBudget {
    pub fn new(statements: usize, expressions: usize) -> Self {
        Self {
            statements,
            expressions,
            types: 0,
        }
    }

    pub fn with_types(mut self, types_budget: usize) -> Self {
        self.types = types_budget;
        self
    }

    pub fn remaining_expressions(&self) -> usize {
        self.expressions
    }

    pub fn take_statement(&mut self) -> bool {
        if self.statements == 0 {
            false
        } else {
            self.statements -= 1;
            true
        }
    }

    pub fn try_take_statements(&mut self, amount: usize) -> usize {
        let took = amount.min(self.statements);
        self.statements -= took;
        took
    }

    pub fn take_expression(&mut self) -> bool {
        if self.expressions == 0 {
            false
        } else {
            self.expressions -= 1;
            true
        }
    }

    pub fn try_take_expressions(&mut self, amount: usize) -> usize {
        let took = amount.min(self.expressions);
        self.expressions -= took;
        took
    }

    pub fn take_type(&mut self) -> bool {
        if self.types == 0 {
            false
        } else {
            self.types -= 1;
            true
        }
    }

    pub fn try_take_types(&mut self, amount: usize) -> usize {
        let took = amount.min(self.types);
        self.types -= took;
        took
    }

    #[inline]
    pub fn can_have_expression(&self, amount: usize) -> bool {
        self.expressions >= amount
    }

    #[inline]
    pub fn can_have_type(&self, amount: usize) -> bool {
        self.types >= amount
    }

    #[inline]
    pub fn has_types(&self) -> bool {
        self.types > 0
    }

    #[inline]
    pub fn has_expressions(&self) -> bool {
        self.expressions > 0
    }
}
