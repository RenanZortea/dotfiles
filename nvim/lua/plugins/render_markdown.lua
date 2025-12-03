return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			file_types = { "markdown", "Avante" },
			render_modes = { "n", "c", "t" },

			anti_conceal = {
				enabled = true,
				ignore = { code_background = true, sign = true },
			},

			-- 1. HEADINGS: remove background, keep icons
			heading = {
				sign = false,
				icons = { "h1 ", "h2 ", "h3 ", "h4 ", "h5 ", "h6 " },
				backgrounds = false, -- 🔥 Removes the background color
				width = "full", -- Options: "full", "block", "content"
			},

			-- 2. LINKS: Disable entirely to show raw URL text
			link = {
				enabled = false, -- 🔥 Stops replacing URLs with icons
			},

			-- Enable Math Rendering
			latex = {
				enabled = true,
				converter = "latex2text", -- The standard converter
				highlight = "RenderMarkdownMath",
				top_pad = 0,
				bottom_pad = 0,
			},
			-- Optional: Keep code blocks clean too
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
		},
		keys = {
			{
				"<leader>mp",
				"<cmd>RenderMarkdown toggle<cr>",
				desc = "Toggle Render Markdown",
			},
		},
	},
}
