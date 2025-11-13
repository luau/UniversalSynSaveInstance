# sUNC Documentation

Welcome to the official documentation for **sUNC** - senS' Unified Naming Convention.

This documentation site serves as the central knowledge base for understanding what sUNC is, how it works, and how to contribute to the project.

Whether you're an executor developer, a curious tester, or a contributor helping document functions, you're in the right place!

!!! info "Not every original UNC function is tested!"

    This documentation covers ***only*** the functions that are **actively tested by the sUNC script**. If a function is not listed here, then it is likely not part of our standard.

    Over time, sUNC has largely diverged from the original UNC to become better and shaped by executor developers and users, hence why some functions have been deprecated/removed and others may have been added.

---

## 📚 Explore the Docs

- [What is sUNC?](./About/what-is-sunc.md)
- [How sUNC Test Results Work](./About/test-results.md)
- [How to contribute](./About/contributing.md)

## 📜 The script

```luau title="The sUNC testing script" linenums="1"
getgenv().sUNCDebug = {
    ["printcheckpoints"] = false,
    ["delaybetweentests"] = 0,
    ["printtesttimetaken"] = false,
}

loadstring(game:HttpGet("https://script.sunc.su/"))() -- (1)
```

1. This loadstring uses [script.sunc.su](https://script.sunc.su/), which is an official mirror of the sUNC script. If the mirror is down or you would like to use the original loadstring, visit [this](https://gitlab.com/sens3/nebunu/-/raw/main/HummingBird8's_sUNC_yes_i_moved_to_gitlab_because_my_github_acc_got_brickedd/sUNCm0m3n7.lua).

Please note that as of sUNC v2.0, the test now only runs inside of the official testing game. The latest one may be retrieved from [our Discord server](https://discord.gg/FNNfTUpFYv).

---

Thank you for being here.
