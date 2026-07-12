return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jayp0521/mason-null-ls.nvim",
	},
	config = function()
		local null_ls = require("null-ls")
		local diagnostics = null_ls.builtins.diagnostics

		-- Formatting now lives in conform.nvim. Mason still installs the binaries,
		-- because conform shells out to them.
		require("mason-null-ls").setup({
			ensure_installed = {
				"prettier", -- JS/TS, HTML, CSS, JSON, YAML, Markdown
				"stylua", -- Lua
				"eslint_d", -- JS linter
				"shfmt", -- Shell
				"checkmake", -- Makefile
				"ruff", -- Python
				"clang-format", -- C / C++
				"asmfmt", -- Assembly
			},
			automatic_installation = true,
		})

		-- Diagnostics only. Keeping formatting sources here too would mean two
		-- things formatting the same buffer on write.
		null_ls.setup({
			sources = {
				diagnostics.checkmake,
			},
		})
	end,
}
