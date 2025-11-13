#[cfg(not(target_arch = "wasm32"))]
use std::time::{Duration, Instant};
#[cfg(target_arch = "wasm32")]
use web_time::{Duration, Instant};

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Timer {
    start: Instant,
    accumulated_time: Duration,
}

impl Timer {
    pub fn now() -> Self {
        Self {
            start: Instant::now(),
            accumulated_time: Duration::new(0, 0),
        }
    }

    pub fn pause(&mut self) {
        let duration = self.start.elapsed();
        self.accumulated_time += duration;
    }

    pub fn start(&mut self) {
        self.start = Instant::now();
    }

    pub fn duration_label(&self) -> String {
        let duration = self.start.elapsed();
        durationfmt::to_string(duration + self.accumulated_time)
    }
}
