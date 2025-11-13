//! The collection of nodes used for the Lua abstract syntax tree.

mod arguments;
mod block;
mod expressions;
mod function_body;
mod function_call;
mod identifier;
mod statements;
mod token;
mod typed_identifier;
mod types;
mod variable;

pub use arguments::*;
pub use block::*;
pub use expressions::*;
pub use function_body::*;
pub use function_call::*;
pub use identifier::*;
pub use statements::*;
pub use token::*;
pub use typed_identifier::*;
pub use types::*;
pub use variable::*;

macro_rules! impl_token_fns {
    (
        target = [ $( $field:ident ),* $(,)? ]
        $(iter = [ $( $iter_field:ident),* $(,)? ])?
        $(iter_flatten = [ $( $iter_flatten_field:ident),* $(,)? ])?
    ) => {
        /// Clears all comments from the tokens in this node.
        pub fn clear_comments(&mut self) {
            $(
                self.$field.clear_comments();
            )*
            $($(
                    for token in self.$iter_field.iter_mut() {
                        token.clear_comments();
                    }
            )*)?
            $($(
                    for token in self.$iter_flatten_field.iter_mut().flatten() {
                        token.clear_comments();
                    }
            )*)?
        }

        /// Clears all whitespaces information from the tokens in this node.
        pub fn clear_whitespaces(&mut self) {
            $(
                self.$field.clear_whitespaces();
            )*
            $($(
                for token in self.$iter_field.iter_mut() {
                    token.clear_whitespaces();
                }
            )*)?
            $($(
                for token in self.$iter_flatten_field.iter_mut().flatten() {
                    token.clear_whitespaces();
                }
            )*)?
        }

        pub(crate) fn replace_referenced_tokens(&mut self, code: &str) {
            $(
                self.$field.replace_referenced_tokens(code);
            )*
            $($(
                for token in self.$iter_field.iter_mut() {
                    token.replace_referenced_tokens(code);
                }
            )*)?
            $($(
                for token in self.$iter_flatten_field.iter_mut().flatten() {
                    token.replace_referenced_tokens(code);
                }
            )*)?
        }

        pub(crate) fn shift_token_line(&mut self, amount: isize) {
            $(
                self.$field.shift_token_line(amount);
            )*
            $($(
                for token in self.$iter_field.iter_mut() {
                    token.shift_token_line(amount);
                }
            )*)?
            $($(
                for token in self.$iter_flatten_field.iter_mut().flatten() {
                    token.shift_token_line(amount);
                }
            )*)?
        }

        pub(crate) fn filter_comments(&mut self, filter: impl Fn(&crate::nodes::Trivia) -> bool) {
            $(
                self.$field.filter_comments(&filter);
            )*
            $($(
                for token in self.$iter_field.iter_mut() {
                    token.filter_comments(&filter);
                }
            )*)?
            $($(
                for token in self.$iter_flatten_field.iter_mut().flatten() {
                    token.filter_comments(&filter);
                }
            )*)?
        }
    };

    (
        iter = [$($field:ident),*]
        iter_flatten = [$($flatten_field:ident),*]
    ) => {
        $crate::nodes::impl_token_fns!(
            target = []
            iter = [ $($field,)* ]
            iter_flatten = [ $($flatten_field,)* ]
        );
    };

    (
        iter = [$($field:ident),*]
    ) => {
        $crate::nodes::impl_token_fns!(
            target = []
            iter = [ $($field,)* ]
            iter_flatten = []
        );
    };

    (
        iter_flatten = [$($field:ident),*]
    ) => {
        $crate::nodes::impl_token_fns!(
            target = []
            iter = []
            iter_flatten = [ $($field,)* ]
        );
    };
}

pub(crate) use impl_token_fns;
