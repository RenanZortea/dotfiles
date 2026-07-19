-- Persistent on/off switch for the heavy language servers (rust-analyzer, clangd).
--
-- The state lives on disk so it survives restarts: spawners read `is_enabled()`
-- at attach time and decline to start rather than being killed after the fact.

local M = {}

local state_file = vim.fn.stdpath("state") .. "/heavy_lsp_enabled"

---@type boolean?
local cached

---@return boolean
function M.is_enabled()
	if cached == nil then
		-- Absent file means "on": a fresh install should have working LSP.
		local f = io.open(state_file, "r")
		if not f then
			cached = true
		else
			cached = f:read("l") ~= "off"
			f:close()
		end
	end
	return cached
end

---@param enabled boolean
function M.set(enabled)
	cached = enabled
	local f = io.open(state_file, "w")
	if not f then
		vim.notify("LSP switch: cannot write " .. state_file, vim.log.levels.ERROR)
		return
	end
	f:write(enabled and "on" or "off")
	f:close()
end

--- Servers this switch governs. Others (lua_ls, etc.) are cheap; leave them be.
---@param name string
---@return boolean
function M.is_heavy(name)
	return name == "rust_analyzer" or name == "rust-analyzer" or name == "clangd"
end

--- Stop any heavy client already running, and clear its diagnostics.
function M.stop_running()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if M.is_heavy(client.name) then
			vim.lsp.stop_client(client.id, true)
		end
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			vim.diagnostic.reset(nil, buf)
		end
	end
end

--- Attach to already-open buffers without needing them reopened.
--- Re-fires FileType autocmds (what lspconfig hooks to launch servers) rather
--- than `:edit`-reloading the file — so it works on modified buffers and never
--- discards unsaved changes.
function M.start_for_open_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
			vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
		end
	end
end

function M.toggle()
	local enabling = not M.is_enabled()
	M.set(enabling)

	if enabling then
		M.start_for_open_buffers()
		vim.notify("🟢 Heavy LSPs ON (rust-analyzer, clangd) — persisted", vim.log.levels.INFO)
	else
		M.stop_running()
		vim.notify("💀 Heavy LSPs OFF — persisted across sessions", vim.log.levels.WARN)
	end
end

function M.status()
	vim.notify(
		("Heavy LSPs are %s (%s)"):format(M.is_enabled() and "🟢 ON" or "💀 OFF", state_file),
		vim.log.levels.INFO
	)
end

return M
