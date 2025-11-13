---
title: Getting Started
description: Overview of darklua
group: Guides
order: 1
---

## Usage

The following section will detail the different commands of darklua. You can also get a list of the available commands and options using the command line tool itself, simply run:

```
darklua help
```

To get help on a specific command, simply append `--help` (or `-h`) to the command name. For example, to get help on the `process` command:

```
darklua process --help
```

### Process

The process command is similar to the minify command: it takes an input path and generates code at the output path. This command will apply [rules](../rules/) (the default rules or the one given in the configuration file) to each Lua file.

```
darklua process <input-path> <output-path>

optional arguments:
  -c, --config <path>
  Path to a configuration file
```

#### Example

If you have a `src` folder that contains a bunch of Lua scripts (files ending with `.lua`), you can process all the files with the default configuration (or with the configuration file located in the same folder where you are running the command) into a new folder called `processed-src` using the following command:

```
darklua process src processed-src
```

If a configuration file is found in the folder where the command is run, darklua will automatically use it. If your configuration file is not named `.darklua.json` or `.darklua.json5`, or not located in the folder where you are running the command, you must specify it with the `--config` argument:

```
darklua process src processed-src --config ./path/config.json
# or the shorter version:
darklua process src processed-src -c ./path/config.json
```

### Convert

This command takes a data file and converts it to a Lua file. If no output path is provided, the Lua code will be printed to the console.

The supported data formats are: `json`, `json5`, `yaml` or `toml`.

```
darklua convert <input-path> [output-path]

optional arguments:
  -f, --format {json, yaml, toml}
```

### Minify

This command reads Lua code and reformats it to reduce the size of the code, measured in total bytes. The input path can be a single file name or a directory name. Given a directory, darklua will find all Lua files under that directory and output them following the same hierarchy.

```
darklua minify <input-path> <output-path>

optional arguments:
  --column-span <number>
  The maximum number of characters that should be written on a line
```

#### Example

If you have a `src` folder that contains a bunch of Lua scripts (files ending with `.lua`), you can generate the minified version of these Lua scripts into a new folder called `minified-src` using the following command:

```
darklua minify src minified-src
```
