import * as React from "react"

import {
  Button,
  IconButton,
  Menu,
  MenuItem,
  Toolbar,
  useMediaQuery,
  useTheme,
} from "@mui/material"
import MenuIcon from "@mui/icons-material/Menu"
import NewTabLink from "./new-tab-link"
import { Box, styled } from "@mui/system"
import { ThemeContext } from "./theme-provider"
import ThemeSwitch from "./theme-switch"
import ViewStateLink from "./ViewStateLink"

const NavigationLink = ({ label, link }) => {
  if (link.startsWith("https://")) {
    return (
      <NewTabLink color="inherit" href={link} target="_blank" rel="noreferrer">
        {label}
      </NewTabLink>
    )
  } else {
    return (
      <Button color="inherit" component={ViewStateLink} to={link}>
        {label}
      </Button>
    )
  }
}

const TOPBAR_LINKS = [
  { label: "darklua", link: "/" },
  { label: "Documentation", link: "/docs" },
  { label: "Try it", link: "/try-it" },
  { label: "GitHub", link: "https://github.com/seaofvoices/darklua" },
]

const FoldedMenuNavBar = ({ children }) => {
  const [anchor, setAnchor] = React.useState(null)

  const openMenu = React.useCallback(
    event => {
      setAnchor(event.currentTarget)
    },
    [setAnchor],
  )

  const closeMenu = React.useCallback(() => {
    setAnchor(null)
  }, [setAnchor])

  return (
    <Toolbar>
      <IconButton
        size="large"
        aria-label="darklua navigation menu"
        aria-controls="navigation-menu"
        aria-haspopup="true"
        onClick={openMenu}
        color="inherit"
      >
        <MenuIcon />
      </IconButton>
      <Menu
        sx={{ mt: "45px" }}
        id="navigation-menu"
        anchorEl={anchor}
        anchorOrigin={{
          vertical: "top",
          horizontal: "right",
        }}
        keepMounted
        transformOrigin={{
          vertical: "top",
          horizontal: "right",
        }}
        open={Boolean(anchor)}
        onClose={closeMenu}
      >
        {TOPBAR_LINKS.map(({ label, link }, i) => (
          <MenuItem
            key={label}
            onClick={() => {
              closeMenu()
            }}
          >
            <NavigationLink label={label} link={link} />
          </MenuItem>
        ))}
      </Menu>
      <Box sx={{ flexGrow: 1 }} />
      {children}
    </Toolbar>
  )
}

const NavBar = () => {
  const theme = React.useContext(ThemeContext)

  const handleChange = () => {
    theme.setTheme(theme.current === "light" ? "dark" : "light")
  }

  const materialTheme = useTheme()
  const useFoldedMenu = useMediaQuery(materialTheme.breakpoints.down("sm"))

  const themeSwitch = (
    <ThemeSwitch checked={theme.current === "dark"} onChange={handleChange} />
  )

  if (useFoldedMenu) {
    return <FoldedMenuNavBar>{themeSwitch}</FoldedMenuNavBar>
  }

  return (
    <Toolbar>
      {TOPBAR_LINKS.map(({ label, link }, i) =>
        i === 0 ? (
          <Box key={label} sx={{ flexGrow: 1 }}>
            <NavigationLink label={label} link={link} />
          </Box>
        ) : (
          <NavigationLink key={label} label={label} link={link} />
        ),
      )}
      {themeSwitch}
    </Toolbar>
  )
}

export const NavBarFiller = styled("div")(({ theme }) => ({
  // necessary for content to be below app bar
  ...theme.mixins.toolbar,
}))

export default NavBar
