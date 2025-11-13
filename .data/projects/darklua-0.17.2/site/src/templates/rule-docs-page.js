import * as React from "react"
import { graphql } from "gatsby"

import DocsPageLayout from "../components/docs-page-layout"
import { LocationContext } from "../components/location-context"
import ThemeProvider from "../components/theme-provider"
import {
  MarkdownRenderer,
  RenderMarkdown,
  RenderCode,
} from "../components/markdown-renderer"
import {
  Box,
  Chip,
  Paper,
  Stack,
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
import Seo from "../components/seo"

const Parameters = ({ parameters }) => {
  if (parameters.length === 0) {
    return <></>
  }

  const hasOneDefault = parameters.find(
    ({ default: defaultValue }) => defaultValue !== null,
  )

  return (
    <>
      <RenderMarkdown markdown="## Parameters" />
      <br />
      <TableContainer component={Paper}>
        <Table sx={{ minWidth: 650 }} aria-label="rule parameters">
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>Description</TableCell>
              {hasOneDefault ? <TableCell>Default</TableCell> : null}
            </TableRow>
          </TableHead>
          <TableBody>
            {parameters.map(
              ({
                name,
                type,
                description,
                default: defaultValue,
                added_in: addedIn,
                required,
              }) => (
                <TableRow key={name}>
                  <TableCell component="th" scope="row">
                    {required === true ? <b>{name}</b> : <>{name}</>}
                  </TableCell>
                  <TableCell>
                    <RenderMarkdown markdown={`\`${type}\``} />
                  </TableCell>
                  <TableCell>{`${description}${
                    addedIn !== null ? ` (added in v${addedIn})` : ""
                  }`}</TableCell>
                  {hasOneDefault ? (
                    <TableCell>
                      {defaultValue === null ? (
                        <></>
                      ) : (
                        <RenderMarkdown markdown={`\`${defaultValue}\``} />
                      )}
                    </TableCell>
                  ) : null}
                </TableRow>
              ),
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </>
  )
}

function a11yProps(identifier) {
  return {
    id: `code-example-${identifier}-tab`,
    "aria-controls": `code-example-${identifier}-panel`,
  }
}

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

const usePatchLines = (input, output) => {
  const addLines = input.split("\n").length - output.split("\n").length

  let codeOutput = output
  let codeInput = input
  if (addLines > 0) {
    codeOutput = output + "\n".repeat(addLines)
  } else if (addLines < 0) {
    codeInput = input + "\n".repeat(-addLines) + " "
  }
  if (codeOutput.length === 0) {
    codeOutput = " "
  }

  return [codeInput, codeOutput]
}

const ExampleTab = ({ input, output, rules }) => {
  const [value, setValue] = React.useState(0)

  const handleChange = (_, newValue) => {
    setValue(newValue)
  }

  const [codeInput, codeOutput] = usePatchLines(input, output)

  return (
    <>
      <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
        <Tabs
          value={value}
          onChange={handleChange}
          aria-label="darklua code example"
        >
          <Tab label="Input" {...a11yProps("input")} />
          <Tab label="Output" {...a11yProps("output")} />
        </Tabs>
      </Box>
      <TabPanel value={value} index={0} identifier={"input"}>
        <RenderCode code={codeInput} rules={rules} />
      </TabPanel>
      <TabPanel value={value} index={1} identifier={"output"}>
        <RenderCode code={codeOutput} rules={rules} />
      </TabPanel>
    </>
  )
}

const ExampleCell = ({ input, output, rules }) => {
  const [codeInput, codeOutput] = usePatchLines(input, output)

  return (
    <TableRow>
      <TableCell component="th" scope="row" style={{ width: "50%" }}>
        <RenderCode code={codeInput} rules={rules} />
      </TableCell>
      <TableCell style={{ width: "50%" }}>
        <RenderCode code={codeOutput} rules={rules} />
      </TableCell>
    </TableRow>
  )
}

const Examples = ({ ruleName, examples, examplesOut }) => {
  const theme = useTheme()
  const withTabs = useMediaQuery(theme.breakpoints.down("lg"))

  if (examples === null || examples.length === 0) {
    return <></>
  }

  return (
    <>
      <RenderMarkdown markdown="## Examples" />
      <br />
      <Box sx={{ display: withTabs ? null : "none" }}>
        {examples.map(({ rules, content }, index) => (
          <ExampleTab
            key={`example-${index}`}
            input={content}
            output={examplesOut[index]}
            rules={rules ?? [ruleName]}
          />
        ))}
      </Box>
      <TableContainer
        component={Paper}
        sx={{ display: withTabs ? "none" : null }}
      >
        <Table aria-label="code example">
          <TableHead>
            <TableRow>
              <TableCell>Input</TableCell>
              <TableCell>Output</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {examples.map(({ rules, content }, index) => (
              <ExampleCell
                key={`example-${index}`}
                input={content}
                output={examplesOut[index]}
                rules={rules ?? [ruleName]}
              />
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </>
  )
}

const AddedInChip = ({ addedIn }) => {
  if (addedIn === "unreleased") {
    return <Chip label="unreleased" color="warning" />
  }
  return <Chip label={`Added in ${addedIn}`} />
}

const RuleDocsTemplate = ({ data }) => {
  const {
    added_in: addedIn,
    parameters,
    examples,
  } = data.markdownRemark.frontmatter
  const { htmlAst, fields } = data.markdownRemark

  const { ruleName, examplesOut } = fields

  return (
    <DocsPageLayout title={ruleName}>
      <Stack direction="row" spacing={1}>
        <AddedInChip addedIn={addedIn} />
      </Stack>

      <Parameters parameters={parameters} />

      <MarkdownRenderer htmlAst={htmlAst} />

      <Examples
        ruleName={ruleName}
        examples={examples}
        examplesOut={examplesOut}
      />

      <br />
    </DocsPageLayout>
  )
}

const RuleDocsPageTemplate = ({ data, location }) => (
  <LocationContext.Provider value={location}>
    <ThemeProvider>
      <RuleDocsTemplate data={data} />
    </ThemeProvider>
  </LocationContext.Provider>
)

export default RuleDocsPageTemplate

export const Head = ({ data }) => {
  const ruleName = data.markdownRemark.fields.ruleName
  return <Seo title={ruleName} articles={[`Documentation for ${ruleName}`]} />
}

export const pageQuery = graphql`
  query RuleDocsPageBySlug($id: String!) {
    markdownRemark(id: { eq: $id }) {
      id
      htmlAst
      fields {
        slug
        ruleName
        examplesOut
      }
      headings {
        depth
        value
      }
      frontmatter {
        added_in
        parameters {
          name
          description
          required
          type
          default
          added_in
        }
        examples {
          content
          rules
        }
      }
    }
  }
`
