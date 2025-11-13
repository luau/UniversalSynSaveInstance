use std::path::Path;

use super::{
    configuration::Configuration,
    resources::Resources,
    utils::maybe_plural,
    work_cache::WorkCache,
    work_item::{WorkItem, WorkProgress, WorkStatus},
    DarkluaError, DarkluaResult, Options,
};

use crate::{
    nodes::Block,
    rules::{bundle::Bundler, ContextBuilder, Rule, RuleConfiguration},
    utils::{normalize_path, Timer},
    GeneratorParameters,
};

const DEFAULT_CONFIG_PATHS: [&str; 2] = [".darklua.json", ".darklua.json5"];

#[derive(Debug)]
pub(crate) struct Worker<'a> {
    resources: &'a Resources,
    cache: WorkCache<'a>,
    configuration: Configuration,
    cached_bundler: Option<Bundler>,
}

impl<'a> Worker<'a> {
    pub(crate) fn new(resources: &'a Resources) -> Self {
        Self {
            resources,
            cache: WorkCache::new(resources),
            configuration: Configuration::default(),
            cached_bundler: None,
        }
    }

    pub(crate) fn setup_worker(&mut self, options: &mut Options) -> DarkluaResult<()> {
        let configuration_setup_timer = Timer::now();

        if let Some(config) = options.take_configuration() {
            self.configuration = config;
            if let Some(config_path) = options.configuration_path() {
                log::warn!(
                    concat!(
                        "the provided options contained both a configuration object and ",
                        "a path to a configuration file (`{}`). the provided configuration ",
                        "takes precedence, so it is best to avoid confusion by providing ",
                        "only the configuration itself or a path to a configuration"
                    ),
                    config_path.display()
                );
            }
        } else if let Some(config) = options.configuration_path() {
            if self.resources.exists(config)? {
                self.configuration = self.read_configuration(config)?;
                log::info!("using configuration file `{}`", config.display());
            } else {
                return Err(DarkluaError::resource_not_found(config)
                    .context("expected to find configuration file as provided by the options"));
            }
        } else {
            let mut configuration_files = Vec::new();
            for path in DEFAULT_CONFIG_PATHS.iter().map(Path::new) {
                if self.resources.exists(path)? {
                    configuration_files.push(path);
                }
            }

            match configuration_files.len() {
                0 => {
                    log::info!("using default configuration");
                }
                1 => {
                    let configuration_file_path = configuration_files.first().unwrap();
                    self.configuration = self.read_configuration(configuration_file_path)?;
                    log::info!(
                        "using configuration file `{}`",
                        configuration_file_path.display()
                    );
                }
                _ => {
                    return Err(DarkluaError::multiple_configuration_found(
                        configuration_files.into_iter().map(Path::to_path_buf),
                    ))
                }
            }
        };

        if let Some(generator) = options.generator_override() {
            log::trace!(
                "override with {} generator",
                match generator {
                    GeneratorParameters::RetainLines => "`retain_lines`".to_owned(),
                    GeneratorParameters::Dense { column_span } =>
                        format!("dense ({})", column_span),
                    GeneratorParameters::Readable { column_span } =>
                        format!("readable ({})", column_span),
                }
            );
            self.configuration.set_generator(generator.clone());
        }

        log::trace!(
            "configuration setup in {}",
            configuration_setup_timer.duration_label()
        );
        log::debug!(
            "using configuration: {}",
            json5::to_string(&self.configuration).unwrap_or_else(|err| {
                format!("? (unable to serialize configuration: {})", err)
            })
        );

        Ok(())
    }

    pub(crate) fn configuration(&self) -> &Configuration {
        &self.configuration
    }

    pub(crate) fn advance_work(&mut self, work_item: &mut WorkItem) -> DarkluaResult<()> {
        match &work_item.status {
            WorkStatus::NotStarted => {
                let source_display = work_item.source().display();

                let content = self.resources.get(work_item.source())?;

                let parser = self.configuration.build_parser();

                log::debug!("beginning work on `{}`", source_display);

                let parser_timer = Timer::now();

                let mut block = parser.parse(&content).map_err(|parser_error| {
                    DarkluaError::parser_error(work_item.source(), parser_error)
                })?;

                let parser_time = parser_timer.duration_label();
                log::debug!("parsed `{}` in {}", source_display, parser_time);

                self.bundle(work_item, &mut block, &content)?;

                work_item.status = WorkProgress::new(content, block).into();

                self.apply_rules(work_item)
            }
            WorkStatus::InProgress(_work_progress) => self.apply_rules(work_item),
            WorkStatus::Done(_) => Ok(()),
        }
    }

    fn read_configuration(&self, config: &Path) -> DarkluaResult<Configuration> {
        let config_content = self.resources.get(config)?;
        json5::from_str(&config_content)
            .map_err(|err| {
                DarkluaError::invalid_configuration_file(config).context(err.to_string())
            })
            .map(|configuration: Configuration| {
                configuration.with_location({
                    config.parent().unwrap_or_else(|| {
                        log::warn!(
                            "unexpected configuration path `{}` (unable to extract parent path)",
                            config.display()
                        );
                        config
                    })
                })
            })
    }

