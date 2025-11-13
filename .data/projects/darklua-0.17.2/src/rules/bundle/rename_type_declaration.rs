use std::collections::HashMap;
use std::mem;

use crate::nodes::*;
use crate::process::utils::{identifier_permutator, CharPermutator};
use crate::process::{
    DefaultVisitor, NodePostProcessor, NodePostVisitor, NodeProcessor, NodeVisitor, Scope,
    ScopePostVisitor,
};
use crate::rules::ShiftTokenLineProcessor;
use crate::utils::{lines, ScopedHashMap};

#[derive(Debug)]
pub(crate) struct RenameTypeDeclarationProcessor {
    suffix: String,
    /// a map from the original type name to its newly generated name
    renamed_types: ScopedHashMap<String, String>,
    /// a map from identifiers to module names
    type_namespace: ScopedHashMap<String, Vec<u8>>,
    /// the exported types found
    exported_types: HashMap<String, String>,
    /// a map from module names to their exported types
    all_types: HashMap<Vec<u8>, HashMap<String, String>>,
    /// permutator to generate unique type identifier suffixes
    permutator: CharPermutator,
    modules_identifier: String,
    hoist_types: bool,
    type_lines: isize,
    type_declarations: Vec<Statement>,
}

impl RenameTypeDeclarationProcessor {
    pub(crate) fn new(modules_identifier: String) -> Self {
        Self {
            suffix: "__DARKLUA_TYPE_".into(),
            renamed_types: Default::default(),
            type_namespace: Default::default(),
            exported_types: Default::default(),
            all_types: Default::default(),
            permutator: identifier_permutator(),
            modules_identifier,
            hoist_types: true,
            type_lines: 0,
            type_declarations: Default::default(),
        }
    }

    pub(crate) fn rename_types(&mut self, block: &mut Block) {
        self.hoist_types = false;
        ScopePostVisitor::visit_block(block, self);
    }

    pub(crate) fn extract_exported_types(&mut self, block: &mut Block) -> HashMap<String, String> {
        self.hoist_types = true;
        ScopePostVisitor::visit_block(block, self);
        mem::take(&mut self.exported_types)
    }

    pub(crate) fn insert_module_types(
        &mut self,
        module_name: String,
        types: HashMap<String, String>,
    ) {
        self.all_types.insert(module_name.into_bytes(), types);
    }

    fn generate_unique_type(&mut self, original_name: &str) -> String {
        let mut new_name = original_name.to_owned();
        new_name.push_str(&self.suffix);
        new_name.push_str(&self.permutator.next().unwrap());
        new_name
    }

    fn get_module_name(&self, value: &Expression) -> Option<Vec<u8>> {
        if let Expression::Call(value) = value {
            if let Prefix::Field(field) = value.get_prefix() {
                if let Prefix::Identifier(variable) = field.get_prefix() {
                    if variable.get_name() == &self.modules_identifier {
                        return Some(field.get_field().get_name().as_bytes().to_vec());
                    }
                }
            }
        }
        None
    }

    fn rename_type_declaration(&mut self, declaration: &mut TypeDeclarationStatement) {
        let original_name = declaration.get_name().get_name().to_owned();

        let new_name = self.generate_unique_type(&original_name);

        if declaration.is_exported() {
            declaration.remove_exported();
            self.exported_types
                .insert(original_name.clone(), new_name.clone());
        }

        self.renamed_types.insert(original_name, new_name.clone());

        declaration.mutate_name().set_name(new_name);
    }

    pub(crate) fn get_type_lines(&self) -> isize {
        self.type_lines
    }

    pub(crate) fn extract_type_declarations(&mut self) -> Vec<Statement> {
        mem::take(&mut self.type_declarations)
    }
}

impl Scope for RenameTypeDeclarationProcessor {
    fn push(&mut self) {
        self.renamed_types.push();
        self.type_namespace.push();
    }

    fn pop(&mut self) {
        self.renamed_types.pop();
        self.type_namespace.pop();
    }

    fn insert(&mut self, _: &mut String) {}

    fn insert_self(&mut self) {}

    fn insert_local(&mut self, identifier: &mut String, value: Option<&mut Expression>) {
        if let Some(module_name) = value.and_then(|value| self.get_module_name(value)) {
            self.type_namespace.insert(identifier.clone(), module_name);
        }
    }

    fn insert_local_function(&mut self, _: &mut LocalFunctionStatement) {}
}

impl NodeProcessor for RenameTypeDeclarationProcessor {
    fn process_block(&mut self, block: &mut Block) {
        if !self.hoist_types {
            return;
        }

        for statement in block.iter_mut_statements() {
            if let Statement::TypeDeclaration(declaration) = statement {
                self.rename_type_declaration(declaration);
            }
        }
    }

    fn process_type(&mut self, r#type: &mut Type) {
        let replace_with = match r#type {
            Type::Name(type_name) => {
                if let Some(new_name) = self.renamed_types.get(type_name.get_type_name().get_name())
                {
                    type_name.mutate_type_name().set_name(new_name);
                }
                None
            }
            Type::Field(type_field) => self
                .type_namespace
                .get(type_field.get_namespace().get_name())
                .and_then(|module_name| self.all_types.get(module_name))
                .and_then(|module_types| {
                    module_types.get(type_field.get_type_name().get_type_name().get_name())
                })
                .map(TypeName::new)
                .map(|type_name| {
                    Type::from(
                        if let Some(parameters) = type_field.get_type_name().get_type_parameters() {
                            type_name.with_type_parameters(parameters.clone())
                        } else {
                            type_name
                        },
                    )
                }),
            _ => None,
        };

        if let Some(new_type) = replace_with {
            *r#type = new_type;
        }
    }
}

impl NodePostProcessor for RenameTypeDeclarationProcessor {
    fn process_after_block(&mut self, block: &mut Block) {
        if !self.hoist_types {
            return;
        }

        block.filter_mut_statements(|statement| {
            if let Statement::TypeDeclaration(_declaration) = statement {
                let mut current = mem::replace(statement, DoStatement::default().into());

                let first_line = lines::statement_first(&current);
                let last_line = lines::statement_total(&current);
                let total = 1 + last_line.saturating_sub(first_line) as isize;

                let mut shift_processor =
                    ShiftTokenLineProcessor::new(1 + self.type_lines - first_line as isize);
                DefaultVisitor::visit_statement(&mut current, &mut shift_processor);

                self.type_lines += total;
                self.type_declarations.push(current);

                false
            } else {
                true
            }
        });
    }
}
