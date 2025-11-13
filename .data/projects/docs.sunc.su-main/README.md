# [sUNC Documentation](https://docs.sunc.su)

[![Publish to docs.sunc.su](https://github.com/sUNC-Utilities/docs.sunc.su/actions/workflows/publish.yml/badge.svg)](https://github.com/sUNC-Utilities/docs.sunc.su/actions/workflows/publish.yml)

Welcome to the repository for sUNC's online documentation.
Documentation is hosted at <https://docs.sunc.su> and it aims to replace the legacy way of simply documenting via markdown in the [old documentation repository](https://github.com/sUNC-Utilities/Global-Functions-Documentation).

## What is sUNC?

Please view the README about sUNC at [docs/About/what-is-sunc.md](./docs/About/what-is-sunc.md) or look at the entire ["About" directory](./docs/About/).

## Contributing

Please make a **PULL REQUEST** with your changes so that they can be reviewed.

In general, commits and pushes (or any interaction with the main branch) is disabled for all users, including administrators. This aims to reduce commit conflicts - please use pull requests instead so that changes can be discussed.

<details>
<summary>Internally working on the documentation system</summary>

If you are internally working on the actual documentation **platform** itself, please use a Python Virtual Environment (venv).

```sh
python3 -m venv venv
```

After which you must install the requirements of the project using `pip`.

```sh
python3 -m pip install -r requirements.txt
```

Once all dependencies are installed, you may see a preview of your work using `mkdocs serve`.
  
</details>
