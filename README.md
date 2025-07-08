### Sync code from local to remote dir ( INPROGRESS )
- Neovim package to sync code from local dir to remote dir.
- Support scp, sftp, rysnc
- Support different ssh mechanisms

### Sample config file.
- You can pass the filename .rsyncignore like .gitignore which will have entries to ignore syncing. Or you can pass individual folders/filer as exclude parameter.

- Config for the case where we have separate **pem file** to ssh.
```json

{
  protocol = "rsync",
  key_path = " ~/Downloads/some.pem",
  ["data-science"] = {
    test = {
      {
        target = "ayush@<hostname>:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/redis_full_dv_process"
      } 
    }
  }
}


```
