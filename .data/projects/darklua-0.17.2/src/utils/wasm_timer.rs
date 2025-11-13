use std::time::Duration;

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Timer {
    start: Duration,
    accumulated_time: Duration,
}

#[inline]
fn instant_now() -> Duration {
    if let Some(performance) = web_sys::window().and_then(|window| window.performance()) {
        let now = performance.now();

        Duration::from_nanos((now * 1_000_000.0) as u64)
    } else {
        let now = node_sys::process.uptime();

        Duration::from_nanos((now * 1_000_000_000.0) as u64)
    }
}

impl Timer {
    pub fn now() -> Self {
        Self {
            start: instant_now(),
            accumulated_time: Duration::new(0, 0),
        }
    }

    pub fn pause(&mut self) {
        let now = instant_now();
        let duration = now - self.start;
        self.accumulated_time += duration;
    }

    pub fn start(&mut self) {
        self.start = instant_now();
    }

    pub fn duration_label(&self) -> String {
        let now = instant_now();
        let duration = now - self.start;
        durationfmt::to_string(duration + self.accumulated_time)
    }
}
