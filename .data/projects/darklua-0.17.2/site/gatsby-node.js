const path = require(`path`)
const { createFilePath } = require(`gatsby-source-filesystem`)
const JSON5 = require(`json5`)

const darklua = require("./darklua-wasm/node-pkg/darklua_wasm")

exports.onCreateWebpackConfig = ({ actions }) => {
  actions.setWebpackConfig({
    experiments: {
      syncWebAssembly: true,
    },
  })
}

exports.createPages = async ({ graphql, actions, reporter }) => {
  const { createPage } = actions

  // Get all markdown documentation posts
  const result = await graphql(`
    {
      allMarkdownRemark(
        limit: 1000
        filter: { fileAbsolutePath: { regex: "/content/docs/" } }
      ) {
        nodes {
          id
          fields {
            slug
          }
        }
      }
    }
  `)

  if (result.errors) {
    reporter.panicOnBuild(
      `There was an error loading the documentation content`,
      result.errors,
    )
    return
  }

  const documentionPages = result.data.allMarkdownRemark.nodes

  if (documentionPages.length === 0) {
    reporter.panicOnBuild(`No documentation page was found`)
    return
  }

  const docsPage = path.resolve(`./src/templates/docs-page.js`)

  documentionPages.forEach((page, index) => {
    const previousPostId = index === 0 ? null : documentionPages[index - 1].id
    const nextPostId =
      index === documentionPages.length - 1
        ? null
        : documentionPages[index + 1].id

    const path = `/docs${page.fields.slug}`

    createPage({
      path,
      component: docsPage,
      context: {
        id: page.id,
        previousPostId,
        nextPostId,
      },
    })
  })

  // Get all markdown rules information
  const ruleResults = await graphql(`
    {
      allMarkdownRemark(
        limit: 1000
        filter: { fileAbsolutePath: { regex: "/content/rules/" } }
      ) {
        nodes {
          id
          fields {
            slug
          }
        }
      }
    }
  `)

  if (result.errors) {
    reporter.panicOnBuild(
      `There was an error loading the documentation content`,
      ruleResults.errors,
    )
    return
  }

  const ruleNodes = ruleResults.data.allMarkdownRemark.nodes.map(node => {
    return {
      rule_name: node.fields.slug.substring(1, -2),
      ...node,
    }
  })
  ruleNodes.sort((a, b) => a.rule_name.localeCompare(b.rule_name))

  const ruleDocsPage = path.resolve(`./src/templates/rule-docs-page.js`)

  ruleNodes.forEach((page, index) => {
    const previousPostId = index === 0 ? null : ruleNodes[index - 1].id
    const nextPostId =
      index === ruleNodes.length - 1 ? null : ruleNodes[index + 1].id

    const path = `/docs/rules${page.fields.slug}`

    createPage({
      path,
      component: ruleDocsPage,
      context: {
        id: page.id,
        previousPostId,
        nextPostId,
      },
    })
  })
}

exports.onCreateNode = ({ node, actions, getNode, reporter }) => {
  const { createNodeField } = actions

  if (node.internal.type === `MarkdownRemark`) {
    const value = createFilePath({ node, getNode })

    createNodeField({
      name: `slug`,
      node,
      value,
    })

    const { fileAbsolutePath, frontmatter } = node

    if (fileAbsolutePath.match("/content/rules/")) {
      const ruleName = path.parse(fileAbsolutePath).name

      createNodeField({
        name: `ruleName`,
        node,
        value: ruleName,
      })

      if (!!frontmatter.examples) {
        createNodeField({
          name: `examplesOut`,
          node,
          value: frontmatter.examples.map(({ content, rules }, i) => {
            try {
              const ruleStack = rules ? JSON5.parse(rules) : [ruleName]
              return darklua.process_code(`${content}`, { rules: ruleStack })
            } catch (e) {
              console.warn("unable to process code:", content)
              console.error(e)
              reporter.panicOnBuild(`Unable to process code example ${e}`)
            }
            return `-- [Failed to generate example code. Please report this error]`
          }),
        })
      }
    }
  }
}

exports.createSchemaCustomization = ({ actions }) => {
  const { createTypes } = actions

  // Explicitly define the siteMetadata {} object
  // This way those will always be defined even if removed from gatsby-config.js

  // Also explicitly define the Markdown frontmatter
  // This way the "MarkdownRemark" queries will return `null` even when no
  // blog posts are stored inside "content/blog" instead of returning an error
  createTypes(`
    type SiteSiteMetadata {
      siteUrl: String
      social: Social
    }

    type Author {
      name: String
      summary: String
    }

    type Social {
      twitter: String
    }

    type MarkdownRemark implements Node {
      frontmatter: Frontmatter
      fields: Fields
    }

    type Frontmatter {
      title: String
      description: String
      date: Date @dateformat
      group: String
      order: Int

      added_in: String
      parameters: [RuleParameter]
      examples: [RuleExample]
    }

    type Fields {
      slug: String
    }

    type RuleParameter {
      name: String!
      type: String!
      default: String
      description: String
      added_in: String
      required: Boolean
    }

    type RuleExample {
      content: String
      rules: String
    }
  `)
}
