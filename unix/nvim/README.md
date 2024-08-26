# Contents
- [Need to know](<README#Need to know>)
- [Packer](README#Packer)
- [Lazy](README#Lazy)

# Need to know

| lua name | plugin  |   status   |
| -------- | ------- | ---------- |
| alpaca   | packer  | test       |
| buggy    | packer  | beta       |
| chimera  | lazy    | final      |
| dolphin  | lazy    | completed  |

Latest version is completed to be IDE

# Packer

Always check and install packer
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

Install configuration
```
git clone https://github.com/dotcreep/neovim.git ~/.config/nvim
```

Run `:PackerInstall` when opening on nvim

# Lazy

Install dependencies

- git
- nodejs
- python
- go
- fzf        - fzf
- `fd-find`  - **fd**
- `ripgrep`  - **rg**
- `git`      - **git**
- `bat`      - **bat**
- viu
- chafa
- ueberzugpp

## Feature
### Development
Default tools that automatically detection packet language :

- LSP
- Debugging
- Linter
- Formatter

This feature setup for x86_64 and arm64 and install it using lazy.
