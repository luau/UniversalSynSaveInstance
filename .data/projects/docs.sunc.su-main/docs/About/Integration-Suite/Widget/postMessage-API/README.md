# `postMessage`

`#!ts postMessage` sends a typed message to a sUNC Widget `#!html <iframe>`, allowing you to dynamically interact with the widget by sending messages from your host page.

```ts
type SuncWidgetMessage =
  | {
    type: "sunc-widget:loadScrap";
    payload: {
      scrapId: string;
      key: string;
    };
  }
  | {
    type: "sunc-widget:setTheme";
    payload: {
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
  };

function postMessage(message: SuncWidgetMessage, targetOrigin: string): void;
```

## Parameters

| Parameter           | Description                                                                    |
| ------------------- | ------------------------------------------------------------------------------ |
| `#!ts message`      | The structured [message](./MessageType.md) to send to the sUNC widget. |
| `#!ts targetOrigin` | The expected origin of the iframe, which should always be `#!ts "https://sunc.rubis.app"`. |

---

## Notes

- `#!ts targetOrigin` **must exactly match** the origin of the `#!html <iframe>` source to avoid your message being ignored - this should always be `#!ts "https://sunc.rubis.app"`.
- The widget ignores unknown or malformed message types.
- Missing theme properties in `#!ts sunc-widget:setTheme` will fall back to the default sUNC colour palette.
