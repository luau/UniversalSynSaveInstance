import * as React from "react"

import EditorProviders from "../components/editor-providers"
import Seo from "../components/seo"
import NavBar, { NavBarFiller } from "../components/nav-bar"
import {
  Alert,
  AppBar,
  Button,
  Drawer,
  Paper,
  Snackbar,
  Stack,
  Tooltip,
  useMediaQuery,
  useTheme,
} from "@mui/material"
import { Box, styled } from "@mui/system"
import RuleConfiguration from "../components/rule-configuration"
import useCodePreview from "../hooks/useCodePreview"
import SettingsIcon from "@mui/icons-material/Settings"
import LinkIcon from "@mui/icons-material/Link"
import MonacoContainer from "../components/monaco-container"
import ThemeProvider from "../components/theme-provider"
import LoadingEditorProviders from "../components/loading-editor-providers"
import { LocationContext } from "../components/location-context"
import DarkluaProvider from "../components/darklua-provider"
import { DarkluaConfigProvider } from "../components/darklua-config-provider"
import { useDispatchAppEvent } from "../components/app-event-context"

const drawerWidth = 500

const ToolbarButton = styled(Button)(({ theme }) => ({
  color: theme.palette.primary.contrastText,
}))

const TryItToolbar = ({ theme, openConfiguration }) => {
  const getLink = useDispatchAppEvent("getLink")

  const [copiedToClipboardOpened, setCopiedToClipboardOpened] =
    React.useState(false)

  const closeCopiedToClipboard = React.useCallback(
    () => setCopiedToClipboardOpened(false),
    [setCopiedToClipboardOpened],
  )

  return (
    <Paper
      square
      sx={{ p: 1, backgroundColor: theme.palette.primary.dark, height: "48px" }}
      elevation={0}
    >
      <Stack direction="row" spacing={2}>
        <ToolbarButton
          variant="outlined"
          startIcon={<SettingsIcon />}
          onClick={openConfiguration}
          sx={{ alignSelf: "center" }}
        >
          Configure
        </ToolbarButton>
        <Tooltip title="Copy link to clipboard">
          <ToolbarButton
            variant="outlined"
            startIcon={<LinkIcon />}
            onClick={() => {
              getLink()
              setCopiedToClipboardOpened(true)
            }}
            sx={{ alignSelf: "center" }}
          >
            Get Link
            <Snackbar
              open={copiedToClipboardOpened}
              onClose={closeCopiedToClipboard}
              autoHideDuration={2500}
            >
              <Alert
                onClose={closeCopiedToClipboard}
                severity="success"
                variant="outlined"
              >
                Link copied to clipboard
              </Alert>
            </Snackbar>
          </ToolbarButton>
        </Tooltip>
      </Stack>
    </Paper>
  )
}

const TryItLayout = () => {
  const theme = useTheme()
  const isPermanent = useMediaQuery(theme.breakpoints.up("lg"))

  const { editor, previewEditor, ref, previewRef } = useCodePreview()

  const [drawerOpened, setDrawerOpened] = React.useState(false)

  const openConfiguration = () => {
    if (isPermanent) {
      setDrawerOpened(!drawerOpened)
    } else {
      setDrawerOpened(true)
    }
  }
  const closeDrawer = () => {
    setDrawerOpened(false)
  }

  return (
    <Box sx={{ display: "flex", flexGrow: 1, overflow: "hidden" }}>
      <AppBar
        position="fixed"
        sx={{ zIndex: theme => theme.zIndex.drawer + 1 }}
      >
        <NavBar />
      </AppBar>

      <Drawer
        variant={isPermanent ? "permanent" : "temporary"}
        open={drawerOpened}
        onClose={closeDrawer}
        ModalProps={{
          keepMounted: true,
        }}
        sx={{
          display: drawerOpened || !isPermanent ? null : "none",
          width: drawerWidth,
          overflowX: "hidden",
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: {
            width: drawerWidth,
            boxSizing: "border-box",
          },
        }}
      >
        <NavBarFiller />
        <RuleConfiguration />
      </Drawer>

      <Paper
        component="main"
        sx={{ display: "flex", flexDirection: "column", flexGrow: 1, p: 0 }}
      >
        <NavBarFiller />
        <TryItToolbar theme={theme} openConfiguration={openConfiguration} />

        <LoadingEditorProviders>
          <Stack direction="row" spacing={0} sx={{ flexGrow: 1 }}>
            <MonacoContainer
              ref={ref}
              editor={editor}
              sx={{ width: "0.5vw" }}
            />
            <MonacoContainer
              ref={previewRef}
              editor={previewEditor}
              sx={{ width: "0.5vw" }}
            />
          </Stack>
        </LoadingEditorProviders>
      </Paper>
    </Box>
  )
}

export const Head = () => <Seo title="Try it" />

const TryIt = ({ location }) => {
  return (
    <LocationContext.Provider value={location}>
      <ThemeProvider>
        <DarkluaProvider>
          <DarkluaConfigProvider>
            <EditorProviders>
              <TryItLayout />
            </EditorProviders>
          </DarkluaConfigProvider>
        </DarkluaProvider>
      </ThemeProvider>
    </LocationContext.Provider>
  )
}

export default TryIt
