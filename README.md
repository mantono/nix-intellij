# nix-intellij
Nix flake for creating a reproducible development environment for Kotlin (using IntelliJ).

#### Build
`nix build`

#### Enter
`nix develop`

#### Run
- X11:`nix run`
- Wayland: `nix develop` and then ./idea

#### Update flake
`nix flake --extra-experimental-features nix-command  update --commit-lock-file`
