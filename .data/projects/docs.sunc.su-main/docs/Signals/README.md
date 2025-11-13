# Signals

The **Signals** library provides functions for inspecting and manipulating [`RBXScriptSignal`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) and [`RBXScriptConnection`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) objects.

---

## What is a signal?

A [signal](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal) in Roblox is an event emitter - an object that can have functions connected to it, which are triggered when something happens. For example, [`Part.Touched`](https://create.roblox.com/docs/reference/engine/classes/BasePart#Touched) is a signal that fires when something touches a part.

Signals are backed by objects called **connections**, which are instances of an [`RBXScriptConnection`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection).

Exploits will return their own [custom connection object](./Connection.md) when using `#!luau getconnections`.

---

## What can you do?

With the Signals library, you can:

- **Get all connections** attached to a signal using [`#!luau getconnections`](./getconnections.md).
- **Fire** a signal's Luau connections using [`#!luau firesignal`](./firesignal.md).
- **Replicate signals to the server** with [`#!luau replicatesignal`](./replicatesignal.md), if supported by the signal.

For a list of known replicable signals, click [this](https://rubis.app/markdown-focus/?scrap=AIOzG1Di7NSLADKE&accent=a460f9).
