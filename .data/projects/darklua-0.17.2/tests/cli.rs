use std::{
    ffi::OsStr,
    fs,
    path::{Path, PathBuf},
};

use assert_cmd::Command;
use insta::assert_snapshot;
use tempfile::{tempdir_in, TempDir};

struct Context {
    command: Command,
    working_directory: TempDir,
    snapshot_replace: Vec<(String, String)>,
}

impl Default for Context {
    fn default() -> Self {
        let working_directory =
            tempdir_in(env!("CARGO_TARGET_TMPDIR")).expect("unable to create temporary directory");

        let mut command = Command::cargo_bin(env!("CARGO_PKG_NAME")).unwrap();
        command.current_dir(working_directory.path());

        Self::new(command, working_directory)
    }
}

impl Context {
    pub fn new(command: Command, working_directory: TempDir) -> Self {
        Self {
            command,
            working_directory,
            snapshot_replace: Vec::new(),
        }
    }

    pub fn arg<S: AsRef<OsStr>>(mut self, arg: S) -> Self {
        self.command.arg(arg);
        self
    }

    pub fn with_cwd(mut self, cwd: impl AsRef<Path>) -> Self {
        let full_dir = self.working_directory.path().join(cwd.as_ref());
        self.command.current_dir(full_dir);
        self
    }

    pub fn expect_file<P: AsRef<Path>>(&self, file_path: P) -> &Self {
        let file_path = file_path.as_ref();
        if !file_path.exists() || !file_path.is_file() {
            Self::debug_working_directory(self.working_directory.path());
        }
        assert!(
            file_path.exists(),
            "file `{}` does not exist",
            file_path.display()
        );
        assert!(
            file_path.is_file(),
            "path `{}` is not a file",
            file_path.display()
        );
        self
    }

    pub fn snapshot_file<P: AsRef<Path>>(
        &self,
        snapshot_name: &'static str,
        file_path: P,
    ) -> &Self {
        let file_path = self.path_from_working_directory(file_path.as_ref());
        self.expect_file(&file_path);
        let content = fs::read_to_string(file_path).expect("unable to read file");
        self.snapshot_string(snapshot_name, content);
        self
    }

    pub fn snapshot_command(mut self, snapshot_name: &'static str) -> Self {
        let output = self.full_output();
        self.snapshot_string(snapshot_name, output);
        self
    }

    fn snapshot_string(&self, snapshot_name: &'static str, content: String) {
        let working_directory_display = format!(
            "{}{}",
            self.working_directory.path().display(),
            std::path::MAIN_SEPARATOR
        );
        let content = content.replace(&working_directory_display, "{{CWD}}");

        let mut settings = insta::Settings::clone_current();
        settings.set_prepend_module_to_snapshot(false);
        settings.add_filter("darklua\\.exe", "darklua");
        for (matcher, replacement) in self.snapshot_replace.iter() {
            settings.add_filter(matcher, replacement);
        }
        settings.bind(|| {
            assert_snapshot!(snapshot_name, content);
        });
    }

    pub fn write_file<P: AsRef<Path>>(self, relative_path: P, content: &str) -> Self {
        let file_path = self.path_from_working_directory(relative_path);

        if let Some(parent) = file_path
            .parent()
            .filter(|parent| *parent != self.working_directory.as_ref())
        {
            fs::create_dir_all(parent).expect("unable to create directory");
        }

        fs::write(file_path, content).expect("unable to write file");
        self
    }

    fn path_from_working_directory<P: AsRef<Path>>(&self, path: P) -> PathBuf {
        self.working_directory.path().join(path)
    }

    fn full_output(&mut self) -> String {
        let output = self.command.output().expect("unable to run command");

        let mut string = std::str::from_utf8(&output.stdout)
            .expect("unable to read output")
            .to_owned();
        let err_output = std::str::from_utf8(&output.stderr).expect("unable to read output");

        if !string.is_empty() && !err_output.is_empty() {
            string.push('\n');
        }

        string.push_str(err_output);
        string
    }

    fn debug_working_directory(root: &Path) {
        eprintln!("{}", root.display());
        for entry in root.read_dir().unwrap() {
            let entry = entry.unwrap().path();
            if entry.is_dir() {
                Self::debug_working_directory(&entry);
            } else {
                eprintln!("{}", entry.display());
            }
        }
    }

    pub fn expect_success(mut self) -> Self {
        self.command.assert().code(0);
        self
    }

    pub fn replace_snapshot_content(
        mut self,
        matcher: impl Into<String>,
        replace_with: impl Into<String>,
    ) -> Self {
        self.snapshot_replace
            .push((matcher.into(), replace_with.into()));
        self
    }

    pub fn replace_duration_labels(self) -> Self {
        self.replace_snapshot_content("\\d+\\.\\d+[µm]s", "{{DURATION}}")
            .replace_snapshot_content("\\d+µs", "{{DURATION}}")
    }

    pub fn replace_backslashes(self) -> Self {
        self.replace_snapshot_content("\\\\", "/")
    }
}

#[test]
fn snapshot_help_command() {
    Context::default()
        .arg("help")
        .snapshot_command("help_command");
}

#[test]
fn snapshot_short_help_command() {
    Context::default()
        .arg("-h")
        .snapshot_command("short_help_command");
}

#[test]
fn snapshot_process_help_command() {
    Context::default()
        .arg("process")
        .arg("--help")
        .snapshot_command("process_help_command");
}

#[test]
fn snapshot_minify_help_command() {
    Context::default()
        .arg("minify")
        .arg("--help")
        .snapshot_command("minify_help_command");
}

#[test]
fn snapshot_convert_help_command() {
    Context::default()
        .arg("convert")
        .arg("--help")
        .snapshot_command("convert_help_command");
}

