return {
	"folke/which-key.nvim",
	event = "VeryLazy",

	---@module "which-key"
	---@type wk.Opts
	opts = {
		preset = "helix",
		delay = 400,
		spec = {
			{ "<leader>s", group = "session" },
			{ "<leader>f", group = "find" },
			{ "<leader>g", group = "git" },
			{ "<leader>k", group = "knowledge (ask the compiler)" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>r", group = "rust" },
			{ "<leader>t", group = "toggle" },
		},
	},

	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer-local keymaps",
		},
	},
}