    fn apply_rules(&mut self, work_item: &mut WorkItem) -> DarkluaResult<()> {
        let work_progress = match &mut work_item.status {
            WorkStatus::InProgress(progress) => progress.as_mut(),
            _ => return Ok(()),
        };

        let progress = &mut work_progress.progress;

        let source_display = work_item.data.source().display();
        let normalized_source = normalize_path(work_item.data.source());

        progress.duration().start();

        for (index, rule) in self
            .configuration
            .rules()
            .enumerate()
            .skip(progress.next_rule())
        {
            let mut context_builder =
                self.create_rule_context(work_item.data.source(), &work_progress.content);
            log::trace!(
                "[{}] apply rule `{}`{}",
                source_display,
                rule.get_name(),
                if rule.has_properties() {
                    format!(" {:?}", rule.serialize_to_properties())
                } else {
                    "".to_owned()
                }
            );
            let mut required_content: Vec<_> = rule
                .require_content(&normalized_source, progress.block())
                .into_iter()
                .map(normalize_path)
                .filter(|path| {
                    if *path == normalized_source {
                        log::debug!("filtering out currently processing path");
                        false
                    } else {
                        true
                    }
                })
                .collect();
            required_content.sort();
            required_content.dedup();

            if !required_content.is_empty() {
                if required_content
                    .iter()
                    .all(|path| self.cache.contains(path))
                {
                    let parser = self.configuration.build_parser();
                    for path in required_content.iter() {
                        let block = self.cache.get_block(path, &parser)?;
                        context_builder.insert_block(path, block);
                    }
                } else {
                    progress.duration().pause();
                    log::trace!(
                        "queue work for `{}` at rule `{}` (#{}) because it requires:{}",
                        source_display,
                        rule.get_name(),
                        index,
                        if required_content.len() == 1 {
                            format!(" {}", required_content.first().unwrap().display())
                        } else {
                            format!(
                                "\n- {}",
                                required_content
                                    .iter()
                                    .map(|path| format!("- {}", path.display()))
                                    .collect::<Vec<_>>()
                                    .join("\n")
                            )
                        }
                    );

                    progress.set_next_rule(index);
                    progress.set_required_content(required_content);
                    return Ok(());
                }
            }

            let context = context_builder.build();
            let block = progress.mutate_block();
            let rule_timer = Timer::now();

            let source = work_item.data.source();

            let rule_result = rule.process(block, &context).map_err(|rule_error| {
                let error = DarkluaError::rule_error(source, rule, index, rule_error);

                log::trace!(
                    "[{}] rule `{}` errored: {}",
                    source_display,
                    rule.get_name(),
                    error
                );

                error
            });

            work_item
                .external_file_dependencies
                .extend(context.into_dependencies());

            rule_result?;

            let rule_duration = rule_timer.duration_label();
            log::trace!(
                "[{}] ⨽completed `{}` in {}",
                source_display,
                rule.get_name(),
                rule_duration
            );
        }

        let rule_time = progress.duration().duration_label();
        let total_rules = self.configuration.rules_len();
        log::debug!(
            "{} rule{} applied in {} for `{}`",
            total_rules,
            maybe_plural(total_rules),
            rule_time,
            source_display,
        );

        log::trace!("begin generating code for `{}`", source_display);

        if cfg!(test) || (cfg!(debug_assertions) && log::log_enabled!(log::Level::Trace)) {
            log::trace!(
                "generate AST debugging view at `{}`",
                work_item.data.output().display()
            );
            self.resources
                .write(work_item.data.output(), &format!("{:#?}", progress.block()))?;
        }

        let generator_timer = Timer::now();

        let lua_code = self
            .configuration
            .generate_lua(progress.block(), &work_progress.content);

        let generator_time = generator_timer.duration_label();
        log::debug!(
            "generated code for `{}` in {}",
            source_display,
            generator_time,
        );

        self.resources.write(work_item.data.output(), &lua_code)?;

        self.cache
            .link_source_to_output(normalized_source, work_item.data.output());

        work_item.status = WorkStatus::done();
        Ok(())
    }

    fn create_rule_context<'block, 'src>(
        &self,
        source: &Path,
        original_code: &'src str,
    ) -> ContextBuilder<'block, 'a, 'src> {
        let builder = ContextBuilder::new(normalize_path(source), self.resources, original_code);
        if let Some(project_location) = self.configuration.location() {
            builder.with_project_location(project_location)
        } else {
            builder
        }
    }

    fn bundle(
        &mut self,
        work_item: &mut WorkItem,
        block: &mut Block,
        original_code: &str,
    ) -> DarkluaResult<()> {
        if self.cached_bundler.is_none() {
            if let Some(bundler) = self.configuration.bundle() {
                self.cached_bundler = Some(bundler);
            }
        }
        let bundler = match self.cached_bundler.as_ref() {
            Some(bundler) => bundler,
            None => return Ok(()),
        };

        log::debug!("beginning bundling from `{}`", work_item.source().display());

        let bundle_timer = Timer::now();

        let context = self
            .create_rule_context(work_item.source(), original_code)
            .build();

        let rule_result = bundler.process(block, &context).map_err(|rule_error| {
            let error = DarkluaError::orphan_rule_error(work_item.source(), bundler, rule_error);

            log::trace!(
                "[{}] rule `{}` errored: {}",
                work_item.source().display(),
                bundler.get_name(),
                error
            );

            error
        });

        work_item
            .external_file_dependencies
            .extend(context.into_dependencies());

        rule_result?;

        let bundle_time = bundle_timer.duration_label();
        log::debug!(
            "bundled `{}` in {}",
            work_item.source().display(),
            bundle_time
        );

        Ok(())
    }
}
