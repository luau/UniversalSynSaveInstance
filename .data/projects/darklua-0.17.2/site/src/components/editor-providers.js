import * as React from "react"

import { useThemeMode } from "../hooks/useThemeMode"

export const MonacoContext = React.createContext()

const THEME_MAPPING = {
  light: "vs",
  dark: "vs-dark",
}

const EditorProviders = ({ children }) => {
  const [monaco, setMonaco] = React.useState(null)

  const monacoTheme = useThemeMode(THEME_MAPPING)

  React.useEffect(() => {
    if (monaco) {
      monaco.editor.setTheme(monacoTheme)
    }
  }, [monaco, monacoTheme])

  React.useEffect(() => {
    import("monaco-editor")
      .then(monaco => {
        setMonaco(monaco)
      })
      .catch(error => {
        console.warn(`unable to load monaco-editor: ${error}`)
      })
  }, [])

  return (
    <MonacoContext.Provider value={monaco}>{children}</MonacoContext.Provider>
  )
}

export default EditorProviders
