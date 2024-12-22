# eureka-sh

`eureka.sh` is a fork of [eureka](https://github.com/simeg/eureka) by Simon Egersand written in shell, and with additional features.

It's a CLI tool that tries to make the experience of jotting ideas down as friction-less as possible right from the terminal. It mainly integrates with git, committing and pushing ideas to a remote git repository.

## Requirements

- Git is required in order to use `eureka.sh`
- A remote git repository (optional)

## Features

- Use an editor to add ideas
- Preview your ideas using a pager
- Git

## Extra Features

- Extends git tools from `add`, `commit` and `push` to `fetch` and `pull`
- Add ideas without an editor
- Not limited to README.md
- Creates the README.md if not existing
- Local only
- Clone remote repository

## Usage

The first time you use `eureka.sh` it's required to use the `-s` option to setup the configuration. The configuration file lives at `$HOME/.local/share/eureka.conf` by default.
After setting the configuration. At least one argument is required in order to use `eureka.sh`.

You may combine arguments with the `-p` for managing a private repository (do not pull changes).

```
CLI tool to input and store your ideas without leaving the terminal\n
Usage: $0 [-p] [-t] [filename] [option]
Available options:
-a,  --add                                - Add new ideas without an editor
-e,  --editor                             - Edit ideas using EDITOR (default:vi)
-h,  --help                               - Display this message and exits
-s,  --setup                              - Set configuration up
-p,  --private [option]                   - Private repository modal
-t,  --target  [filename] [option]        - Edit a specified file
-v,  --view                               - Preview ideas using PAGER (default:less)
--fetch                                   - Fetch eureka repo
--pull                                    - Pull eureka repo
```

**Examples:**

1. `eureka.sh -p -s` to set up the private repository configuration.
2. `eureka.sh -p -t [filename] -e` to create or edit a file in the private repository. The file name is optional, as it will display the available files and request you enter one.
3. `eureka.sh -a` to quickly add a new idea to your remote repository without an editor.

**Important:**

- Private repositories do not pull changes
- The arguments have the following priority: `-p`, `-t`, others
- If you don't want to specific a filename when using `target`, you will need to insert "." (dot). Example: `-t . -a`
- To use `-a`, ensure the desired file has at least 2 lines, or it will **fail**. It's only an issue, when a new file is created using `target` and the `editor`, leaving the file with one line.

## Installation

Make sure to add the script to your `$PATH` for convenience.

```
git clone https://github.com/janpstrunn/eureka-sh
cd eureka-sh
chmod +x eureka.sh
```

Tip: Set an alias for `eureka.sh`

## Notes

This script has been only tested in a Linux Machine.
