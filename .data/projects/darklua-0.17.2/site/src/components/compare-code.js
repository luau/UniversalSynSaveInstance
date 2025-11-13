import * as React from "react"

import { RenderCode } from "./markdown-renderer"
import {
  Box,
  Paper,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Tabs,
  useMediaQuery,
} from "@mui/material"
import { useTheme } from "@mui/material/styles"

const a11yProps = identifier => ({
  id: `compare-code-${identifier}-tab`,
  "aria-controls": `compare-code-${identifier}-panel`,
})

const TabPanel = ({ children, value, index, identifier, ...other }) => {
  const a11y = a11yProps(identifier)
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`code-example-${index}-tabpanel`}
      aria-labelledby={a11y.id}
      {...other}
    >
      <Box sx={{ p: 3, display: value !== index ? "none" : null }}>
        {children}
      </Box>
    </div>
  )
}

const CompareCodeTabPabel = ({ value, index, title, language, code }) => (
  <TabPanel value={value} index={index} identifier={title}>
    <RenderCode language={language} code={code} />
  </TabPanel>
)

const CompareCodeTabs = ({
  hidden,
  leftTitle,
  rightTitle,
  leftLanguage,
  rightLanguage,
  leftCode,
  rightCode,
}) => {
  const [value, setValue] = React.useState(0)

  const handleChange = (_, newValue) => {
    setValue(newValue)
  }

  return (
    <Box sx={{ display: hidden ? "none" : null }}>
      <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
        <Tabs value={value} onChange={handleChange} aria-label="compare code">
          <Tab label={leftTitle} {...a11yProps(leftTitle)} />
          <Tab label={rightTitle} {...a11yProps(rightTitle)} />
        </Tabs>
      </Box>
      <CompareCodeTabPabel
        value={value}
        index={0}
        title={leftTitle}
        language={leftLanguage}
        code={leftCode}
      />
      <CompareCodeTabPabel
        value={value}
        index={1}
        title={rightTitle}
        language={rightLanguage}
        code={rightCode}
      />
    </Box>
  )
}

const CompareCodeTableCell = ({ language, code }) => (
  <TableCell component="th" scope="row" sx={{ padding: 0 }}>
    <Box sx={{ overflowX: "auto", padding: 2 }}>
      <RenderCode language={language} code={code} />
    </Box>
  </TableCell>
)

const CompareCodeTable = ({
  hidden,
  leftTitle,
  rightTitle,
  leftLanguage,
  rightLanguage,
  leftCode,
  rightCode,
}) => {
  return (
    <TableContainer
      component={Paper}
      sx={{
        display: hidden ? "none" : null,
        maxWidth: "100%",
        margin: "auto",
      }}
    >
      <Table
        aria-label="code example"
        sx={{ tableLayout: "fixed" }}
        stickyHeader={true}
      >
        <TableHead>
          <TableRow>
            <TableCell>{leftTitle}</TableCell>
            <TableCell>{rightTitle}</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          <TableRow key="code-content">
            <CompareCodeTableCell language={leftLanguage} code={leftCode} />
            <CompareCodeTableCell language={rightLanguage} code={rightCode} />
          </TableRow>
        </TableBody>
      </Table>
    </TableContainer>
  )
}

const filterReactElements = child => {
  return React.isValidElement(child)
}

export const CompareCode = ({
  children,
  left,
  right,
  "left-language": leftLanguage,
  "right-language": rightLanguage,
}) => {
  const columns = children.filter(filterReactElements)

  const theme = useTheme()
  const withTabs = useMediaQuery(theme.breakpoints.down("lg"))

  const codeSnippets = columns.map(element => {
    if (typeof element.props.children === "string") {
      return element.props.children
    }
    const codeContent = element.props.children
      .map(codeChild => {
        if (typeof codeChild == "string") {
          return codeChild
        } else if (typeof codeChild.props.children == "string") {
          return "\n" + codeChild.props.children
        } else {
          return codeChild.props.children[0] + "\n"
        }
      })
      .join("")
      .trim()

    return codeContent
  })

  const leftCode = codeSnippets[0]
  const rightCode = codeSnippets[1]

  return (
    <>
      <CompareCodeTabs
        hidden={!withTabs}
        leftTitle={left}
        rightTitle={right}
        leftLanguage={leftLanguage}
        rightLanguage={rightLanguage}
        leftCode={leftCode}
        rightCode={rightCode}
      />
      <CompareCodeTable
        hidden={withTabs}
        leftTitle={left}
        rightTitle={right}
        leftLanguage={leftLanguage}
        rightLanguage={rightLanguage}
        leftCode={leftCode}
        rightCode={rightCode}
      />
    </>
  )
}
