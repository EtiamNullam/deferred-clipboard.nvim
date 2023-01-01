local M = {}

M.version = '0.4.0'

local function is_continuous_clipboard_sync_enabled()
    return vim.o.clipboard ~= nil
        and vim.o.clipboard ~= ''
end

local function schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    vim.api.nvim_create_autocmd({
        'FocusGained',
        'FocusLost',
    }, {
        once = true,
        pattern = '*',
        callback = function()
            vim.o.clipboard = nil
        end,
    })
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
local function init(options)
    schedule_clipboard_sync_on_focus_change()

    if is_register_empty('"') then
        copy_register('+', '"')
    end

    if is_continuous_clipboard_sync_enabled() then
        schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    end
end

---@param options? InitOptions
function M.setup(options)
    options = options or {}

    if options.lazy == true or options.lazy == nil then
        vim.schedule(function()
            init(options)
        end)
    else
        init(options)
    end
end

return M
