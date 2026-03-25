# dotfiles

Chezmoi-managed dotfiles. Bash, tmux, LazyVim, Starship, mise.

## Quick start

**Fresh machine (one command):**

```bash
curl -fsSL https://raw.githubusercontent.com/vbalashi/dotfiles/main/setup.sh | \
  DOTFILES_REPO=https://github.com/vbalashi/dotfiles.git bash
```

**With SSH keys:**

```bash
curl -fsSL https://raw.githubusercontent.com/vbalashi/dotfiles/main/setup.sh | \
  DOTFILES_REPO=git@github.com:vbalashi/dotfiles.git bash
```

**Existing clone:**

```bash
git clone git@github.com:vbalashi/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup.sh
```

## What setup.sh does

1. Detects OS (Arch/Debian)
2. Installs system packages via pacman/yay (Arch only)
3. Installs [mise](https://mise.jdx.dev) (polyglot tool manager)
4. Installs [chezmoi](https://chezmoi.io) via mise
5. Runs `chezmoi init --apply` (prompts for machine config)
6. Runs `mise install` → starship, bat, lsd, fzf, ripgrep, neovim, node
7. Installs tmux plugin manager (TPM)

## What's included

| Target | Source | Notes |
|---|---|---|
| `~/.bashrc` | `dot_bashrc.tmpl` | Templated: sections for k8s, AI proxy, arch-specific |
| `~/.bash_functions` | `dot_bash_functions` | gcm(), proxy switchers, claude wrappers (opus/sonnet/q/qq/qqq) |
| `~/.aliases` | `dot_aliases` | vim, ls/lsd, bat, k8s, ssh, git aliases |
| `~/.gitconfig` | `dot_gitconfig.tmpl` | Templated: email, signing key, 1Password SSH signing |
| `~/.config/nvim/` | `dot_config/nvim/` + external | LazyVim + Catppuccin, JSON/TOML/YAML extras |
| `~/.config/starship.toml` | `dot_config/starship.toml` | Prompt: git, k8s, python, node, cmd duration |
| `~/.config/mise/config.toml` | `dot_config/mise/config.toml` | Global tools |
| `~/.config/ghostty/config` | `dot_config/ghostty/config` | Catppuccin theme, block cursor |
| `~/.config/git/ignore` | `dot_config/git/ignore` | Global gitignore |
| `~/.tmux.conf` + `~/.tmux/` | `dot_tmux.conf` + `dot_tmux/` | C-a prefix, vim keys, F12 nesting, powerline status |
| `~/.ssh/config` | `private_dot_ssh/config.tmpl` | Templated: 1Password agent, host entries |
| `~/.secrets` | `private_dot_secrets` | API keys (gitignored, mode 0600) |
| `~/.k8s-proxy.sh` | `dot_k8s-proxy.sh` | kubectl/helm SOCKS proxy wrappers |
| `~/.dircolors` | `dot_dircolors` | ls colors for ghostty |
| `~/bin/borg-*` | `bin/executable_borg-*` | Borg backup scripts |

## Machine config

On first `chezmoi init`, you'll be prompted:

| Variable | Values | Effect |
|---|---|---|
| `machine_type` | `arch` / `devmachine` / `container` | Arch-specific blocks (yay, NVM, opencode, KV SDK) |
| `has_1password` | `true` / `false` | SSH agent, git signing via 1Password |
| `has_k8s` | `true` / `false` | KUBECONFIG, k8s proxy wrappers |
| `has_ai_proxy` | `true` / `false` | AI proxy config, claude shortcuts |
| `git_email` | string | Git commit email |
| `git_signing_key` | string | SSH signing key |

Config stored in `~/.config/chezmoi/chezmoi.toml`. Re-run `chezmoi init` to change.

## Secrets

`~/.secrets` is sourced by bashrc. Contains API keys and proxy endpoints.

- **Gitignored** — not pushed to this repo
- **Mode 0600** — chezmoi `private_` prefix
- **Portable** — plain env file, scp to remote machines:
  ```bash
  scp laptop:~/.secrets devmachine:~/.secrets
  ```

## Day-to-day

```bash
chezmoi edit ~/.bashrc     # edit source, not target
chezmoi apply              # deploy changes
chezmoi diff               # preview before applying
chezmoi cd                 # cd into source dir
```

After editing source files directly in `~/dotfiles/`:

```bash
chezmoi apply              # deploy to ~
cd ~/dotfiles && git add -A && git commit -m "..." && git push
```

## Post-install

- Open new terminal → starship prompt should render
- `vim` → LazyVim opens, plugins auto-install on first run
- In tmux: `prefix + I` to install TPM plugins
- Verify: `show_proxy`, `gcm`, git commit signing

## Local Notes

- Home Tailscale routing roles and failure mode: `docs/tailscale-home-topology.md`
