### Sync code from local to remote dir ( INPROGRESS )
- Neovim package to sync code from local dir to remote dir.
- Support scp, sftp, rysnc
- Support different ssh mechanisms

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

