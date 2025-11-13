//! Darklua is a utility for transforming and processing Lua and Luau code. It provides
//! a set of tools for parsing and modifying Lua/Luau code.
//!
//! If you are looking for a command-line tool, please visit [darklua.com](https://darklua.com/docs/installation/)
//! or [github.com/seaofvoices/darklua](https://github.com/seaofvoices/darklua)
//! for installation and usage instructions.
//!
//! This documentation site is for the darklua library itself.
//!
//! # Library Usage
//!
//! To start using darklua in your own project, add the following to your `Cargo.toml` file:
//!
//! ```toml
//! [dependencies]
//! darklua = "0.17.2"
//! ```
//!
//! This library is designed for developers who want to integrate Lua/Luau transformation capabilities
//! into their own applications.
//!
//! Please note that the library is developed primarily for the darklua command line tool. There may be
//! some rough edges, but it should be stable enough for most use cases.
//!
//! # Running Darklua in Memory
//!
//! The following example shows how to run darklua in memory, without writing to the file system.
//!
//! Note that the library name is `darklua_core` and **not** `darklua`.
//!
//! ```rust
//! use std::path::Path;
//! use darklua_core::{Configuration, Options, Resources, rules::{RemoveEmptyDo, Rule}};
//!
//! let resources = Resources::from_memory();
//! resources.write("project-path/src/main.lua", "do end print('Hello, world!')");
//! let input_path = Path::new("project-path/src");
//!
//! let remove_empty_do: Box<dyn Rule> = Box::new(RemoveEmptyDo::default());
//! let config = Configuration::empty().with_rule(remove_empty_do);
//!
//! let process_result = darklua_core::process(
//!     &resources,
//!     Options::new(&input_path)
//!         .with_configuration(config),
//! );
//!
//! process_result.expect("failed to process with darklua");
//!
//! assert_eq!(
//!     resources.get("project-path/src/main.lua").expect("failed to get output"),
//!     "print('Hello, world!')"
//! );
//! ```

mod ast_converter;
mod frontend;
pub mod generator;
pub mod nodes;
mod parser;
pub mod process;
pub mod rules;
mod utils;

pub use frontend::{
    convert_data, process, BundleConfiguration, Configuration, DarkluaError, GeneratorParameters,
    Options, Resources, WorkerTree,
};
pub use parser::{Parser, ParserError};
