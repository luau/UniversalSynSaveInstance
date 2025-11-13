import * as React from "react"

import { Box } from "@mui/system"

const REFRESH_RATE = 0.05

const MonacoContainer = React.forwardRef(({ editor, sx, ...props }, ref) => {
  const containerRef = React.useRef()

  const [monacoWidth, setMonacoWidth] = React.useState(0)
  const [monacoHeight, setMonacoHeight] = React.useState(0)

  React.useLayoutEffect(() => {
    if (!editor) {
      return
    }
    const dimension = { width: monacoWidth, height: monacoHeight }
    editor.layout(dimension)
  }, [editor, monacoWidth, monacoHeight])

  React.useEffect(() => {
    if (!containerRef.current) {
      return
    }
    const refreshView = () => {
      if (!containerRef.current) {
        return
      }
      setMonacoWidth(containerRef.current.clientWidth)
      setMonacoHeight(containerRef.current.clientHeight)
    }
    refreshView()
    const intervalId = setInterval(refreshView, REFRESH_RATE * 1000)
    return () => {
      clearInterval(intervalId)
    }
  }, [containerRef])

  return (
    <Box ref={containerRef} sx={{ flexGrow: 1, ...sx }} {...props}>
      <div
        ref={ref}
        style={{
          width: monacoWidth,
          height: monacoHeight,
        }}
      />
    </Box>
  )
})

export default MonacoContainer
