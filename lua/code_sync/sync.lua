local config = require("code_sync.config")
local protocols = require("code_sync.protocols")

local M = {}

function M.run(env, mode)
  local protocol = config.get_protocol()
  local remotes = config.get_targets(env)
  local keypath = config.get_key_path()
  local project_name = config.get_project_name()

  if #remotes == 0 then
    vim.notify("No remotes defined for environment: " .. env, vim.log.levels.WARN)
    return
  end

  local local_path
  if mode == "project" then
    local_path = vim.fn.getcwd() .. "/"
  elseif mode == "cwd" then
    local_path = vim.fn.expand("%:p:h") .. "/"
  else
    local_path = vim.fn.expand("%:p")
  end

  for _, remote in ipairs(remotes) do
    rel_path = M.get_relative_file_path(local_path, project_name)
    if #rel_path > 0 then
      remote = remote .. "/" .. rel_path
    end
    local cmd = protocols.build_command(protocol, keypath, local_path, remote)
    vim.notify(cmd)
    if cmd then
      local output = vim.fn.system(cmd)
      vim.notify("Synced to " .. remote .. ":\n" .. output)
    else
      vim.notify("Unsupported protocol: " .. protocol, vim.log.levels.ERROR)
    end
  end
end

function M.get_relative_file_path(full_path, project_name)
  project_name = M.escape_lua_pattern(project_name)
  local rel_path = full_path:gsub(".*" .. project_name .. "/", "")
  return rel_path
end

function M.escape_lua_pattern(s)
  return s:gsub("([^%w])", "%%%1")
end

return M

