use wasm_bindgen::prelude::wasm_bindgen;

pub fn set_panic_hook() {
    // When the `console_error_panic_hook` feature is enabled, we can call the
    // `set_panic_hook` function at least once during initialization, and then
    // we will get better error messages if our code ever panics.
    //
    // For more details see
    // https://github.com/rustwasm/console_error_panic_hook#readme
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}

#[wasm_bindgen]
pub struct Configuration {
    column_width: usize,
    line_endings: String,
    indentation_type: String,
    indentation_width: usize,
    quote_style: String,
}

#[wasm_bindgen]
impl Configuration {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        Self::default()
    }

    #[wasm_bindgen(getter)]
    pub fn column_width(&self) -> usize {
        self.column_width
    }

    #[wasm_bindgen(getter)]
    pub fn line_endings(&self) -> String {
        self.line_endings.clone()
    }

    #[wasm_bindgen(getter)]
    pub fn indentation_type(&self) -> String {
        self.indentation_type.clone()
    }

    #[wasm_bindgen(getter)]
    pub fn indentation_width(&self) -> usize {
        self.indentation_width
    }

    #[wasm_bindgen(getter)]
    pub fn quote_style(&self) -> String {
        self.quote_style.clone()
    }

    #[wasm_bindgen(setter)]
    pub fn set_column_width(&mut self, column_width: usize) {
        self.column_width = column_width;
    }

    #[wasm_bindgen(setter)]
    pub fn set_line_endings(&mut self, line_endings: String) {
        self.line_endings = line_endings;
    }

    #[wasm_bindgen(setter)]
    pub fn set_indentation_type(&mut self, indentation_type: String) {
        self.indentation_type = indentation_type;
    }

    #[wasm_bindgen(setter)]
    pub fn set_indentation_width(&mut self, indentation_width: usize) {
        self.indentation_width = indentation_width;
    }

    #[wasm_bindgen(setter)]
    pub fn set_quote_style(&mut self, quote_style: String) {
        self.quote_style = quote_style;
    }
}

impl Default for Configuration {
    fn default() -> Self {
        Self {
            column_width: 100,
            line_endings: "unix".to_owned(),
            indentation_type: "tabs".to_owned(),
            indentation_width: 4,
            quote_style: "double".to_owned(),
        }
    }
}
