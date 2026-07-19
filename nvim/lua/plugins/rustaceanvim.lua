return {
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false, -- This plugin is already lazy
		config = function()
			-- 1. Configure the Plugin (Server + Tools)
			-- rustaceanvim owns the rust-analyzer client outright. It must NOT also be
			-- configured through nvim-lspconfig/mason-lspconfig or two servers attach;
			-- see the no-op handler in plugins/lsp.lua.
			local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")

			local switch = require("core.lsp_switch")

			vim.g.rustaceanvim = {
				-- UI Configuration
				tools = {
					float_win_config = {
						border = "rounded",
					},
				},
				server = {
					-- The spawner reads the persisted switch and declines to start,
					-- rather than being killed after it has already indexed.
					auto_attach = function(bufnr)
						if not switch.is_enabled() then
							return false
						end
						if #vim.bo[bufnr].buftype > 0 then
							return false
						end
						local path = vim.api.nvim_buf_get_name(bufnr)
						if path == "" or vim.fn.filereadable(path) == 0 then
							return false
						end
						return vim.fn.executable("rust-analyzer") == 1
					end,
					capabilities = ok and cmp_lsp.default_capabilities() or nil,
					default_settings = {
						["rust-analyzer"] = {
							lru = {
								capacity = 16,
							},
							cargo = {
								allFeatures = true,
							},
						},
					},
				},
				-- Format on save is handled by conform.nvim (plugins/conform.lua),
				-- which routes rust -> rustfmt for every buffer, not just the ones
				-- a particular client happens to attach to.
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

			-- 4. Knowledge maps: <leader>k = "ask the compiler something".
			-- Buffer-local to Rust, so they don't occupy the global namespace.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "rust",
				group = vim.api.nvim_create_augroup("RustKnowledgeMaps", { clear = true }),
				callback = function(event)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
					end

					map("<leader>ke", "<cmd>RustLsp explainError<cr>", "[K]nowledge: [E]xplain error (rustc --explain)")
					map("<leader>kr", "<cmd>RustLsp renderDiagnostic<cr>", "[K]nowledge: [R]ender full diagnostic")
					map("<leader>km", "<cmd>RustLsp expandMacro<cr>", "[K]nowledge: expand [M]acro")
					map("<leader>kd", "<cmd>RustLsp openDocs<cr>", "[K]nowledge: open [D]ocs (docs.rs)")
					map("<leader>kp", "<cmd>RustLsp parentModule<cr>", "[K]nowledge: [P]arent module")
					map("<leader>kc", "<cmd>RustLsp openCargo<cr>", "[K]nowledge: open [C]argo.toml")
					map("<leader>kh", "<cmd>RustLsp view hir<cr>", "[K]nowledge: view [H]IR (desugared)")
					map("<leader>ki", "<cmd>RustLsp view mir<cr>", "[K]nowledge: view M[I]R (control flow)")
					map("<leader>ks", "<cmd>RustLsp syntaxTree<cr>", "[K]nowledge: [S]yntax tree")
					map("<leader>kt", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[K]nowledge: toggle inlay [T]ypes")
				end,
			})
		end,
	},
}
