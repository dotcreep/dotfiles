local M = {}

local function has_command(cmd)
    local handle = io.popen("command -v " .. cmd .. " > /dev/null 2>&1")
    local result = handle:read("*a")
    handle:close()
    return result == ""
end

function M.install_language_server(lang)
    if lang == 'typescript' then
        if has_command('npm') then
            os.execute('npm install -g typescript typescript-language-server')
            print("TypeScript language server installed.")
        else
            print("npm is not available on your system.")
        end
    elseif lang == 'python' then
        if has_command('pip') then
            os.execute('pip install python-language-server')
            print("Python language server installed.")
        else
            print("pip is not available on your system.")
        end
    elseif lang == 'rust' then
        if has_command('cargo') then
            os.execute('cargo install rust-analyzer')
            print("Rust Analyzer installed.")
        else
            print("cargo is not available on your system.")
        end
    elseif lang == 'lua' then
        -- Assuming lua-language-server is installed via GitHub
        print("Lua language server installation requires manual steps.")
    elseif lang == 'go' then
        if has_command('go') then
            os.execute('go install golang.org/x/tools/gopls@latest')
            print("Go language server installed.")
        else
            print("go is not available on your system.")
        end
    -- Add more languages as needed
    else
        print("Language server for " .. lang .. " is not supported.")
    end
end

return M
