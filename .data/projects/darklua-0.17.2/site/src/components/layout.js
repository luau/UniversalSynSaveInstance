import * as React from "react"

import Footer, { FooterFiller } from "./footer"
import { Box } from "@mui/system"
import { AppBar, Paper } from "@mui/material"
import NavBar, { NavBarFiller } from "./nav-bar"

const Layout = ({ children }) => {
  const onTopOfDrawer = theme => theme.zIndex.drawer + 1

  return (
    <Paper elevation={0} square sx={{ display: "flex", flexGrow: 1 }}>
      <AppBar position="fixed" sx={{ zIndex: onTopOfDrawer }}>
        <NavBar />
      </AppBar>
      <Box
        component="main"
        sx={{
          display: "flex",
          flexDirection: "column",
          flexGrow: 1,
          margin: 0,
          justifyContent: "space-between",
        }}
      >
        <NavBarFiller />
        <Box sx={{ flexGrow: 1 }}>
          {children}
          <br />
        </Box>
        <FooterFiller />
      </Box>
      <AppBar
        position="fixed"
        color="primary"
        sx={{ top: "auto", bottom: 0, zIndex: onTopOfDrawer }}
      >
        <Footer />
      </AppBar>
    </Paper>
  )
}

export default Layout
