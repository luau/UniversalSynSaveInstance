import * as React from "react"

import Layout from "../components/layout"
import { Paper, Typography } from "@mui/material"
import { DocumentationNavigation } from "../components/documentation-nav"
import { useTheme } from "@mui/system"
import { LocationContext } from "../components/location-context"
import ThemeProvider from "../components/theme-provider"
import Seo from "../components/seo"

const Docs = () => {
  const theme = useTheme()
  return (
    <Layout>
      <Paper
        square
        sx={{
          maxWidth: "md",
          margin: "auto",
          pt: 2,
          pb: 6,
          color: theme.palette.primary.contrastText,
          backgroundColor: theme.palette.primary.main,
        }}
      >
        <Typography variant="h1" align="center">
          Documentation
        </Typography>
        <Typography variant="subtitle1" align="center">
          Learn things here
        </Typography>
      </Paper>
      <Paper sx={{ maxWidth: "md", margin: "auto", marginTop: 4 }}>
        <DocumentationNavigation drawerOpened={true} openDrawer={() => {}} />
      </Paper>
    </Layout>
  )
}

const DocsPage = ({ location }) => (
  <LocationContext.Provider value={location}>
    <ThemeProvider>
      <Docs />
    </ThemeProvider>
  </LocationContext.Provider>
)

export const Head = () => <Seo title="Documentation" />

export default DocsPage
