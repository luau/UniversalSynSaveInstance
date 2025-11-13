---
title: Generators
description: How to customize Lua code generation
group: Configuration
order: 3
---

When outputting code, darklua uses a generator to convert its internal representation of code into actual Lua code in text. You can configure how the code is written by choosing which generator to use.

## retain_lines

This is the **default generator** and the most useful one. This generator will attempt to keep the line numbers from the original code in the generated code.

### Example

Let's take this snippet of code.

```lua
local function giveReason(message)
    if _G.DEBUG_MODE then
        return message .. " - reason: " .. getReason()
    else
        return message
    end
end
```

If darklua processes this code and inline the `_G.DEBUG_MODE` as `true`, remove the if statement and the spaces, the `retain_lines` generator will keep what's left to fit on the same line. It will produce the following code:

```lua
local function giveReason(message)

return message.." - reason: "..getReason()



end
```

You can specify this generator in the configuration file with:

```json5
{
  generator: "retain_lines",
}
```

## dense

This generator will minimize the amount of spaces used when producing Lua code. It will fill each line up to a certain number of characters. By default, it will maximize each line to 80 characters.

The dense generator does not output comments from the original code.

You can specify this generator in the configuration file with:

```json5
{
  generator: "dense",
}
```

To configure the maximum column width parameter, use the object notation for the generator value:

```json5
{
  generator: { name: "dense", column_span: 50 },
}
```

## readable

This generator will produce Lua code that is, as the name suggest, readable at best. Darklua does not aim to be used as a formatter, so the results may not be optimal.

Compared to the retain_lines generator, this one will completely re-generate the code and will not even attempt to keep the line numbers.

The readable generator does not output comments from the original code.

You can specify this generator in the configuration file with:

```json5
{
  generator: "readable",
}
```

To configure the maximum column width parameter, use the object notation for the generator value:

```json5
{
  generator: { name: "readable", column_span: 50 },
}
```
