# Widget API Message Types

## `#!ts sunc-widget:loadScrap`

Loads a test result from the provided `scrapId` and `accessKey`.

```ts
type LoadScrapPayload = {
  scrapId: string;
  key: string;
};
```

### Parameters

| Parameter      | Description                               |
| -------------- | ----------------------------------------- |
| `#!ts scrapId` | The unique ID of the test result.         |
| `#!ts key`     | The access key required to view the test. |

### Example

```ts title="Load a test result" linenums="1"
iframe.contentWindow.postMessage({
  type: "sunc-widget:loadScrap",
  payload: {
    scrapId: "abc123XYZ",
    key: "someAccessKey"
  }
}, "https://sunc.rubis.app");

```

---

## `#!ts sunc-widget:setTheme`

Updates the colour theme of the widget to match your branding. Any missing fields will fall back to defaults.

```ts
type ThemePayload = {
  dark?: string;
  light?: string;
  lighter?: string;

  sunc?: string;
  suncLighter?: string;

  grey?: string;
  lightText?: string;

  success?: string;
  failure?: string;

  useDarkLogo?: boolean;
};
```

### Parameters

| Parameter          | Type          | Description                                                                                                                                                | Default         |
| ------------------ | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `#!ts dark`        | `#!ts string` | Primary background colour for the entire widget.                                                                                                           | `#!css #12121c` |
| `#!ts light`       | `#!ts string` | The secondary colour used for function cards and the summary on the right.                                                                                 | `#!css #1b1b2a` |
| `#!ts lighter`     | `#!ts string` | Colour used for the information bar at the top.                                                                                                            | `#!css #1c1b28` |
| `#!ts sunc`        | `#!ts string` | Brand accent colour to be used by the info text, circle stroke and passed amount.                                                                          | `#!css #b7a0f6` |
| `#!ts suncLighter` | `#!ts string` | Used for hover effects, like the Numelon link at the bottom.                                                                                               | `#!css #d1b9ff` |
| `#!ts grey`        | `#!ts string` | Used for muted UI elements like search input icons, placeholder text, and metadata titles in the summary area.                                             | `#!css #aaaaaa` |
| `#!ts lightText`   | `#!ts string` | Main readable text colour - used in the widget "Test Result" title, percentage label inside ring, and metadata values in the summary area and button text. | `#!css #e0e0e0` |
| `#!ts success`     | `#!ts string` | Colour used to indicate passed tests.                                                                                                                      | `#!css #22c55e` |
| `#!ts failure`     | `#!ts string` | Colour used for general failures, notably in the list of functions but also for widget errors and the "x tests failed" text.                               | `#!css #ef4444` |
| `#!ts useDarkLogo` | `#!ts string` | Whether to use a light-friendly (dark) version of the sUNC logo. Set to `#!ts false` if you are using a light theme.                                       | `#!ts true`     |

### Clarification on colour names

You may have noticed that the colour names (like `dark`, `light`, `lighter`) do not follow typical design conventions like `primary`/`secondary`/`tertiary`. In hindsight, they might seem a bit misleading at first glance - however they are named based on **where they are used** in the widget, not their strict visual roles.

The image below visually presents parts of the SEW with the colour names they are associated with - and the names start to make much more sense. For example, `dark` corresponds to the deepest background colour in the very background of the page, `light` is the colour of the main title bar at the top where the sUNC logo, and `lighter` is literally a slightly lighter colour for the information bar below the title bar, et cetera:

![Visual overview of the colours for the sUNC Embeddable Widget](./assets/SEW-colours.jpg)

### Logo Comparison

The sUNC logo shown in the top left of the widget can be customised depending on whether you intend to use a light theme or a dark theme. This is important to get right, otherwise you will have horrible contrast in the title bar of the widget.

If `#!ts useDarkLogo` is omitted entirely, then the widget defaults to `#!ts true` - it uses the dark logo by default.

#### `#!ts useDarkLogo: false`

When `#!ts useDarkLogo` is set to `#!ts false`, a light variant is used. This is perfect for when the background is dark as it provides enough contrast.

**Use this when you have a dark theme.**

![sUNC Full Light Logo](https://sunc.su/sunc-full.png)

#### `#!ts useDarkLogo: true`

When `#!ts useDarkLogo` is set to `#!ts true`, a dark variant is used. This is perfect for when the background is light as it provides enough contrast.

**Use this when you have a light theme.**

![sUNC Full Light Logo](https://sunc.su/sunc-full-dark.png?useNew)

### Examples

#### Example 1

??? info "Preview of the Creamy Pink theme"
    Not Initialised
    ![sUNC Widget Creamy Pink Theme, Not Initialised](./assets/creamypink-notinit.jpg)

    Spoofed
    ![sUNC Widget Creamy Pink Theme, Spoofed](./assets/creamypink-spoofed.jpg)

    Result
    ![sUNC Widget Creamy Pink Theme, Result](./assets/creamypink-result.jpg)

```ts title="Apply a light, creamy pink theme" linenums="1"
iframe.contentWindow.postMessage({
    type: "sunc-widget:setTheme",

    payload: {
        dark: "#fff0f5",
        light: "#fffbfc",
        lighter: "#ffeeee",

        sunc: "#ff6aa0",
        suncLighter: "#ff9abe",

        grey: "#888",
        lightText: "#444",

        success: "#44c26a",
        failure: "#e74c3c",

        useDarkLogo: true // (1)
    }
}, "https://sunc.rubis.app");
```

1. Set this to `#!ts true` when using light background colours.

#### Example 2

??? info "Preview of the Electric Yellow theme"
    Not Initialised
    ![sUNC Widget Electric Yellow Theme, Not Initialised](./assets/electricyellow-notinit.jpg)

    Spoofed
    ![sUNC Widget Electric Yellow Theme, Spoofed](./assets/electricyellow-spoofed.jpg)

    Result
    ![sUNC Widget Electric Yellow Theme, Result](./assets/electricyellow-result.jpg)

```ts title="Applying a dark, electric yellow theme" linenums="1"
iframe.contentWindow.postMessage({
    type: "sunc-widget:setTheme",

    payload: {
        dark: "#0f0f12",
        light: "#1a1a20",
        lighter: "#26262f",

        sunc: "#ffe600",
        suncLighter: "#fff36b",

        grey: "#999999",
        lightText: "#eeeeee",

        success: "#4caf50",
        failure: "#ff4b5c",

        useDarkLogo: false // (1)
    }
}, "https://sunc.rubis.app");
```

1. Set this to `#!ts false` when using dark background colours.

#### Example 3

??? info "Preview of the Default theme"
    Not Initialised
    ![sUNC Widget Default Theme, Not Initialised](./assets/default-notinit.jpg)

    Spoofed
    ![sUNC Widget Default Theme, Spoofed](./assets/default-spoofed.jpg)

    Result
    ![sUNC Widget Default Theme, Result](./assets/default-result.jpg)

```ts title="Applying a dark, electric yellow theme" linenums="1"
iframe.contentWindow.postMessage({
    type: "sunc-widget:setTheme",

    payload: {} // (1)
}, "https://sunc.rubis.app");
```

1. To revert back to the default theme, one may simply pass a message with an empty payload using the `postMessage` API.
