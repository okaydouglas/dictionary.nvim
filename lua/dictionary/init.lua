local M = {} -- M stands for module, a naming convention


local buf = vim.api.nvim_create_buf(false, true)

local win = nil

local _max_win_height = 32      -- maximum height of the dictionary popup/floating window 
                                -- this number is arbitrary, and is the number of lines that can be shown without scrolling the window

local _win_width = 76           -- default width (in characters) of the dictionary popup/floating window
                                -- DICT wraps definitions at 75 characters, but we add a space to offset the text in the floating window

function M.close_dictionary()
    if win then
        vim.api.nvim_win_close(win, false)
        win = nil
    end
end


function M.show_definition()
    local cword = vim.fn.expand('<cword>') -- select word under cursor.

    local output = vim.fn.system("dict " .. cword .. " | sed 's/^/ /' | recode html ")
    local lines = vim.split("\n" .. output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

    local _win_height = #lines

    _win_height = (_win_height > _max_win_height) and _max_win_height or _win_height

    local opts = {
        relative= 'editor',
        width= _win_width,
        height= _win_height,
        col= 3,
        row= 2,
        anchor= 'NW',
        style= 'minimal',
        border = 'rounded',
        title = " Dictionary - '" .. cword .. "' ",
        title_pos = 'center',
    }

    if win then
        vim.api.nvim_win_set_config(win, opts)
        -- vim.api.nvim_win_set_buf(win, buf)
    else
        win = vim.api.nvim_open_win(buf, true, opts)
    end

    vim.api.nvim_win_set_cursor(win, {1,1})

--    vim.api.nvim_set_hl(0, 'NormalFloat', {bg='#252A31', fg='#E7E9EA'})  
--    vim.api.nvim_set_hl(0, 'FloatBorder', {bg='#252A31', fg='#71767B', }) 
--    vim.api.nvim_set_hl(0, 'FloatTitle', {bg='#252A31', fg='#71767B', })

end

-- Key mappings for dictionary
-- these keymaps will only be valid for the _G.buf buffer {the menu window}
vim.keymap.set('n', '<Esc>', M.close_dictionary, { noremap = true, silent = true, buffer = buf })
vim.keymap.set('n', '<leader>q', M.close_dictionary, { noremap = true, silent = true, buffer = buf })


return M


-- TODO
-- determine _max_win_height programmatically 
-- set start,end pos programmatically (anchor the floating window at cword not the top of buffer)
-- use vim.fn.win_getid() and vim.fn.getwininfo( vim.fn.win_getid() ) and vim.fn.line('.') 
-- to get the size of the current window and determine where the cursor is and open the dictionary in an appropriate place 
-- also use the coordinates info to determine an appropriate max_size value
