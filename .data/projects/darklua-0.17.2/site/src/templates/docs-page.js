import * as React from "react"
import { graphql } from "gatsby"

import { LocationContext } from "../components/location-context"
import ThemeProvider from "../components/theme-provider"
import DocsPageLayout from "../components/docs-page-layout"
import { MarkdownRenderer } from "../components/markdown-renderer"
import { Paper } from "@mui/material"

const DocsTemplate = ({ data }) => {
  const title = data.markdownRemark.frontmatter.title
  const htmlAst = data.markdownRemark.htmlAst

  return (
    <DocsPageLayout title={title}>
      <Paper elevation={0}>
        <MarkdownRenderer htmlAst={htmlAst} />
      </Paper>
    </DocsPageLayout>
  )
}

const DocsPageTemplate = ({ data, location }) => (
  <LocationContext.Provider value={location}>
    <ThemeProvider>
      <DocsTemplate data={data} />
    </ThemeProvider>
  </LocationContext.Provider>
)

export default DocsPageTemplate

export const pageQuery = graphql`
  query DocsPageBySlug(
    $id: String!
    $previousPostId: String
    $nextPostId: String
  ) {
    site {
      siteMetadata {
        title
      }
    }
    markdownRemark(id: { eq: $id }) {
      id
      excerpt(pruneLength: 160)
      htmlAst
      frontmatter {
        title
        description
      }
      headings {
        depth
        value
      }
    }
    previous: markdownRemark(id: { eq: $previousPostId }) {
      fields {
        slug
      }
      frontmatter {
        title
      }
    }
    next: markdownRemark(id: { eq: $nextPostId }) {
      fields {
        slug
      }
      frontmatter {
        title
      }
    }
  }
`
