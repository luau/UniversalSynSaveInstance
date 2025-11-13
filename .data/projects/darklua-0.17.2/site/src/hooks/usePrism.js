import * as React from "react"

import { createRoot } from "react-dom/client"
import Prism from "prismjs"
import ViewStateLink from "../components/ViewStateLink"
import { Button } from "@mui/material"
import ThemeProvider from "../components/theme-provider"

const TryItButtonLink = React.forwardRef(({ code, configuration }, ref) => {
  return (
    <ThemeProvider>
      <Button
        ref={ref}
        variant="contained"
        size="small"
        component={ViewStateLink}
        to="/try-it"
        target="_blank"
        state={{ code, configuration }}
      >
        Try it
      </Button>
    </ThemeProvider>
  )
})

let registerTryItOnce = false

export const usePrism = () => {
  React.useEffect(() => {
    if (registerTryItOnce) {
      return
    }
    registerTryItOnce = true
    Prism.plugins.toolbar.registerButton("try-it", env => {
      if (env.language !== "lua") {
        return null
      }

      let configuration

      try {
        const context = JSON.parse(
          env.element.parentNode.attributes.__darkluacontext.nodeValue,
        )
        configuration = { rules: context?.rules }
      } catch (_) {}

      const container = document.createElement("div")

      const root = createRoot(container)

      root.render(
        <TryItButtonLink code={env.code} configuration={configuration} />,
      )

      return container
    })
  }, [])

  React.useEffect(() => {
    Prism.highlightAll()
  }, [])
}
