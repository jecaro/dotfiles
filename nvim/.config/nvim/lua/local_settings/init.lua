local M = {}

function without_ext(filename)
    return filename:gsub('%.%w+$', '')
end

function basename(filename)
    return filename:match('[^/]+$')
end

-- lua is unable to load a .module.lua file so the .xmonad repo is handled by
-- the file xmonad.lua
function unhide(filename)
    return filename:gsub('^%.', '')
end

repos = {}
M.repos = {}

for filename in io.popen('ls ~/.config/nvim/lua/local_settings/repositories/*.lua'):lines() do
    local name = without_ext(basename(filename))
    repos[name] = require("local_settings.repositories."..name)
    M.repos[name] = require("local_settings.repositories."..name)
end

function modulename()
    return unhide(basename(vim.fn.getcwd()))
end

function M.apply()
    local name = modulename()

    if repos[name] and repos[name].apply then
        repos[name].apply()
    end
end

function M.format()
    local name = modulename()

    if repos[name] and repos[name].format then
        repos[name].format()
    end
end

function M.on_new_config(lsp)
    local name = modulename()

    if repos[name] and repos[name].on_new_config then
        return (function (new_config)
                    return repos[name].on_new_config(lsp, new_config)
                end)
    end
end

return M
