local serde = require("@lune/serde")

local Config = {
    generator = {
        name = "dense",
        column_span = 120,
    },

    rules = {
        "convert_index_to_field",
        "compute_expression",
        "group_local_assignment",
        "filter_after_early_return",
        "remove_comments",
        "remove_empty_do",
        "remove_function_call_parens",
        "remove_nil_declaration",
        "remove_method_definition",
        "remove_spaces",
        "remove_unused_if_branch",
        "remove_unused_while",

        {
            rule = "rename_variables",
            include_functions = true,
        },
    },
}

return serde.encode("json", Config, false)
