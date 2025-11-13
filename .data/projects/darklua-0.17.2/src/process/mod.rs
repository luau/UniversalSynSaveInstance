//! Defines how rules can process and mutate Lua nodes.

mod evaluator;
mod expression_serializer;
#[cfg(test)]
mod node_counter;
mod node_processor;
mod post_visitor;
pub mod processors;
mod scope_visitor;
pub(crate) mod utils;
mod visitors;

pub use evaluator::*;
pub(crate) use expression_serializer::*;
#[cfg(test)]
pub use node_counter::NodeCounter;
pub use node_processor::{NodePostProcessor, NodeProcessor};
pub use post_visitor::{DefaultPostVisitor, NodePostVisitor};
pub(crate) use scope_visitor::IdentifierTracker;
pub use scope_visitor::{Scope, ScopePostVisitor, ScopeVisitor};
pub use visitors::{DefaultVisitor, NodeVisitor};
