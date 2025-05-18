local config = require("code_sync.config")
local protocols = require("code_sync.protocols")

local M = {}

function M.run(env, mode)
  local protocol = config.get_protocol()
  local remotes = config.get_targets(env)
  local keypath = config.get_key_path()

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

return M

