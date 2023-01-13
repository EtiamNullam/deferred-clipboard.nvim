local M = {}

M.version = '0.7.0'

---@return boolean
local function is_continuous_clipboard_sync_enabled()
    return vim.o.clipboard ~= ''
end

local function schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    local group_id = vim.api.nvim_create_augroup(
        'DisableContinuousClipboardSync',
        { clear = true }
    )

    vim.api.nvim_create_autocmd({
        'FocusGained',
        'FocusLost',
    }, {
        once = true,
        group = group_id,
        callback = function()
            vim.o.clipboard = ''
        end,
    })
end

---@param content? string
function M.write(content)
    content = type(content) == 'string' and content
        or vim.fn.getreg('"')

    if content ~= '' then
        vim.fn.setreg(
            '+',
            content
        )
    end
end

---@return string | nil
function M.read()
    local loaded_content = vim.fn.getreg('+')

    if loaded_content == '' then
        return nil
    end

    vim.fn.setreg(
        '"',
        loaded_content
    )

    return loaded_content
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
        callback = M.write,
    })

    vim.api.nvim_create_autocmd('FocusGained', {
        group = deferred_clipboard_sync_group,
        callback = M.read,
    })
end


---@param register string
---@return boolean
local function is_register_empty(register)
    return vim.fn.getreg(register) == ''
end

---@param value '' | 'unnamed' | 'unnamedplus'
local function setup_fallback(value)
    if value ~= nil then
        vim.o.clipboard = value
    end
end

---@param lazy? boolean
local function initialize_unnamed_register(lazy)
    if not is_continuous_clipboard_sync_enabled() then
        if lazy == true then
            vim.schedule(initialize_unnamed_register)
        else
            M.read()
        end
    end
end

---@class DeferredClipboard.InitOptions
    ---@field lazy? boolean
    ---@field fallback? '' | 'unnamed' | 'unnamedplus'

---@param options? DeferredClipboard.InitOptions
function M.setup(options)
    options = options or {}

    setup_fallback(options.fallback)

    schedule_clipboard_sync_on_focus_change()

    if is_continuous_clipboard_sync_enabled() then
        schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    elseif is_register_empty('"') then
        initialize_unnamed_register(options.lazy)
    end
end

return M
