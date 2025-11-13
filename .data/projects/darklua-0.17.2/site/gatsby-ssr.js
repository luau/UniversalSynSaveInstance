import * as React from "react"
import { getInitColorSchemeScript } from "@mui/material/styles"

export function onRenderBody({ setPreBodyComponents }) {
  setPreBodyComponents([getInitColorSchemeScript()])
}
