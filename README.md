# Mac Environment Setup

A curated setup for a fresh macOS development environment, including essential tools, configurations, and scripts to get up and running quickly.

## Mac Setup Assitant

[Set up Mac with iPhone or iPad](https://support.apple.com/en-us/122216).


## Install Xcode Command Line Tools

Install Xcode Command Line Tools by running the following command in your terminal:

```bash
xcode-select --install
```

This will prompt a dialog to install the tools. After installation, essential tools like `git`, `python3`, `gcc`, etc. will be installed

## Install Homebrew

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

## Install Oh My Zsh

```bash
brew install zsh
```

Install [Oh My Zsh](https://ohmyz.sh/):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Clone this Repository

```bash
mkdir ~/Projects
cd ~/Projects

git clone https://github.com/kuanchoulai10/mac-setup.git
```

## Install Essential Applications via Homebrew

```bash
cd ~/Projects/mac-setup/homebrew

brew install --cask $(cat casks.txt)
brew install $(cat formulae.txt)
```
