import * as React from "react"
import { Button } from "@mui/material"

const NewTabLink = React.forwardRef(({ link, children, ...props }, ref) => {
  return (
    <Button
      ref={ref}
      color="inherit"
      href={link}
      target="_blank"
      rel="noreferrer"
      {...props}
    >
      {children}
    </Button>
  )
})

export default NewTabLink
