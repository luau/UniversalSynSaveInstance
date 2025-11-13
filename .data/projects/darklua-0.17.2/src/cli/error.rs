#[derive(Debug, Clone)]
pub struct CliError {
    exit_code: i32,
}

impl CliError {
    pub fn new(exit_code: i32) -> Self {
        Self { exit_code }
    }

    pub fn exit_code(&self) -> i32 {
        self.exit_code
    }
}
