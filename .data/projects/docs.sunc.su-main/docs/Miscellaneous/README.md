# Miscellaneous

The **Miscellaneous** library contains functions that do not belong to a specific category.

---

## What can you do?

With the Miscellaneous library, you can:

- **Identify** the current executor and version using [`#!luau identifyexecutor`](./identifyexecutor.md)
- **Send HTTP requests** and receive full responses with [`#!luau request`](./request.md)

---

## What does [`#!luau request`](./request.md) support?

The [`#!luau request`](./request.md) function supports a variety of features:

- Custom HTTP methods (`GET`, `POST`, `PATCH`, `PUT`, `DELETE`)
- Request and response headers
- Request body and cookies
- Built-in executor identification headers, such as `PREFIX-User-Identifier` and `PREFIX-Fingerprint`

---

## What can't you do?

- [`#!luau request`](./request.md) is **synchronous** and yields until the server responds - it's not suitable for parallel messaging.
- Some executors may restrict access to external domains (such as the Roblox API for account safety purposes) or block specific methods for security reasons.
- [`#!luau identifyexecutor`](./identifyexecutor.md) should never be relied on as a secure identifier - it's for informational purposes only.
