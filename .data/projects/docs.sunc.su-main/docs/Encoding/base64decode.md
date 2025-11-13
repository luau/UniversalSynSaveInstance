# `base64decode`

`#!luau base64decode` decodes a [Base64-encoded](https://en.wikipedia.org/wiki/Base64) string back into its original form.

```luau
function base64decode(data: string): string
```

## Parameters

| Parameter     | Description                          |
| ------------- | ------------------------------------ |
| `#!luau data` | The Base64-encoded string to decode. |

---

## Example

```luau title="Decoding a Base64-encoded string" linenums="1"
local bytecode = game:HttpGet("https://api.rubis.app/v2/scrap/zuxQZuM9Tnl5MRbo/raw")
writefile("sound.mp3", base64decode(bytecode)) -- This file should be a valid and working MP3 file.
```

<!-- TODO: in the future, make a note that hopefully we should explicitly check for ONLY base64xyz, rather than base64_xyz or crypt.xyz -->