# To-Do List

This to-do list is split up into sections with tasks assigned to documentation maintainers.

## To-Do List for me (Richy)

- cross-reference with old documentation to ensure we arent missing any functions in the new documentation
- Write a linter for this documentation:
  - Warn when there is a `code snippet` that doesnt have syntax highlighting applied to it
  - It should not error when it encounters just one error immediately. errors/warnings for linting must be appended to an array and then printed last. os.exit code shoudl be error if strict errors appended but no os.exit error code if there are only warnings.
  - Must check when "Lua" is used individually instead of "Luau". also detect "Lua's", etc. because Luau is used, not Lua.
  - Must check when the long hyphens are used or the non-standard quotes are used (the fancy ones instead of the programmer ones)
  - add emoji checking, allowing them only on level 3 headings (`###`). nowhere else.
- ensure there is a luau type definition for the following things:
  - Drawing object
- search for code snippets and ensure they have relevant, appropriate links
- search for "TODO" messages to fix todo items

## Latest to-do list for Richy

- Make a document somewhere under the About section explaining why we dont test some functions from the original UNC, eg "Where is the cache library?"
  - where are mouse funcs or isrbxactive etc?
- Potentially note that debug.getinfo is useless as we have better debug.info (just put this note in debug.getinfo, if you still want to implement getinfo then visit this link etc, but otherwise theyre somewhat similar)
  - "dont really care much about this function, but i think we should add it, since we did add setscriptable"
- create documentation for `decompile` under SCRIPTS (not reflection!) group, and also every other function mentioned [here](https://github.com/sUNC-Utilities/docs.sunc.su/issues/162)
  - <https://synapsexdocs.github.io/custom-lua-functions/reflection-functions/#decompile>
  - cross off items from same github issue
- cache library, even though it may seem redundant in the meantime (it will be removed in the future from the next version of sUNC)
  - <https://synapsexdocs.github.io/libraries/syn/>
  - <https://github.com/unified-naming-convention/NamingStandard/blob/305c31e4f469c056812c9f412c9a4d78293021bc/api/cache.md?plain=1>
- `debug.getinfo`
  - <https://github.com/unified-naming-convention/NamingStandard/blob/305c31e4f469c056812c9f412c9a4d78293021bc/api/debug.md?plain=1#L70-L112>
  - <https://synapsexdocs.github.io/libraries/debug/#get-info>
- Modify the documentation parser to ignore HTML comments in markdown (so that comments / todo notes dont have to be moved to the very bottom of a markdown file)
- Document how the Rubiš API can be used (currently) to retrieve information about sUNC test results
  - note differences about public and private scraps
  - most test results are private
  - unfortunately we do not provide a way for the public to know whether a scrap posted on rubis is officially from sUNC, although by popular request we may add an endpoint to give in-depth sunc information (including verified results)
    - note that rubis results will be deprecated in the future (at least via the regular rubis api) and they will be migrated to the rubis partners api
