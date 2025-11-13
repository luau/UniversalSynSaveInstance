use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::{utils, DarkluaError};

use super::InstancePath;

type NodeId = usize;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
struct RojoSourcemapNode {
    name: String,
    class_name: String,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    file_paths: Vec<PathBuf>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    children: Vec<RojoSourcemapNode>,
    #[serde(skip)]
    id: NodeId,
    #[serde(skip)]
    parent_id: NodeId,
}

impl RojoSourcemapNode {
    fn initialize(mut self, relative_to: &Path) -> Self {
        let mut queue = vec![&mut self];
        let mut index = 0;

        while let Some(node) = queue.pop() {
            node.id = index;
            for file_path in &mut node.file_paths {
                *file_path = utils::normalize_path(relative_to.join(&file_path));
            }
            for child in &mut node.children {
                child.parent_id = index;
                queue.push(child);
            }
            index += 1;
        }

        self
    }

    fn id(&self) -> NodeId {
        self.id
    }

    fn parent_id(&self) -> NodeId {
        self.parent_id
    }

    fn iter(&self) -> impl Iterator<Item = &Self> {
        RojoSourcemapNodeIterator::new(self)
    }

    fn get_child(&self, id: NodeId) -> Option<&RojoSourcemapNode> {
        self.children.iter().find(|node| node.id == id)
    }

    fn get_descendant(&self, id: NodeId) -> Option<&RojoSourcemapNode> {
        self.iter().find(|node| node.id == id)
    }

    fn is_root(&self) -> bool {
        self.id == self.parent_id
    }
}

struct RojoSourcemapNodeIterator<'a> {
    queue: Vec<&'a RojoSourcemapNode>,
}

impl<'a> RojoSourcemapNodeIterator<'a> {
    fn new(root_node: &'a RojoSourcemapNode) -> Self {
        Self {
            queue: vec![root_node],
        }
    }
}

impl<'a> Iterator for RojoSourcemapNodeIterator<'a> {
    type Item = &'a RojoSourcemapNode;

