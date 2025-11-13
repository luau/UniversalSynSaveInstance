mod module_definitions;

use module_definitions::BuildModuleDefinitions;

use std::collections::{HashMap, HashSet};
use std::ops::{Deref, DerefMut};
use std::path::{Path, PathBuf};
use std::{iter, mem};

use serde::Serialize;

use crate::frontend::DarkluaResult;
use crate::nodes::{
    Block, DoStatement, Expression, FunctionCall, LocalAssignStatement, Prefix, Statement,
    StringExpression,
};
use crate::process::{
    to_expression, DefaultVisitor, IdentifierTracker, NodeProcessor, NodeVisitor, ScopeVisitor,
};
use crate::rules::require::{is_require_call, match_path_require_call, PathLocator};
use crate::rules::{
    Context, ContextBuilder, FlawlessRule, ReplaceReferencedTokens, RuleProcessResult,
};
use crate::utils::Timer;
use crate::{DarkluaError, Resources};

use super::BundleOptions;

pub(crate) enum RequiredResource {
    Block(Block),
    Expression(Expression),
}

#[derive(Debug)]
struct RequirePathProcessor<'a, 'b, 'resources, PathLocatorImpl> {
    options: &'a BundleOptions,
    identifier_tracker: IdentifierTracker,
    path_locator: &'b PathLocatorImpl,
    module_definitions: BuildModuleDefinitions,
    source: PathBuf,
    module_cache: HashMap<PathBuf, Expression>,
    require_stack: Vec<PathBuf>,
    skip_module_paths: HashSet<PathBuf>,
    resources: &'resources Resources,
    errors: Vec<String>,
}

impl<'a, 'b, 'resources, PathLocatorImpl: PathLocator>
    RequirePathProcessor<'a, 'b, 'resources, PathLocatorImpl>
{
    fn new<'context, 'code>(
        context: &'context Context<'b, 'resources, 'code>,
        options: &'a BundleOptions,
        path_locator: &'b PathLocatorImpl,
    ) -> Self
    where
        'context: 'b,
        'context: 'resources,
        'context: 'code,
    {
        Self {
            options,
            identifier_tracker: IdentifierTracker::new(),
            path_locator,
            module_definitions: BuildModuleDefinitions::new(options.modules_identifier()),
            source: context.current_path().to_path_buf(),
            module_cache: Default::default(),
            require_stack: Default::default(),
            skip_module_paths: Default::default(),
            resources: context.resources(),
            errors: Vec::new(),
        }
    }

    fn apply(self, block: &mut Block, context: &Context) -> RuleProcessResult {
        self.module_definitions.apply(block, context);
        match self.errors.len() {
            0 => Ok(()),
            1 => Err(self.errors.first().unwrap().to_string()),
            _ => Err(format!("- {}", self.errors.join("\n- "))),
        }
    }

    fn require_call(&self, call: &FunctionCall) -> Option<PathBuf> {
        if is_require_call(call, self) {
            match_path_require_call(call)
        } else {
            None
        }
    }

    fn try_inline_call(&mut self, call: &FunctionCall) -> Option<Expression> {
        let literal_require_path = self.require_call(call)?;

        if self.options.is_excluded(&literal_require_path) {
            log::info!(
                "exclude `{}` from bundle [from `{}`]",
                literal_require_path.display(),
                self.source.display()
            );
            return None;
        }

        let require_path = match self
            .path_locator
            .find_require_path(&literal_require_path, &self.source)
        {
            Ok(path) => path,
            Err(err) => {
                self.errors.push(err.to_string());
                return None;
            }
        };

        log::debug!(
            "found require call to path `{}` (normalized `{}`)",
            literal_require_path.display(),
            require_path.display()
        );

        if self.skip_module_paths.contains(&require_path) {
            log::trace!(
                "skip `{}` because it previously errored",
                require_path.display()
            );
            return None;
        }

        match self.inline_require(&require_path, call) {
            Ok(expression) => Some(expression),
            Err(error) => {
                self.errors.push(error.to_string());
                self.skip_module_paths.insert(require_path);
                None
            }
        }
    }

    fn inline_require(
        &mut self,
        require_path: &Path,
        call: &FunctionCall,
    ) -> DarkluaResult<Expression> {
        if let Some(expression) = self.module_cache.get(require_path) {
            Ok(expression.clone())
        } else {
            if let Some(i) = self
                .require_stack
                .iter()
                .enumerate()
                .find(|(_, path)| **path == require_path)
                .map(|(i, _)| i)
            {
                let require_stack_paths: Vec<_> = self
                    .require_stack
                    .iter()
                    .skip(i)
                    .map(|path| path.display().to_string())
                    .chain(iter::once(require_path.display().to_string()))
                    .collect();

                return Err(DarkluaError::custom(format!(
                    "cyclic require detected with `{}`",
                    require_stack_paths.join("` > `")
                )));
            }

            self.require_stack.push(require_path.to_path_buf());
            let required_resource = self.require_resource(require_path);
            self.require_stack.pop();

            let module_value = self.module_definitions.build_module_from_resource(
                required_resource?,
                require_path,
                call,
            )?;

            self.module_cache
                .insert(require_path.to_path_buf(), module_value.clone());

            Ok(module_value)
        }
    }

    fn require_resource(&mut self, path: impl AsRef<Path>) -> DarkluaResult<RequiredResource> {
        let path = path.as_ref();
        log::trace!("look for resource `{}`", path.display());
        let content = self.resources.get(path).map_err(DarkluaError::from)?;

        match path.extension() {
            Some(extension) => match extension.to_string_lossy().as_ref() {
                "lua" | "luau" => {
                    let parser_timer = Timer::now();
                    let mut block =
                        self.options
                            .parser()
                            .parse(&content)
                            .map_err(|parser_error| {
                                DarkluaError::parser_error(path.to_path_buf(), parser_error)
                            })?;
                    log::debug!(
                        "parsed `{}` in {}",
                        path.display(),
                        parser_timer.duration_label()
                    );

                    if self.options.parser().is_preserving_tokens() {
                        log::trace!("replacing token references of {}", path.display());
                        let context = ContextBuilder::new(path, self.resources, &content).build();
                        // run `replace_referenced_tokens` rule to avoid generating invalid code
                        // when using the token-based generator
                        let replace_tokens = ReplaceReferencedTokens::default();

                        let apply_replace_tokens_timer = Timer::now();

                        replace_tokens.flawless_process(&mut block, &context);

                        log::trace!(
                            "replaced token references for `{}` in {}",
                            path.display(),
                            apply_replace_tokens_timer.duration_label()
                        );
                    }

                    let current_source = mem::replace(&mut self.source, path.to_path_buf());

                    let apply_processor_timer = Timer::now();
                    DefaultVisitor::visit_block(&mut block, self);

                    log::debug!(
                        "processed `{}` into bundle in {}",
                        path.display(),
                        apply_processor_timer.duration_label()
                    );

                    self.source = current_source;

                    Ok(RequiredResource::Block(block))
                }
                "json" | "json5" => {
                    transcode("json", path, json5::from_str::<serde_json::Value>, &content)
                }
                "yml" | "yaml" => transcode(
                    "yaml",
                    path,
                    serde_yaml::from_str::<serde_yaml::Value>,
                    &content,
                ),
                "toml" => transcode("toml", path, toml::from_str::<toml::Value>, &content),
                "txt" => Ok(RequiredResource::Expression(
                    StringExpression::from_value(content).into(),
                )),
                _ => Err(DarkluaError::invalid_resource_extension(path)),
            },
            None => unreachable!("extension should be defined"),
        }
    }
}

