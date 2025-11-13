use darklua_core::rules::{ConvertLuauNumber, Rule};

test_rule!(
    convert_luau_number,
    ConvertLuauNumber::default(),
    binary_literal_lowercase("local a = 0b10101010")
        => "local a = 0xAA",
    binary_literal_uppercase("local b = 0B11001100")
        => "local b = 0xCC",
    binary_literal_lowercase_with_underscores("local c = 0b_1111_0000")
        => "local c = 0xF0",
    binary_literal_uppercase_with_underscores("local d = 0B_0000_1111")
        => "local d = 0x0F",
    binary_literal_with_multiple_underscores("local e = 0b__________1010_1010")
        => "local e = 0xAA",
    decimal_with_underscores("local a = 1_048_576")
        => "local a = 1048576",
    decimal_with_multiple_underscores("local a1 = 1___048__576__")
        => "local a1 = 1048576",
    hexadecimal_with_underscores("local b = 0xFFFF_FFFF")
        => "local b = 0xFFFFFFFF",
    hexadecimal_lowercase("local c = 0xabcd_ef12")
        => "local c = 0xabcdef12",
    hexadecimal_mixed_case("local d = 0xA1b2_C3d4")
        => "local d = 0xA1b2C3d4",
    hexadecimal_single_underscore("local e = 0x1234_5678")
        => "local e = 0x12345678",
    hexadecimal_multiple_underscores("local f = 0x1___234__567")
        => "local f = 0x1234567",
    hexadecimal_leading_underscore("local g = 0x_DEAD_BEEF")
        => "local g = 0xDEADBEEF",
    hexadecimal_trailing_underscore("local h = 0xCAFE_BABE_")
        => "local h = 0xCAFEBABE",
    hexadecimal_small_number("local i = 0x1_2_3_4")
        => "local i = 0x1234",
    hexadecimal_zero("local j = 0x0_0_0_0")
        => "local j = 0x0000",
    hexadecimal_single_digit("local k = 0xF")
        => "local k = 0xF",
    hexadecimal_single_digit_with_underscore("local l = 0xF_")
        => "local l = 0xF",
    hexadecimal_two_digits("local m = 0xAB")
        => "local m = 0xAB",
    hexadecimal_three_digits("local n = 0x123")
        => "local n = 0x123",
    hexadecimal_four_digits("local o = 0xABCD")
        => "local o = 0xABCD",
    hexadecimal_six_digits("local p = 0x123___456")
        => "local p = 0x123456",
    hexadecimal_eight_digits("local q = 0x1234_5678")
        => "local q = 0x12345678",
    hexadecimal_ten_digits("local r = 0x12_34_56_78_9A")
        => "local r = 0x123456789A",
    hexadecimal_twelve_digits("local s = 0x123_456_789_ABC")
        => "local s = 0x123456789ABC",
);

#[test]
fn deserialize_from_object_notation() {
    json5::from_str::<Box<dyn Rule>>(
        r#"{
        rule: 'convert_luau_number',
    }"#,
    )
    .unwrap();
}

#[test]
fn deserialize_from_string() {
    json5::from_str::<Box<dyn Rule>>("'convert_luau_number'").unwrap();
}
