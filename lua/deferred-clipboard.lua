local M = {}

M.version = '0.6.1'

local function is_continuous_clipboard_sync_enabled()
    return vim.o.clipboard ~= nil
        and vim.o.clipboard ~= ''
end

local function disable_continuous_clipboard_sync()
    local hasFocusLostEvent = vim.api.nvim_command_output(([[echo exists('##FocusLost')]]))
    local hasFocusGainedEvent = vim.api.nvim_command_output(([[echo exists('##FocusGained')]]))
    if hasFocusLostEvent == '1' or hasFocusGainedEvent == '1' then
        vim.o.clipboard = nil
    end
end

---@param from string
---@param to string
local function copy_register(from, to)
    vim.fn.setreg(
        to,
        vim.fn.getreg(from)
    )
end

local function schedule_clipboard_sync_on_focus_change()
    local deferred_clipboard_sync_group = vim.api.nvim_create_augroup(
        'DeferredClipboardSync',
        { clear = true }
    )

    vim.api.nvim_create_autocmd({
        'FocusLost',
        'VimLeavePre'
    }, {
        group = deferred_clipboard_sync_group,
        pattern = '*',
        callback = function()
            copy_register('"', '+')
        end
    })

    vim.api.nvim_create_autocmd('FocusGained', {
        group = deferred_clipboard_sync_group,
        pattern = '*',
        callback = function()
            copy_register('+', '"')
        end
    })
end

---@param register string
---@return boolean
local function is_register_empty(register)
    return vim.fn.getreg(register) == ''
end

---@class InitOptions
    ---@field lazy? boolean

---@param options? InitOptions
function M.setup(options)
    options = options or {}

    schedule_clipboard_sync_on_focus_change()

    if is_continuous_clipboard_sync_enabled() then
        disable_continuous_clipboard_sync()
    elseif is_register_empty('"') then
        if options.lazy then
            vim.schedule(function()
                copy_register('+', '"')
            end)
        else
            copy_register('+', '"')
        end
    end
end

return M
