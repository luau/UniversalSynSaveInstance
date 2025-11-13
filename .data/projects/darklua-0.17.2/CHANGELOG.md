# Changelog

## 0.17.2

* add `convert_function_to_assignment` rule ([#317](https://github.com/seaofvoices/darklua/pull/317))
* fix module types when bundling code ([#300](https://github.com/seaofvoices/darklua/pull/300))
* improve the `compute_expression` rule to compute the length of strings ([#316](https://github.com/seaofvoices/darklua/pull/316))
* improve `append_text_comment` rule to support multiple comments being defined in a single config (this also fix a bug in the code generator related to how multiline comments were written) ([#314](https://github.com/seaofvoices/darklua/pull/314))
* add `remove_floor_division` rule to the all rule names list ([#313](https://github.com/seaofvoices/darklua/pull/313))
* upgrade inner parser (full-moon) to `2.0.0`. This fixes parsing errors when reading function attributes and type functions, but darklua will automatically strip them ([#312](https://github.com/seaofvoices/darklua/pull/312))

## 0.17.1

* fix ignored aliases from `.luaurc` configuration files when bundling ([#307](https://github.com/seaofvoices/darklua/pull/307))
* fix issue with command line input paths starting with `./` ([#306](https://github.com/seaofvoices/darklua/pull/306))
* fix issue with `.luaurc` configuration files containing aliases starting with `./` ([#305](https://github.com/seaofvoices/darklua/pull/305))

## 0.17.0

* improve statements filtering by transfering comments. This fixes the `remove_types` rule issues related to lost comments ([#297](https://github.com/seaofvoices/darklua/pull/297))
* improve warning messages when a path can't be found in a Rojo sourcemap (when using the `roblox` require mode) ([#294](https://github.com/seaofvoices/darklua/pull/294))
* fix missing trailing commas when writing table types using the `retain_lines` generator ([#293](https://github.com/seaofvoices/darklua/pull/293))
* fix string value generation to properly use decimal escape codes (e.g. `"\12"`) ([#292](https://github.com/seaofvoices/darklua/pull/292))
* add a new require mode for the Luau require semantics (supporting the usage of `@self`) ([#290](https://github.com/seaofvoices/darklua/pull/290))
* change internal representation of Lua strings to avoid issues with non utf-8 encoded strings ([#282](https://github.com/seaofvoices/darklua/pull/282))
* add support for path requires ending with an extension different than `.luau` or `.lua` ([#280](https://github.com/seaofvoices/darklua/pull/280))
* add rule to convert `math.sqrt()` calls into an exponent form (using the `^` operator) (`convert_square_root_call`) ([#278](https://github.com/seaofvoices/darklua/pull/278))
* improve `inject_global_value` to support structured data. Add the `env_json` property to inject JSON encoded data and the `default_value` property to inject data when the provided environment variable is not defined ([#277](https://github.com/seaofvoices/darklua/pull/277))
* add rule to remove method call syntax (`remove_method_call`) ([#276](https://github.com/seaofvoices/darklua/pull/276))
* fix `remove_unused_variable` rule to correctly handle trailing unassigned (but used!) variables ([#275](https://github.com/seaofvoices/darklua/pull/275))
* add rule to convert Luau numbers (`convert_luau_number`) ([#274](https://github.com/seaofvoices/darklua/pull/274))
* export the `PathRequireMode` struct when using the darklua library and refactor AST node types to reduce size difference between variants ([#273](https://github.com/seaofvoices/darklua/pull/273))

## 0.16.0

* add `remove_statement(index)` method to `Block` ([#254](https://github.com/seaofvoices/darklua/pull/254))
* fix floating point number representation ([#251](https://github.com/seaofvoices/darklua/pull/251))
* read Luau configuration files (`.luaurc`) to get path aliases ([#246](https://github.com/seaofvoices/darklua/pull/246))
* support Luau types when bundling ([#249](https://github.com/seaofvoices/darklua/pull/249))

## 0.15.0

* improve file watching: re-process specific files, sourcemap changes re-process the project, bundling re-starts whenever a dependent file changes ([#239](https://github.com/seaofvoices/darklua/pull/239))

## 0.14.1

* fix `rename_variables` rule to rename module names in types ([#233](https://github.com/seaofvoices/darklua/pull/233))
* fix string encoding containing unicode characters taking more than 1 byte ([#232](https://github.com/seaofvoices/darklua/pull/232))
* fix `append_text_comment` to not add an extra space to comments ([#231](https://github.com/seaofvoices/darklua/pull/231))
* add rule to remove floor divisions (`remove_floor_division`) ([#230](https://github.com/seaofvoices/darklua/pull/230))
* fix `remove_assertions` rule to make the `assert` calls return their arguments ([#229](https://github.com/seaofvoices/darklua/pull/229))
* add rule to remove continue statements (`remove_continue`) ([#227](https://github.com/seaofvoices/darklua/pull/227))
* fix negative zero sign erasure ([#222](https://github.com/seaofvoices/darklua/pull/222))
* add `remove_if_expression` rule ([#221](https://github.com/seaofvoices/darklua/pull/221))

## 0.14.0

* migrate parser to the latest version. Reduce stack overflow issues, add support for compound assignments using floor division and leading symbols in union and intersection types ([#219](https://github.com/seaofvoices/darklua/pull/219))

## 0.13.1

* fix `remove_unused_variable` rule ([#192](https://github.com/seaofvoices/darklua/pull/192))
* add `except` parameter to skip comments when using the `remove_comments` rule ([#194](https://github.com/seaofvoices/darklua/pull/194))
* fix generators that creates spaces when writing field expressions, function statements and field-types ([#193](https://github.com/seaofvoices/darklua/pull/193))

## 0.13.0

* add `convert` command to convert data files (`json`, `json5`, `yaml` and `toml`) into Lua modules ([#178](https://github.com/seaofvoices/darklua/pull/178))
* remove previously generated files between process runs in watch mode ([#177](https://github.com/seaofvoices/darklua/pull/177))
* fix `remove_compound_assignment` rule to avoid copying variable tokens ([#176](https://github.com/seaofvoices/darklua/pull/176))
* add get link button to [try-it](https://darklua.com/try-it/) page ([#175](https://github.com/seaofvoices/darklua/pull/175))
* add rule to remove unused variables (`remove_unused_variable`). Fix issue with `rename_variables` where `self` variables and some cases of variable shadowing were not correctly renamed ([#172](https://github.com/seaofvoices/darklua/pull/172))

## 0.12.1

* fix `append_text_comment` rule to support multiline comments ([#167](https://github.com/seaofvoices/darklua/pull/167))

## 0.12.0

* fix relative parent paths when working with sourcemaps ([#164](https://github.com/seaofvoices/darklua/pull/164))
* add rule to remove assertions (`remove_assertions`) ([#163](https://github.com/seaofvoices/darklua/pull/163))
* add rule to remove Roblox profiling function calls (`remove_debug_profiling`) ([#162](https://github.com/seaofvoices/darklua/pull/162))
* add rule to remove interpolated strings (`remove_interpolated_string`) ([#156](https://github.com/seaofvoices/darklua/pull/156))
* add support for floor division (`//`) operator in binary expressions ([#155](https://github.com/seaofvoices/darklua/pull/155))
* add support for Luau interpolated strings ([#94](https://github.com/seaofvoices/darklua/pull/94))
* add rule to append text comments ([#141](https://github.com/seaofvoices/darklua/pull/141))

## 0.11.3

* fix undeclared modules variable when bundling ([#151](https://github.com/seaofvoices/darklua/pull/151))

## 0.11.2

* fix bundling to handle modules with early return calls. This change also makes the bundled code preserve the module require ordering ([#147](https://github.com/seaofvoices/darklua/pull/147))
* fix bundling to avoid token reference removal errors ([#146](https://github.com/seaofvoices/darklua/pull/146))
* fix `remove_types` rule to handle type cast of expressions that could return multiple values ([#142](https://github.com/seaofvoices/darklua/pull/142))

## 0.11.1

* fix type packs, function variadic types and variadic type packs ([#137](https://github.com/seaofvoices/darklua/pull/137))
* fix generic types on function types ([#136](https://github.com/seaofvoices/darklua/pull/136))
* fix table types to allow string literal property types ([#135](https://github.com/seaofvoices/darklua/pull/135))

## 0.11.0

* fix lost comment or spacing tokens in empty ASTs ([#132](https://github.com/seaofvoices/darklua/pull/132))
* add rule to remove Luau types ([#130](https://github.com/seaofvoices/darklua/pull/130))
* add support for Luau types ([#129](https://github.com/seaofvoices/darklua/pull/129))

## 0.10.3

* add watch argument (`--watch` or `-w`) to process command to automatically re-run darklua on file changes ([#123](https://github.com/seaofvoices/darklua/pull/123))

## 0.10.2

* fix crashes when bundling code and fix `remove_spaces` and `remove_comments` rule for missing cases (if expressions and numeric for) ([#119](https://github.com/seaofvoices/darklua/pull/119))

## 0.10.1

* make rojo sourcemap paths relative to its file location ([#117](https://github.com/seaofvoices/darklua/pull/117))

## 0.10.0

* convert configuration to snake case (this renames the `retain-lines` generator to `retain_lines`) ([#114](https://github.com/seaofvoices/darklua/pull/114))
* fix dense and readable string generator to escape extended ascii using backslashes ([#111](https://github.com/seaofvoices/darklua/pull/111))
* fix number parsing to support underscore after decimal point (like `0._123`) ([#110](https://github.com/seaofvoices/darklua/pull/110))
* add rule to convert require modes (from paths to Roblox instances) ([#107](https://github.com/seaofvoices/darklua/pull/107))
* fix number parsing to support underscores before `x` in hexadecimal number and before `b` in binary numbers ([#103](https://github.com/seaofvoices/darklua/pull/103))
* add bundling with path require mode ([#97](https://github.com/seaofvoices/darklua/pull/97))
* upgrade full-moon parser to 0.18.1 ([#100](https://github.com/seaofvoices/darklua/pull/100))
* enable stacker feature on full-moon to avoid stack overflows on large input ([#109](https://github.com/seaofvoices/darklua/pull/109))

## 0.9.0

* improve `convert_index_to_field` to refactor table entries ([#88](https://github.com/seaofvoices/darklua/pull/88))
* fix `remove_nil_declaration` ([#84](https://github.com/seaofvoices/darklua/pull/84))
* upgrade CLI library (mostly changes the help messages format) ([#83](https://github.com/seaofvoices/darklua/pull/83))
* add rule to remove compount assignments ([#78](https://github.com/seaofvoices/darklua/pull/78))
* enhance `remove_unused_if_branch` to process if expressions ([#77](https://github.com/seaofvoices/darklua/pull/77))
* remove possible panic in AST parsing ([#74](https://github.com/seaofvoices/darklua/pull/74))
* fix large AST parsing issue ([#73](https://github.com/seaofvoices/darklua/pull/73))
* refactor ParserError into an opaque struct (instead of an enum) ([#71](https://github.com/seaofvoices/darklua/pull/71))
* refactor darklua frontend ([#69](https://github.com/seaofvoices/darklua/pull/69)):
  * the `--config-path` argument of the `minify` command was removed
  * the configuration file does not accept the `column_span` field anymore (use the [`generator` field](https://darklua.com/docs/generators/) instead)
  * darklua can now also read `.luau` files

## 0.8.0

* update configuration file ([!60](https://gitlab.com/seaofvoices/darklua/-/merge_requests/60))
* add rule to remove statements after a do blocks returns early ([!59](https://gitlab.com/seaofvoices/darklua/-/merge_requests/59))
* fix readable formatter to put a space after `return` keywords ([!58](https://gitlab.com/seaofvoices/darklua/-/merge_requests/58))
* fix the `remove_nil_declaration` to also pop commas correctly ([!57](https://gitlab.com/seaofvoices/darklua/-/merge_requests/57))
* fix bug where filtering statements of a block would panic when there were missing semicolons ([!56](https://gitlab.com/seaofvoices/darklua/-/merge_requests/56))
* add rule to remove unnecessary `nil` values in local assignments ([!54](https://gitlab.com/seaofvoices/darklua/-/merge_requests/54))
* enhance the `compute_expression` rule to remove left side of binary `and` or `or` expressions when they always return the right side and they don't have side effects ([!53](https://gitlab.com/seaofvoices/darklua/-/merge_requests/53))
* add support for if expressions ([!51](https://gitlab.com/seaofvoices/darklua/-/merge_requests/51))
* add function to get all valid rule names ([!46](https://gitlab.com/seaofvoices/darklua/-/merge_requests/46))

## 0.7.0

* add `include_functions` property to `rename_variables` to prevent function name renaming and remove `group_local_assignment` and `convert_local_function_to_assign` from default rules ([!44](https://gitlab.com/seaofvoices/darklua/-/merge_requests/44))
* add `env` property to `inject_global_value` to inject an environment variable value ([!43](https://gitlab.com/seaofvoices/darklua/-/merge_requests/43))
* fix command line tracing logs for planned work ([!42](https://gitlab.com/seaofvoices/darklua/-/merge_requests/42))
* fix extra space generated with retain-lines generator on field expressions ([!41](https://gitlab.com/seaofvoices/darklua/-/merge_requests/41))
* enhance the `compute_expression` rule by processing `<`, `<=`, `>` and `>=` operators ([!40](https://gitlab.com/seaofvoices/darklua/-/merge_requests/40))
* enhance the `compute_expression` rule by processing parentheses expressions ([!39](https://gitlab.com/seaofvoices/darklua/-/merge_requests/39))
* add rule to convert index expression to field expression ([!36](https://gitlab.com/seaofvoices/darklua/-/merge_requests/36))
* add logging to time processing steps ([!35](https://gitlab.com/seaofvoices/darklua/-/merge_requests/35))
* add rule to remove spaces ([!34](https://gitlab.com/seaofvoices/darklua/-/merge_requests/34))
* add rule to remove comments ([!33](https://gitlab.com/seaofvoices/darklua/-/merge_requests/33))
* fix block mutations to handle semicolon tokens ([!32](https://gitlab.com/seaofvoices/darklua/-/merge_requests/32))
* enhance the `compute_expression` rule by improving the evaluation of binary and unary expressions ([!31](https://gitlab.com/seaofvoices/darklua/-/merge_requests/31))

## 0.6.1

* enhance the `inject_global_value` rule to work also from the global table (`_G`) ([!30](https://gitlab.com/seaofvoices/darklua/-/merge_requests/30))

## 0.6.0

* add new generator that retains line numbers ([!28](https://gitlab.com/seaofvoices/darklua/-/merge_requests/28))
* add token information to Block ([!27](https://gitlab.com/seaofvoices/darklua/-/merge_requests/27))
* add computation of binary expression using concat operator ([!25](https://gitlab.com/seaofvoices/darklua/-/merge_requests/25))
* fix bugs with string generation ([!26](https://gitlab.com/seaofvoices/darklua/-/merge_requests/26))
* add token information to AST ([!24](https://gitlab.com/seaofvoices/darklua/-/merge_requests/24))

## 0.5.0

* add support for Luau syntax by switching to [full-moon](https://github.com/Kampfkarren/full-moon) for parsing ([!18](https://gitlab.com/seaofvoices/darklua/-/merge_requests/18))

## 0.4.1

* add new rule traits ([!16](https://gitlab.com/seaofvoices/darklua/-/merge_requests/16))
* fix installation using `cargo install` command ([!17](https://gitlab.com/seaofvoices/darklua/-/merge_requests/17))

## 0.4.0

* add readable code generator ([!13](https://gitlab.com/seaofvoices/darklua/-/merge_requests/13))

## 0.3.6

* add rule to compute expressions ([!12](https://gitlab.com/seaofvoices/darklua/-/merge_requests/12))

## 0.3.5

* add rule to inject a value into a global variable ([!10](https://gitlab.com/seaofvoices/darklua/-/merge_requests/10))

## 0.3.4

* add rule to remove function call parentheses ([!11](https://gitlab.com/seaofvoices/darklua/-/merge_requests/11))

## 0.3.3

* add rule to convert local functions to local assignments ([!4](https://gitlab.com/seaofvoices/darklua/-/merge_requests/4))

## 0.3.2

* add rule to group local assignment statements ([!8](https://gitlab.com/seaofvoices/darklua/-/merge_requests/8))

## 0.3.1

* add rule to remove unused if branches ([!7](https://gitlab.com/seaofvoices/darklua/-/merge_requests/7))

## 0.3.0

* fix code generation bugs ([!9](https://gitlab.com/seaofvoices/darklua/-/merge_requests/9))

## 0.2.3

* add rule to remove unused while statements ([!6](https://gitlab.com/seaofvoices/darklua/-/merge_requests/6))

## 0.2.2

* add rule to remove method definitions ([!5](https://gitlab.com/seaofvoices/darklua/-/merge_requests/5))

## 0.2.1

* add rule to rename variables ([!2](https://gitlab.com/seaofvoices/darklua/-/merge_requests/2))

## 0.2.0

* add process command and rule to remove empty do statement ([!1](https://gitlab.com/seaofvoices/darklua/-/merge_requests/1))

## 0.1.0

* minify command
