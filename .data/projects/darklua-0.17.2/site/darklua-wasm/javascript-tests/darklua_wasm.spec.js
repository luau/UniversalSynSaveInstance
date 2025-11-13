const {
  process_code,
  get_all_rule_names,
} = require("darklua-wasm/darklua_wasm")

test("process empty string", () => {
  expect(process_code("")).toEqual("")
})

test("process with default rules", () => {
  expect(process_code("return 1 + 1")).toEqual("return 2")
})

test("process with no rules", () => {
  expect(process_code("return 1 + 1", { rules: [] })).toEqual("return 1 + 1")
})

test("process with no rules (string config)", () => {
  expect(process_code("return 1 + 1", "{ rules: [] }")).toEqual("return 1 + 1")
})

test("process and inject global", () => {
  const options = {
    rules: [
      { rule: "inject_global_value", identifier: "CONSTANT", value: true },
    ],
  }
  expect(process_code("return CONSTANT", options)).toEqual("return true")
})

test("`get_all_rule_names` returns an array", () => {
  const names = get_all_rule_names()
  expect(names).toEqual(expect.any(Array))
  expect(names.length).toBeGreaterThan(10)
})
