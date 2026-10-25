# midas

Small CLI for updating Gold dotfiles and restowing configuration packages.

| Command | Action |
| --- | --- |
| \`midas update\` or \`midas gold\` | Require a clean dotfiles checkout, pull \`origin main\` with \`--ff-only\`, then restow \`gold\` to \`~/.local/bin\`. |
| \`midas opencode\` | Restow the \`opencode\` package to \`HOME\` when it exists. |

Set \`GOLD_DOTFILES\` to override the default \`~/.dotfiles\` checkout path. The CLI invokes Git and Stow directly, without a shell. It returns a nonzero status when the checkout is dirty or either command fails.

Build and test with \`cargo test --manifest-path tools/midas/Cargo.toml\`. Image packaging is a separate integration step.
