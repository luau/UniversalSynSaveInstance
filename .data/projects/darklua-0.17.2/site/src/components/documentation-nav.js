import * as React from "react"
import { graphql, useStaticQuery } from "gatsby"

import {
  Collapse,
  Divider,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
} from "@mui/material"
import ExpandLess from "@mui/icons-material/ExpandLess"
import ExpandMore from "@mui/icons-material/ExpandMore"
import MenuBook from "@mui/icons-material/MenuBook"
import Settings from "@mui/icons-material/Settings"
import Rule from "@mui/icons-material/Rule"
import ViewStateLink from "./ViewStateLink"
import { useLocation } from "./location-context"

const query = graphql`
  query allDocumentation {
    site {
      siteMetadata {
        title
        groupsOrder
        rulesGroup
      }
    }
    allMarkdownRemark(filter: { frontmatter: { group: { ne: null } } }) {
      nodes {
        fields {
          slug
        }
        frontmatter {
          title
          group
          order
        }
      }
    }
    rules: allMarkdownRemark(filter: { frontmatter: { group: { eq: null } } }) {
      nodes {
        fields {
          slug
          ruleName
        }
        frontmatter {
          added_in
        }
      }
    }
  }
`

const DocumentationLink = ({ title, slug, isSelected, drawerOpened }) => {
  return (
    <ListItemButton
      selected={isSelected}
      sx={{ pl: 4 }}
      component={ViewStateLink}
      to={slug}
      state={{ drawerOpened }}
    >
      <ListItemText
        primary={title}
        primaryTypographyProps={{
          textOverflow: "ellipsis",
          overflow: "hidden",
        }}
      />
    </ListItemButton>
  )
}

const groupIconMap = {
  Guides: MenuBook,
  Configuration: Settings,
  Rules: Rule,
}

const GroupIcon = ({ groupName }) => {
  const IconComponent = groupIconMap[groupName]
  if (IconComponent) {
    return <IconComponent />
  }
  return <MenuBook />
}

const DocumentationSection = ({ documentation }) => (
  <>
    <Divider />
    <li>
      <Typography
        sx={{ mt: 0.5, ml: 2 }}
        color="text.secondary"
        display="block"
        variant="caption"
      >
        {documentation}
      </Typography>
    </li>
  </>
)

const DocumentationGroup = ({ name, content, drawerOpened, openDrawer }) => {
  const [open, setOpen] = React.useState(true)

  return (
    <>
      <ListItemButton
        onClick={() => {
          if (drawerOpened) {
            setOpen(!open)
          } else {
            openDrawer()
            setOpen(true)
          }
        }}
      >
        <ListItemIcon>
          <GroupIcon groupName={name} />
        </ListItemIcon>
        {drawerOpened && (
          <>
            <ListItemText primary={name} />
            {open ? <ExpandLess /> : <ExpandMore />}
          </>
        )}
      </ListItemButton>
      {drawerOpened && (
        <Collapse in={open} timeout="auto" unmountOnExit>
          <List component="div" disablePadding>
            {content.map(documentation => {
              if (typeof documentation === "string") {
                return (
                  <DocumentationSection
                    key={documentation}
                    documentation={documentation}
                  />
                )
              } else {
                return (
                  <DocumentationLink
                    key={documentation.slug}
                    drawerOpened={drawerOpened}
                    {...documentation}
                  />
                )
              }
            })}
          </List>
        </Collapse>
      )}
    </>
  )
}

const sortGroupContent = (a, b) => a.order - b.order

export const DocumentationNavigation = ({ drawerOpened, openDrawer }) => {
  const data = useStaticQuery(query)
  const location = useLocation()
  const { pathname } = location

  const groups = React.useMemo(() => {
    const groupNameToIndex = new Map()
    const groups = data.site.siteMetadata.groupsOrder.map(
      (groupName, index) => {
        groupNameToIndex.set(groupName, index)
        return { name: groupName, content: [] }
      },
    )

    const documents = data.allMarkdownRemark.nodes.map(node => {
      const slug = `/docs${node.fields.slug}`
      return {
        ...node.frontmatter,
        slug,
        isSelected: pathname === slug,
      }
    })

    documents.forEach(document => {
      const { group: groupName } = document
      const groupIndex = groupNameToIndex.get(groupName)

      if (typeof groupIndex !== "number") {
        const { title, slug } = document
        throw new Error(
          `Unknown group '${groupName}' associated with '${title}' (at ${slug})`,
        )
      }
      groups[groupIndex].content.push(document)
    })

    groups.forEach(group => group.content.sort(sortGroupContent))

    // Append generate rules documentation in the correct group
    const rulesGroupName = data.site.siteMetadata.rulesGroup
    const rulesGroup = groups.find(({ name }) => name === rulesGroupName)

    const [releasedRules, unreleasedRules] = data.rules.nodes.reduce(
      ([releasedRules, unreleasedRules], { fields, frontmatter }) => {
        const { slug: ruleSlug, ruleName } = fields
        const { added_in: addedIn } = frontmatter
        const slug = `/docs/rules${ruleSlug}`

        const ruleLinkProps = {
          title: ruleName,
          slug: slug,
          isSelected: pathname === slug,
        }

        if (addedIn === "unreleased") {
          unreleasedRules.push(ruleLinkProps)
        } else {
          releasedRules.push(ruleLinkProps)
        }

        return [releasedRules, unreleasedRules]
      },
      [[], []],
    )
    const sortByTitle = (a, b) => a.title > b.title
    releasedRules.sort(sortByTitle)
    unreleasedRules.sort(sortByTitle)

    rulesGroup.content.push("Rules")
    rulesGroup.content.push(...releasedRules)
    rulesGroup.content.push("Unreleased rules")
    rulesGroup.content.push(...unreleasedRules)

    return groups
  }, [data, pathname])

  return (
    <List>
      {groups.map(({ name, content }) => (
        <DocumentationGroup
          location={location}
          key={name}
          name={name}
          content={content}
          drawerOpened={drawerOpened}
          openDrawer={openDrawer}
        />
      ))}
    </List>
  )
}
