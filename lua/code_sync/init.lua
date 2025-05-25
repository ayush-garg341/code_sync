local M = {}

local config = require("code_sync.config")
local sync = require("code_sync.sync")

function M.setup(user_config)
  config.load(user_config)

  vim.api.nvim_create_user_command("CodeSync", function(opts)
    local args = {}
    for word in string.gmatch(opts.args, "%S+") do
      table.insert(args, word)
    end

    local env = args[1] or "dev"
    local scope = args[2] or "file"

    if env ~= "dev" and env ~= "test" and env ~= "stage" then
      vim.notify("Invalid environment. Use dev, test, or stage.", vim.log.levels.ERROR)
      return
    end

    local mode
    if scope == "--project" then
      mode = "project"
    elseif scope == "--cwd" then
      mode = "cwd"
    else
      mode = "file"
    end

    sync.run(env, mode)
  end, {
    nargs = "*",
    complete = function()
      return { "dev", "test", "stage", "--project", "--cwd" }
    end,
  })

  -- List sync jobs command register
  vim.api.nvim_create_user_command("CodeSyncList", function()
    sync.list_jobs()
  end, {})


  -- Cancel sync job command register
  vim.api.nvim_create_user_command("CodeSyncCancel", function(opts)
    sync.cancel_job(opts.args)
  end, {
  nargs = 1,
  complete = function()
    sync.clean_jobs()
    local job_ids = {}
    for id, _ in pairs(sync.active_jobs) do
      table.insert(job_ids, tostring(id))
    end
    return job_ids
  end,
})

end

return M

