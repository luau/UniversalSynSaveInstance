# Debug

The **Debug** library offers powerful tools for inspecting and modifying Luau functions at a bytecode level.

It allows you to access constants, upvalues, stack frames, and internal structures of functions that would otherwise be hidden - making it especially useful for reverse engineering and hooking.

---

## What can you do?

With the Debug library, you can:

- **Inspect** constants with [`#!luau debug.getconstants`](./getconstants.md), [`#!luau debug.getconstant`](./getconstant.md)
- **Modify** constants using [`#!luau debug.setconstant`](./setconstant.md)
- **Access** upvalues using [`#!luau debug.getupvalues`](./getupvalues.md) and [`#!luau debug.getupvalue`](./getupvalue.md)
- **Replace** upvalues with [`#!luau debug.setupvalue`](./setupvalue.md)
- **Read** or **write** values from a stack frame, using [`#!luau debug.getstack`](./getstack.md) and [`#!luau debug.setstack`](./setstack.md)
- **List** or **retrieve** function prototypes, using [`#!luau debug.getprotos`](./getprotos.md) and [`#!luau debug.getproto`](./getproto.md)

---

## What can't you do?

- You cannot access C closures with this library, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print)