impl<'a, 'b, 'resources, PathLocatorImpl: PathLocator> Deref
    for RequirePathProcessor<'a, 'b, 'resources, PathLocatorImpl>
{
    type Target = IdentifierTracker;

    fn deref(&self) -> &Self::Target {
        &self.identifier_tracker
    }
}

impl<'a, 'b, 'resources, PathLocatorImpl: PathLocator> DerefMut
    for RequirePathProcessor<'a, 'b, 'resources, PathLocatorImpl>
{
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.identifier_tracker
    }
}

fn transcode<'a, T, E>(
    label: &'static str,
    path: &Path,
    deserialize_value: impl Fn(&'a str) -> Result<T, E>,
    content: &'a str,
) -> Result<RequiredResource, DarkluaError>
where
    T: Serialize,
    E: Into<DarkluaError>,
{
    log::trace!("transcode {} data to Lua from `{}`", label, path.display());
    let transcode_duration = Timer::now();
    let value = deserialize_value(content).map_err(E::into)?;
    let expression = to_expression(&value)
        .map(RequiredResource::Expression)
        .map_err(DarkluaError::from);
    log::debug!(
        "transcoded {} data to Lua from `{}` in {}",
        label,
        path.display(),
        transcode_duration.duration_label()
    );
    expression
}

impl<'a, 'b, 'resources, PathLocatorImpl: PathLocator> NodeProcessor
    for RequirePathProcessor<'a, 'b, 'resources, PathLocatorImpl>
{
    fn process_expression(&mut self, expression: &mut Expression) {
        if let Expression::Call(call) = expression {
            if let Some(replace_with) = self.try_inline_call(call) {
                *expression = replace_with;
            }
        }
    }

    fn process_prefix_expression(&mut self, prefix: &mut Prefix) {
        if let Prefix::Call(call) = prefix {
            if let Some(replace_with) = self.try_inline_call(call) {
                *prefix = replace_with.into();
            }
        }
    }

    fn process_statement(&mut self, statement: &mut Statement) {
        if let Statement::Call(call) = statement {
            if let Some(replace_with) = self.try_inline_call(call) {
                if let Expression::Call(replace_with) = replace_with {
                    *call = *replace_with;
                } else {
                    *statement = convert_expression_to_statement(replace_with);
                }
            }
        }
    }
}

fn convert_expression_to_statement(expression: Expression) -> Statement {
    DoStatement::new(
        Block::default()
            .with_statement(LocalAssignStatement::from_variable("_").with_value(expression)),
    )
    .into()
}

pub(crate) fn process_block(
    block: &mut Block,
    context: &Context,
    options: &BundleOptions,
    locator: impl PathLocator,
) -> Result<(), String> {
    if options.parser().is_preserving_tokens() {
        log::trace!(
            "replacing token references of {}",
            context.current_path().display()
        );
        let replace_tokens = ReplaceReferencedTokens::default();

        let apply_replace_tokens_timer = Timer::now();

        replace_tokens.flawless_process(block, context);

        log::trace!(
            "replaced token references for `{}` in {}",
            context.current_path().display(),
            apply_replace_tokens_timer.duration_label()
        );
    }

    let mut processor = RequirePathProcessor::new(context, options, &locator);
    ScopeVisitor::visit_block(block, &mut processor);
    processor.apply(block, context)
}
