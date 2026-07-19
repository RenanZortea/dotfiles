-- Custom code snippets for different purposes

-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Word-wrap a string to `width` columns, preserving any existing newlines.
-- neovim's virtual_lines renderer splits the diagnostic message on '\n' and emits
-- one virtual line per segment (with virt_lines_overflow = 'scroll', so long
-- segments are CLIPPED, not wrapped). By inserting our own '\n' at word boundaries
-- we make each segment short enough to fit — i.e. manual soft-wrapping.
local function wrap_text(text, width)
  local out = {}
  for paragraph in (text .. '\n'):gmatch '(.-)\n' do
    local line = ''
    for word in paragraph:gmatch '%S+' do
      if line == '' then
        line = word
      elseif #line + 1 + #word <= width then
        line = line .. ' ' .. word
      else
        out[#out + 1] = line
        line = word
      end
    end
    out[#out + 1] = line
  end
  return table.concat(out, '\n')
end

-- The virtual_lines config, kept in a variable so the toggle keymap below can
-- restore this exact spec (wrapping + [code] prefix) when turning the widget back on.
local virt_lines_spec = {
  current_line = false, -- show under EVERY diagnostic line, not just the cursor line
  format = function(diagnostic)
    local code = diagnostic.code and string.format('[%s] ', diagnostic.code) or ''
    -- Available width = window minus the diagnostic's indent under the code, the
    -- ~6-char tree prefix, and the number/sign gutter. Conservative so it never
    -- overflows; floored so deeply-indented diagnostics still get a usable width.
    local width = math.max(30, vim.o.columns - (diagnostic.col or 0) - 14)
    return code .. wrap_text(diagnostic.message, width)
  end,
}

-- Appearance of diagnostics
vim.diagnostic.config {
  -- Inline virtual_text can't wrap; it runs off the right edge and gets clipped.
  -- virtual_lines renders the diagnostic on its own line(s) below the code. Native
  -- virtual_lines also can't soft-wrap (overflow = 'scroll'), so format() hard-wraps
  -- the message to the window width before it's rendered.
  virtual_text = false,
  virtual_lines = virt_lines_spec,
  underline = false,
  update_in_insert = true,
  float = {
    source = 'if_many',
    border = 'rounded',
    wrap = true, -- wrap long messages instead of running off-screen
    max_width = 100, -- cap width so it never spills past the right edge
    max_height = 20, -- cap height; longer content becomes scrollable
    focusable = true, -- trigger twice (e.g. <leader>d then again) to enter & scroll
  },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
}

-- Toggle the below-code diagnostic widget on/off. Underline/signs/floats are left
-- untouched, so you keep the gutter marks even with the virtual lines hidden.
local virt_lines_on = true
vim.keymap.set('n', '<leader>td', function()
  virt_lines_on = not virt_lines_on
  vim.diagnostic.config { virtual_lines = virt_lines_on and virt_lines_spec or false }
  vim.notify('Diagnostic virtual lines: ' .. (virt_lines_on and 'ON' or 'OFF'), vim.log.levels.INFO)
end, { desc = '[T]oggle [D]iagnostic virtual lines' })

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