#[test]
fn run_minify_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("minify")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .snapshot_command("run_minify_command")
        .snapshot_file("run_minify_command_init_out", "out/init.lua");
}

#[test]
fn run_minify_with_column_span_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("minify")
        .arg("--column-span")
        .arg("2")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .expect_success()
        .snapshot_file(
            "run_minify_with_column_span_command_init_out",
            "out/init.lua",
        );
}

#[test]
fn run_minify_with_column_span_in_config_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        // minify does not read the configuration file anymore, so we should expect
        // the snapshot to have the default generator used
        .write_file(".darklua.json", "{ column_span: 2 }")
        .arg("minify")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .expect_success()
        .snapshot_file(
            "run_minify_with_column_span_in_config_command_init_out",
            "out/init.lua",
        );
}

#[test]
fn run_minify_verbose_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("minify")
        .arg("-v")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .replace_backslashes()
        .snapshot_command("run_minify_verbose_command");
}

#[test]
fn run_process_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("process")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .snapshot_command("run_process_command")
        .snapshot_file("run_process_command_init_out", "out/init.lua");
}

#[test]
fn run_process_command_with_input_path_starting_with_dot() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("process")
        .arg("./src")
        .arg("out")
        .replace_duration_labels()
        .snapshot_command("run_process_command")
        .snapshot_file("run_process_command_init_out", "out/init.lua");
}

#[test]
fn run_process_command_with_output_path_starting_with_dot() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("process")
        .arg("src")
        .arg("./out")
        .replace_duration_labels()
        .snapshot_command("run_process_command")
        .snapshot_file("run_process_command_init_out", "out/init.lua");
}

#[test]
fn run_process_command_with_input_and_output_path_starting_with_dot() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("process")
        .arg("./src")
        .arg("./out")
        .replace_duration_labels()
        .snapshot_command("run_process_command")
        .snapshot_file("run_process_command_init_out", "out/init.lua");
}

#[test]
fn run_process_command_with_input_path_starting_with_parent_dir() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .write_file("lib/.darklua.json", "{}")
        .arg("process")
        .arg("../src")
        .arg("out")
        .with_cwd("lib")
        .replace_duration_labels()
        .snapshot_command("run_process_command")
        .snapshot_file("run_process_command_init_out", "lib/out/init.lua");
}

#[test]
fn run_process_verbose_command() {
    Context::default()
        .write_file("src/init.lua", "return 1 + 1\n")
        .arg("process")
        .arg("-v")
        .arg("src")
        .arg("out")
        .replace_duration_labels()
        .replace_backslashes()
        .snapshot_command("run_process_verbose_command");
}

#[test]
fn run_process_single_file_custom_config_command() {
    Context::default()
        .write_file("test.lua", "return _G.CONSTANT\n")
        .write_file(
            "custom.json5",
            "{ rules: [{ rule: 'inject_global_value', identifier: 'CONSTANT', value: true }] }",
        )
        .arg("process")
        .arg("--config")
        .arg("custom.json5")
        .arg("test.lua")
        .arg("out.lua")
        .replace_duration_labels()
        .snapshot_command("run_process_single_file_custom_config")
        .snapshot_file("run_process_custom_config_command_out", "out.lua");
}

#[test]
fn run_process_single_file_custom_config_command_deprecated_config_path() {
    Context::default()
        .write_file("test.lua", "return _G.CONSTANT\n")
        .write_file(
            "custom.json5",
            "{ rules: [{ rule: 'inject_global_value', identifier: 'CONSTANT', value: true }] }",
        )
        .arg("process")
        .arg("--config-path")
        .arg("custom.json5")
        .arg("test.lua")
        .arg("out.lua")
        .replace_duration_labels()
        .snapshot_command("run_process_single_file_custom_config")
        .snapshot_file("run_process_custom_config_command_out", "out.lua");
}

#[test]
fn run_convert_command_on_json_file_with_output() {
    Context::default()
        .write_file("data.json", "{ \"property\": true }")
        .arg("convert")
        .arg("data.json")
        .arg("out.lua")
        .replace_duration_labels()
        .snapshot_command("run_convert_command_on_json_file_with_output")
        .snapshot_file("run_convert_command_on_json_file_out", "out.lua");
}

#[test]
fn run_convert_command_on_json_without_extension_file_with_output() {
    Context::default()
        .write_file("data", "{ \"property\": true }")
        .arg("convert")
        .arg("data")
        .arg("out.lua")
        .arg("--format")
        .arg("json")
        .replace_duration_labels()
        .snapshot_command("run_convert_command_on_json_without_extension_file_with_output")
        .snapshot_file("run_convert_command_on_json_file_out", "out.lua");
}

#[test]
fn run_convert_command_on_json_file() {
    Context::default()
        .write_file("data.json", "{ \"property\": true }")
        .arg("convert")
        .arg("data.json")
        .replace_duration_labels()
        .snapshot_command("run_convert_command_on_json_file_stdout");
}

#[test]
fn run_convert_command_errors_when_no_extension_and_no_format() {
    Context::default()
        .write_file("data", "{ \"property\": true }")
        .arg("convert")
        .arg("data")
        .arg("out.lua")
        .replace_duration_labels()
        .snapshot_command("run_convert_command_errors_when_no_extension_and_no_format");
}

#[test]
fn run_convert_command_errors_when_unrecognized_extension() {
    Context::default()
        .write_file("data.yoyo", "{ \"property\": true }")
        .arg("convert")
        .arg("data.yoyo")
        .arg("out.lua")
        .replace_duration_labels()
        .snapshot_command("run_convert_command_errors_when_unrecognized_extension");
}
