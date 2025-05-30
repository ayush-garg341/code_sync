local config = require("code_sync.config")
local protocols = require("code_sync.protocols")

local M = {}
local active_jobs = {}
local job_id_counter = 1

function M.run(env, mode)
  local protocol = config.get_protocol()
  local remotes = config.get_targets(env)
  local keypath = config.get_key_path()
  local project_name = config.get_project_name()

  if type(remotes) ~= "table" then
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

  for _, server in ipairs(remotes) do
    local dest = server.target
    local exclude = server.exclude
    local exclude_file = server.exclude_file
    rel_path = M.get_relative_file_path(local_path, project_name)
    if #rel_path > 0 then
      remote = remote .. "/" .. rel_path
    end

    local cmd = protocols.build_command(protocol, local_path, dest, {
      keypath = keypath,
      exclude = exclude,
      exclude_file = exclude_file,
    })
    vim.notify(cmd)

    local job_id = job_id_counter
    job_id_counter = job_id_counter + 1

    if cmd then
      -- jobstart is async
      -- system is sync
      local stderr_output = {}
      local stdout_output = {}

      local actual_job_id = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,

        on_stdout = function(_, data, _)
          if data then
            for _, line in ipairs(data) do
              if line ~= "" then
                table.insert(stdout_output, line)
              end
            end
          end
        end,

        on_stderr = function(_, data, _)
          if data then
            for _, line in ipairs(data) do
              if line ~= "" then
                table.insert(stderr_output, line)
              end
            end
          end
        end,

        on_exit = function(_, exit_code, _)
          if exit_code == 0 then 
            vim.schedule(function()
              vim.notify("Job " .. job_id .. " completed successfully.")
            end)
          else
            local error_msg = table.concat(stderr_output, "\n")
            vim.schedule(function()
              vim.notify("Job " .. job_id .. " failed:\n" .. error_msg, vim.log.levels.ERROR)
            end)
          end
          active_jobs[job_id] = nil
        end,
      })

      if actual_job_id <= 0 then
        vim.notify("Failed to start rsync job", vim.log.levels.ERROR)
        return
      end

      active_jobs[job_id] = {
        nvim_job_id = actual_job_id,
        command = cmd,
        started_at = os.date("%Y-%m-%d %H:%M:%S"),
      }
      vim.notify("Started sync job " .. job_id)
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

function M.clean_jobs()
  for id, job in pairs(active_jobs) do
    local status = vim.fn.jobwait({ job.nvim_job_id }, 0)[1]
    if status ~= -1 then -- not running anymore
      active_jobs[id] = nil
    end
  end
end

function M.list_jobs()
  M.clean_jobs()
  if vim.tbl_isempty(active_jobs) then
    vim.notify("No running sync jobs")
  end

  local lines = { "Active CodeSync Jobs: "}
  for id, job in pairs(active_jobs) do
    table.insert(lines, string.format("ID: %d | Started: %s", id, job.started_at))
    table.insert(lines, "  " .. job.command)
  end

  M.display_floating_window(lines)
end


function M.cancel_job(id)
  id = tonumber(id)
  job = active_jobs[id]
  if job then
    vim.fn.jobstop(job.nvim_job_id)
    active_jobs[id] = nil
    vim.notify("Cancelled job " .. id)
  else
    vim.notify("No running job with ID " .. id, vim.log.levels.WARN)
  end
end


function M.display_floating_window(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.max(60, math.floor(vim.o.columns * 0.5))
  local height = #lines + 2
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Close the window on <Tab>
  vim.keymap.set("n", "<Tab>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true, silent = true })
end

return M

