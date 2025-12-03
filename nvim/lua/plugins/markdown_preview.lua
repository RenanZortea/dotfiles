return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npm install", -- Fix 1: Force proper install of the Node server
		init = function()
			-- Fix 2: Set these globals BEFORE the plugin loads
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_close = 0 -- Keep preview open when switching buffers
		end,
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "Markdown Preview",
				ft = "markdown",
			},
		},
	},
}
