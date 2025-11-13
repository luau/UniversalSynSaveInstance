use std::{
    collections::HashSet,
    path::{Path, PathBuf},
};

use crate::{nodes::Block, utils::Timer};

use super::{DarkluaError, DarkluaResult};

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct Progress {
    block: Block,
    next_rule: usize,
    required: Vec<PathBuf>,
    duration: Timer,
}

impl Progress {
    pub(crate) fn new(block: Block) -> Self {
        Self {
            block,
            next_rule: 0,
            required: Vec::new(),
            duration: Timer::now(),
        }
    }

    pub(crate) fn set_required_content(&mut self, required_content: Vec<PathBuf>) {
        self.required = required_content;
    }

    pub(crate) fn next_rule(&self) -> usize {
        self.next_rule
    }

    pub(crate) fn set_next_rule(&mut self, rule_index: usize) {
        self.next_rule = rule_index;
    }

    pub(crate) fn block(&self) -> &Block {
        &self.block
    }

    pub(crate) fn mutate_block(&mut self) -> &mut Block {
        &mut self.block
    }

    pub(crate) fn duration(&mut self) -> &mut Timer {
        &mut self.duration
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct WorkProgress {
    pub(crate) content: String,
    pub(crate) progress: Progress,
}

impl WorkProgress {
    pub(crate) fn new(content: String, block: Block) -> Self {
        Self {
            content,
            progress: Progress::new(block),
        }
    }

    pub(crate) fn required_content(&self) -> impl Iterator<Item = &Path> {
        self.progress.required.iter().map(AsRef::as_ref)
    }
}

#[derive(Debug, Clone)]
pub(crate) enum WorkStatus {
    NotStarted,
    InProgress(Box<WorkProgress>),
    Done(DarkluaResult<()>),
}

impl WorkStatus {
    pub(crate) fn done() -> Self {
        Self::Done(Ok(()))
    }

    pub(crate) fn err(err: DarkluaError) -> Self {
        Self::Done(Err(err))
    }

    pub(crate) fn is_done(&self) -> bool {
        matches!(self, WorkStatus::Done(_))
    }
}

impl Default for WorkStatus {
    fn default() -> Self {
        Self::NotStarted
    }
}

impl From<WorkProgress> for WorkStatus {
    fn from(progress: WorkProgress) -> Self {
        Self::InProgress(Box::new(progress))
    }
}

#[derive(Debug, Clone)]
pub(crate) struct WorkData {
    source: PathBuf,
    output: PathBuf,
}

impl WorkData {
    pub(crate) fn is_in_place(&self) -> bool {
        self.source == self.output
    }

    pub(crate) fn source(&self) -> &Path {
        &self.source
    }

    pub(crate) fn output(&self) -> &Path {
        &self.output
    }
}

#[derive(Debug, Clone)]
pub(crate) struct WorkItem {
    pub(crate) data: WorkData,
    pub(crate) status: WorkStatus,
    pub(crate) external_file_dependencies: HashSet<PathBuf>,
}

impl WorkItem {
    pub(crate) fn new(source: impl Into<PathBuf>, output: impl Into<PathBuf>) -> Self {
        Self {
            data: WorkData {
                source: source.into(),
                output: output.into(),
            },
            status: Default::default(),
            external_file_dependencies: Default::default(),
        }
    }

    pub(crate) fn new_in_place(source: impl Into<PathBuf>) -> Self {
        let source = source.into();
        Self::new(source.clone(), source)
    }

    pub(crate) fn source(&self) -> &Path {
        &self.data.source
    }

    pub(crate) fn total_required_content(&self) -> usize {
        match &self.status {
            WorkStatus::NotStarted | WorkStatus::Done(_) => 0,
            WorkStatus::InProgress(progress) => progress.progress.required.len(),
        }
    }

    pub(crate) fn reset(&mut self) {
        self.status = WorkStatus::NotStarted;
        self.external_file_dependencies.clear();
    }
}
