mod assign;
mod compound_assign;
mod do_statement;
mod function;
mod generic_for;
mod if_statement;
mod last_statement;
mod local_assign;
mod local_function;
mod numeric_for;
mod repeat_statement;
mod type_declaration;
mod while_statement;

pub use assign::*;
pub use compound_assign::*;
pub use do_statement::*;
pub use function::*;
pub use generic_for::*;
pub use if_statement::*;
pub use last_statement::*;
pub use local_assign::*;
pub use local_function::*;
pub use numeric_for::*;
pub use repeat_statement::*;
pub use type_declaration::*;
pub use while_statement::*;

use crate::nodes::FunctionCall;

use super::impl_token_fns;

/// Represents all possible statement.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Statement {
    /// An assignment statement (e.g., `a = 1`)
    Assign(AssignStatement),
    /// A do statement (e.g., `do ... end`)
    Do(DoStatement),
    /// A function call statement (e.g., `print("Hello")`)
    Call(FunctionCall),
    /// A compound assignment statement (e.g., `a += 1`)
    CompoundAssign(CompoundAssignStatement),
    /// A function declaration statement (e.g., `function name() ... end`)
    Function(Box<FunctionStatement>),
    /// A generic for loop (e.g., `for k, v in pairs(t) do ... end`)
    GenericFor(GenericForStatement),
    /// An if statement (e.g., `if condition then ... elseif ... else ... end`)
    If(IfStatement),
    /// A local variable assignment (e.g., `local a, b = 1, 2`)
    LocalAssign(LocalAssignStatement),
    /// A local function declaration (e.g., `local function name() ... end`)
    LocalFunction(Box<LocalFunctionStatement>),
    /// A numeric for loop (e.g., `for i = 1, 10, 2 do ... end`)
    NumericFor(Box<NumericForStatement>),
    /// A repeat loop (e.g., `repeat ... until condition`)
    Repeat(RepeatStatement),
    /// A while loop (e.g., `while condition do ... end`)
    While(WhileStatement),
    /// A type declaration statement (e.g., `type T = string | number`)
    TypeDeclaration(TypeDeclarationStatement),
}

impl Statement {
    /// Returns a mutable reference to the first token of this statement.
    pub fn mutate_first_token(&mut self) -> &mut crate::nodes::Token {
        match self {
            Self::Assign(assign) => assign.mutate_first_token(),
            Self::Do(do_stmt) => do_stmt.mutate_first_token(),
            Self::Call(call) => call.mutate_first_token(),
            Self::CompoundAssign(compound) => compound.mutate_first_token(),
            Self::Function(function) => function.mutate_first_token(),
            Self::GenericFor(generic_for) => generic_for.mutate_first_token(),
            Self::If(if_stmt) => if_stmt.mutate_first_token(),
            Self::LocalAssign(local_assign) => local_assign.mutate_first_token(),
            Self::LocalFunction(local_function) => local_function.mutate_first_token(),
            Self::NumericFor(numeric_for) => numeric_for.mutate_first_token(),
            Self::Repeat(repeat_stmt) => repeat_stmt.mutate_first_token(),
            Self::While(while_stmt) => while_stmt.mutate_first_token(),
            Self::TypeDeclaration(type_decl) => type_decl.mutate_first_token(),
        }
    }

    /// Returns a mutable reference to the last token of this statement,
    /// creating it if missing.
    pub fn mutate_last_token(&mut self) -> &mut crate::nodes::Token {
        match self {
            Self::Assign(assign) => assign.mutate_last_token(),
            Self::Do(do_stmt) => do_stmt.mutate_last_token(),
            Self::Call(call) => call.mutate_last_token(),
            Self::CompoundAssign(compound) => compound.mutate_last_token(),
            Self::Function(function) => function.mutate_last_token(),
            Self::GenericFor(generic_for) => generic_for.mutate_last_token(),
            Self::If(if_stmt) => if_stmt.mutate_last_token(),
            Self::LocalAssign(local_assign) => local_assign.mutate_last_token(),
            Self::LocalFunction(local_function) => local_function.mutate_last_token(),
            Self::NumericFor(numeric_for) => numeric_for.mutate_last_token(),
            Self::Repeat(repeat_stmt) => repeat_stmt.mutate_last_token(),
            Self::While(while_stmt) => while_stmt.mutate_last_token(),
            Self::TypeDeclaration(type_decl) => type_decl.mutate_last_token(),
        }
    }
}

impl From<AssignStatement> for Statement {
    fn from(assign: AssignStatement) -> Statement {
        Statement::Assign(assign)
    }
}

impl From<DoStatement> for Statement {
    fn from(do_statement: DoStatement) -> Statement {
        Statement::Do(do_statement)
    }
}

impl From<CompoundAssignStatement> for Statement {
    fn from(statement: CompoundAssignStatement) -> Statement {
        Statement::CompoundAssign(statement)
    }
}

impl From<FunctionCall> for Statement {
    fn from(call: FunctionCall) -> Statement {
        Statement::Call(call)
    }
}

impl From<FunctionStatement> for Statement {
    fn from(function: FunctionStatement) -> Statement {
        Statement::Function(Box::new(function))
    }
}

impl From<GenericForStatement> for Statement {
    fn from(generic_for: GenericForStatement) -> Statement {
        Statement::GenericFor(generic_for)
    }
}

impl From<IfStatement> for Statement {
    fn from(if_statement: IfStatement) -> Statement {
        Statement::If(if_statement)
    }
}

impl From<LocalAssignStatement> for Statement {
    fn from(assign: LocalAssignStatement) -> Statement {
        Statement::LocalAssign(assign)
    }
}

impl From<LocalFunctionStatement> for Statement {
    fn from(function: LocalFunctionStatement) -> Statement {
        Statement::LocalFunction(Box::new(function))
    }
}

impl From<NumericForStatement> for Statement {
    fn from(numeric_for: NumericForStatement) -> Statement {
        Statement::NumericFor(numeric_for.into())
    }
}

impl From<RepeatStatement> for Statement {
    fn from(repeat_statement: RepeatStatement) -> Statement {
        Statement::Repeat(repeat_statement)
    }
}

impl From<WhileStatement> for Statement {
    fn from(while_statement: WhileStatement) -> Statement {
        Statement::While(while_statement)
    }
}

impl From<TypeDeclarationStatement> for Statement {
    fn from(type_declaration: TypeDeclarationStatement) -> Statement {
        Statement::TypeDeclaration(type_declaration)
    }
}
