# Dotfiles

`links.tsv` is the explicit symlink manifest and collision allowlist. Chezmoi's
source state lives in `../home` and maps each target to its authoritative backing
file in this directory. The bootstrap refuses to overwrite an unknown existing file
or link.

After changing a backing file, the live symlink reflects it immediately. Use
`chezmoi status`, `chezmoi diff`, and `chezmoi apply` to inspect or repair
managed targets. Add every new target to both `links.tsv` and the matching
chezmoi source entry.
