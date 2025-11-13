use std::path::Path;

static ROACT_SRC: include_dir::Dir<'_> =
    include_dir::include_dir!("$CARGO_MANIFEST_DIR/bench_content/roact/src");

static CROSSWALK_SRC: include_dir::Dir<'_> =
    include_dir::include_dir!("$CARGO_MANIFEST_DIR/bench_content/crosswalk/src");

pub fn roact_content(path: impl AsRef<Path>) -> Content<'static> {
    let path = path.as_ref();
    if path == Path::new(".") {
        Content::Root(&ROACT_SRC)
    } else {
        match ROACT_SRC.get_entry(path) {
            Some(entry) => Content::Entry(entry),
            None => {
                panic!("unable to obtain content from Roact: `{}`", path.display())
            }
        }
    }
}

pub fn crosswalk_content(path: impl AsRef<Path>) -> Content<'static> {
    let path = path.as_ref();
    if path == Path::new(".") {
        Content::Root(&CROSSWALK_SRC)
    } else {
        match CROSSWALK_SRC.get_entry(path) {
            Some(entry) => Content::Entry(entry),
            None => {
                panic!(
                    "unable to obtain content from crosswalk: `{}`",
                    path.display()
                )
            }
        }
    }
}

pub fn count_lua_bytes(file: &include_dir::File<'_>) -> u64 {
    file.path()
        .extension()
        .map(|extension| {
            if extension.to_str().unwrap() == "lua" {
                file.contents().len() as u64
            } else {
                0
            }
        })
        .unwrap_or(0)
}

pub fn write_content(resources: &darklua_core::Resources, dir: &include_dir::Dir<'_>) -> u64 {
    dir.entries()
        .iter()
        .map(|entry| match entry {
            include_dir::DirEntry::Dir(next_dir) => write_content(resources, next_dir),
            include_dir::DirEntry::File(file) => {
                resources
                    .write(file.path(), file.contents_utf8().unwrap())
                    .unwrap();
                count_lua_bytes(file)
            }
        })
        .sum()
}

pub enum Content<'a> {
    Root(&'static include_dir::Dir<'static>),
    Entry(&'a include_dir::DirEntry<'a>),
    Literal(&'static str),
}

impl From<&'static str> for Content<'_> {
    fn from(value: &'static str) -> Self {
        Content::Literal(value)
    }
}

#[allow(unused_macros)]
macro_rules! generate_resources {
    ($($path:literal => $content:expr),+$(,)?) => {{
        let mut bytes = 0_u64;
        let resources = darklua_core::Resources::from_memory();
            $(
            let path = $path;
            let content = Content::from($content);
            match content {
                Content::Root(root) => {
                    bytes += write_content(&resources, &root);
                }
                Content::Literal(value) => {
                    resources.write(path, value).unwrap();
                    bytes += value.as_bytes().len() as u64;
                }
                Content::Entry(entry) => match entry {
                    DirEntry::Dir(dir) => {
                        bytes += write_content(&resources, &dir);
                    }
                    DirEntry::File(file) => {
                        resources.write(path, file.contents_utf8().unwrap()).unwrap();
                        bytes += count_lua_bytes(file);
                    }
                }
            }
        )*
        (resources, bytes)
    }};
}

#[allow(unused_macros)]
macro_rules! generate_bench {
    ($name:ident, {
        resources = { $($path:literal => $content:expr),+$(,)? }
        bench = $callback:expr
        $(,)?
    } ) => {
    };
    ($name:ident, {
        resources = { $($path:literal => $content:expr),+$(,)? },
        options = { $($option_name:ident => $options:expr),+$(,)? }
        $(,)?
    } ) => {
        pub fn $name(c: &mut criterion::Criterion) {
            use $crate::bench_utils::{Content, write_content, count_lua_bytes};
            use include_dir::DirEntry;

            let (resources, bytes) = $crate::bench_utils::generate_resources!(
                $( $path => $content, )*
            );

            let mut group = c.benchmark_group(stringify!($name));
            group.throughput(criterion::Throughput::Bytes(bytes));

            $(
                group.bench_function(stringify!($option_name), |b| {
                    b.iter(|| {
                        darklua_core::process(
                            criterion::black_box(&resources),
                            criterion::black_box($options),
                        )
                        .unwrap()
                        .result()
                        .unwrap()
                    })
                });
            )*

            group.finish();
        }
    };
}

#[allow(unused_imports)]
pub(crate) use generate_bench;
#[allow(unused_imports)]
pub(crate) use generate_resources;
