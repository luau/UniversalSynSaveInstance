use std::{
    collections::HashSet,
    env,
    hash::Hash,
    iter,
    path::{Path, PathBuf},
    sync::mpsc::{self, Receiver, Sender},
    time::{Duration, Instant},
};

use darklua_core::{Options, Resources, WorkerTree};
use notify::{EventKind, RecursiveMode};
use notify_debouncer_full::{new_debouncer, DebounceEventResult, DebouncedEvent};

use crate::cli::{error::CliError, process::Options as ProcessOptions, CommandResult};

use super::report_process;

const FILE_WATCHING_DEBOUNCE_DURATION_MILLIS: u64 = 400;
const DEFAULT_CONFIG_PATHS: [&str; 2] = [".darklua.json", ".darklua.json5"];

enum WatcherSignal {
    Exit,
    Watch(PathBuf),
    Unwatch(PathBuf),
}

pub struct FileWatcher {
    input_path: PathBuf,
    resources: Resources,
    sender: Sender<WatcherSignal>,
    receiver: Option<Receiver<WatcherSignal>>,
    worker_tree: Option<WorkerTree>,
    process_option: ProcessOptions,
    extra_file_watch: HashSet<PathBuf>,
    links_file_watch: HashSet<(PathBuf, PathBuf)>,
    current_working_path: Option<PathBuf>,
}

impl FileWatcher {
    pub fn new(process_option: &ProcessOptions) -> Self {
        let (sender, receiver) = mpsc::channel();

        Self {
            input_path: process_option.input_path.clone(),
            resources: Resources::from_file_system(),
            sender,
            receiver: Some(receiver),
            worker_tree: None,
            process_option: process_option.clone(),
            extra_file_watch: Default::default(),
            links_file_watch: Default::default(),
            current_working_path: env::current_dir().ok(),
        }
    }

    fn run_worker_tree(&mut self) {
        let options = self.build_options();

        let process_start_time = Instant::now();

        if let Some(worker_tree) = self.worker_tree.as_mut() {
            log_darklua_error(worker_tree.process(&self.resources, options), || ());
        } else {
            self.worker_tree = log_darklua_error(
                darklua_core::process(&self.resources, options).map(Some),
                || None,
            );
        }

        if let Some(worker_tree) = self.worker_tree.as_mut() {
            report_process("processed", worker_tree, process_start_time.elapsed()).ok();
        }

        self.update_extra_file_watch();
    }

    fn build_options(&self) -> Options {
        self.process_option.get_process_options()
    }

