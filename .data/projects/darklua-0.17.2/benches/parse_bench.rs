fn parse_code(c: &mut criterion::Criterion) {
    let inputs = [
        (
            "Roact - Component.lua",
            include_str!("../bench_content/roact/src/Component.lua"),
        ),
        (
            "Roact - assign.lua",
            include_str!("../bench_content/roact/src/assign.lua"),
        ),
        (
            "React - ReactFiberWorkLoop.new.lua",
            include_str!("../bench_content/core-packages/modules/ReactReconciler-9c8468d8-8a7220fd/src/ReactFiberWorkLoop.new.lua"),
        ),
        (
            "React - ReactFiberCommitWork.new.lua",
            include_str!("../bench_content/core-packages/modules/ReactReconciler-9c8468d8-8a7220fd/src/ReactFiberCommitWork.new.lua"),
        ),
        (
            "React - ReactFiberHooks.new.lua",
            include_str!("../bench_content/core-packages/modules/ReactReconciler-9c8468d8-8a7220fd/src/ReactFiberHooks.new.lua"),
        ),
        (
            "React - ReactFiberBeginWork.new.lua",
            include_str!("../bench_content/core-packages/modules/ReactReconciler-9c8468d8-8a7220fd/src/ReactFiberBeginWork.new.lua"),
        ),
    ];

    #[cfg(feature = "tracing")]
    tracing::subscriber::set_global_default(
        tracing_subscriber::prelude::__tracing_subscriber_SubscriberExt::with(
            tracing_subscriber::registry(),
            tracing_tracy::TracyLayer::default(),
        ),
    )
    .expect("set up the subscriber");

    for (name, content) in inputs {
        let mut group = c.benchmark_group(name);
        group.throughput(criterion::Throughput::Bytes(content.len() as u64));

        let parser = darklua_core::Parser::default();
        group.bench_function("parse-without-tokens", |b| {
            b.iter(|| {
                parser.parse(criterion::black_box(content)).unwrap();
            })
        });

        let retain_line_parser = darklua_core::Parser::default().preserve_tokens();
        group.bench_function("parse-with-tokens", |b| {
            b.iter(|| {
                retain_line_parser
                    .parse(criterion::black_box(content))
                    .unwrap();
            })
        });

        group.finish();
    }
}

criterion::criterion_group!(
    name = parse;
    config = criterion::Criterion::default();
    targets = parse_code,
);
criterion::criterion_main!(parse);
