---
title: Bundling
description: How to bundle Lua code
group: Guides
order: 3
---

Darklua is capable of bundling Lua code: it will start from a given file and attempt to merge every require into a single file.

**Warning:** it is important that each module do not have any side effects at require-time, as the order of those side effects may not be preserved in the bundled code.

The process command will bundle Lua code when defined in the configuration file. Defining the `bundle` field will set up darklua to bundle code. The following minimal configuration will bundle code using path requires:

```json5
{
  bundle: {
    require_mode: "path",
  },
}
```

## Process Command

To bundle code, use the process command. Provide the entry point that you would like to bundle from and the second argument is the output location:

```
darklua process entry-point.lua bundled.lua
```

Given the `entry-point.lua`, darklua will recursively follow the requires and inline the code into a single `bundled.lua` file.

## Configuration

### Require Mode

Require modes are what darklua uses to interpret require calls to other modules. They are useful when bundling or when converting require calls using the [`convert_require` rule](../rules/convert_require). When bundling code, darklua uses the require mode defined in the configuration file (in the bundling part) to find the source files.

Currently, there is **2 require mode available for bundling**:

<table-container aria-label="bundling require mode support">
  <table-head>
    <table-row>
      <table-cell>Mode name</table-cell>
      <table-cell>Usage</table-cell>
      <table-cell>Example</table-cell>
      <table-cell>Documentation</table-cell>
    </table-row>
  </table-head>
  <table-body>
    <table-row>
      <table-cell>path</table-cell>
      <table-cell>with regular file paths</table-cell>
      <table-cell>require("./module")</table-cell>
      <table-cell><a href="../path-require-mode/">documentation</a></table-cell>
    </table-row>
    <table-row>
      <table-cell>luau</table-cell>
      <table-cell>with Luau module paths</table-cell>
      <table-cell>require("@self/module")</table-cell>
      <table-cell><a href="../luau-require-mode/">documentation</a></table-cell>
    </table-row>
  </table-body>
</table-container>

For more information about how to configure the require mode, take a look at the [path require mode](../path-require-mode/) or the [luau require mode](../luau-require-mode/) configuration pages.

### Excludes

Provide a list of patterns to exclude certain paths from the bundle.

For example, to avoid bundling any require to paths starting with `@lune`:

```json5
{
  bundle: {
    require_mode: "path",
    excludes: ["@lune/**"],
  },
}
```

