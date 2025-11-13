import * as React from "react"

import useMonacoEditor from "./useMonacoEditor"
import { DarkluaContext } from "../components/darklua-provider"
import { useLocation } from "../components/location-context"
import { DarkluaConfigContext } from "../components/darklua-config-provider"

const DEFAULT_TEXT = "-- paste code here to preview the darklua transform"

const useCodePreview = () => {
  const darklua = React.useContext(DarkluaContext)
  const darkluaConfig = React.useContext(DarkluaConfigContext)
  const location = useLocation()

  const {
    model: previewModel,
    editor: previewEditor,
    ref: previewRef,
  } = useMonacoEditor({ readOnly: true })

  const locationCode = location.state?.code
  const defaultText = locationCode || DEFAULT_TEXT
  const { model, editor, ref } = useMonacoEditor({ defaultText })

  const processCode = React.useCallback(
    code => {
      try {
        return darklua.process_code(code, darkluaConfig)
      } catch (error) {
        return (
          `--[[\n\tan error happened while trying to process the code:\n${error}\n\n` +
          `Configuration: ${darkluaConfig}]]`
        )
      }
    },
    [darklua, darkluaConfig],
  )

  React.useEffect(() => {
    if (!model || !previewModel) {
      return
    }
    const onChange = _event => {
      const newCode = processCode(model.getValue())
      previewModel.setValue(newCode)
    }
    const connection = model.onDidChangeContent(onChange)
    onChange()

    return () => connection.dispose()
  }, [model, previewModel, processCode])

  return { previewEditor, editor, previewRef, ref }
}

export default useCodePreview
