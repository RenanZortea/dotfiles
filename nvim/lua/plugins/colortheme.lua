-- ~/.config/nvim/lua/plugins/colortheme.lua
return {
	"aliqyan-21/darkvoid.nvim",
	enabled = true,
	lazy = false,
	priority = 1000,
	config = function()
		local transparent = true

		local colors = {
			fg = "#c8c8c8",
			bg = "#000000",
			cursor = "#bdfe58",
			line_nr = "#3a3a3a",
			visual = "#1f1f1f",
			comment = "#828282",
			string = "#d1d1d1",
			func = "#e1e1e1",
			kw = "#f1f1f1",
			identifier = "#b1b1b1",
			type = "#a1a1a1",
			type_builtin = "#c5c5c5",
			search_highlight = "#1bfd9c",
			operator = "#1bfd9c",
			bracket = "#e6e6e6",
			preprocessor = "#4b8902",
			bool = "#66b2b2",
			constant = "#b2d8d8",
			glow_color = "#1bfd9c",
			plugins = {
				gitsigns = true,
				nvim_cmp = true,
				treesitter = true,
				nvimtree = true,
				telescope = true,
				lualine = true,
				bufferline = true,
				oil = true,
				whichkey = true,
				nvim_notify = true,
			},
			added = "#baffc9",
			changed = "#ffffba",
			removed = "#ffb3ba",
			pmenu_bg = "#0a0a0a",
			pmenu_sel_bg = "#1bfd9c",
			pmenu_fg = "#c8c8c8",
			eob = "#242424",
			border = "#404040",
			title = "#bdfe58",
			bufferline_selection = "#1bfd9c",
			error = "#dea6a0",
			warning = "#d6efd8",
			hint = "#bedc74",
			info = "#7fa1c3",
		}

		-- Grayscale ramp. Hue is gone, so luminance and weight carry all the signal.
		--
		-- Contrast is floored for transparent mode, where text lands on kitty's
		-- #101418 at 0.7 opacity over the wallpaper rather than on true black.
		-- Every value below clears WCAG 4.5:1 against both backgrounds except
		-- `faint`, which is deliberately structural: you pattern-match brackets,
		-- you don't read them. Comments are prose, so they sit above that floor
		-- and lean on italic -- not dimness -- to stay subordinate.
		local gray = {
			faint = "#5f5f5f", -- delimiters, brackets  (3.3:1 / 2.9:1)
			dim = "#828282", -- comments               (5.5:1 / 4.8:1)
			muted = "#8f8f8f", -- operators, attributes  (6.5:1 / 5.7:1)
			soft = "#9c9c9c", -- strings                (7.7:1 / 6.7:1)
			mid = "#b0b0b0", -- variables, parameters  (9.7:1 / 8.5:1)
			bright = "#c8c8c8", -- types, fields         (12.6:1 / 11.1:1)
			high = "#e2e2e2", -- constants, numbers     (16.2:1 / 14.3:1)
			peak = "#ffffff", -- keywords, functions    (21.0:1 / 18.5:1)
		}

		local syntax = {
			["@comment"] = { fg = gray.dim, italic = true },
			["@comment.documentation"] = { fg = gray.dim, italic = true },
			["@punctuation.delimiter"] = { fg = gray.faint },
			["@punctuation.bracket"] = { fg = gray.faint },
			["@punctuation.special"] = { fg = gray.muted },
			["@string"] = { fg = gray.soft },
			["@string.escape"] = { fg = gray.high },
			["@character"] = { fg = gray.soft },
			["@operator"] = { fg = gray.muted },
			["@variable"] = { fg = gray.mid },
			["@variable.parameter"] = { fg = gray.mid, italic = true },
			["@variable.member"] = { fg = gray.bright },
			["@property"] = { fg = gray.bright },
			["@field"] = { fg = gray.bright },
			["@type"] = { fg = gray.bright, bold = true },
			["@type.builtin"] = { fg = gray.bright },
			["@type.definition"] = { fg = gray.bright, bold = true },
			["@constant"] = { fg = gray.high },
			["@constant.builtin"] = { fg = gray.high, bold = true },
			["@number"] = { fg = gray.high },
			["@boolean"] = { fg = gray.high, bold = true },
			["@function"] = { fg = gray.peak },
			["@function.call"] = { fg = gray.high },
			["@function.builtin"] = { fg = gray.peak },
			["@function.macro"] = { fg = gray.peak, italic = true },
			["@constructor"] = { fg = gray.bright, bold = true },
			["@keyword"] = { fg = gray.peak, bold = true },
			["@keyword.function"] = { fg = gray.peak, bold = true },
			["@keyword.return"] = { fg = gray.peak, bold = true },
			["@keyword.operator"] = { fg = gray.high, bold = true },
			["@keyword.import"] = { fg = gray.bright, bold = true },
			["@module"] = { fg = gray.mid },
			["@attribute"] = { fg = gray.muted, italic = true },
			["@label"] = { fg = gray.bright },
			-- Rust-specific: lifetimes and sigils read as structure, not content.
			["@lsp.type.lifetime"] = { fg = gray.faint, italic = true },
			["@lsp.type.selfKeyword"] = { fg = gray.high, bold = true },
			["@lsp.type.macro"] = { fg = gray.peak, italic = true },
			["@lsp.type.derive"] = { fg = gray.muted, italic = true },
			-- LSP semantic tokens override treesitter; neutralize the noisy ones.
			["@lsp.type.variable"] = { fg = gray.mid },
			["@lsp.type.parameter"] = { fg = gray.mid, italic = true },
			["@lsp.type.property"] = { fg = gray.bright },
			["@lsp.type.struct"] = { fg = gray.bright, bold = true },
			["@lsp.type.enum"] = { fg = gray.bright, bold = true },
			["@lsp.type.enumMember"] = { fg = gray.high },
			["@lsp.type.interface"] = { fg = gray.bright, bold = true },
			["@lsp.type.namespace"] = { fg = gray.mid },
			["@lsp.type.method"] = { fg = gray.high },
			["@lsp.type.function"] = { fg = gray.peak },
			["@lsp.type.keyword"] = { fg = gray.peak, bold = true },
			["@lsp.type.comment"] = { fg = gray.dim, italic = true },
			["@lsp.mod.mutable"] = { underline = true },
		}

		local function apply()
			local config = {
				transparent = transparent,
				glow = true,
				show_end_of_buffer = true,
				colors = colors,
			}
			require("darkvoid").setup(config)
			require("darkvoid").load(config)

			-- Must run after load(), which issues `highlight clear`.
			for group, opts in pairs(syntax) do
				vim.api.nvim_set_hl(0, group, opts)
			end
		end

		apply()

		-- Re-assert after any future :colorscheme, which wipes these.
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("GrayscaleSyntax", { clear = true }),
			pattern = "darkvoid",
			callback = function()
				for group, opts in pairs(syntax) do
					vim.api.nvim_set_hl(0, group, opts)
				end
			end,
		})

		vim.keymap.set("n", "<leader>bg", function()
			transparent = not transparent
			apply()
		end, { noremap = true, silent = true, desc = "Toggle background transparency" })
	end,
}
