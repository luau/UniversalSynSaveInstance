---
name: Bug report
about: Create a report to help us improve
title: "[BUG] "
labels: bug
assignees: phoriah
---

- [ ] I searched existing issues (both open & closed) and this isn't a duplicate

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
What did you expect to happen instead?

**Screenshots**
*IMPORTANT: Please always include a console screenshot (F9 or `/console`; also show your executor's built-in console if it has one).*

**Executor (& Emulator if used) Name(s):**
<!-- For example: Fluxus v1, Delta, Wave, etc. -->

**Game Link(s):**
<!-- Always include, even if the bug happens on any game -->

**Script Used (options/settings matter):**
```lua
local Params = {
    RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
    SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

local Options = {NilInstances=true} -- Documentation here https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance

synsaveinstance(Options)
```

**Additional context**
Add any other context about the problem here.