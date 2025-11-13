import * as React from "react"

import Layout from "../components/layout"
import ThemeProvider from "../components/theme-provider"
import { LocationContext } from "../components/location-context"
import { Button, Paper, Stack, Typography } from "@mui/material"
import ViewStateLink from "../components/ViewStateLink"
import RocketLaunchIcon from "@mui/icons-material/RocketLaunch"
import Seo from "../components/seo"

const LINKS = [
  { label: "Home", link: "/" },
  { label: "Documentation", link: "/docs" },
  { label: "Try darklua", link: "/try-it", icon: () => <RocketLaunchIcon /> },
]

const NotFound = () => {
  return (
    <Layout>
      <Paper
        square
        elevation={1}
        sx={{ maxWidth: "lg", margin: "auto", mt: 0, height: "100%" }}
      >
        <Typography variant="h1" align="center">
          404: Not Found
        </Typography>
        <Typography variant="h4" align="center">
          You landed on a page that doesn&#39;t exist 🥲
        </Typography>

        <Stack spacing={4} pt={4} mx={8}>
          {LINKS.map(({ label, link, icon }) => (
            <Button
              key={label}
              variant="contained"
              size="large"
              component={ViewStateLink}
              endIcon={icon && icon()}
              to={link}
            >
              {label}
            </Button>
          ))}
        </Stack>
      </Paper>
    </Layout>
  )
}

const NotFoundPage = ({ location }) => (
  <LocationContext.Provider value={location}>
    <ThemeProvider>
      <NotFound />
    </ThemeProvider>
  </LocationContext.Provider>
)

export const Head = () => <Seo title="Not Found" />

export default NotFoundPage