    pub fn start(mut self) -> CommandResult {
        self.run_worker_tree();
        self.setup_ctrl_exit()?;

        let receiver = self
            .receiver
            .take()
            .expect("file watcher channel receiver should exist");

        let input_path = self.input_path.clone();
        let config_path = self.process_option.config.clone();

        for link_path in iter_all_links(input_path.clone()) {
            if let Ok(link_location) = link_path.read_link() {
                self.send_watch_signal(&link_location);

                self.links_file_watch.insert((link_location, link_path));
            }
        }

        let mut debouncer = new_debouncer(
            Duration::from_millis(FILE_WATCHING_DEBOUNCE_DURATION_MILLIS),
            None,
            move |events: DebounceEventResult| match events {
                Ok(events) => {
                    log::debug!("changes detected, re-running process");
                    self.process_events(events);
                    self.run_worker_tree();
                }
                Err(errors) => {
                    for err in errors {
                        log::error!(
                            "an error occured while watching file system for changes: {}",
                            err
                        );
                    }
                }
            },
        )
        .map_err(|err| {
            log::error!("unable to create file watcher: {}", err);
            CliError::new(1)
        })?;

        log::debug!("start watching file system on {}", input_path.display());

        debouncer
            .watch(&input_path, RecursiveMode::Recursive)
            .map_err(|err| {
                log::error!(
                    "unable to start watching file system at `{}`: {}",
                    input_path.display(),
                    err
                );
                CliError::new(1)
            })?;

        if let Some(config) = &config_path {
            log::debug!("start watching provided config path {}", config.display());
            debouncer
                .watch(config, RecursiveMode::NonRecursive)
                .map_err(|err| {
                    log::error!(
                        "unable to start watching file system at `{}`: {}",
                        config.display(),
                        err
                    );
                    CliError::new(1)
                })?;
        } else {
            for path in DEFAULT_CONFIG_PATHS.iter().map(Path::new) {
                if path.exists() {
                    log::debug!("start watching default config path {}", path.display());
                    debouncer
                        .watch(path, RecursiveMode::NonRecursive)
                        .map_err(|err| {
                            log::error!(
                                "unable to start watching file system at `{}`: {}",
                                path.display(),
                                err
                            );
                            CliError::new(1)
                        })?;
                }
            }
        }

        log::debug!("waiting for Ctrl-C to close the program");

        loop {
            match receiver.recv().expect("Could not receive from channel.") {
                WatcherSignal::Exit => break,
                WatcherSignal::Watch(path) => {
                    log::debug!("start file watching on '{}'", path.display());
                    match debouncer.watch(&path, RecursiveMode::Recursive) {
                        Ok(()) => {}
                        Err(err) => {
                            log::error!(
                                "unable to start watching file system at `{}`: {}",
                                path.display(),
                                err
                            );
                        }
                    }
                }
                WatcherSignal::Unwatch(path) => {
                    log::debug!("stop file watching on '{}'", path.display());
                    match debouncer.unwatch(&path) {
                        Ok(()) => {}
                        Err(err) => {
                            log::error!(
                                "unable to stop watching file system at `{}`: {}",
                                path.display(),
                                err
                            );
                        }
                    }
                }
            }
        }

        Ok(())
    }

    fn send_watch_signal(&self, link_location: &Path) {
        if let Err(err) = self
            .sender
            .send(WatcherSignal::Watch(link_location.to_path_buf()))
        {
            log::warn!(
                "unable to send signal to watch '{}': {}",
                link_location.display(),
                err
            );
        }
    }

    fn send_unwatch_signal(&self, path: &Path) {
        if let Err(err) = self.sender.send(WatcherSignal::Unwatch(path.to_path_buf())) {
            log::warn!(
                "unable to send signal to unwatch '{}': {}",
                path.display(),
                err
            );
        }
    }

    fn setup_ctrl_exit(&self) -> Result<(), CliError> {
        let sender = self.sender.clone();
        ctrlc::set_handler(move || {
            sender
                .send(WatcherSignal::Exit)
                .expect("unable to send signal to terminate")
        })
        .map_err(|err| {
            log::error!("unable to set Ctrl-C handler: {}", err);
            CliError::new(1)
        })?;
        Ok(())
    }

    fn process_events(&mut self, events: Vec<DebouncedEvent>) {
        if events.is_empty() {
            return;
        }
        let current_path = self.current_working_path.as_ref();

        let worker_tree = if let Some(worker_tree) = self.worker_tree.as_mut() {
            worker_tree
        } else {
            return;
        };

        log::debug!("file watch has detected changes");

        let mut has_created = false;

        for event in events {
            let links = &self.links_file_watch;

            let mut paths_iterator = event.event.paths.iter().map(|path| {
                links
                    .iter()
                    .find_map(|(link_location, link_path)| {
                        path.starts_with(link_location)
                            .then_some(link_path.as_path())
                    })
                    .or_else(|| {
                        current_path.and_then(|current_path| path.strip_prefix(current_path).ok())
                    })
                    .unwrap_or(path)
            });

            if log::log_enabled!(log::Level::Trace) {
                let event_display = match event.kind {
                    EventKind::Any => Some("unknown operation on"),
                    EventKind::Create(_) => Some("created"),
                    EventKind::Modify(_) => Some("modified"),
                    EventKind::Remove(_) => Some("removed"),
                    EventKind::Access(_) | EventKind::Other => None,
                };
                if let Some(event_display) = event_display {
                    for path in event.event.paths.iter() {
                        log::trace!("file watcher: {} '{}'", event_display, path.display());
                    }
                }
            }

            match event.kind {
                EventKind::Any => {
                    for path in paths_iterator {
                        has_created = true;
                        worker_tree.source_changed(path);
                    }
                }
                EventKind::Create(_create_kind) => {
                    has_created = paths_iterator.next().is_some();
                }
                EventKind::Modify(_modify_kind) => {
                    for path in paths_iterator {
                        worker_tree.source_changed(path);
                    }
                }
                EventKind::Remove(_remove_kind) => {
                    for path in paths_iterator {
                        worker_tree.remove_source(path);
                    }
                }
                EventKind::Access(_) | EventKind::Other => {}
            }
        }

        if has_created {
            self.worker_collect_work();
            self.update_links();
        }
    }

