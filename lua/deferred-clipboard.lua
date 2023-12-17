local M = {}

M.version = '0.8.0'

local content_after_latest_operation = nil

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
    if type(content) ~= 'string' then
        if content_after_latest_operation == vim.fn.getreg('"') then
            return
        end

        content = vim.fn.getreg('"')
    end

    if content ~= '' then
        vim.fn.setreg(
            '+',
            content
        )

        content_after_latest_operation = content
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

    content_after_latest_operation = loaded_content

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

---@param value DeferredClipboard.Fallback
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

local function avoid_invalid_error_code_on_exit()
    local group_id = vim.api.nvim_create_augroup(
        'AvoidInvalidErrorCodeOnExit',
        { clear = true }
    )

    vim.api.nvim_create_autocmd('VimLeave', {
        group = group_id,
        callback = function()
            vim.api.nvim_command('sleep 10m')
        end,
    })
end

---@param options? DeferredClipboard.InitOptions
function M.setup(options)
    options = options or {}

    setup_fallback(options.fallback)

    schedule_clipboard_sync_on_focus_change()

    if is_continuous_clipboard_sync_enabled() then
        schedule_disable_of_continuous_clipboard_sync_on_focus_change()
    elseif options.force_init_unnamed or is_register_empty('"') then
        initialize_unnamed_register(options.lazy)
    end

    avoid_invalid_error_code_on_exit()
end

return M
