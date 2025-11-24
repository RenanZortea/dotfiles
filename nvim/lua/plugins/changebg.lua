return {
	"aliqyan-21/darkvoid.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- Define initial transparency
		local transparent = true

		-- Apply initial setup
		require("darkvoid").setup({
			transparent = transparent,
			glow = true, -- Example: You can add other settings here as well
		})
		vim.cmd([[colorscheme darkvoid]])

		-- Define a function to toggle transparency
		local toggle_transparency = function()
			transparent = not transparent
			require("darkvoid").setup({
				transparent = transparent,
				glow = true, -- Keep other settings intact
			})
			vim.cmd([[colorscheme darkvoid]]) -- Reload the colorscheme to apply changes
		end

		-- Key mapping for toggling transparency
		vim.keymap.set("n", "<leader>bg", toggle_transparency, { noremap = true, silent = true })
	end,
}
