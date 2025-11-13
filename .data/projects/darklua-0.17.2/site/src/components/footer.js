import * as React from "react"

import { Box } from "@mui/system"
import { Link, Toolbar, Typography } from "@mui/material"
import { useThemeMode } from "../hooks/useThemeMode"

const FooterLink = ({ href, content, color }) => {
  return (
    <Link
      underline="always"
      color={color}
      href={href}
      target="_blank"
      rel="noreferrer"
    >
      <Typography color={color}>{content}</Typography>
    </Link>
  )
}

const THEME_MAPPING = {
  light: theme => theme.palette.primary.contrastText,
  dark: theme => theme.palette.primary.main,
}

const Footer = () => {
  const color = useThemeMode(THEME_MAPPING)
  return (
    <Toolbar variant="dense">
      <Box
        component={"footer"}
        sx={{
          display: "flex",
          alignSelf: "bottom",
          alignContent: "center",
          margin: "auto",
        }}
      >
        <FooterLink
          color={color}
          href="https://seaofvoices.ca"
          content="SEA OF VOICES"
        />
        <Typography color={color}>. BUILT WITH&nbsp;</Typography>
        <FooterLink
          color={color}
          href="https://www.gatsbyjs.com"
          content="GATSBY"
        />
      </Box>
    </Toolbar>
  )
}

export const FooterFiller = () => <Toolbar variant="dense" />

export default Footer
