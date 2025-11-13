# `getfunctionhash`

`#!luau getfunctionhash` returns the ***hex-represented*** [SHA384 hash](https://en.wikipedia.org/wiki/SHA-2) of a provided function's instructions (code) and constants.

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), since C closures have no reliable information to hash. The error should be something along the lines of `lua function expected`

!!! info "Notes on `#!luau getfunctionhash`"

    In order to have reliable knowledge over what the function changes, `constants` should **also** be added to the hash alongside the `l.p->code`. Add the constants at the beginning of the instructions, and hash that.

    We suggest following [this implementation](https://rubis.app/view?scrap=mwDweOS6zirsPJtc&type=cpp) in order to keep the same functionality across multiple executors, since it will be more convenient for the users not having to change their hashes if they do migrate to a different executor.

    Full credits go to Dottik and Ragnar regarding the source provided above.

```luau
function getfunctionhash(functionToHash: (...any) -> (...any)): string
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau functionToHash` | The function to retrieve the hash of. |

---

## Example

```luau title="Checking the SHA384 hash of functions with getfunctionhash" linenums="1"
local function is_sha384_hex(hash)
    return #hash == 96 and hash:match("^[0-9a-fA-F]+$") ~= nil
end

local dummy_function_0 = function() end
local dummy_function_1 = function(...) end
local dummy_function_2 = function() end
local dummy_function_3 = function() return "Constant" end
local dummy_function_4 = function() return "Constant2" end

print(is_sha384_hex(getfunctionhash(dummy_function_0))) -- Output: true
print(getfunctionhash(dummy_function_0) == getfunctionhash(dummy_function_1)) -- Output: false
print(getfunctionhash(dummy_function_0) == getfunctionhash(dummy_function_2)) -- Output: true
print(getfunctionhash(dummy_function_3) == getfunctionhash(dummy_function_4)) -- Output: false
```
