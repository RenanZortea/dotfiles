return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false, -- This plugin is already lazy
		config = function()
			-- 1. Configure the Plugin (Server + Tools)
			vim.g.rustaceanvim = {
				-- UI Configuration
				tools = {
					float_win_config = {
						border = "rounded",
					},
				},
				-- LSP Server Configuration
				server = {
					on_attach = function(client, bufnr)
						-- This enables "Format on Save" specifically for Rust
						if client.server_capabilities.documentFormattingProvider then
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({ async = false })
								end,
							})
						end
					end,
				},
			}

			-- 2. Define the Custom Tools Menu
			local function show_rust_tools()
				local options = {
					{
						label = "Rustfmt",
						desc = "Format this code with Rustfmt.",
						cmd = function()
							vim.lsp.buf.format()
						end,
					},
					{
						label = "Clippy",
						desc = "Catch common mistakes (Check only).",
						cmd = function()
							vim.cmd("!cargo clippy")
						end,
					},
					{
						label = "Miri",
						desc = "Execute binary with Miri (Nightly).",
						cmd = function()
							vim.cmd("vsplit | term cargo +nightly miri run")
						end,
					},
					{
						label = "Expand macros",
						desc = "Expand macros in code.",
						cmd = function()
							vim.cmd("RustLsp expandMacro")
						end,
					},
				}

				local select_opts = {
					prompt = "Rust Tools",
					format_item = function(item)
						return item.label .. " - " .. item.desc
					end,
				}

				vim.ui.select(options, select_opts, function(item)
					if item then
						item.cmd()
					end
				end)
			end

			-- 3. Create Command and Keybind
			vim.api.nvim_create_user_command("RustTools", show_rust_tools, {})
			vim.keymap.set("n", "<leader>rt", show_rust_tools, { desc = "Open Rust Tools Menu" })
		end,
	},
}