These patterns are similar to Unix globs, but for more information about the differences and the syntax, see the [pattern library documentation](https://github.com/olson-sean-k/wax/blob/master/README.md#patterns) used by darklua.

### Modules Identifier

When darklua bundles multiple modules into a single file, it uses a variable to store all the required modules. This parameter lets you modify that variable name if needed.

```json5
{
  bundle: {
    require_mode: "path",
    // by default, darklua will use the following value
    modules_identifier: "__DARKLUA_BUNDLE_MODULES",
  },
}
```

## Require Data Files as Lua

When bundling, the `path` require mode is able to require data files and convert them into Lua data. All that is needed is that the file has one of the recognized extensions:

- [JSON](https://en.wikipedia.org/wiki/JSON) with `.json` or `.json5`

- [YAML](https://en.wikipedia.org/wiki/YAML) with `.yml` or `.yaml`

- [Toml](https://toml.io/en/) with `.toml`

Text files (ending with `.txt`) are also supported and they will simply map to a string with the file content.

If you would like to see a format added, feel free to submit a request using a [GitHub issue](https://github.com/seaofvoices/darklua/issues).

### JSON Example

<br/>

<compare-code left="JSON file" right="Generated Lua" left-language="json" right-language="lua">
<code>
{
  "experienceActivation_singleton": "experienceActivation",
  "experienceConfiguration_singleton": "experienceConfiguration",
  "experience_singleton": {
    "experience": {
      "assetId": 3296599132,
      "startPlaceId": 8667346609
    }
  },
  "placeConfiguration_start": "placeConfiguration",
  "placeFile_start": {
    "placeFile": {
      "version": 2
    }
  },
  "place_start": {
    "place": {
      "assetId": 8667346609
    }
  }
}
</code>

<code>
{
	experienceActivation_singleton = "experienceActivation",
	experienceConfiguration_singleton = "experienceConfiguration",
	experience_singleton = {
		experience = {
			assetId = 3296599132,
			startPlaceId = 8667346609,
		},
	},
	placeConfiguration_start = "placeConfiguration",
	placeFile_start = {
		placeFile = {
			version = 2,
		},
	},
	place_start = {
		place = {
			assetId = 8667346609,
		},
	},
}
</code>
</compare-code>

### YAML Example

<br/>

<compare-code left="YAML file" right="Generated Lua" left-language="yml" right-language="lua">
<code>
name: Tests
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  code-style:
    name: Verify code style
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Verify code format
        run: cargo fmt -- --check
</code>

<code>
{
    name = "Tests",
    on = {
        push = {
            branches = { "main" },
        },
        pull_request = {
            branches = { "main" },
        },
    },
    jobs = {
        ["code-style"] = {
            name = "Verify code style",
            ["runs-on"] = "ubuntu-latest",
            steps = {
                {
                    uses = "actions/checkout@v3",
                },
                {
                    name = "Verify code format",
                    run = "cargo fmt -- --check",
                },
            },
        },
    },
}
</code>
</compare-code>

### Toml Example

<br/>

<compare-code left="Toml file" right="Generated Lua" left-language="toml" right-language="lua">
<code>
[package]
name = "darklua"
version = "0.17.2"
edition = "2018"
readme = "README.md"
description = "Transform Lua scripts"
repository = "https://github.com/seaofvoices/darklua"
homepage = "https://darklua.com"
license = "MIT"
keywords = ["lua", "obsfucation", "minify"]
exclude = ["site"]

[badges]
github = { repository = "seaofvoices/darklua" }

[lib]
name = "darklua_core"
path = "src/lib.rs"

[[bin]]
name = "darklua"
path = "src/bin.rs"

[features]
tracing = ["dep:tracing"]

[dependencies]
clap = { version = "4.1.1", features = ["derive"] }
durationfmt = "0.1.1"
elsa = "1.7.0"
env_logger = "0.9.0"
full_moon = { version = "0.16.2", features = ["roblox"] }
json5 = "0.4"
log = "0.4"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0.92"
serde_yaml = "0.9.17"
toml = "0.7.2"
tracing = { version = "0.1", optional = true }
wax = "0.5.0"

[dev-dependencies]
assert_cmd = "2.0.4"
criterion = { version = "0.4", features = ["html_reports"] }
include_dir = "0.7.3"
insta = { version = "1.29.0", features = ["json", "filters"] }
paste = "1.0"
pretty_assertions = "0.7.2"
rand = "0.7.3"
rand_distr = "0.2.2"
serde_bytes = "0.11"
tempfile = "3.5.0"
tracing-subscriber = "0.3.16"
tracing-tracy = "0.10.1"

[target.'cfg(target_arch = "wasm32")'.dependencies]
node-sys = "0.4.2"
web-sys = { version = "0.3.60", features = ["Window", "Performance"] }

[profile.dev.package.full_moon]
opt-level = 3

[[bench]]
name = "process_bench"
harness = false

[[bench]]
name = "parse_bench"
harness = false

</code>

<code>
{
	bench = {
		{ harness = false, name = "process_bench" },
		{ harness = false, name = "parse_bench" },
	},
	bin = {
		{ name = "darklua", path = "src/bin.rs" },
	},
	badges = {
		github = { repository = "seaofvoices/darklua" },
	},
	dependencies = {
		durationfmt = "0.1.1",
		elsa = "1.7.0",
		env_logger = "0.9.0",
		json5 = "0.4",
		log = "0.4",
		serde_json = "1.0.92",
		serde_yaml = "0.9.17",
		toml = "0.7.2",
		wax = "0.5.0",
		clap = { features = { "derive" }, version = "4.1.1" },
		full_moon = { features = { "roblox" }, version = "0.16.2" },
		serde = { features = { "derive" }, version = "1.0" },
		tracing = { optional = true, version = "0.1" },
	},
	["dev-dependencies"] = {
		assert_cmd = "2.0.4",
		include_dir = "0.7.3",
		paste = "1.0",
		pretty_assertions = "0.7.2",
		rand = "0.7.3",
		rand_distr = "0.2.2",
		serde_bytes = "0.11",
		tempfile = "3.5.0",
		["tracing-subscriber"] = "0.3.16",
		["tracing-tracy"] = "0.10.1",
		criterion = { features = { "html_reports" }, version = "0.4" },
		insta = { features = { "json", "filters" }, version = "1.29.0" },
	},
	features = {
		tracing = { "dep:tracing" },
	},
	lib = { name = "darklua_core", path = "src/lib.rs" },
	package = {
		description = "Transform Lua scripts",
		edition = "2018",
		exclude = { "site" },
		homepage = "https://darklua.com",
		keywords = { "lua", "obsfucation", "minify" },
		license = "MIT",
		name = "darklua",
		readme = "README.md",
		repository = "https://github.com/seaofvoices/darklua",
		version = "0.17.2",
	},
	profile = {
		dev = {
			package = { full_moon = { ["opt-level"] = 3 } },
		},
	},
	target = {
		['cfg(target_arch = "wasm32")'] = {
			dependencies = {
				["node-sys"] = "0.4.2",
				["web-sys"] = { features = { "Window", "Performance" }, version = "0.3.60" },
			},
		},
	},
}
</code>
</compare-code>
