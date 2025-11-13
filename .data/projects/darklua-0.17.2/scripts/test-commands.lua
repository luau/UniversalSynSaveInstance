local CONFIG_FILE_NAME = '.darklua.json5'

local function concatCommands(...)
    return table.concat({...}, ' && ')
end

local function run(...)
    local command = concatCommands(...)

    local status = os.execute(command)

    if status ~= 0 then
        return false, ('\n\nAn error status code (%d) was returned after running the command:\n%s\n'):format(status, command)
    end

    return true
end

local function verify(success, message)
    if not success then
        error(message, 2)
    end
end

local function verifyRun(...)
    verify(run(...))
end

local Project = {}
local projectMetatable = {__index = Project}

function Project.new(repo, commit, processFolder, ...)
    return setmetatable({
        Repository = repo,
        RepositoryName = repo:match('([%a%-]+)%.git'),
        Commit = commit,
        ProcessFolder = processFolder,
        Test = concatCommands(...),
    }, projectMetatable)
end

function Project:init()
    verifyRun(
        'git clone ' .. self.Repository,
        'cd ' .. self.RepositoryName,
        'git checkout ' .. self.Commit,
        'git submodule init',
        'git submodule update',
        'cd ..'
    )
end

function Project:clean()
    verifyRun('rm -r -f ' .. self.RepositoryName)
end

function Project:test(generatedFolderName)
    return run((self.Test:gsub('%$generated', generatedFolderName)))
end

local Json = {}

function Json.fromArray(array)
    local content = {}

    for i=1, #array do
        table.insert(content, Json.from(array[i]))
    end

    return ('[%s]'):format(table.concat(content, ','))
end

function Json.fromMap(data)
    local content = {}

    for key, value in pairs(data) do
        table.insert(content, ('%s:%s'):format(key, Json.from(value)))
    end

    return ('{%s}'):format(table.concat(content, ','))
end

function Json.from(data)
    local dataType = type(data)

    if dataType == 'table' then
        if #data ~= 0 then
            return Json.fromArray(data)
        else
            return Json.fromMap(data)
        end
    elseif dataType == 'string' then
        return ('"%s"'):format(data)
    end

    return tostring(data)
end

local DarkluaTest = {}
local darkluaTestMetatable = {__index = DarkluaTest}

function DarkluaTest.new(name, command, config)
    return setmetatable({
        Name = name,
        Command = command,
        ConfigurationFile = config and Json.fromMap(config) or '',
    }, darkluaTestMetatable)
end

function DarkluaTest:execute(project)
    local generatedName = 'processed-' .. project.RepositoryName
    local escapedRepoName = project.RepositoryName:gsub('%-', '%%-')
    local output = project.ProcessFolder:gsub(escapedRepoName, generatedName);

    local command = self.Command
        :gsub('$input', project.ProcessFolder)
        :gsub('$output', output)

    if self.ConfigurationFile:len() > 0 then
        local configFile = io.open(CONFIG_FILE_NAME, 'w+')
        configFile:write(self.ConfigurationFile)
        configFile:close()
    end

    verifyRun('cargo run --release -- ' .. command)

    verifyRun(('rm -f %s'):format(CONFIG_FILE_NAME))

    local success, message = project:test(generatedName)

    if not success then
        return false, (('\nerror while executing test <%s> on <%s>:\n%s'):format(
            self.Name,
            project.RepositoryName,
            message
        ))
    end

    return true, 'success', function() verifyRun('rm -r -f ' .. generatedName) end
end

