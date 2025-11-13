use std::fs;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use crate::nodes::{Block, Token, TriviaKind};
use crate::rules::{
    verify_property_collisions, verify_required_any_properties, Context, Rule, RuleConfiguration,
    RuleConfigurationError, RuleProcessResult, RuleProperties,
};

use super::{FlawlessRule, ShiftTokenLine};

pub const APPEND_TEXT_COMMENT_RULE_NAME: &str = "append_text_comment";

/// A rule to append a comment at the beginning or the end of each file.
#[derive(Debug, Default)]
pub struct AppendTextComment {
    text_value: OnceLock<Result<String, String>>,
    text_content: TextContent,
    location: AppendLocation,
}

impl AppendTextComment {
    pub fn new(value: impl Into<String>) -> Self {
        Self {
            text_value: Default::default(),
            text_content: TextContent::Value(value.into()),
            location: Default::default(),
        }
    }

    pub fn from_file_content(file_path: impl Into<PathBuf>) -> Self {
        Self {
            text_value: Default::default(),
            text_content: TextContent::FilePath(file_path.into()),
            location: Default::default(),
        }
    }

    pub fn at_end(mut self) -> Self {
        self.location = AppendLocation::End;
        self
    }

    fn text(&self, project_path: &Path) -> Result<String, String> {
        self.text_value
            .get_or_init(|| {
                match &self.text_content {
                    TextContent::None => Err("".to_owned()),
                    TextContent::Value(value) => Ok(value.clone()),
                    TextContent::FilePath(file_path) => {
                        fs::read_to_string(project_path.join(file_path)).map_err(|err| {
                            format!("unable to read file `{}`: {}", file_path.display(), err)
                        })
                    }
                }
                .map(|content| {
                    if content.is_empty() {
                        "".to_owned()
                    } else if content.contains('\n') {
                        let mut equal_count = 0;

                        let close_comment = loop {
                            let close_comment = format!("]{}]", "=".repeat(equal_count));
                            if !content.contains(&close_comment) {
                                break close_comment;
                            }
                            equal_count += 1;
                        };

                        format!(
                            "--[{}[\n{}\n{}",
                            "=".repeat(equal_count),
                            content,
                            close_comment
                        )
                    } else {
                        format!("--{}", content)
                    }
                })
            })
            .clone()
    }
}

impl Rule for AppendTextComment {
    fn process(&self, block: &mut Block, context: &Context) -> RuleProcessResult {
        let text = self.text(context.project_location())?;

        if text.is_empty() {
            return Ok(());
        }

        let shift_lines = text.lines().count();
        ShiftTokenLine::new(shift_lines as isize).flawless_process(block, context);

        match self.location {
            AppendLocation::Start => {
                self.location
                    .append_comment(block.mutate_first_token(), text);
            }
            AppendLocation::End => {
                self.location
                    .append_comment(block.mutate_last_token(), text);
            }
        }

        Ok(())
    }
}

impl RuleConfiguration for AppendTextComment {
    fn configure(&mut self, properties: RuleProperties) -> Result<(), RuleConfigurationError> {
        verify_required_any_properties(&properties, &["text", "file"])?;
        verify_property_collisions(&properties, &["text", "file"])?;

        for (key, value) in properties {
            match key.as_str() {
                "text" => {
                    self.text_content = TextContent::Value(value.expect_string(&key)?);
                }
                "file" => {
                    self.text_content =
                        TextContent::FilePath(PathBuf::from(value.expect_string(&key)?));
                }
                "location" => {
                    self.location = match value.expect_string(&key)?.as_str() {
                        "start" => AppendLocation::Start,
                        "end" => AppendLocation::End,
                        unexpected => {
                            return Err(RuleConfigurationError::UnexpectedValue {
                                property: "location".to_owned(),
                                message: format!(
                                    "invalid value `{}` (must be `start` or `end`)",
                                    unexpected
                                ),
                            })
                        }
                    };
                }
                _ => return Err(RuleConfigurationError::UnexpectedProperty(key)),
            }
        }

        Ok(())
    }

    fn get_name(&self) -> &'static str {
        APPEND_TEXT_COMMENT_RULE_NAME
    }

    fn serialize_to_properties(&self) -> RuleProperties {
        let mut properties = RuleProperties::new();

        match self.location {
            AppendLocation::Start => {}
            AppendLocation::End => {
                properties.insert("location".to_owned(), "end".into());
            }
        }

        match &self.text_content {
            TextContent::None => {}
            TextContent::Value(value) => {
                properties.insert("text".to_owned(), value.into());
            }
            TextContent::FilePath(file_path) => {
                properties.insert(
                    "file".to_owned(),
                    file_path.to_string_lossy().to_string().into(),
                );
            }
        }

        properties
    }
}

#[derive(Debug, PartialEq, Eq)]
enum TextContent {
    None,
    Value(String),
    FilePath(PathBuf),
}

impl Default for TextContent {
    fn default() -> Self {
        Self::None
    }
}

#[derive(Debug, PartialEq, Eq)]
enum AppendLocation {
    Start,
    End,
}

impl AppendLocation {
    fn append_comment(&self, token: &mut Token, comment: String) {
        match self {
            AppendLocation::Start => {
                token.insert_leading_trivia(0, TriviaKind::Comment.with_content(comment));
                token.insert_leading_trivia(1, TriviaKind::Whitespace.with_content("\n"));
            }
            AppendLocation::End => {
                token.push_trailing_trivia(TriviaKind::Comment.with_content(comment));
            }
        }
    }
}

impl Default for AppendLocation {
    fn default() -> Self {
        Self::Start
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::rules::Rule;

    use insta::assert_json_snapshot;

    #[test]
    fn serialize_rule_with_text() {
        let rule: Box<dyn Rule> = Box::new(AppendTextComment::new("content"));

        assert_json_snapshot!("append_text_comment_with_text", rule);
    }

    #[test]
    fn serialize_rule_with_text_at_end() {
        let rule: Box<dyn Rule> = Box::new(AppendTextComment::new("content").at_end());

        assert_json_snapshot!("append_text_comment_with_text_at_end", rule);
    }

    #[test]
    fn configure_with_extra_field_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'append_text_comment',
            text: '',
            prop: "something",
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected field 'prop'");
    }

    #[test]
    fn configure_with_invalid_location_error() {
        let result = json5::from_str::<Box<dyn Rule>>(
            r#"{
            rule: 'append_text_comment',
            text: 'hello',
            location: 'oops',
        }"#,
        );
        pretty_assertions::assert_eq!(result.unwrap_err().to_string(), "unexpected value for field 'location': invalid value `oops` (must be `start` or `end`)");
    }
}
