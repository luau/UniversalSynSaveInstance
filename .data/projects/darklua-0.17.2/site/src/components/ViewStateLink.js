import * as React from "react"

import { Link } from "gatsby"
import { ThemeContext } from "./theme-provider"

const ViewStateLink = React.forwardRef(
  ({ to, state = {}, children, ...props }, ref) => {
    const { current: currentThemeName } = React.useContext(ThemeContext)

    return (
      <Link
        ref={ref}
        to={to ?? ""}
        state={{ currentThemeName, ...state }}
        {...props}
      >
        {children}
      </Link>
    )
  },
)

export default ViewStateLink
