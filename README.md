# Homebrew tap for filee-cli

[filee-cli](https://github.com/NomaDamas/filee-cli) is an **unofficial** redistribution of the command line of
[Filee](https://github.com/KnifeLemon/Filee): offline file conversion (255 formats, 16,000+ conversions) with the
conversion engines bundled. Not made or endorsed by Filee's author.

```sh
brew install NomaDamas/filee-cli/filee-cli
filee-cli formats
filee-cli convert photo.heic --to jpg
```

macOS (Apple silicon and Intel) and Linux (x64 and arm64). Windows: see the
[Scoop bucket](https://github.com/NomaDamas/scoop-filee-cli).

- The download is about 900 MB (the engines are in it). Homebrew checks its SHA-256.
- This tap updates itself every few hours from the latest release of NomaDamas/filee-cli (`.github/workflows/update.yml`).
- macOS packages are ad-hoc signed, not notarized (the same as Filee's own macOS packages).
