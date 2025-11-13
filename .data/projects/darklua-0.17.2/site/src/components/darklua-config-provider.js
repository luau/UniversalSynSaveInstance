import json5 from "json5"
import * as React from "react"
import { DarkluaContext } from "./darklua-provider"

export const DarkluaConfigContext = React.createContext(null)
export const SetDarkluaConfigContext = React.createContext(null)

export const DarkluaConfigProvider = ({ children }) => {
  const darklua = React.useContext(DarkluaContext)

  const [darkluaConfig, setDarkluaConfig] = React.useState(null)

  React.useEffect(() => {
    if (darkluaConfig === null && !!darklua) {
      const defaultConfig = json5.stringify(
        {
          rules: json5.parse(darklua.get_serialized_default_rules()),
        },
        null,
        2,
      )
      setDarkluaConfig(defaultConfig)
    }
  }, [darkluaConfig, darklua])

  return (
    <DarkluaConfigContext.Provider value={darkluaConfig ?? "{}"}>
      <SetDarkluaConfigContext.Provider value={setDarkluaConfig}>
        {children}
      </SetDarkluaConfigContext.Provider>
    </DarkluaConfigContext.Provider>
  )
}
