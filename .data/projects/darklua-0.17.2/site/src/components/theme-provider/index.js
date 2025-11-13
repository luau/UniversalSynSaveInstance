import * as React from "react"

import { responsiveFontSizes } from "@mui/material"
import {
  experimental_extendTheme as extendTheme,
  Experimental_CssVarsProvider as CssVarsProvider,
  useColorScheme,
} from "@mui/material/styles"

import LightThemeOptions from "./light"
import DarkThemeOptions from "./dark"
import { usePrism } from "../../hooks/usePrism"

const COMMON_OPTIONS = {
  typography: {
    allVariants: {
      fontFamily: "'Open Sans Variable', system-ui",
    },
    h1: { fontSize: "3.8rem", marginTop: "3rem" },
    h2: { fontSize: "2.7rem", marginTop: "2.3rem" },
    h3: { fontSize: "2rem", marginTop: "1.8rem" },
    h4: { fontSize: "1.5rem", marginTop: "1.5rem" },
    h5: { fontSize: "1.2rem", marginTop: "1.3rem" },
    h6: { fontSize: "1.1rem", marginTop: "1.2rem" },
  },
}
const THEME = responsiveFontSizes(
  extendTheme({
    colorSchemes: {
      light: LightThemeOptions,
      dark: DarkThemeOptions,
    },
    ...COMMON_OPTIONS,
  }),
)

export const ThemeContext = React.createContext(null)

const CustomThemeProvider = ({ children }) => {
  const { mode, setMode } = useColorScheme()

  const setTheme = themeName => {
    setMode(themeName)
  }

  return (
    <ThemeContext.Provider
      value={{
        current: mode,
        setTheme,
      }}
    >
      {children}
    </ThemeContext.Provider>
  )
}

const ThemeProvider = ({ children }) => {
  usePrism()

  return (
    <CssVarsProvider theme={THEME}>
      <CustomThemeProvider>{children}</CustomThemeProvider>
    </CssVarsProvider>
  )
}

export default ThemeProvider
