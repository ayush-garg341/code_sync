### What it does and what is the need.
- I was looking for a simple package to sync my code to remote server. I love to code in neovim and it's my primary code editor with all the package and themes I love.
- I found that some already existing packages provide too much than needed and configuring them is a nightmare while it should not be.
- So here is this simple package, completely written in lua and which does only one job i.e syncing the code from local computer to remote server.
- You just have to define the configuration in ~/.config/.code_sync.lua and you are good to go. Below I have demonstrated and explained how to create this config.
- If you love this package and wanna contribute, I have list of todos in future, pick one and ship.

### How to install
- Via Packer or check reference [here](https://github.com/ayush-garg341/Neovim-from-scratch-ayush/blob/feature/personal-nvim-config/lua/user/plugins.lua#L113)
```lua
  use({
      "ayush-garg341/code_sync",
      config = function()
        require("code_sync").setup()
      end,
  })

```

### Sync code from local to remote dir ( INPROGRESS )
- Neovim package to sync code from local dir to remote dir.
- Currently supporting `rsync` only but in future plan to support `scp`, `sftp` as well.
- Support different ssh mechanisms.

### Sample config file.
- This file should be saved as ~/.config/.code_sync.lua

- Config for the case where we have separate **pem file** to ssh.

- Let's understand the keys in below config
    - **protocol**:- one of the scp, rsync, ftp, sftp. Currently supported only rsync.
    - **keypath**:- where our pem file is located
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
        keypath= " ~/Downloads/some.pem",
        method = "key_based"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        keypath= " ~/Downloads/some.pem",
        method = "key_based"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "ayush@<hostname>:/home/ayush/redis_full_dv_process",
        keypath= "~/.ssh/id_rsa",
        method = "key_based"
      } 
    }
  }
}


```

- Lua config for the case where we are not passing any key during ssh:

```bash

# Generate SSH key on your client
ssh-keygen -t rsa -b 4096 -C "yourname@yourhost"

# Copy the public key to your server: You will be prompted for pwd one last time.
ssh-copy-id -i <file_path> ubuntu@192.168.1.42

# user - ubuntu, host - 192.168.1.42
ssh ubuntu@192.168.1.42

```

```yaml

# Store the hostname in a config file for shorter login

# Entry for home server, hostname - myserver
Host myserver
    HostName 192.168.1.42
    User ubuntu
    IdentityFile ~/.ssh/id_rsa

# Entry for work server
Host workserver, hostname - workserver
  HostName 10.0.0.5
  User devops
  IdentityFile ~/.ssh/id_work

# Entry using custom port, hostname - mypi
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

```bash

# You can do ssh now like this.
ssh myserver
ssh workserver
ssh mypi

```

```lua

{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "user@host:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore",
        keypath= "",
        method = "key_less"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "<HostName from config>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        keypath= "",
        method = "key_less"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "<HostName from config>:/home/ayush/redis_full_dv_process",
        keypath= "",
        method = "key_less"
      } 
    }
  }
}

```

- Lua config for the case where we are using plain password to ssh.
```bash

# On Linux system

sudo apt install sshpass
sshpass -p 'yourpassword' ssh user@host

# On macos
brew install hudochenkov/sshpass/sshpass

```

```lua

{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "ayush@<host>:/home/ayush/data-science",
        -- exclude = { "venv", "feature_prototypes", "results", "experiments", ".git", ".coveragerc", ".pre-commit-config.yaml", "klm-218.txt"}
        exclude_file = "/Users/elliott/.rsyncignore",
        keypath= "yourpassword",
        method = "pwd_based"
      }  
    },
  },
  user_agent = {
    test = { 
      {
        target = "ayush@<host>:/home/ayush/user_agent",
        exclude_file = "/home/ayush/.rsyncignore",
        keypath= "yourpassword",
        method = "pwd_based"
      } 
    }
  },
  redis_full_dv_process = {
    test = { 
      {
        target = "ayush@<host>:/home/ayush/redis_full_dv_process",
        keypath= "yourpassword",
        method = "pwd_based"
      } 
    }
  }
}

```

- If we are doing ssh on a port other than 22, then we should pass this port parameter at appropriate places in the lua config.
    - If we are using `~/.ssh/config` file, we can mention the port in that file.
    - Else we can pass it like `ssh -p <port> user@host`. We have to change our `target` key and append `-p <port>` in the beginning of the command like `-p <port> user@host:/some/location`

### Usage
- Right now 3 commands are supported.
    - `CodeSync`
    - `CodeSyncCancel`
    - `CodeSyncList`

- CodeSync -> This command is responsible to sync the code between your local dir and remote dir. It supports two options:
```bash
# This command will sync the current whole project opened in neovim on test environment defined in ~/.config/.code_sync.lua
:CodeSync test --project

# Similarly to sync current working directory, we will use --cwd. By default if no option is passed, it will sync the current file.
# Similar to test, we can pass stage/dev which will sync the code on stage and dev environent. 
```
- Not added the support for prod key intentionally, because on prod code must go through proper CI/CD not via rsync.

- CodeSyncList -> This command will list current syncing commands in progress along with their ID. You can use this ID to cancel the sync.
```bash
:CodeSyncList
```

- CodeSyncCancel -> This command will cancel the sync job given the ID of the job.
```bash
:CodeSyncCancel <job_id>
```

### Future Todos
- Add better logging/output for sync success or fail.
- Add auto sync at regular intervals, time interval can be defined by the user.
- Add support for `scp` and `sftp`.

### Contributions
- This project is open source, you can fork the repo and create PR.

