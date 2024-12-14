# eureka-sh

`eureka.sh` is a fork of [eureka](https://github.com/simeg/eureka) by Simon Egersand written in shell, and with additional features.

It's a CLI tool that tries to make the experience of jotting ideas down as friction-less as possible right from the terminal. It mainly integrates with git, committing and pushing ideas to a remote git repository.

## Requirements

- You will need a remote git repository in order to use `eureka.sh`

## Features

- Use an editor to add ideas.
- Preview your ideas using a pager
- Git

## Extra Features

- Extends git tools from `add`, `commit` and `push` to `fetch` and `pull`.
- Add ideas without an editor.
- Not limited to README.md.
- Creates the README.md if not existing.

## Usage

The first time you use `eureka.sh` it's required to use the `-s` option to setup the configuration. The configuration file lives at `$HOME/.local/share/eureka.conf` by default.
After setting the configuration, you can use the script with no option to if you want to add an idea without an editor.

```
Usage: $0 [option]
Available options:
-e, --editor                   - Edit ideas using EDITOR (default:vi)
-f, --fetch                    - Fetch eureka repo
-h, --help                     - Display this message and exits
-s, --setup                    - Set configuration up
-p, --pull                     - Pull eureka repo
-t, --target                   - Edit a specified file
-v, --view                     - Preview ideas using PAGER (default:less)
```

## Installation

Make sure to add the script to your $PATH for convenience.

```
git clone https://github.com/janpstrunn/eureka-sh
cd eureka-sh
chmod +x eureka.sh
```

Tip: Set an alias for `eureka.sh`

## Notes

This script has been only tested in a Linux Machine.
