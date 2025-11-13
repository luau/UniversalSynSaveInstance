#[cfg(not(target_arch = "wasm32"))]
mod file_watcher;

use std::time::Duration;

use darklua_core::WorkerTree;
#[cfg(not(target_arch = "wasm32"))]
pub use file_watcher::FileWatcher;

pub fn maybe_plural(count: usize) -> &'static str {
    if count > 1 {
        "s"
    } else {
        ""
    }
}

pub fn report_process(
    command: &'static str,
    worker_tree: &WorkerTree,
    duration: Duration,
) -> Result<(), ()> {
    let process_duration = durationfmt::to_string(duration);

    let success_count = worker_tree.success_count();

    println!(
        "successfully {} {} file{} (in {})",
        command,
        success_count,
        maybe_plural(success_count),
        process_duration
    );

    let errors = worker_tree.collect_errors();

    if errors.is_empty() {
        Ok(())
    } else {
        let error_count = errors.len();
        eprintln!(
            "{}{} error{} happened:",
            if success_count > 0 { "but " } else { "" },
            error_count,
            maybe_plural(error_count)
        );

        for error in errors {
            eprintln!("-> {}", error);
        }

        Err(())
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn maybe_plural_gives_s_when_size_is_above_one() {
        assert_eq!(maybe_plural(2), "s");
    }

    #[test]
    fn maybe_plural_gives_s_when_size_is_one() {
        assert_eq!(maybe_plural(1), "");
    }

    #[test]
    fn maybe_plural_gives_s_when_size_is_zero() {
        assert_eq!(maybe_plural(0), "");
    }
}
