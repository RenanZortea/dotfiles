return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local status_ok, alpha = pcall(require, "alpha")
		if not status_ok then
			return
		end

		local dashboard = require("alpha.themes.dashboard")

		-- Define a table with multiple ASCII arts
		local ascii_arts = {
			{
				[[                                                    ]],
				[[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
				[[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
				[[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
				[[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
				[[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
				[[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
				[[                                                    ]],
			},
		}

		-- Pick a random ASCII art
		math.randomseed(os.time())
		local random_ascii = ascii_arts[math.random(#ascii_arts)]

		-- Assign the random ASCII art to the header
		dashboard.section.header.val = random_ascii

		-- Configure dashboard buttons
		dashboard.section.buttons.val = {
			dashboard.button("f", "🔍 Find file", ":Telescope find_files <CR>"),
			dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("r", "⌛ Recently used files", ":Telescope oldfiles <CR>"),
			dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
			dashboard.button("c", "  Configuration", ":e ~/dotfiles/.config/nvim/init.lua<CR>"),
			dashboard.button("q", "🗙  Quit Neovim", ":qa<CR>"),
		}

		-- Set highlight options
		dashboard.section.footer.opts.hl = "Type"
		dashboard.section.header.opts.hl = "Include"
		dashboard.section.buttons.opts.hl = "Keyword"

		-- Finalize Alpha setup
		dashboard.opts.opts.noautocmd = true
		alpha.setup(dashboard.opts)
	end,
}
