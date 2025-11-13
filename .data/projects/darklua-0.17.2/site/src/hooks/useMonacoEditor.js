import * as React from "react"

import { useRefEffect } from "react-use-ref-effect"
import { MonacoContext } from "../components/editor-providers"

const useMonacoEditor = ({
  defaultText = "",
  language = "lua",
  minimap = true,
  readOnly = false,
  tabSize = 4,
  insertSpaces = false,
}) => {
  const monaco = React.useContext(MonacoContext)

  const [model, setModel] = React.useState(null)
  const [editor, setEditor] = React.useState(null)

  const ref = useRefEffect(
    element => {
      if (!monaco) {
        return
      }
      const newModel = monaco.editor.createModel(defaultText, language)
      newModel.updateOptions({
        tabSize,
        insertSpaces,
      })

      const newEditor = monaco.editor.create(element, {
        model: newModel,
        detectIndentation: true,
        language,
        readOnly,
        minimap: { enabled: minimap },
      })

      setModel(newModel)
      setEditor(newEditor)

      return () => {
        newEditor.dispose()
      }
    },
    [monaco, defaultText, language, minimap, readOnly],
  )

  return { model, editor, ref }
}

export default useMonacoEditor
