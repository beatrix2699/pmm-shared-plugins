# Installation
## Codex CLI
```
git clone https://github.com/beatrix2699/pmm-shared-plugins ~/.codex/pmm-shared-plugins --depth 1
mkdir -p ~/.agents/skills
ln -s ~/.codex/pmm-shared-plugins ~/.agents/skills/pmm-shared-plugins
```

To upgrade this skill, follow these steps:
```bash
# make sure exit codex cli
make upgrade

# login codex again
```

## Claude Code
```bash
claude

/plugin marketplace add beatrix2699/pmm-shared-plugins

claude # Now you can use the skills in this collection!
```

### Local plugins
```bash
mkdir -p .claude
cd .claude

ln -s /Users/beatrix/Documents/GitHub/pmm-shared-plugins/skills/ .
```