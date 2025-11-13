import * as React from "react"

import { Tab, Tabs } from "@mui/material"
import { Box } from "@mui/system"
import TextRuleEditor from "./text-rule-editor"
import { DarkluaContext } from "../darklua-provider"
import LoadingEditorProviders from "../loading-editor-providers"

const getTabId = index => `simple-tab-${index}`
const getTabPanelId = index => `simple-tabpanel-${index}`

const TabPanel = ({ children, value, index, sx = {} }) => {
  const hidden = value !== index
  return (
    <Box
      role="tabpanel"
      hidden={hidden}
      id={getTabPanelId(index)}
      aria-labelledby={getTabId(index)}
      sx={{ flexGrow: 1, ...sx }}
    >
      {children}
    </Box>
  )
}

const a11yProps = index => {
  return {
    id: getTabId(index),
    "aria-controls": getTabPanelId(index),
  }
}

const RuleConfiguration = () => {
  const darklua = React.useContext(DarkluaContext)

  const [value, setValue] = React.useState(0)

  const handleChange = (_event, newValue) => {
    setValue(newValue)
  }

  if (!darklua) {
    return
  }

  return (
    <>
      <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
        <Tabs
          value={value}
          onChange={handleChange}
          aria-label="basic tabs example"
        >
          <Tab label="Text" {...a11yProps(0)} />
          {/* <Tab label="Editor" disabled {...a11yProps(1)} /> */}
        </Tabs>
      </Box>
      <TabPanel value={value} index={0} sx={{ overflow: "hidden" }}>
        <LoadingEditorProviders>
          <TextRuleEditor />
        </LoadingEditorProviders>
      </TabPanel>
      {/* <TabPanel value={value} index={1}>
        <Box sx={{ overflow: "auto" }}><UiRuleEditor /></Box>
      </TabPanel> */}
    </>
  )
}

export default RuleConfiguration
