import { List, ListItemButton, ListItemText } from "@mui/material"
import { graphql, useStaticQuery } from "gatsby"
import * as React from "react"
import { RenderMarkdown } from "./markdown-renderer"
import ViewStateLink from "./ViewStateLink"

const RuleListItem = ({ ruleName, description, link }) => {
  return (
    <ListItemButton component={ViewStateLink} to={link}>
      <ListItemText primary={ruleName} secondary={description} />
    </ListItemButton>
  )
}

export const RuleReference = () => {
  const data = useStaticQuery(query)

  const allRules = React.useMemo(() => {
    const rules = data.rules.nodes.map(node => {
      const { slug, ruleName } = node.fields
      const { description, added_in } = node.frontmatter

      return {
        ruleName,
        description,
        addedIn: added_in,
        link: `/docs/rules${slug}`,
      }
    })

    rules.sort((a, b) => a.ruleName.localeCompare(b.ruleName))

    return rules
  }, [data])

  const released = React.useMemo(
    () =>
      allRules.filter(
        ({ addedIn }) => addedIn !== null && addedIn !== "unreleased",
      ),
    [allRules],
  )
  const unreleased = React.useMemo(
    () =>
      allRules.filter(
        ({ addedIn }) => addedIn === null || addedIn === "unreleased",
      ),
    [allRules],
  )

  return (
    <>
      <RenderMarkdown markdown="## All Rules" />
      <List dense={true}>
        {released.map(({ ruleName, description, link }) => (
          <RuleListItem
            key={ruleName}
            ruleName={ruleName}
            description={description}
            link={link}
          />
        ))}
      </List>
      <RenderMarkdown markdown="## Unreleased Rules" />
      <RenderMarkdown markdown="These rules will be added in the next release:" />
      <List dense={true}>
        {unreleased.map(({ ruleName, description, link }) => (
          <RuleListItem
            key={ruleName}
            ruleName={ruleName}
            description={description}
            link={link}
          />
        ))}
      </List>
    </>
  )
}

const query = graphql`
  query allRules {
    rules: allMarkdownRemark(filter: { frontmatter: { group: { eq: null } } }) {
      nodes {
        fields {
          slug
          ruleName
        }
        frontmatter {
          added_in
          description
        }
      }
    }
  }
`
