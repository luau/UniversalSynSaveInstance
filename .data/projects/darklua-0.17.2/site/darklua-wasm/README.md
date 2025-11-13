<h1>darklua-wasm</h1>

## Setup

- [install Rust](https://www.rust-lang.org/tools/install)
- [`wasm-pack` installer](https://rustwasm.github.io/wasm-pack/installer/)

## 🛠️ Build with `wasm-pack build`

```
wasm-pack build -t web
```

## 🔬 Test in Headless Browsers with `wasm-pack test`

```
wasm-pack test --headless --firefox
```

You can run the tests with `chrome` or `safari` instead of `firefox` too.

There is also a separate package (`javascript-tests`) that runs tests using [`Jest`](jestjs.io/) on the wasm package. To run those tests do:

```bash
cd javascript-tests
npm install
```

Build the wasm package for nodejs with:

```bash
npm run build
```

And finally, run tests with:

```bash
npm run test
```

## 🎁 Publish to NPM with `wasm-pack publish`

```
wasm-pack publish
```

## 🔋 Batteries Included

- [`wasm-bindgen`](https://github.com/rustwasm/wasm-bindgen) for communicating
  between WebAssembly and JavaScript.
- [`console_error_panic_hook`](https://github.com/rustwasm/console_error_panic_hook)
  for logging panic messages to the developer console.
