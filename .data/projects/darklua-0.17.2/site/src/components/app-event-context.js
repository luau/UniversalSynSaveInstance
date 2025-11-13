import * as React from "react"

export const DarkluaAppEvent = "DarkluaApp"

export const useDispatchAppEvent = kind => {
  return React.useCallback(
    payload => {
      const event = new CustomEvent(DarkluaAppEvent, {
        detail: { kind, ...payload },
      })

      document.dispatchEvent(event)
    },
    [kind],
  )
}

export const useAppEvent = (kind, fn, deps) => {
  const memoizedFn = React.useCallback(fn, deps)

  React.useEffect(() => {
    const handleEvent = ({ detail }) => {
      if (detail.kind === kind) {
        memoizedFn(detail)
      }
    }

    document.addEventListener(DarkluaAppEvent, handleEvent)

    return () => {
      document.removeEventListener(DarkluaAppEvent, handleEvent)
    }
  }, [kind, memoizedFn])
}
