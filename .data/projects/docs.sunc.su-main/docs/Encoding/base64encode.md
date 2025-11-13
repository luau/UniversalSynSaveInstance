# `base64encode`

`#!luau base64encode` encodes a string with [Base64](https://en.wikipedia.org/wiki/Base64) encoding.

```luau
function base64encode(data: string): string
```

## Parameters

| Parameter     | Description           |
| ------------- | --------------------- |
| `#!luau data` | The string to encode. |

---

## Example

```luau title="Encoding a string with Base64" linenums="1"
print(base64encode("DummyString\0\2")) -- Output: RHVtbXlTdHJpbmcAAg==
```

<!-- TODO: in the future, make a note that hopefully we should explicitly check for ONLY base64xyz, rather than base64_xyz or crypt.xyz -->