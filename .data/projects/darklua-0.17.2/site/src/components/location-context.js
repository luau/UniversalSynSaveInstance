import * as React from "react"

export const LocationContext = React.createContext(null)

export const useLocation = () => React.useContext(LocationContext)
