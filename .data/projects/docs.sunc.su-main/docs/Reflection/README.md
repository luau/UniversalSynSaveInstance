# Reflection

The **Reflection** library allows access to and manipulation of hidden or non-scriptable properties of [Instances](https://create.roblox.com/docs/reference/engine/classes/Instance) and internal execution context. It is primarily used to bypass standard Luau restrictions in controlled environments.

---

## What can you do?

With the Reflection library, you can:

- **Read** hidden instance properties using [`#!luau gethiddenproperty`](./gethiddenproperty.md)
- **Write** to hidden instance properties with [`#!luau sethiddenproperty`](./sethiddenproperty.md)
- **Toggle and check** scriptability of properties using [`#!luau setscriptable`](./setscriptable.md) and [`#!luau isscriptable`](./isscriptable.md).
- **Elevate** thread permissions with [`#!luau setthreadidentity`](./setthreadidentity.md)
- **Query** the current thread's permission level with [`#!luau getthreadidentity`](./getthreadidentity.md)

These identities are internally refered to as [security context levels](https://github.com/Pseudoreality/Roblox-Identities/), and determine the permissions granted to a thread.

---

## What can't you do?

While powerful, the Reflection library carries **detection risks** in sensitive environments:

- [`#!luau setscriptable`](./setscriptable.md) is detectable by games that check for unusual access.
- Using these methods irresponsibly may break core game logic or introduce unintended side effects.
