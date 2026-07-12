return {
	"rmagatti/auto-session",
	lazy = false,

	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		-- Don't save a session for these; a session rooted at $HOME or / restores
		-- whatever junk happened to be open and is never what you want.
		suppressed_dirs = { "~/", "~/Downloads", "/" },

		-- Without this, quitting from the dashboard saves a session containing
		-- only the dashboard, which then overwrites the real one.
		bypass_save_filetypes = { "alpha" },
	},

	keys = {
		{ "<leader>ss", "<cmd>AutoSession search<cr>", desc = "[S]ession [S]earch" },
		{ "<leader>sw", "<cmd>AutoSession save<cr>", desc = "[S]ession [W]rite" },
		{ "<leader>sr", "<cmd>AutoSession restore<cr>", desc = "[S]ession [R]estore" },
		{ "<leader>sd", "<cmd>AutoSession delete<cr>", desc = "[S]ession [D]elete" },
	},
}
