local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error "This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local utils = require "telescope.utils"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local conf = require("telescope.config").values

local M = {}

local function getNavCmds()
    return vim.call("projectionist#navigation_commands")
end

local function getPaths(type)
    return getNavCmds()[type]
end

local projectionist = function (opts)
    opts = opts or {}
    opts.path_display = utils.get_default(opts.path_display, "hidden")
    opts.ignore_filename = utils.get_default(opts.ignore_filename, true)
    opts.include_extensions = utils.get_default(opts.include_extensions, false)

    local results = {}

    for type, _ in pairs(getNavCmds()) do
        table.insert(results, {
            filename = type,
            text = type,
        })
    end

    pickers.new(opts, {
        promt_title = type,
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    text = entry.text,
                    display = entry.text,
                    ordinal = entry.text,
                    filename = entry.filename,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if selection == nil then
                    print "[telescope] Nothing currently selected"
                    return
                end

                actions._close(prompt_bufnr, true)
                M.findByType(selection.value.filename, opts)
            end)

            return true
        end,
    }):find()

end

local create = function (type)
    return function (prompt_bufnr)
        local new_file = action_state.get_current_line()
        if new_file == nil then
            print "[telescope] Nothing currently selected"
            return
        end
        actions._close(prompt_bufnr, true)
        vim.api.nvim_command(string.format("E%s %s", type, new_file))
    end
end

M.findByType = function(type, opts)
    opts = opts or {}
    opts.path_display = utils.get_default(opts.path_display, "hidden")
    opts.ignore_filename = utils.get_default(opts.ignore_filename, true)
    opts.include_extensions = utils.get_default(opts.include_extensions, false)

    local paths = getPaths(type)
    local results = {}

    for _, location in pairs(paths) do
        local path = location[1] .. '/' .. location[2]
        local findings = vim.call("projectionist#glob", path:gsub('*', '**/*'))
        for _, find in ipairs(findings) do
            table.insert(results, {
                filename = find,
                text = find,
            })
        end
    end

    pickers.new(opts, {
        promt_title = type,
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    text = entry.text,
                    display = entry.text,
                    ordinal = entry.text,
                    filename = entry.filename,
                }
            end,
        },
        previewer = previewers.builtin.new(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            map("i", "<C-y>", create(type))
            map("n", "<C-y>", create(type))
            return true
        end,
    }):find()
end

return telescope.register_extension {
  exports = {
    projectionist = projectionist,
  },
}
