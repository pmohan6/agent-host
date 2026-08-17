# mise

`config.toml` pins exact Node, Python, and pnpm versions. Runtime archives are
installed into the standard user's home directory; the configuration, not the
downloaded runtime, is tracked in Git. Individual repositories may override these
defaults with their own trusted `mise.toml` files.
