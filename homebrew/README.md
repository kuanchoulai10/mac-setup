# Install Homebrew and All the Essential Applications via Homebrew

This guide will help you set up your macOS environment by installing Homebrew, Zsh, Oh My Zsh, and all the essential applications via Homebrew. Additionally, it will guide you on customizing your shell environment and setting up Helix for Python development. Below is a checklist of the steps involved:

- [ ] Install homebrew
- [ ] Install Zsh and Oh My Zsh
- [ ] Install All the Essential Applications via Homebrew
- [ ] Customize Your Shell Environment
- [ ] Set up Helix for Python Development

### Install homebrew

Install [Homebrew](https://brew.sh/), the package manager for macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run these commands to add Homebrew to your PATH:

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Install Zsh and Oh My Zsh

Install [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#macos) and [Oh My Zsh](https://ohmyz.sh/):

```bash
brew install zsh

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install All the Essential Applications via Homebrew

Clone this repository and install all the essential applications via Homebrew:

```bash
mkdir -p ~/Projects
cd ~/Projects
git clone https://github.com/kuanchoulai10/mac-setup.git

cd ~/Projects/mac-setup/homebrew

brew install --cask $(cat casks.txt)
brew install --formula $(cat formulae.txt)

# Install Terraform using Homebrew
# https://developer.hashicorp.com/terraform/install
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Customize Your Shell Environment:

To customize your shell environment, run the following commands to append necessary configurations to your `~/.zshrc` file:

```bash
mkdir -p ~/.nvm

echo '
# uv Shell Autocompletions
# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
eval "$(uv generate-shell-completion zsh)"

# Zsh Autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Set up fzf key bindings and fuzzy completion
# https://github.com/junegunn/fzf#setting-up-shell-integration
source <(fzf --zsh)

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
# For compilers to libomp you may need to set
#   export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"

# libomp
# For compilers to libpq you may need to set
#   export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

# openjdk@21
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
# For the system Java wrappers to find this JDK, symlink it with
#   sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
# For compilers to find openjdk@21 you may need to set:
#   export CPPFLAGS="-I/opt/homebrew/opt/openjdk@21/include"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Alias
alias cat="bat -pp"
alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree --level=3"
alias vim="hx"
alias nano="micro"
alias k="kubectl"
alias myip="curl -s https://checkip.amazonaws.com"

' >> ~/.zshrc

source ~/.zshrc
```

## Set up Helix for Python Development

Helix is a post-modern, vim-like text editor. To set up Helix for Python development, run the following commands:

```bash
mkdir -p ~/.config/helix

touch ~/.config/helix/languages.toml
echo '
# Helix Language
# https://docs.helix-editor.com/languages.html#languages
# https://github.com/helix-editor/helix/wiki/Language-Server-Configurations
# ruff
# https://docs.astral.sh/ruff/editors/#language-server-protocol
# https://docs.astral.sh/ruff/editors/setup/#helix


[language-server.pyrefly]
command = "pyrefly"
args = ["lsp"]

[language-server.ruff]
command = "ruff"
args = ["server"]

[[language]]
name = "python"

language-servers = [
  { name = "ruff", only-features = ["diagnostics", "code-action"] },
  "pyrefly"
]
auto-format = true

formatter = { command = "ruff", args = ["format", "-"] }

roots = [".git", "pyproject.toml", "pyrefly.toml"]
' >> ~/.config/helix/languages.toml


touch ~/.config/helix/config.toml
echo '
theme = "kaolin-light"' >> ~/.config/helix/config.toml
```

This will:

- Set up Helix with Python language support using `pyrefly` and `ruff`
- Enable auto-formatting on save using `ruff`
- Set the Helix theme to "kaolin-light"

---

After completing the above steps, go back to [Clone My Personal Repositories](../README.md#clone-my-personal-repositories) step to continue the setup.