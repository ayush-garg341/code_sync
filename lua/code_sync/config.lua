local M = {
  config_data = {},
}

function M.load()
  local path = vim.fn.fnamemodify("~/.config" .. "/.code_sync.lua", ":p")
  local ok, data = pcall(dofile, path)
  if ok and data then
    M.config_data = data
    return
  end

  -- Optional fallback
  local global_path = vim.fn.stdpath("config") .. "/code_sync/config.lua"
  if vim.fn.filereadable(global_path) == 1 then
    M.config_data = dofile(global_path)
  else
    -- vim.notify(vim.fn.getcwd())
    vim.notify("No .code_sync.lua config found", vim.log.levels.WARN)
  end
end

function M.get_project_name()
  local cwd = vim.fn.getcwd()
  return vim.fn.fnamemodify(cwd, ":t")
end

function M.get_targets(env)
  local project = M.get_project_name()
  if not M.config_data[project] then
    return {}
  end
  return M.config_data[project][env] or {}
end

function M.get_protocol()
  return M.config_data.protocol or "rsync"
end

function M.get_key_path()
  return M.config_data.key_path
end

return M
