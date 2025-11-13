import * as React from "react"

const localStorage = typeof window !== "undefined" ? window.localStorage : null

const createUseLocalStorage = itemName => {
  const useLocalStorage = initialValue => {
    const [item, setItem] = React.useState(() => {
      const item = localStorage && localStorage.getItem(itemName)
      if (item === null) {
        return initialValue
      } else {
        return item
      }
    })

    const updateCookie = value => {
      if (localStorage) {
        localStorage.setItem(itemName, value)
      }
      setItem(value)
    }

    return [item, updateCookie]
  }

  return useLocalStorage
}

export const useThemeLocalStorage = createUseLocalStorage("theme")
