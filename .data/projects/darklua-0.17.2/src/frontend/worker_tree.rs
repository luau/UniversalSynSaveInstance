use std::{
    collections::{HashMap, HashSet},
    path::{Path, PathBuf},
};

use petgraph::{algo::toposort, graph::NodeIndex, stable_graph::StableDiGraph, visit::Dfs};
use xxhash_rust::xxh3::xxh3_64;

use crate::{
    frontend::utils::maybe_plural,
    utils::{clear_luau_configuration_cache, Timer},
    DarkluaError,
};

use super::{
    normalize_path, work_item::WorkStatus, Configuration, DarkluaResult, Options, Resources,
    WorkItem, Worker,
};

/// A structure that manages the processing of Lua/Luau files and their dependencies.
///
/// Under the hood, the `WorkerTree` maintains a directed graph of work items, where each node
/// represents a file to be processed and edges represent dependencies between files. It handles
/// the collection and processing of work items, manages file dependencies, and tracks the status
/// of each work item.
#[derive(Debug, Default)]
pub struct WorkerTree {
    graph: StableDiGraph<WorkItem, ()>,
    node_map: HashMap<PathBuf, NodeIndex>,
    external_dependencies: HashMap<PathBuf, HashSet<NodeIndex>>,
    remove_files: Vec<PathBuf>,
    last_configuration_hash: Option<u64>,
}

impl WorkerTree {
    /// Collects work items based on the provided resources and options.
    ///
    /// This method traverses the input directory or file specified in the options and
    /// creates work items for each Lua/Luau file that needs to be processed. It also sets up
    /// the output paths based on the provided options.
    pub fn collect_work(&mut self, resources: &Resources, options: &Options) -> DarkluaResult<()> {
        log::trace!("start collecting work");
        let collect_work_timer = Timer::now();

        if let Some(output) = options.output().map(Path::to_path_buf) {
            if resources.is_file(options.input())? {
                if resources.is_directory(&output)? {
                    let file_name = options.input().file_name().ok_or_else(|| {
                        DarkluaError::custom(format!(
                            "unable to extract file name from `{}`",
                            options.input().display()
                        ))
                    })?;

                    self.add_source_if_missing(options.input(), Some(output.join(file_name)));
                } else if resources.is_file(&output)? || output.extension().is_some() {
                    self.add_source_if_missing(options.input(), Some(output));
                } else {
                    let file_name = options.input().file_name().ok_or_else(|| {
                        DarkluaError::custom(format!(
                            "unable to extract file name from `{}`",
                            options.input().display()
                        ))
                    })?;

                    self.add_source_if_missing(options.input(), Some(output.join(file_name)));
                }
            } else {
                let input = normalize_path(options.input());

                for source in resources.collect_work(&input) {
                    let source = normalize_path(source);

                    let relative_path = source.strip_prefix(&input).map_err(|err| {
                        DarkluaError::custom(format!(
                            "unable to remove path prefix `{}` from `{}`: {}",
                            input.display(),
                            source.display(),
                            err
                        ))
                    })?;

                    let output_path = Some(output.join(relative_path));
                    self.add_source_if_missing(source, output_path);
                }
            }
        } else {
            let input = normalize_path(options.input());

            for source in resources.collect_work(input) {
                self.add_source_if_missing(source, None);
            }
        }

        log::trace!("work collected in {}", collect_work_timer.duration_label());

        Ok(())
    }

