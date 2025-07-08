local M = {}

function M.build_command(protocol, local_path, remote_path, opts)
  if protocol == "rsync" then

    local cmd

    if opts.method == "pwd_based" then
      cmd = {
        string.format("sshpass -p %q rsync -avz --update -e ssh", opts.keypath)
      }

    elseif opts.method == "pem" then
      cmd = {
        string.format("rsync -avz --update -e 'ssh -i %s'", opts.keypath)
      }

    elseif opts.method == "ssh_key" then
      cmd = {
        string.format("rsync -avz --update ")
      }

    else
      error("Unknown method: " .. tostring(opts.method))

    end

    -- Add excludes
    if opts.exclude then
      for _, pattern in ipairs(opts.exclude) do
        table.insert(cmd, "--exclude=" .. pattern)
      end
    end

    -- Add exclude file
    if opts.exclude_file then
      table.insert(cmd, "--exclude-from=" .. opts.exclude_file)
    end

    -- Source and destination
    table.insert(cmd, local_path)
    table.insert(cmd, remote_path)

    local cmd_str = table.concat(cmd, " ")
    return cmd_str

  elseif protocol == "scp" then
    return string.format("scp -r %s %s %s", opts.keypath, local_path, remote_path)
  elseif protocol == "ftp" then
    return string.format("lftp -e 'mirror -R %s %s %s; quit'", opts.keypath, local_path, remote_path)
  elseif protocol == "sftp" then
    return string.format("sftp %s %s <<< $'put -r %s'", opts.keypath, local_path, remote_path)
  else
    return nil
  end
end

return M

