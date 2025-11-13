import * as React from "react"

import { CircularProgress } from "@mui/material"
import { Box } from "@mui/system"

import { MonacoContext } from "../components/editor-providers"
import { DarkluaContext } from "./darklua-provider"

const APPEARANCE_DELAY = 0.5

const DelayAppearance = ({ children }) => {
  const [hasWaited, setHasWaited] = React.useState(false)

  React.useEffect(() => {
    const handle = setTimeout(() => {
      setHasWaited(true)
    }, APPEARANCE_DELAY * 1000)
    return () => clearTimeout(handle)
  }, [])

  if (hasWaited) {
    return children
  } else {
    return <></>
  }
}

const LoadingEditorProviders = ({ children }) => {
  const monaco = React.useContext(MonacoContext)
  const darklua = React.useContext(DarkluaContext)

  if (!!monaco && !!darklua) {
    return children
  }

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        p: 4,
      }}
    >
      <DelayAppearance>
        <CircularProgress key="loading" />
      </DelayAppearance>
    </Box>
  )
}

export default LoadingEditorProviders
