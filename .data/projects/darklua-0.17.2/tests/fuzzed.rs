#![cfg(not(coverage))]

// this test file is for collecting fuzzed Lua code that were causing issues that have been fixed

macro_rules! generate_tests {
    ($( $name:ident =>  $file_name:literal ),* $(,)?) => {
        $(
            #[test]
            fn $name() {
                use darklua_core::Parser;

                let input = include_str!($file_name);

                match Parser::default().parse(&input) {
                    Ok(_block) => (),
                    Err(error) => panic!("could not parse content: {:?}\ncontent:\n{}", error, input),
                }

            }
        )*
    }
}

generate_tests!(
    ast_conversion_stackoverflow_in_debug => "./fuzzed_test_cases/a.lua",
    full_moon_parser_stackoverflow => "./fuzzed_test_cases/full_moon_stackoverflow.lua",
);
