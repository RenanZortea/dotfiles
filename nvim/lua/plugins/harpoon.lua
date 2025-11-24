return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		-- REQUIRED: Setup harpoon
		harpoon:setup({
			settings = {
				save_on_toggle = true, -- auto-save the list when closing the menu
			},
		})

		-- 1. ADD current file to the list (mark it)
		vim.keymap.set("n", "<leader>m", function()
			harpoon:list():add()
		end, { desc = "Harpoon: Add File" })

		-- 2. MENU: Open the default Harpoon window (Editable buffer)
		vim.keymap.set("n", "<leader>M", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: Open Menu" })

		-- 3. NAVIGATE: Jump to specific slots (1-4)
		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: Jump to 1" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: Jump to 2" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: Jump to 3" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: Jump to 4" })

		-- 4. CYCLE: Previous / Next buffer in the list
		vim.keymap.set("n", "<leader>p", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: Prev" })
		vim.keymap.set("n", "<leader>n", function()
			harpoon:list():next()
		end, { desc = "Harpoon: Next" })
	end,
}