    /// Processes all collected work items according to the provided options.
    ///
    /// This method performs the actual processing of work items in topological order,
    /// respecting dependencies between files.
    pub fn process(&mut self, resources: &Resources, mut options: Options) -> DarkluaResult<()> {
        clear_luau_configuration_cache();

        if !self.remove_files.is_empty() {
            let remove_count = self.remove_files.len();
            log::debug!(
                "clean {} file{} before beginning process",
                remove_count,
                maybe_plural(remove_count)
            );
            for path in self.remove_files.drain(..) {
                log::trace!("remove file {}", path.display());
                if let Err(err) = resources.remove(path).map_err(DarkluaError::from) {
                    log::warn!("failed to remove resource: {}", err);
                }
            }
        }

        let mut worker = Worker::new(resources);
        worker.setup_worker(&mut options)?;

        if self.has_configuration_changed(worker.configuration()) {
            log::debug!("configuration change detected");
            self.reset();
        }

        let total_not_done = self
            .graph
            .node_weights()
            .filter(|work_item| !work_item.status.is_done())
            .count();

        if total_not_done == 0 {
            return Ok(());
        }

        let work_timer = Timer::now();

        'work_loop: loop {
            let mut add_edges = Vec::new();

            match toposort(&self.graph, None) {
                Ok(node_indexes) => {
                    let mut done_count = 0;

                    for node_index in node_indexes {
                        let work_item = self
                            .graph
                            .node_weight_mut(node_index)
                            .expect("node index should exist");

                        if !work_item.status.is_done() {
                            match worker.advance_work(work_item) {
                                Ok(()) => match &work_item.status {
                                    WorkStatus::Done(result) => {
                                        done_count += 1;
                                        if result.is_ok() {
                                            log::info!(
                                                "successfully processed `{}`",
                                                work_item.source().display()
                                            );
                                        }
                                    }
                                    WorkStatus::InProgress(progress) => {
                                        for content in progress.required_content() {
                                            if let Some(content_node_index) =
                                                self.node_map.get(content)
                                            {
                                                add_edges.push((*content_node_index, node_index));
                                            }
                                        }
                                        log::trace!(
                                            "work on `{}` has not completed",
                                            work_item.source().display()
                                        );
                                    }
                                    WorkStatus::NotStarted => {}
                                },
                                Err(err) => {
                                    log::error!(
                                        "an error happened while processing {}: {}",
                                        work_item.source().display(),
                                        err
                                    );
                                    work_item.status = WorkStatus::err(err);
                                    done_count += 1;
                                    if options.should_fail_fast() {
                                        log::debug!(
                                            "dropping all work because the fail-fast option is enabled"
                                        );
                                        break 'work_loop;
                                    }
                                }
                            }
                        }

                        for path in work_item.external_file_dependencies.iter() {
                            let container = self
                                .external_dependencies
                                .entry(path.to_path_buf())
                                .or_default();

                            if !container.contains(&node_index) {
                                log::trace!(
                                    "link external dependency {} to {}",
                                    path.display(),
                                    work_item.source().display()
                                );
                                container.insert(node_index);
                            }
                        }
                    }

                    log::debug!("process batch of tasks ({}/{})", done_count, total_not_done);

                    if done_count == total_not_done {
                        break;
                    }
                }
                Err(_cycle_err) => {
                    return Err(DarkluaError::cyclic_work(
                        self.graph
                            .node_weights()
                            .filter(|item| !item.status.is_done())
                            .collect(),
                    ));
                }
            }

            for (from, to) in add_edges {
                self.graph.add_edge(from, to, ());
            }
        }

        log::info!("executed work in {}", work_timer.duration_label());

