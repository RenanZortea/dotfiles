return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- 1. COLORS (Kept your OneDark palette, but using it for a flat look)
		local colors = {
			blue = "#61afef",
			green = "#98c379",
			purple = "#c678dd",
			cyan = "#56b6c2",
			red1 = "#e06c75",
			red2 = "#be5046",
			yellow = "#e5c07b",
			fg = "#abb2bf",
			bg = "#282c34",
			gray1 = "#828997",
			gray2 = "#2c323c",
			gray3 = "#3e4452",
		}

		local onedark_theme = {
			normal = {
				a = { fg = colors.bg, bg = colors.green, gui = "bold" },
				b = { fg = colors.fg, bg = colors.gray3 },
				c = { fg = colors.fg, bg = colors.bg }, -- Match bg to make it look flat
			},
			command = { a = { fg = colors.bg, bg = colors.yellow, gui = "bold" } },
			insert = { a = { fg = colors.bg, bg = colors.blue, gui = "bold" } },
			visual = { a = { fg = colors.bg, bg = colors.purple, gui = "bold" } },
			terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = "bold" } },
			replace = { a = { fg = colors.bg, bg = colors.red1, gui = "bold" } },
			inactive = {
				a = { fg = colors.gray1, bg = colors.bg, gui = "bold" },
				b = { fg = colors.gray1, bg = colors.bg },
				c = { fg = colors.gray1, bg = colors.bg },
			},
		}

		local themes = { onedark = onedark_theme, nord = "nord" }
		local env_var_nvim_theme = os.getenv("NVIM_THEME") or "nord"

		-- 2. CUSTOM FUNCTIONS --------------------------------------------------------

		local function lsp_clients()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if #clients == 0 then
				return ""
			end

			local names = {}
			for _, client in pairs(clients) do
				-- Filter out null-ls if you find it too noisy, otherwise keep it
				table.insert(names, client.name)
			end
			return "  " .. table.concat(names, ", ")
		end

		local function harpoon_component()
			local harpoon = require("harpoon")
			local list = harpoon:list()
			local root_dir = list.config:get_root_dir()
			local current_file_path = vim.api.nvim_buf_get_name(0)

			local length = #root_dir
			if string.sub(current_file_path, 1, length) == root_dir then
				current_file_path = string.sub(current_file_path, length + 2)
			end

			for i, item in ipairs(list.items) do
				if item.value == current_file_path then
					return " " .. i .. " " -- Simple number indicating harpoon index
				end
			end
			return ""
		end

		-- 3. SETUP -------------------------------------------------------------------
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = themes[env_var_nvim_theme] or "auto",

				-- MINIMALIST SETTINGS:
				-- No arrows, just clean vertical bars or empty space
				section_separators = { left = "", right = "" },
				component_separators = { left = "│", right = "│" },

				disabled_filetypes = { "alpha", "neo-tree", "Avante" },
				always_divide_middle = true,
				globalstatus = true, -- Makes the statusline span the whole width (very clean)
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					}, -- Just "N", "I", "V" (Very minimal)
				},
				lualine_b = { "branch", "diff" },
				lualine_c = {
					{ "filename", path = 1 },
				},
				lualine_x = {
					harpoon_component,
					{
						"diagnostics",
						colored = true,
						symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
					},
					lsp_clients,
					"filetype", -- Kept filetype, removed encoding
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
