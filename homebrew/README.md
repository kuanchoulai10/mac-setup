# Install Essential Applications via Homebrew

```bash
mkdir ~/Projects
cd ~/Projects
git clone https://github.com/kuanchoulai10/mac-setup.git

cd ~/Projects/mac-setup/homebrew

brew install --cask $(cat casks.txt)
brew install --formula $(cat formulae.txt)
```

## Setup Zsh Autosuggestions

```bash
echo 'source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

source ~/.zshrc
```

## fzf

https://github.com/junegunn/fzf#setting-up-shell-integration

## libomp

libomp
libomp is keg-only, which means it was not symlinked into /opt/homebrew,
because it can override GCC headers and result in broken builds.

For compilers to find libomp you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"

## libpq

libpq is keg-only, which means it was not symlinked into /opt/homebrew,
because it conflicts with PostgreSQL.

If you need to have libpq first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc

For compilers to find libpq you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

## nvm

Please note that upstream has asked us to make explicit managing
nvm via Homebrew is unsupported by them and you should check any
problems against the standard nvm install method prior to reporting.

You should create NVM's working directory if it doesn't exist:
  mkdir ~/.nvm

Add the following to your shell profile e.g. ~/.profile or ~/.zshrc:
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

You can set $NVM_DIR to any location, but leaving it unchanged from
/opt/homebrew/Cellar/nvm/0.40.3 will destroy any nvm-installed Node installations
upon upgrade/reinstall.

## openjdk@21

For the system Java wrappers to find this JDK, symlink it with
  sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk

openjdk@21 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have openjdk@21 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc

For compilers to find openjdk@21 you may need to set:
  export CPPFLAGS="-I/opt/homebrew/opt/openjdk@21/include"