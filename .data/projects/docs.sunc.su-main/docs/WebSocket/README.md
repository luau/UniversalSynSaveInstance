# WebSocket class

!!! warning "This is a WebSocket client only, meaning you won't be able to create a server with this library."

!!! info "The sUNC test explicitly checks for `wss` (secure) support."

The `#!luau WebSocket` class provides a lightweight interface for establishing and working with WebSocket connections. It allows scripts to **send** and **receive** messages over a persistent connection to a [WebSocket](https://en.wikipedia.org/wiki/WebSocket) server.

---

## Constructor

Attempts to create a new connection to the provided URL. The URL must be a valid WebSocket server URL, typically starting with `ws://` (unsecure) or `wss://` (secure).

```luau
function WebSocket.connect(url: string): WebSocket
```

## Parameters

| Parameter     | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `#!luau url`  | A WebSocket URL.|

---

## Events

Signals that allow you handle events that occur during the WebSocket's lifetime, such as opening, receiving messages, or closing.

| Event         | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `#!luau OnMessage(message: string): ()`  | Triggered when a message is received over the WebSocket connection.|
| `#!luau OnClose(): ()`                   | Triggered when the WebSocket connection closes.  |

## Methods

| Method        | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `#!luau Send(message: string): ()` | Sends a message over the WebSocket connection.    |
| `#!luau Close(): ()`                     | Closes the WebSocket connection.                 |

---

## Examples

### Using the `#!luau OnMessage` event, and `#!luau Send` method

```luau title="Responding to incoming messages" linenums="1"
local ws = WebSocket.connect("wss://echo.websocket.events")
ws.OnMessage:Connect(function(message)
    print(message)
end)
ws:Send("Hello") -- Output: Hello
```

---

### Using the `#!luau OnClose` event, and `#!luau Close` method

```luau title="Receive a closing message and catch it via OnClose" linenums="1"
local ws = WebSocket.connect("wss://echo.websocket.events")
ws.OnClose:Connect(function()
    print("Closed")
end)
ws:Close() -- Output: Closed
```
