# 🔁 code_sync.nvim

> A lightweight Neovim plugin to sync your local code to remote servers with minimal configuration. Runs in background, does not freeze the main window.

---

## ✨ What It Does & Why It Exists

- I wanted a **simple, minimal plugin** to sync code from my local machine to a remote server while coding in Neovim—my go-to editor.
- Existing plugins were either too bloated or difficult to configure.
- So I built this: a **single-purpose, Lua-based plugin** that does one thing well—**syncing code from local to remote**.
- You just need to define your sync configuration in `~/.config/.code_sync.lua`, and you're ready to go!
- If you find this plugin useful and want to contribute, check out the [🛠️ Future Todos](#-future-todos) section.

---

## 📦 Installation

Install using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
    "ayush-garg341/code_sync",
    config = function()
        require("code_sync").setup()
    end,
})
```

Or refer to [this config reference](https://github.com/ayush-garg341/Neovim-from-scratch-ayush/blob/feature/personal-nvim-config/lua/user/plugins.lua#L113).

---

## 🚀 Features (In Progress)

- Sync local directories to remote servers.
- Currently supports: `rsync` (more protocols like `scp`, `sftp` coming soon).
- Support for different SSH methods: password-based, key-based, keyless.

---

## 🛠️ Sample Configuration

Save your config in: `~/.config/.code_sync.lua`

### 🔐 Key-Based SSH (e.g. using a `.pem` file)

```lua
{
  protocol = "rsync",
  ["data-science"] = {
    test = {
      {
        target = "ayush@<hostname>:/home/ayush/data-science",
        exclude_file = "/Users/elliott/.rsyncignore",
        keypath = "~/Downloads/some.pem",
        method = "key_based"
      }
    }
  },
  ...
}
```

---

### 🔑 Keyless SSH (Public Key copied to server)

**Steps:**

```bash
ssh-keygen -t rsa -b 4096 -C "yourname@yourhost"
ssh-copy-id -i ~/.ssh/id_rsa.pub user@host
```

Update `~/.ssh/config` for shorthand access:

```ini
Host myserver
  HostName 192.168.1.42
  User ubuntu
  IdentityFile ~/.ssh/id_rsa

Host workserver
  HostName 10.0.0.5
  User devops
  IdentityFile ~/.ssh/id_work
```

**Sample Lua config:**

```lua
{
  protocol = "rsync",
  ["project-name"] = {
    test = {
      {
        target = "myserver:/home/ubuntu/project-name",
        exclude_file = "~/.rsyncignore",
        method = "key_less"
      }
    }
  }
}
```

---

### 🔓 Password-Based SSH

**Install `sshpass`:**

```bash
# Linux
sudo apt install sshpass

# macOS
brew install hudochenkov/sshpass/sshpass
```

**Lua Config:**

```lua
{
  protocol = "rsync",
  ["project-name"] = {
    test = {
      {
        target = "user@host:/home/user/project-name",
        keypath = "yourpassword",
        method = "pwd_based"
      }
    }
  }
}
```

--- 

### 🧾 Configuration Key Reference

Let's understand the keys used in the config:

- **protocol**: One of the supported sync methods: `scp`, `rsync`, `ftp`, `sftp`.  
  _(Currently, only `rsync` is supported.)_
- **keypath**: Path to the SSH private key (`.pem`) file for authentication.
- **["data-science"], user_agent, redis_full_dv_process, ...**:  
  These represent the **currently opened folders** in Neovim which you want to sync. These act as source identifiers.
  - **test, stage, dev**:  
    Environment keys indicating where the code should be synced.
    - Each environment key holds an array of targets.  
      _(You can sync code to multiple `test`, `stage`, or `dev` servers.)_
  - **target**: Destination server and directory where code should be synced.
  - **exclude_file**: Path to a file like `.rsync_ignore` that lists files/folders to be excluded from syncing (similar to `.gitignore`).
  - **exclude**: Inline list of files/folders to be excluded (array).

---

### 🔁 Using Custom Ports

- Define ports in your `~/.ssh/config`:
```ini
Host mypi
  HostName 192.168.1.100
  User pi
  Port 2222
  IdentityFile ~/.ssh/id_rsa
```

- Or modify the `target` string to include `-p <port>` before the SSH address.

---

## 🧪 Usage

Three commands are currently supported:

| Command            | Description                                                  |
|--------------------|--------------------------------------------------------------|
| `:CodeSync`        | Syncs code to the defined environment (test/stage/dev).      |
| `:CodeSyncList`    | Shows running sync jobs with their job IDs.                  |
| `:CodeSyncCancel`  | Cancels a sync job given its ID.                             |

### 🔧 Example

```vim
:CodeSync test --project   " Sync entire project to test env
:CodeSync test --cwd       " Sync current directory to test env
:CodeSync dev              " Sync current file to dev env
```

❗**Note:** `prod` sync is intentionally not supported. Production sync should go through CI/CD pipelines.

---

## 📋 Future Todos

- 🧪 Support dry run of rsync command before actually start syncing (emphasizes testing safely)
- 🔄 **Hot-reload support**: Automatically refreshes the config file on-the-fly when updated — no need to restart Neovim.
- 📊 Better logging for sync success/failure
- ⏱️  Auto-sync at user-defined intervals
- 🧠 Smarter file tracking and change detection
- ✅ Add support for `scp`, `sftp`.

---

## 🤝 Contributing

All contributions are welcome! 🚀

### 📌 How to Contribute

1. Fork the repository
2. Create a new branch: `git checkout -b my-feature`
3. Make your changes and test thoroughly
4. Commit and push: `git commit -m "Add new feature"` then `git push origin my-feature`
5. Open a Pull Request with a description of what you’ve changed

---

> Made with ❤️ by [@ayush-garg341](https://github.com/ayush-garg341)

