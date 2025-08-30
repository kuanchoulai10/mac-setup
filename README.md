# Mac Setup

A curated setup for a fresh macOS development environment, including essential tools, configurations, and scripts to get up and running quickly.

### Mac Setup Assitant

[Set up Mac with iPhone or iPad](https://support.apple.com/en-us/122216).

### Install Xcode Command Line Tools

Install Xcode Command Line Tools by running the following command in your terminal:

```bash
xcode-select --install
```

This will prompt a dialog to install the tools. After installation, essential tools like `git`, `python3`, `gcc`, etc. will be installed

### Install Homebrew and All the Essential Applications via Homebrew

Go to [`homebrew/`](./homebrew/) directory and see the instructions there.

### Clone My Personal Repositories

```bash
mkdir -p ~/Projects
cd ~/Projects

git clone https://github.com/kuanchoulai10/monorepo.git --recurse-submodules
git clone https://github.com/kuanchoulai10/kuanchoulai10.git
git clone https://github.com/kuanchoulai10/leetcode.git
git clone https://github.com/kuanchoulai10/retail-lakehouse.git
git clone https://github.com/kuanchoulai10/data-mesh.git
git clone https://github.com/kuanchoulai10/data2ml-ops.git
```

### AWS, Gemini, and OpenAI

```bash
echo '
# AWS
# https://console.aws.amazon.com/console/home
export AWS_REGION="_________" # Taiwan (ap-east-2)
export AWS_ACCESS_KEY_ID="_________"
export AWS_SECRET_ACCESS_KEY="_________"

# Gemini
# https://aistudio.google.com/app/apikey
export GEMINI_API_KEY="_________"

# OpenAI
# https://platform.openai.com/api-keys
export OPENAI_API_KEY="_________"' >> ~/.zshrc

source ~/.zshrc
```

### Setup Karabiner-Elements

Go to [`karabiner-elements/`](./karabiner-elements/) directory and see the instructions there.

### Raycast

See [`raycast/`](./raycast/) directory for instructions.

### Customize macOS Settings

- `Energy` > `Prevent automatic sleeping on power adapter when the display is off`
- `Lock Screen`
    - `Start screen saver when inactive for` > `3 minutes`
    - `Turn display off after` > `10 minutes`
    - `Require password` > `immediately` after sleep or screen saver begins or display is turned off
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