    fn worker_collect_work(&mut self) {
        let options = self.build_options();
        if let Some(worker_tree) = self.worker_tree.as_mut() {
            log_darklua_error(worker_tree.collect_work(&self.resources, &options), || ());
        }
    }

    fn update_extra_file_watch(&mut self) {
        if let Some(worker_tree) = self.worker_tree.as_ref() {
            let files: HashSet<_> = worker_tree
                .iter_external_dependencies()
                .map(ToOwned::to_owned)
                .collect();

            diff_sets(
                &files,
                &self.extra_file_watch,
                |new_file| {
                    self.send_watch_signal(new_file);
                },
                |last_file| {
                    self.send_unwatch_signal(last_file);
                },
            );

            self.extra_file_watch = files;
        }
    }

    fn update_links(&mut self) {
        let new_links: HashSet<_> = iter_all_links(self.input_path.clone())
            .filter_map(|link_path| {
                link_path
                    .read_link()
                    .ok()
                    .map(|link_location| (link_location, link_path))
            })
            .collect();

        diff_sets(
            &new_links,
            &self.links_file_watch,
            |(link_location, _link_path)| {
                self.send_watch_signal(link_location);
            },
            |(link_location, _link_path)| {
                self.send_unwatch_signal(link_location);
            },
        );

        self.links_file_watch = new_links;
    }
}

fn diff_sets<T: Eq + Hash>(
    new_set: &HashSet<T>,
    previous_set: &HashSet<T>,
    on_added: impl Fn(&T),
    on_removed: impl Fn(&T),
) {
    for item in previous_set.difference(new_set) {
        on_removed(item);
    }

    for item in new_set.difference(previous_set) {
        on_added(item);
    }
}

fn iter_all_links(location: PathBuf) -> impl Iterator<Item = PathBuf> {
    let mut unknown_paths = vec![location];
    let mut links = Vec::new();
    let mut dir_entries = Vec::new();

    iter::from_fn(move || loop {
        if let Some(location) = unknown_paths.pop() {
            match location.symlink_metadata() {
                Ok(metadata) => {
                    if metadata.is_symlink() {
                        links.push(location);
                    } else if metadata.is_dir() {
                        dir_entries.push(location.to_path_buf());
                    };
                }
                Err(err) => {
                    log::warn!(
                        "unable to read metadata from file `{}`: {}",
                        location.display(),
                        err
                    );
                }
            }
        } else if let Some(dir_location) = dir_entries.pop() {
            match dir_location.read_dir() {
                Ok(read_dir) => {
                    for entry in read_dir {
                        match entry {
                            Ok(entry) => {
                                unknown_paths.push(entry.path());
                            }
                            Err(err) => {
                                log::warn!(
                                    "unable to read directory entry `{}`: {}",
                                    dir_location.display(),
                                    err
                                );
                            }
                        }
                    }
                }
                Err(err) => {
                    log::warn!(
                        "unable to read directory `{}`: {}",
                        dir_location.display(),
                        err
                    );
                }
            }
        } else if let Some(path) = links.pop() {
            break Some(path);
        } else {
            break None;
        }
    })
}

fn log_darklua_error<T>(
    result: Result<T, darklua_core::DarkluaError>,
    else_result: impl Fn() -> T,
) -> T {
    result
        .inspect_err(|err| {
            log::error!("{}", err);
        })
        .unwrap_or_else(|_| else_result())
}
