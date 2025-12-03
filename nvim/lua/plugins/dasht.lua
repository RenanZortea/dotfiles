return {
	"sunaku/vim-dasht",
	-- Load the plugin only when these keys are pressed to save startup time
	keys = {
		{ "<leader>k", ":call Dasht(dasht#cursor_search_terms())<CR>", desc = "Dasht: Word under cursor" },
		{
			"<leader>k",
			"y:<C-U>call Dasht(getreg(0))<CR>",
			mode = "v",
			desc = "Dasht: Selected text",
		},
		{ "<leader>sb", ":Dasht ", desc = "Dasht: Search query" },
	},
	config = function()
		-- == Display Settings ==
		-- 'new'    = horizontal split at bottom
		-- 'vnew'   = vertical split (recommended for wide monitors)
		-- 'tabnew' = new tab
		vim.g.dasht_results_window = "vnew"

		-- == Docset Configuration ==
		-- Define which docsets to query based on the filetype you are editing.
		-- NOTE: You must install these docsets first using `dasht-docsets-install`
		vim.g.dasht_filetype_docsets = {
			rust = { "rust", "cargo" },
			c = { "c", "glibc", "man_pages" },
			cpp = { "cpp", "c", "boost", "man_pages" },
			python = { "python", "numpy", "pandas" },
			javascript = { "javascript", "nodejs", "html", "css" },
			typescript = { "typescript", "javascript", "nodejs" },
			lua = { "lua", "neovim" },
			sh = { "bash", "man_pages" },
		}
	end,
}