    fn next(&mut self) -> Option<Self::Item> {
        if let Some(next_node) = self.queue.pop() {
            for child in &next_node.children {
                self.queue.push(child);
            }
            Some(next_node)
        } else {
            None
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct RojoSourcemap {
    root_node: RojoSourcemapNode,
    is_datamodel: bool,
}

impl RojoSourcemap {
    pub(crate) fn parse(
        content: &str,
        relative_to: impl AsRef<Path>,
    ) -> Result<Self, DarkluaError> {
        let root_node =
            serde_json::from_str::<RojoSourcemapNode>(content)?.initialize(relative_to.as_ref());

        let is_datamodel = root_node.class_name == "DataModel";
        Ok(Self {
            root_node,
            is_datamodel,
        })
    }

    pub(crate) fn exists(&self, path: &Path) -> bool {
        self.find_node(path).is_some()
    }

    pub(crate) fn get_instance_path(
        &self,
        from_file: impl AsRef<Path>,
        target_file: impl AsRef<Path>,
    ) -> Option<InstancePath> {
        let from_file = from_file.as_ref();
        let target_file = target_file.as_ref();

        let from_node = self.find_node(from_file)?;
        let target_node = self.find_node(target_file)?;

        let from_ancestors = self.hierarchy(from_node);
        let target_ancestors = self.hierarchy(target_node);

        let (parents, descendants, common_ancestor_id) = from_ancestors
            .iter()
            .enumerate()
            .find_map(|(index, ancestor_id)| {
                if let Some((target_index, common_ancestor_id)) = target_ancestors
                    .iter()
                    .enumerate()
                    .find(|(_, id)| *id == ancestor_id)
                {
                    Some((index, target_index, *common_ancestor_id))
                } else {
                    None
                }
            })
            .map(
                |(from_ancestor_split, target_ancestor_split, common_ancestor_id)| {
                    (
                        from_ancestors.split_at(from_ancestor_split).0,
                        target_ancestors.split_at(target_ancestor_split).0,
                        common_ancestor_id,
                    )
                },
            )?;

        let relative_path_length = parents.len().saturating_add(descendants.len());

        if !self.is_datamodel || relative_path_length <= target_ancestors.len() {
            log::trace!("  ⨽ use Roblox path from script instance");

            let mut instance_path = InstancePath::from_script();

            for _ in 0..parents.len() {
                instance_path.parent();
            }

            self.index_descendants(
                instance_path,
                self.root_node.get_descendant(common_ancestor_id)?,
                descendants.iter().rev(),
            )
        } else {
            log::trace!("  ⨽ use Roblox path from DataModel instance");

            self.index_descendants(
                InstancePath::from_root(),
                &self.root_node,
                target_ancestors.iter().rev().skip(1),
            )
        }
    }

    fn index_descendants<'a>(
        &self,
        mut instance_path: InstancePath,
        mut node: &RojoSourcemapNode,
        descendants: impl Iterator<Item = &'a usize>,
    ) -> Option<InstancePath> {
        for descendant_id in descendants {
            node = node.get_child(*descendant_id)?;
            instance_path.child(&node.name);
        }
        Some(instance_path)
    }

    /// returns the ids of each ancestor of the given node and itself
    fn hierarchy(&self, node: &RojoSourcemapNode) -> Vec<NodeId> {
        let mut ids = vec![node.id()];

        if node.is_root() {
            return ids;
        }

        let mut parent_id = node.parent_id();

        while let Some(parent) = self.root_node.get_descendant(parent_id) {
            ids.push(parent_id);
            if parent.is_root() {
                break;
            }
            parent_id = parent.parent_id();
        }

        ids
    }

    fn find_node(&self, path: &Path) -> Option<&RojoSourcemapNode> {
        self.root_node
            .iter()
            .find(|node| node.file_paths.iter().any(|file_path| file_path == path))
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn new_sourcemap(content: &str) -> RojoSourcemap {
        RojoSourcemap::parse(content, "").expect("unable to parse sourcemap")
    }

    mod instance_paths {
        use super::*;

        fn script_path(components: &[&'static str]) -> InstancePath {
            components
                .iter()
                .fold(InstancePath::from_script(), |mut path, component| {
                    match *component {
                        "parent" => {
                            path.parent();
                        }
                        child_name => {
                            path.child(child_name);
                        }
                    }
                    path
                })
        }

        #[test]
        fn from_init_to_sibling_module() {
            let sourcemap = new_sourcemap(
                r#"{
                "name": "Project",
                "className": "ModuleScript",
                "filePaths": ["src/init.lua", "default.project.json"],
                "children": [
                    {
                        "name": "value",
                        "className": "ModuleScript",
                        "filePaths": ["src/value.lua"]
                    }
                ]
            }"#,
            );
            pretty_assertions::assert_eq!(
                sourcemap
                    .get_instance_path("src/init.lua", "src/value.lua")
                    .unwrap(),
                script_path(&["value"])
            );
        }

        #[test]
        fn from_sibling_to_sibling_module() {
            let sourcemap = new_sourcemap(
                r#"{
                "name": "Project",
                "className": "ModuleScript",
                "filePaths": ["src/init.lua", "default.project.json"],
                "children": [
                    {
                        "name": "main",
                        "className": "ModuleScript",
                        "filePaths": ["src/main.lua"]
                    },
                    {
                        "name": "value",
                        "className": "ModuleScript",
                        "filePaths": ["src/value.lua"]
                    }
                ]
            }"#,
            );
            pretty_assertions::assert_eq!(
                sourcemap
                    .get_instance_path("src/main.lua", "src/value.lua")
                    .unwrap(),
                script_path(&["parent", "value"])
            );
        }

        #[test]
        fn from_sibling_to_nested_sibling_module() {
            let sourcemap = new_sourcemap(
                r#"{
                "name": "Project",
                "className": "ModuleScript",
                "filePaths": ["src/init.lua", "default.project.json"],
                "children": [
                    {
                        "name": "main",
                        "className": "ModuleScript",
                        "filePaths": ["src/main.lua"]
                    },
                    {
                        "name": "Lib",
                        "className": "Folder",
                        "children": [
                            {
                                "name": "format",
                                "className": "ModuleScript",
                                "filePaths": ["src/Lib/format.lua"]
                            }
                        ]
                    }
                ]
            }"#,
            );
            pretty_assertions::assert_eq!(
                sourcemap
                    .get_instance_path("src/main.lua", "src/Lib/format.lua")
                    .unwrap(),
                script_path(&["parent", "Lib", "format"])
            );
        }

        #[test]
        fn from_child_require_parent() {
            let sourcemap = new_sourcemap(
                r#"{
                "name": "Project",
                "className": "ModuleScript",
                "filePaths": ["src/init.lua", "default.project.json"],
                "children": [
                    {
                        "name": "main",
                        "className": "ModuleScript",
                        "filePaths": ["src/main.lua"]
                    }
                ]
            }"#,
            );
            pretty_assertions::assert_eq!(
                sourcemap
                    .get_instance_path("src/main.lua", "src/init.lua")
                    .unwrap(),
                script_path(&["parent"])
            );
        }

        #[test]
        fn from_child_require_parent_nested() {
            let sourcemap = new_sourcemap(
                r#"{
                "name": "Project",
                "className": "ModuleScript",
                "filePaths": ["src/init.lua", "default.project.json"],
                "children": [
                    {
                        "name": "Sub",
                        "className": "ModuleScript",
                        "filePaths": ["src/Sub/init.lua"],
                        "children": [
                            {
                                "name": "test",
                                "className": "ModuleScript",
                                "filePaths": ["src/Sub/test.lua"]
                            }
                        ]
                    }
                ]
            }"#,
            );
            pretty_assertions::assert_eq!(
                sourcemap
                    .get_instance_path("src/Sub/test.lua", "src/Sub/init.lua")
                    .unwrap(),
                script_path(&["parent"])
            );
        }
    }
}
