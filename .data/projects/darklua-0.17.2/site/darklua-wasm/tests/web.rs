//! Test suite for the Web and headless browsers.

#![cfg(target_arch = "wasm32")]
extern crate wasm_bindgen_test;
use wasm_bindgen_test::*;

use wasm_bindgen::JsValue;

wasm_bindgen_test_configure!(run_in_browser);

#[wasm_bindgen_test]
fn process_empty_code() {
    assert_eq!(
        darklua_wasm::process_code("", JsValue::undefined()).unwrap(),
        ""
    );
}
