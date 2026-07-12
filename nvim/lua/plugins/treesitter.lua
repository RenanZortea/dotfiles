return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- post-rewrite API: no more .configs/opts, see README
  build = ":TSUpdate",
  config = function()
    local ensure_installed = {
      "lua",
      "python",
      "javascript",
      "typescript",
      "vimdoc",
      "vim",
      "regex",
      "terraform",
      "sql",
      "dockerfile",
      "toml",
      "json",
      "java",
      "groovy",
      "go",
      "gitignore",
      "graphql",
      "yaml",
      "make",
      "cmake",
      "markdown",
      "markdown_inline",
      "bash",
      "tsx",
      "css",
      "html",
      "rust",
    }
    require("nvim-treesitter").install(ensure_installed)

    -- Highlighting + indent are opt-in per filetype now (used to be highlight.enable/indent.enable)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match) or args.match
        if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", true) > 0 then
          vim.treesitter.start()
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
