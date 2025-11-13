import * as React from "react"
import * as production from "react/jsx-runtime"
import { Link } from "gatsby"
import rehypeReact from "rehype-react"

import { styled, useTheme } from "@mui/system"
import {
  Typography,
  Link as MuiLink,
  TableRow,
  TableCell,
  TableHead,
  TableBody,
  TableContainer,
  Paper,
  Table,
} from "@mui/material"
import { RuleReference } from "./rule-reference"
import { toHast } from "mdast-util-to-hast"
import { fromMarkdown } from "mdast-util-from-markdown"
import ViewStateLink from "./ViewStateLink"
import { CompareCode } from "./compare-code"
import { unified } from "unified"

const AnchorOffsetByToolbar = styled("div")(({ theme }) => {
  const newStyle = {
    display: "block",
    position: "relative",
    visibility: "hidden",
    bottom: `${theme.mixins.toolbar.minHeight}px`,
  }

  Object.entries(theme.mixins.toolbar).forEach(([key, value]) => {
    if (key.startsWith("@media")) {
      newStyle[key] = { bottom: `${value.minHeight}px` }
    }
  })

  return newStyle
})

const createTypographyComponent = (level, linkable = false) => {
  const LinkableHeader = ({ children, id = null, ...props }) => {
    if (!linkable || !id) {
      return (
        <Typography variant={level} {...props}>
          {children}
        </Typography>
      )
    }

    return (
      <Typography variant={level} {...props}>
        <AnchorOffsetByToolbar id={id} />

        {children}

        <MuiLink
          component={Link}
          to={`#${id}`}
          underline="none"
          sx={{
            ml: "0.5rem",
            opacity: 0.3,
          }}
        >
          ¶
        </MuiLink>
      </Typography>
    )
  }

  return LinkableHeader
}

const visitNodes = (node, callback) => {
  callback(node)
  if (!!node.children) {
    node.children.forEach(child => {
      visitNodes(child, callback)
    })
  }
}

const generateId = ({ children, ...node }) => {
  const text = children[0].value
  return text.toLowerCase().replaceAll(" ", "-")
}

const TextLink = React.forwardRef((props, ref) => {
  const theme = useTheme()

  const linkColor =
    theme.palette.mode === "dark"
      ? theme.palette.primary.light
      : theme.palette.primary.dark

  return <ViewStateLink ref={ref} style={{ color: linkColor }} {...props} />
})

const TypographyBody = createTypographyComponent("body1")
const typographyParagraph = ({ children }) => {
  return (
    <p>
      <TypographyBody component="span">{children}</TypographyBody>
    </p>
  )
}

const TableContainerWrapper = ({
  children,
  "aria-label": ariaLabel,
  ...props
}) => (
  <TableContainer component={Paper} {...props}>
    <Table sx={{ minWidth: 650 }} aria-label={ariaLabel}>
      {children}
    </Table>
  </TableContainer>
)

const MarkdownLink = ({ href, ...props }) => <TextLink to={href} {...props} />

const renderAst = unified().use(rehypeReact, {
  ...production,
  components: {
    h1: createTypographyComponent("h1"),
    h2: createTypographyComponent("h2", true),
    h3: createTypographyComponent("h3", true),
    h4: createTypographyComponent("h4"),
    h5: createTypographyComponent("h5"),
    h6: createTypographyComponent("h6"),
    p: typographyParagraph,
    a: MarkdownLink,
    "rule-reference": RuleReference,
    "compare-code": CompareCode,
    "table-container": TableContainerWrapper,
    "table-row": TableRow,
    "table-cell": TableCell,
    "table-head": TableHead,
    "table-body": TableBody,
  },
})

export const MarkdownRenderer = ({ htmlAst }) => {
  const [ast, setAst] = React.useState(null)

  React.useEffect(() => {
    addIdToHtmlHeaders(htmlAst)
    setAst(htmlAst)
  }, [htmlAst])

  return renderAst.stringify(ast ?? htmlAst)
}

const EMPTY_OBJECT = JSON.stringify({})

export const RenderMarkdown = ({ markdown, ...context }) => {
  const serializedContext = JSON.stringify(context)

  const htmlAst = React.useMemo(() => {
    const html = toHast(fromMarkdown(markdown))
    if (serializedContext !== EMPTY_OBJECT) {
      html.children[0].properties.__darkluacontext = serializedContext
    }
    return html
  }, [markdown, serializedContext])

  return <MarkdownRenderer htmlAst={htmlAst} />
}

export const RenderCode = ({ code, language = "lua", ...context }) => (
  <RenderMarkdown
    markdown={`\`\`\`${language}\n${code}${
      code.endsWith("\n") ? "" : "\n"
    }\`\`\``}
    {...context}
  />
)

const addIdToHtmlHeaders = htmlAst => {
  const generatedIds = new Set()

  visitNodes(htmlAst, node => {
    if (node.type === "element") {
      const { tagName, properties } = node

      if (tagName === "h2" || tagName === "h3") {
        const baseId = generateId(node)

        if (generatedIds.has(baseId)) {
          let i = 0
          let newId = ""
          do {
            i += 1
            newId = `${baseId}-${i}`
          } while (generatedIds.has(newId))
          generatedIds.add(newId)

          properties.id = newId
        } else {
          generatedIds.add(baseId)

          properties.id = baseId
        }
      }
    }
  })
}