-- define Lua projects and how to test them
local projects = {
    Project.new(
        'https://github.com/Roblox/roact.git',
        'd9b7f9661b26ff16db240f2fe8b0f8284303c61d',
        'roact/src',
        -- test commands
        'cp -r roact/bin $generated/bin',
        'cp -r roact/modules $generated/modules',
        'cd $generated',
        'lua bin/spec.lua',
        'cd ..'
    ),
    Project.new(
        'https://github.com/Roblox/rodux.git',
        '45c106f09c58f706a7ea458c6ff17914dd9a22c6',
        'rodux/src',
        -- test commands
        'cp rodux/spec.lua $generated/spec.lua',
        'cp -r rodux/modules $generated/modules',
        'cd $generated',
        'lua spec.lua',
        'cd ..'
    ),
    Project.new(
        'https://github.com/Roblox/roact-rodux.git',
        '7ec071ae3174a88e9054d8a814828ad4f0448a7a',
        'roact-rodux/src',
        -- test commands
        'cp -r roact-rodux/test $generated/test',
        'cp -r roact-rodux/modules $generated/modules',
        'cd $generated',
        'lua test/lemur.lua',
        'cd ..'
    ),
    Project.new(
        'https://github.com/Roblox/t.git',
        '00b91a76847572e32a365dff71ac606798f86609',
        't/lib',
        -- test commands
        'cp t/spec.lua $generated/spec.lua',
        'cp -r t/modules $generated/modules',
        'cd $generated',
        'lua spec.lua',
        'cd ..'
    ),
}

-- define commands to test on each project
local testSuite = {
    DarkluaTest.new('minify', 'minify $input $output'),
    DarkluaTest.new('default-process-dense', 'process $input $output --format dense'),
    DarkluaTest.new('default-process-readable', 'process $input $output --format readable'),
    DarkluaTest.new('default-process-retain-lines', 'process $input $output --format retain-lines'),
    DarkluaTest.new('rename-dense', 'process $input $output --format dense', {
        process = {{
            rule = 'rename_variables',
            globals = {'$default', '$roblox'},
        }}
    }),
    DarkluaTest.new('rename-retain-lines', 'process $input $output --format retain-lines', {
        process = {{
            rule = 'rename_variables',
            globals = {'$default', '$roblox'},
        }}
    }),
    DarkluaTest.new('rename-all-retain-lines', 'process $input $output --format retain-lines', {
        process = {{
            rule = 'rename_variables',
            globals = {'$default', '$roblox'},
            include_functions = true,
        }}
    }),
    DarkluaTest.new('process-retain-lines', 'process $input $output --format retain-lines', {
        process = {
            'compute_expression',
            'remove_unused_if_branch',
            'remove_unused_while',
            'remove_empty_do',
            {
                rule = 'rename_variables',
                globals = { '$default', '$roblox' },
            },
            'remove_function_call_parens',
        }
    }),
    DarkluaTest.new('compress-dense', 'process $input $output --format dense', {
        process = {
            'compute_expression',
            'remove_unused_if_branch',
            'remove_unused_while',
            'convert_index_to_field',
            'remove_method_definition',
            'convert_local_function_to_assign',
            'group_local_assignment',
            'remove_empty_do',
            {
                rule = 'rename_variables',
                globals = {'$default', '$roblox'},
                include_functions = true,
            },
            'remove_function_call_parens',
        }
    }),
}

local failFast = false

for i=1, select('#', ...) do
    local argument = select(i, ...)

    if argument == '--fail-fast' or argument == '-f' then
        failFast = true
    end
end

local results = {}

for _, test in ipairs(testSuite) do
    results[test.Name] = {}
end

local allSuccess = true
local longestProjectNameLength = 0

for _, project in ipairs(projects) do
    project:init()

    longestProjectNameLength = math.max(
        longestProjectNameLength,
        project.RepositoryName:len()
    )

    for _, test in ipairs(testSuite) do
        local success, message, cleanCallback = test:execute(project)
        allSuccess = allSuccess and success

        if not success and failFast then
            print(message)
            os.exit(1)
        end

        if cleanCallback then
            cleanCallback()
        end

        results[test.Name][project.RepositoryName] = success
    end

    project:clean()
end

print('')
print('Printing test results')

for testName, projectResults in pairs(results) do
    print((':'):rep(80))
    print(('Test: %s'):format(testName))

    for projectName, success in pairs(projectResults) do
        local padding = (' '):rep(longestProjectNameLength - projectName:len())
        print(('    %s%s -> %s'):format(projectName, padding, success and 'ok' or 'failed !!!'))
    end

    print('')
end

if not allSuccess then
    os.exit(1)
end
