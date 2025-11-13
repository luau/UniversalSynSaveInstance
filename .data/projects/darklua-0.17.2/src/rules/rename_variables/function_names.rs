use crate::nodes::LocalFunctionStatement;
use crate::process::NodeProcessor;

#[derive(Debug, Clone, Default)]
pub struct CollectFunctionNames {
    names: Vec<String>,
}

impl From<CollectFunctionNames> for Vec<String> {
    fn from(collector: CollectFunctionNames) -> Self {
        collector.names
    }
}

impl NodeProcessor for CollectFunctionNames {
    fn process_local_function_statement(&mut self, function: &mut LocalFunctionStatement) {
        self.names
            .push(function.get_identifier().get_name().to_owned());
    }
}
