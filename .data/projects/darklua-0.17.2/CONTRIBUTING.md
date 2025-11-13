<h1>Contributing</h1>

Thank you for your interest in contributing to this tool! There are different ways you can help this project become better.

- [Code of Conduct](#code-of-conduct)
- [Issues](#issues)
  - [Bugs](#bugs)
  - [Feature Requests](#feature-requests)
- [Submitting Code](#submitting-code)
- [Development](#development)
  - [Too Long Didn't Read](#too-long-didnt-read)
  - [Initial Setup](#initial-setup)
    - [Code Formatter](#code-formatter)
    - [Additional Linter](#additional-linter)
    - [Snapshot Testing Utility](#snapshot-testing-utility)
    - [Lua Interpreter](#lua-interpreter)
  - [Running Tests](#running-tests)
    - [Snapshot tests](#snapshot-tests)
    - [End-to-end Tests](#end-to-end-tests)
  - [Code formatter](#code-formatter-1)
  - [Clippy](#clippy)
  - [Benchmarks](#benchmarks)
  - [Help](#help)
    - [clippy is failing on CI but not locally](#clippy-is-failing-on-ci-but-not-locally)

# Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

# Issues

Issues are used for various reasons. They're used to communicate and organize the project. Here's a few general ideas of what you can do:

* React to an issue: leaving a thumbs up or a heart emoji on an issue shows your interest for that issue. It can be **very** helpful when planning out the next features to add to the project.
* Replying to an issue: someone reported a bug and you found a way to reproduce it? Amazing! That's a really good thing to share to make it easier for maintainers to fix the problem. Giving feedback on a feature request or giving use case examples are also excellent examples of valuable help.
* Linking issues: you found duplicated issues? Write a comment that references the other issue, by using `#` followed by the issue number. For example, if an issue is duplicating the issue `7`, you can write a comment `Duplicate of #7`.

## Bugs

Before creating an issue to report a bug, search both opened and closed [issues](issues) to see if it does not exist already.

If you can, try to provide reproducing steps and the verbose mode output from the tool.

## Feature Requests

Have an idea about a new feature that could be added to the project? Create an issue and pitch it!

# Submitting Code

By contributing code to this project, you agree to license your contribution under the MIT license.

It's best to open an issue before contributing code, just to make sure that the new feature is ready to be integrated, or that the solution for a fix is appropriate for example. For trivial changes, like fixing a typo or re-wording the README, feel free to skip the issue and just submit a merge request.

# Development

If you are interested to work on darklua, this section will help you get started. To ensure quality, darklua has automated checks running on each merge request. You'll learn how to verify these checks locally.

## Too Long Didn't Read

In short, run these three commands often because they run really fast and give you the most actionable feedback.

```sh
cargo fmt
cargo test -q
cargo clippy --all-targets --all-features -- -D warnings
```

When the three previous commands are passing and you want to run a final longer check, run the integrations tests:
```sh
lua ./scripts/test-commands.lua
```

## Initial Setup

darklua is written in [Rust](https://www.rust-lang.org/), so you'll need to install the usual tools for Rust development. You can find how to install Rust [here](https://www.rust-lang.org/tools/install).

### Code Formatter

Code style is enforced on each merge request, so you will need to install `rustfmt` to auto-format your code.

```sh
rustup component add rustfmt
# adds the command `cargo fmt` to auto format
```

### Additional Linter

[Clippy](https://github.com/rust-lang/rust-clippy) is a static analysis tool that helps avoiding common mistakes in Rust code.

```sh
rustup component add clippy
# adds the command `cargo clippy` to verify the code
```

### Snapshot Testing Utility
darklua has snapshot tests using the [insta library](https://insta.rs/). To review or add new snapshot tests, you will need to install `cargo-insta`

```sh
cargo install cargo-insta
# adds the command `cargo insta` to manage snapshots
```

### Lua Interpreter

To run the end-to-end tests, you will need to install a standalone Lua 5.1 interpreter with [Luarocks](https://luarocks.org/). Install the following packages:

```sh
luarocks install luafilesystem
luarocks install busted
```

## Running Tests

To run all the unit tests, snapshot tests and integration tests, simply run the usual command with `cargo`

```sh
cargo test
# or if the output is too verbose
cargo test -q
```

### Snapshot tests

If there are snapshot test failures (because snapshots need to be updated, or new snapshots are added), use the following command to review them:

```sh
cargo insta review
```

The terminal will enter in interactive mode that lets you accept, reject or skip snapshots. More info can be found on the [insta quickstart](https://insta.rs/docs/quickstart/) documentation.

### End-to-end Tests

The `test-commands.lua` script will clone a few Lua repositories, apply various darklua rules and assert that tests are still passing.

```sh
lua ./scripts/test-commands.lua
```

## Code formatter

To automatically format all the code, run:

```sh
cargo fmt
```

## Clippy

To get a full report and what needs to be fixed, run:

```sh
cargo clippy --all-targets --all-features -- -D warnings
```

## Benchmarks

Benchmarking is done using [Criterion.rs](https://github.com/bheisler/criterion.rs).

The benchmarks will depend on public Lua sources that are not committed to the repository. To fetch the content, simply run:

```sh
./bench_content/download_content.sh
```

To run benchmarks, run:

```sh
cargo bench
```

Benchmark reports are generated automatically under `target/criterion/`.

### Benchmark Tracing

Some benchmarks may emit tracing information that can be captured with the [Tracy profiler](https://github.com/wolfpld/tracy). To setup a benchmark to emit information to Tracy, look for other benchmarks that do it (search for `TracyLayer::new()`).

Using Tracy is simple: download the exectuable the release from GitHub, run it and connect.

When running benchmarks, enable the the `tracing` feature:

```sh
cargo bench --features tracing
```

## Help

### clippy is failing on CI but not locally

You are probably running an older version of `rustc` or `clippy`. You can upgrade the Rust toolchain with `rustup`

```
rustup update
```

And re-run the clippy installation command to update clippy:

```
rustup component add clippy
```
