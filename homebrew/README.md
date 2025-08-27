# Install Essential Applications via Homebrew

```bash
mkdir ~/Projects
cd ~/Projects
git clone https://github.com/kuanchoulai10/mac-setup.git

cd ~/Projects/mac-setup/homebrew

brew install --cask $(cat casks.txt)
brew install --formula $(cat formulae.txt)
```

## UV Shell Autocompletions

```bash
echo '
# UV
# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
```

### Zsh Autosuggestions

```bash
echo '
# Zsh Autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
```

### fzf

```bash
echo '
# Set up fzf key bindings and fuzzy completion
# https://github.com/junegunn/fzf#setting-up-shell-integration
source <(fzf --zsh)' >> ~/.zshrc
```

### libomp

```bash
# For compilers to libomp you may need to set
#   export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"
```

### libpq

```bash
echo '
# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

```bash
# For compilers to libpq you may need to set
#   export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
```

### nvm

```bash
mkdir ~/.nvm

echo '
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.zshrc
```

### openjdk@21

```bash
echo '
# openjdk@21
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
```

```bash
# For the system Java wrappers to find this JDK, symlink it with
#   sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk

# For compilers to find openjdk@21 you may need to set:
#   export CPPFLAGS="-I/opt/homebrew/opt/openjdk@21/include"
```

---

After adding all these snippets to your `~/.zshrc`, run:

```bash
source ~/.zshrc
```

