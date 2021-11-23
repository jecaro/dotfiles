local M = {}

function M.format()
    vim.lsp.buf.formatting_sync()
end

function M.hls_on_new_config(new_config)
    new_config.settings.haskell.formattingProvider = "fourmolu"
end

return M
