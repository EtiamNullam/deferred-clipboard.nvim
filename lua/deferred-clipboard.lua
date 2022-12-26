local M = {}

M.setup = function()
    local deferred_clipboard_sync_group = vim.api.nvim_create_augroup(
        'DeferredClipboardSync',
        { clear = true }
    )

    local function copy_register(from, to)
        vim.fn.setreg(
            to,
            vim.fn.getreginfo(from)
        )
    end

    vim.api.nvim_create_autocmd(
        {
            'FocusLost',
            'VimLeavePre'
        }, {
            group = sync_clipboard_group,
            pattern = '*',
            callback = function()
                copy_register('"', '+')
            end
        }
    )

    vim.api.nvim_create_autocmd(
        'FocusGained',
        {
            group = sync_clipboard_group,
            pattern = '*',
            callback = function()
                copy_register('+', '"')
            end
        }
    )
end

return M
