use darklua_core::{
    rules::{self, Rule},
    Configuration, Options,
};

mod bench_utils;

bench_utils::generate_bench!(roact, {
    resources = {
        "src" => bench_utils::roact_content("."),
    },
    options = {
        default_run => Options::new("src").with_configuration(Configuration::default()),
        dense_rewrite => Options::new("src").with_configuration(Configuration::empty()),
        minify => Options::new("src").with_configuration({
            let rules: Vec<Box<dyn Rule>> = vec![
                Box::<rules::RemoveSpaces>::default(),
                Box::<rules::RemoveComments>::default(),
                Box::<rules::ComputeExpression>::default(),
                Box::<rules::RemoveUnusedIfBranch>::default(),
                Box::<rules::RemoveUnusedWhile>::default(),
                Box::<rules::FilterAfterEarlyReturn>::default(),
                Box::<rules::RemoveEmptyDo>::default(),
                Box::<rules::RemoveMethodDefinition>::default(),
                Box::<rules::ConvertIndexToField>::default(),
                Box::<rules::RemoveNilDeclaration>::default(),
                Box::new(rules::RenameVariables::default().with_function_names()),
                Box::<rules::RemoveFunctionCallParens>::default(),
            ];

            rules.into_iter().fold(
                Configuration::empty()
                    .with_generator(darklua_core::GeneratorParameters::Dense { column_span: 80 }),
                |config, rule| config.with_rule(rule)
            )
        }),
    },
});

bench_utils::generate_bench!(crosswalk, {
    resources = {
        "src" => bench_utils::crosswalk_content("."),
        "debug-config.json5" =>
            include_str!("../bench_content/crosswalk/scripts/darklua/debug.json5"),
        "prod-config.json5" =>
            include_str!("../bench_content/crosswalk/scripts/darklua/prod.json5"),
    },
    options = {
        default_run => Options::new("src").with_configuration(Configuration::default()),
        dense_rewrite => Options::new("src").with_configuration(Configuration::empty()),
        debug_config => Options::new("src").with_configuration_at("debug-config.json5"),
        prod_config => Options::new("src").with_configuration_at("prod-config.json5"),
    },
});

criterion::criterion_group!(
    name = process;
    config = criterion::Criterion::default();
    targets = roact, crosswalk
);
criterion::criterion_main!(process);
