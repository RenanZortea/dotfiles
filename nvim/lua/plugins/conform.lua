return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },

	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- One explicit formatter per filetype. The old setup hung format-on-save
		-- off none-ls's on_attach, so it only ever fired for filetypes that had a
		-- none-ls source -- Rust and TypeScript silently never formatted, even
		-- though their servers support it.
		formatters_by_ft = {
			rust = { "rustfmt" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			lua = { "stylua" },

			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },

			json = { "prettier" },
			jsonc = { "prettier" },
			yaml = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			markdown = { "prettier" },

			sh = { "shfmt" },
			bash = { "shfmt" },
			python = { "ruff_format" },
		},

		format_on_save = {
			-- rust-analyzer and clangd can be slow on a cold cache.
			timeout_ms = 3000,
			-- Anything without a formatter above still formats, via its LSP.
			lsp_format = "fallback",
		},

		formatters = {
			shfmt = { prepend_args = { "-i", "4" } },
		},
	},

	keys = {
		{
			"<leader>gf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[F]ormat buffer",
		},
	},
}
