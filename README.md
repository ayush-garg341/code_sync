### Sync code from local to remote dir ( INPROGRESS )
- Neovim package to sync code from local dir to remote dir.
- Support scp, sftp, rysnc
- Support different ssh mechanisms

### Sample config file.
- This file should be saved as ~/.config/.code_sync.lua

- Config for the case where we have separate **pem file** to ssh.

- Let's understand the keys in below config
    - **protocol**:- one of the scp, rsync, ftp, sftp. Currently supported only rsync.
    - **key_path**:- where our pem file is located
    - **["data-science"], user_agent** ...:- these are the currently opened folders in neovim, which we want to sync. It works as a source.
        - **test, stage, dev**:- These are the key for environent on which we want to sync the code.
            - This is an array, not a single entry as we might want to sync the code on different test, stage, dev servers.
        - **target**:- this is the destination server and the location on which we want to sync the current code.
        - **exclude_file**:- .rsync_ignore, this is the file like .gitignore which contains the files and folders to ignore.
        - **exclude**:- Individual files and folders to ignore.

```lua

{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "ayush@<hostname>:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore",
        key_path = " ~/Downloads/some.pem",
        method = "pem"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        key_path = " ~/Downloads/some.pem",
        method = "pem"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/redis_full_dv_process",
        key_path = " ~/Downloads/some.pem",
        method = "pem"
      } 
    }
  }
}


```

- Lua config for the case where we have config stored at ~/.ssh/config like shown below:

```yaml

# Entry for home server
Host myserver
    HostName 192.168.1.42
    User ubuntu
    IdentityFile ~/.ssh/id_rsa

# Entry for work server
Host workserver
  HostName 10.0.0.5
  User devops
  IdentityFile ~/.ssh/id_work

# Entry using custom port
Host mypi
  HostName 192.168.1.100
  User pi
  Port 2222
  IdentityFile ~/.ssh/id_rsa

# Wildcard example
Host *.local
  User ubuntu
  IdentityFile ~/.ssh/id_rsa
```

```lua

{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "<HostName from config>:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore",
        key_path = "",
        method = "ssh_key"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "<HostName from config>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        key_path = "",
        method = "ssh_key"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "<HostName from config>:/home/ayush/redis_full_dv_process",
        key_path = "",
        method = "ssh_key"
      } 
    }
  }
}

```

- Lua config for the case where we are using plain password to ssh.
```bash

sudo apt install sshpass
sshpass -p 'yourpassword' ssh user@host

```

```lua

{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "ayush@<hostname>:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore",
        key_path = "yourpassword",
        method = "pwd_based"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        key_path = "yourpassword",
        method = "pwd_based"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/redis_full_dv_process",
        key_path = "yourpassword",
        method = "pwd_based"
      } 
    }
  }
}

```
