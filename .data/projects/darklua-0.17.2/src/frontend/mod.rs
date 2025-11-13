mod configuration;
mod error;
mod options;
mod resources;
mod utils;
mod work_cache;
mod work_item;
mod worker;
mod worker_tree;

pub use configuration::{BundleConfiguration, Configuration, GeneratorParameters};
pub use error::{DarkluaError, DarkluaResult};
pub use options::Options;
pub use resources::Resources;
use serde::Serialize;
use work_item::WorkItem;
use worker::Worker;
pub use worker_tree::WorkerTree;

use crate::{
    generator::{DenseLuaGenerator, LuaGenerator},
    nodes::{Block, ReturnStatement},
    process::to_expression,
    utils::normalize_path,
};

/// Convert serializable data into a Lua module.
///
/// This function takes any value that implements `Serialize` and converts it into a Lua module
/// that returns the serialized data. The resulting Lua code will be a module that returns
/// a table containing the serialized data.
///
/// # Example
///
/// ```rust
/// # use serde::Serialize;
/// # use darklua_core::convert_data;
/// #[derive(Serialize)]
/// struct ExampleData {
///     name: String,
///     value: i32,
/// }
///
/// let config = ExampleData {
///     name: "test".to_string(),
///     value: 42,
/// };
///
/// let lua_code = convert_data(config).unwrap();
///
/// assert_eq!(lua_code, "return{name='test',value=42}");
/// ```
pub fn convert_data(value: impl Serialize) -> Result<String, DarkluaError> {
    let expression = to_expression(&value).map_err(DarkluaError::from)?;

    let block = Block::default()
        .with_last_statement(ReturnStatement::default().with_expression(expression));

    let mut generator = DenseLuaGenerator::default();
    generator.write_block(&block);
    Ok(generator.into_string())
}

/// Process resources according to the given options.
///
/// This function is the main entry point for processing resources. It creates a [`WorkerTree`],
/// collects work items based on the provided resources and options, and then processes them.
pub fn process(resources: &Resources, options: Options) -> DarkluaResult<WorkerTree> {
    let mut worker_tree = WorkerTree::default();

    worker_tree.collect_work(resources, &options)?;
    worker_tree.process(resources, options)?;

    Ok(worker_tree)
}
