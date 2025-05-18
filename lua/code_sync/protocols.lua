local M = {}

function M.build_command(protocol, keypath, local_path, remote_path)
  if protocol == "rsync" then
    return string.format("rsync -avz --update -e 'ssh -i %s' %s %s", keypath, local_path, remote_path)
  elseif protocol == "scp" then
    return string.format("scp -r %s %s %s", keypath, local_path, remote_path)
  elseif protocol == "ftp" then
    return string.format("lftp -e 'mirror -R %s %s %s; quit'", keypath, local_path, remote_path)
  elseif protocol == "sftp" then
    return string.format("sftp %s %s <<< $'put -r %s'", keypath, remote_path, local_path)
  else
    return nil
  end
end

return M