        Ok(())
    }

    /// Returns the final result of processing all work items.
    ///
    /// This method consumes the `WorkerTree` and returns either Ok(()) if all work items
    /// were processed successfully, or a vector of errors if any work items failed.
    pub fn result(self) -> Result<(), Vec<DarkluaError>> {
        let errors: Vec<_> = self.iter_errors().cloned().collect();
        if errors.is_empty() {
            Ok(())
        } else {
            Err(errors)
        }
    }

    /// Collects all errors that occurred during processing.
    pub fn collect_errors(&self) -> Vec<&DarkluaError> {
        self.iter_errors().collect()
    }

    fn iter_errors(&self) -> impl Iterator<Item = &DarkluaError> {
        self.graph
            .node_weights()
            .filter_map(|work_item| match &work_item.status {
                WorkStatus::NotStarted | WorkStatus::InProgress(_) => None,
                WorkStatus::Done(result) => result.as_ref().err(),
            })
    }

    /// Returns the number of successfully processed work items.
    pub fn success_count(&self) -> usize {
        self.graph
            .node_weights()
            .filter_map(|work_item| match &work_item.status {
                WorkStatus::NotStarted | WorkStatus::InProgress(_) => None,
                WorkStatus::Done(result) => result.as_ref().ok(),
            })
            .count()
    }

    /// Returns an iterator over all external dependencies.
    pub fn iter_external_dependencies(&self) -> impl Iterator<Item = &Path> {
        self.external_dependencies
            .iter()
            .filter_map(|(path, container)| (!container.is_empty()).then_some(path.as_path()))
    }

    /// Resets the worker tree to its initial state.
    pub fn reset(&mut self) {
        self.graph.node_weights_mut().for_each(|work_item| {
            work_item.reset();
        });
        self.external_dependencies.clear();
    }

    /// Notifies the worker tree that a source file has changed.
    pub fn source_changed(&mut self, path: impl AsRef<Path>) {
        let path = normalize_path(path.as_ref());

        if let Some(node_index) = self.node_map.get(&path) {
            self.restart_work(*node_index);
        } else {
            let node_indexes: Vec<_> = self
                .node_map
                .iter()
                .filter_map(|(node_path, node_index)| {
                    node_path.starts_with(&path).then_some(*node_index)
                })
                .collect();

            for node_index in node_indexes {
                self.restart_work(node_index);
            }
        }

        self.update_external_dependencies(&path);
    }

    fn update_external_dependencies(&mut self, path: &Path) {
        let node_indexes = self
            .external_dependencies
            .get(path)
            .map(|nodes| nodes.iter().copied().collect::<Vec<_>>())
            .unwrap_or_default();

        for index in node_indexes {
            self.restart_work(index);
        }
    }

    /// Removes a source file from the worker tree.
    pub fn remove_source(&mut self, path: impl AsRef<Path>) {
        let path = normalize_path(path.as_ref());

        if let Some(node_index) = self.node_map.get(&path).copied() {
            let root_item = self
                .graph
                .node_weight_mut(node_index)
                .expect("node index should exist");

            if !root_item.data.is_in_place() {
                self.remove_files
                    .push(root_item.data.output().to_path_buf());
            }

            self.restart_work(node_index);

            self.graph.remove_node(node_index);
            self.node_map.remove(&path);
        } else {
            let mut remove_nodes = Vec::new();

            self.node_map.retain(|node_path, node_index| {
                if node_path.starts_with(&path) {
                    remove_nodes.push(*node_index);
                    false
                } else {
                    true
                }
            });

            for node_index in remove_nodes {
                if let Some(work_item) = self.graph.remove_node(node_index) {
                    if !work_item.data.is_in_place() {
                        self.remove_files
                            .push(work_item.data.output().to_path_buf());
                    }
                }
            }
        }

        self.update_external_dependencies(&path);
    }

    /// Checks if a source file is present in the worker tree.
    pub fn contains(&mut self, path: impl AsRef<Path>) -> bool {
        let path = normalize_path(path.as_ref());
        self.node_map.contains_key(&path)
    }

    /// Adds a source file to the worker tree.
    pub fn add_source(&mut self, path: impl AsRef<Path>, output: Option<PathBuf>) {
        let path = normalize_path(path.as_ref());

        self.update_external_dependencies(&path);

        if let Some(node_index) = self.node_map.get(&path) {
            self.restart_work(*node_index);
        } else {
            self.insert_source(path, output);
        }
    }

    fn add_source_if_missing(&mut self, path: impl AsRef<Path>, output: Option<PathBuf>) {
        let path = normalize_path(path.as_ref());

        if !self.node_map.contains_key(&path) {
            self.insert_source(path, output);
        }
    }

    fn insert_source(&mut self, path: PathBuf, output: Option<PathBuf>) {
        let node_index = self.graph.add_node(if let Some(output) = output {
            WorkItem::new(path.clone(), output)
        } else {
            WorkItem::new_in_place(path.clone())
        });
        self.node_map.insert(path, node_index);
    }

    fn restart_work(&mut self, node_index: NodeIndex) {
        let mut dfs = Dfs::new(&self.graph, node_index);

        while let Some(dependent_node) = dfs.next(&self.graph) {
            let item = self
                .graph
                .node_weight_mut(dependent_node)
                .expect("node index should exist");

            log::debug!("restart work for {}", item.source().display());
            for path in item.external_file_dependencies.iter() {
                if let Some(container) = self.external_dependencies.get_mut(path) {
                    container.remove(&node_index);
                }
            }
            item.reset();
        }
    }

    fn has_configuration_changed(&mut self, config: &Configuration) -> bool {
        let input = serde_json::to_vec(config).ok().unwrap_or_default();

        let new_hash = xxh3_64(&input);

        let last_hash = self.last_configuration_hash.replace(new_hash);

        last_hash
            .map(|last_hash| new_hash != last_hash)
            .unwrap_or_default()
    }
}
