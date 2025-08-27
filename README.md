# Mac Environment Setup

A curated setup for a fresh macOS development environment, including essential tools, configurations, and scripts to get up and running quickly.

### Mac Setup Assitant

[Set up Mac with iPhone or iPad](https://support.apple.com/en-us/122216).

### Install Xcode Command Line Tools

Install Xcode Command Line Tools by running the following command in your terminal:

```bash
xcode-select --install
```

This will prompt a dialog to install the tools. After installation, essential tools like `git`, `python3`, `gcc`, etc. will be installed

### Install Homebrew

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

### Install Oh My Zsh

Install [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#macos) and [Oh My Zsh](https://ohmyz.sh/):

```bash
brew install zsh

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

```

### Install Essential Applications via Homebrew

Go to [`homebrew/`](./homebrew/) directory and see the instructions there.

### Install Terraform

Go to [`terraform/`](./terraform/) directory and see the instructions there.

### Clone My Personal Repositories

```bash
cd ~/Projects

git clone https://github.com/kuanchoulai10/monorepo.git --recurse-submodules
git clone https://github.com/kuanchoulai10/kuanchoulai10.git
git clone https://github.com/kuanchoulai10/leetcode.git
git clone https://github.com/kuanchoulai10/retail-lakehouse.git
git clone https://github.com/kuanchoulai10/data-mesh.git
git clone https://github.com/kuanchoulai10/data2ml-ops.git
```

### Alias

```bash
echo '# Alias
alias cat="bat"
alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree --level=3"
alias k="kubectl"' >> ~/.zshrc

source ~/.zshrc
```

### Setup Karabiner-Elements

Go to [`karabiner-elements/`](./karabiner-elements/) directory and see the instructions there.

### Customize macOS Settings

- `Energy` > 螢幕不顯示時，不關機
- `Lock Screen` > ``
- `General` > `Login Items & Extensions` > `Open at Login`
- `General` > `Sharing` > `Remote Login`
- `Desktop & Dock` > `Automatically hide and show the Dock`
- `Privacy & Security` > `Screen & System Audio Recording` > `Screen & System Audio Recording` > Add
    - `ChatGPT`
    - `Google Chrome`
    - `LINE`
    - `Shottr`
    - `Xnapper`
    - `Zoom`

