return {
    private = true,
    name = "Richy-Z/sUNC-documentation-parser",
    version = "2.0.1",
    description = "A parser for the docs.sunc.su GitHub repository",
    tags = { "docs.sunc.su", "documentation", "parser", "sUNC" },
    license = "MIT",
    author = { name = "Richard Ziupsnys", email = "hello@richy.lol" },
    homepage = "https://github.com/sUNC-Utilities/docs.sunc.su/tree/main/parser",
    dependencies = {
        "luvit/fs",
        "luvit/json",

        "luvit/coro-http",
        "luvit/secure-socket",
        "Richy-Z/string-extensions"
    },
    files = {
        "!*"
    }
}
