import * as React from "react"

import Layout from "../components/layout"
import { DocumentationNavigation } from "../components/documentation-nav"
import {
  Divider,
  Drawer as MuiDrawer,
  IconButton,
  Toolbar,
  Typography,
  Paper,
  useMediaQuery,
} from "@mui/material"
import { styled, useTheme } from "@mui/material/styles"
import MenuIcon from "@mui/icons-material/Menu"
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft"
import ChevronRightIcon from "@mui/icons-material/ChevronRight"
import { Box } from "@mui/system"
import { useLocation } from "../components/location-context"

const MARGIN = 4

const openedMixin = (theme, drawerWidth) => ({
  width: drawerWidth,
  // transition: theme.transitions.create("width", {
  //   easing: theme.transitions.easing.sharp,
  //   duration: theme.transitions.duration.enteringScreen,
  // }),
  overflowX: "hidden",
})

const openedMixinSide = (theme, fullWidth, drawerWidth) => ({
  ...theme.breakpoints.keys.reduce((props, breakpoint) => {
    props[theme.breakpoints.only(breakpoint)] = {
      width: `calc(${
        fullWidth ? "100vw" : theme.breakpoints.values[breakpoint] + "px"
      } - ${drawerWidth}px - 1px - 2*${theme.spacing(MARGIN)})`,
    }
    return props
  }, {}),
  // transition: theme.transitions.create("width", {
  //   easing: theme.transitions.easing.sharp,
  //   duration: theme.transitions.duration.enteringScreen,
  // }),
})

const CLOSED_SPACING = 9

const closedMixin = theme => ({
  // transition: theme.transitions.create("width", {
  //   easing: theme.transitions.easing.sharp,
  //   duration: theme.transitions.duration.leavingScreen,
  // }),
  overflowX: "hidden",
  width: `calc(${theme.spacing(CLOSED_SPACING)} + 1px)`,
})

const closedMixinSide = (theme, fullWidth) => ({
  // transition: theme.transitions.create("width", {
  //   easing: theme.transitions.easing.sharp,
  //   duration: theme.transitions.duration.leavingScreen,
  // }),
  overflowX: "hidden",
  ...theme.breakpoints.keys.reduce((props, breakpoint) => {
    props[theme.breakpoints.only(breakpoint)] = {
      width: `calc(${
        fullWidth ? "100vw" : theme.breakpoints.values[breakpoint] + "px"
      } - ${theme.spacing(CLOSED_SPACING)} - 1px - 2*${theme.spacing(MARGIN)})`,
    }
    return props
  }, {}),
})

const DrawerHeader = styled("div")(({ theme }) => ({
  display: "flex",
  alignItems: "center",
  justifyContent: "flex-end",
  padding: theme.spacing(0, 1),
  // necessary for content to be below app bar
  ...theme.mixins.toolbar,
}))

const CUSTOM_PROPS = new Set(["open", "drawerWidth", "fullWidth"])

const Drawer = styled(MuiDrawer, {
  shouldForwardProp: prop => !CUSTOM_PROPS.has(prop),
})(({ theme, open, drawerWidth }) => ({
  width: drawerWidth,
  flexShrink: 0,
  whiteSpace: "nowrap",
  boxSizing: "border-box",
  ...(open && {
    ...openedMixin(theme, drawerWidth),
    "& .MuiDrawer-paper": openedMixin(theme, drawerWidth),
  }),
  ...(!open && {
    ...closedMixin(theme),
    "& .MuiDrawer-paper": closedMixin(theme),
  }),
}))

const Side = styled(Box, {
  shouldForwardProp: prop => !CUSTOM_PROPS.has(prop),
})(({ theme, open, fullWidth, drawerWidth }) => ({
  boxSizing: "border-box",
  ...(open && {
    ...openedMixinSide(theme, fullWidth, drawerWidth),
  }),
  ...(!open && {
    ...closedMixinSide(theme, fullWidth, drawerWidth),
  }),
}))

const DocsPageLayout = ({ title, children }) => {
  const location = useLocation()
  const theme = useTheme()

  const [opened, setOpen] = React.useState(
    location.state ? location.state.drawerOpened || false : false,
  )
  const forceOpenedDrawer = useMediaQuery(theme.breakpoints.up("lg"))
  const fullWidth = useMediaQuery(theme.breakpoints.down("xl"))
  const wideDrawer = useMediaQuery(theme.breakpoints.up("lg"))

  const handleDrawerOpen = () => setOpen(true)
  const handleDrawerClose = () => setOpen(false)

  const drawerOpened = opened || forceOpenedDrawer

  React.useEffect(() => {
    if (forceOpenedDrawer && !opened) {
      setOpen(true)
    }
  }, [forceOpenedDrawer, opened])

  const drawerHeaderContent = forceOpenedDrawer ? (
    <></>
  ) : drawerOpened ? (
    <IconButton onClick={handleDrawerClose}>
      {theme.direction === "rtl" ? <ChevronRightIcon /> : <ChevronLeftIcon />}
    </IconButton>
  ) : (
    <IconButton
      color="inherit"
      aria-label="open drawer"
      onClick={handleDrawerOpen}
      edge="start"
      sx={{
        margin: "auto",
      }}
    >
      <MenuIcon />
    </IconButton>
  )

  const DRAWER_WIDTH = wideDrawer ? 300 : 240

  return (
    <Layout title={title} margin={MARGIN}>
      <Paper
        elevation={0}
        square={false}
        sx={{
          display: "flex",
          border: 0,
          justifyContent: fullWidth ? "center" : "center",
        }}
      >
        <Drawer
          variant="permanent"
          anchor="left"
          open={drawerOpened}
          drawerWidth={DRAWER_WIDTH}
        >
          <Toolbar />
          <DrawerHeader>{drawerHeaderContent}</DrawerHeader>
          <Divider />

          <DocumentationNavigation
            drawerOpened={drawerOpened}
            openDrawer={handleDrawerOpen}
          />
          <Toolbar />
        </Drawer>
        <Side
          open={drawerOpened}
          fullWidth={fullWidth}
          drawerWidth={DRAWER_WIDTH}
          component="main"
          sx={{ width: "100vw", margin: 0 }}
        >
          <header>
            <Typography
              variant="h1"
              itemProp="headline"
              sx={{
                marginTop: 3,
              }}
            >
              {title}
            </Typography>
          </header>
          <hr />
          {children}
          <hr />
        </Side>
      </Paper>
    </Layout>
  )
}

export default DocsPageLayout
