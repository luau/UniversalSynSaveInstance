import * as React from "react"

import { useTheme } from "@mui/material"
import { ThemeContext } from "../components/theme-provider"

export const useThemeMode = ({ light, dark }) => {
  const theme = React.useContext(ThemeContext)
  const themeValue = useTheme()

  if (theme.current === "light") {
    if (typeof light === "function") {
      return light(themeValue)
    }
    return light
  } else {
    if (typeof dark === "function") {
      return dark(themeValue)
    }
    return dark
  }
}
