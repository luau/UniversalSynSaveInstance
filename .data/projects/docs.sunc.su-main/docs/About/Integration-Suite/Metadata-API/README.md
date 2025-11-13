# Metadata API

The **sUNC Metadata API (SMA)** provides machine-friendly JSON datasets containing metadata for every documented sUNC function and library.

This API is designed for integration into apps, extensions, custom documentation browsers, or anywhere you want access to sUNC data programmatically. For example, we use the mini version in our test results viewer and the jumbo version for our Discord bot, sunc-chan.

**You can access it [here](https://docs.sunc.su/api).**

---

## Versions

You can choose between two formats depending on your needs.

### Mini Version (~10KB)

A lightweight object which maps function names to their descriptions.

---

### Jumbo Version (~45KB)

A fully structured, enriched metadata dump including:

- Function signatures
- Parameter names and descriptions
- Type information
- Library overviews
- Direct links to the official documentation

---

## Format

Both versions are served as `application/json` and are **automatically kept in sync** with the official sUNC documentation.
You do not need an API key or authentication to use this API.

---

## Example Usage

```js title="Fetching the mini version to print clonefunction's description"
const res = await fetch("https://docs.sunc.su/api/mini.json");
const metadata = await res.json();

console.log(metadata["clonefunction"]);
// Output: "clonefunction creates and returns a new function that has the exact same behaviour as the passed function."
```
