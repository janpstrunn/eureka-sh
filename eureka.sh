#!/bin/env bash

editor=${EDITOR:-vi}
pager=${PAGER:-less}
config="$HOME/.local/share/eureka.conf"

PRIVATE_REPO=false
RED="$(tput setaf 196)"
GREEN="$(tput setaf 82)"
BLUE="$(tput setaf 87)"
ORANGE="$(tput setaf 166)"

function text() {
  local color=$1
  local text=$2
  local reset=$(tput sgr0)
  echo -e "${color}${text}${reset}"
}

function help() {
cat << EOF
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
EOF
}

function private() {
  PRIVATE_REPO=true
}

function workspace() {
  if [ -n "$path" ]; then
    :
  elif [ -z "$path" ]; then
    if [ "$PRIVATE_REPO" = true ]; then
      path="$(grep "private" "$config" | awk -F ' = ' '{print $2}')"
      text "$ORANGE" "Using private repo: $path"
      if [ "$path" = "" ]; then
        text "$RED" "The path doesn't exist!"
        exit 1
      fi
    else
      path="$(grep "remote_path" "$config" | awk -F ' = ' '{print $2}')"
      text "$ORANGE" "Using remote repo: $path"
      if [ "$path" = "" ]; then
        text "$RED" "The path doesn't exist!"
        exit 1
      fi
    fi
  fi
}

function setup() {
  if [ "$PRIVATE_REPO" = true ]; then
    setup_private
  else
    setup_remote
  fi
}

function setup_remote() {
  if [ ! -f "$config" ]; then
    text "$RED" "You don't have a configuration file!"
    text "$BLUE" "Creating one now..."
    touch "$config" && text "$GREEN" "Config file create at $config"
    remote_address=$(grep "remote_address" "$config" | awk -F ' = ' '{print $2}')
    if [ ! -d "$remote_address" ]; then
      text "$BLUE" "> Insert your remote repo address (e.g. https://github.com/$USER/reponame"
      read -p ">> " irepo
    fi
    path=$(grep "remote_path" "$config" | awk -F ' = ' '{print $2}')
    if [ ! -d "$path" ]; then
      text "$BLUE" "> Select the directory you want to clone your repo to (e.g. /home/$USER)"
      text "$BLUE" "> The result will be: /home/$USER/your-repo-name"
      read -p ">> " clone
      text "$BLUE" "> Cloning your repo now..."
      git -C "$clone" clone "$irepo"
      if [ "$?" -eq 0 ]; then
        text "$GREEN" "> You repo has been cloned to $clone"
      else
        text "$RED" "> An error occured! Try cloning manually"
      fi
      text "$BLUE" "> Insert the name of your repo (e.g. eureka)"
      read -p ">> " iname
      echo "remote_path = $clone/$iname" >> "$config" && text "$GREEN" "> The provided path has been saved to $config"
      exit 0
    fi
  else
    path=$(grep "remote_path" "$config" | awk -F ' = ' '{print $2}')
    text "$GREEN" "> You already have a configuration file set!"
    text "$BLUE" "> The current path is: $path"
    text "$BLUE" "> Do you want to overwrite it? (y/n):"
    read -p ">> " overwrite
    if [ "$overwrite" = "y" ]; then
      text "$BLUE" "> Insert the new path (e.g. $HOME/reponame/)"
      read -p ">> " newpath
      old_path=$(printf '%s' "$path" | sed 's/[&/\]/\\&/g')
      new_path=$(printf '%s' "$newpath" | sed 's/[&/\]/\\&/g')
      sed -i "s|$old_path|$new_path|" "$config" && text "$GREEN" "> The provided path has been saved to $config"
    fi
	fi
}

function setup_private() {
  path=$(grep "private" "$config" | awk -F ' = ' '{print $2}')
  if [ ! -d "$path" ]; then
    text "$RED" "The private path doesn't exist!"
    text "$BLUE" "> Do you want to add it now? (y/n)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
		text "$BLUE" "> Select the directory you want to use (e.g. /home/$USER/reponame/)"
    read -p ">> " privaterepo
    echo "private = $privaterepo" >> "$config" && text "$GREEN" "> The provided path has been saved to $config"
    fi
  else
    text "$GREEN" "> You already have a private path set!"
    text "$BLUE" "> The current private path is: $path"
    text "$BLUE" "> Do you want to overwrite it? (y/n):"
    read -p ">> " overwrite
    if [ "$overwrite" = "y" ]; then
    text "$BLUE" "> Insert the new private repo name (e.g. $HOME/reponame)"
    read -p ">> " newpath
    old_private=$(printf '%s' "$path" | sed 's/[&/\]/\\&/g')
    new_private=$(printf '%s' "$newpath" | sed 's/[&/\]/\\&/g')
    sed -i "s|$old_private|$new_private|" "$config" && text "$GREEN" "> The provided path has been saved to $config"
    fi
  fi
}

function getidea() {
	text "$BLUE" "> Idea Summary"
	read -p ">> " idea
	text "$BLUE" "> Idea Content"
  read -p ">> " ideacontent
}

function git_cmd() {
  if [ "$PRIVATE_REPO" = true ]; then
    git -C "$path" add .
    git -C "$path" commit -m "$idea"
  else
    git -C "$path" add .
    git -C "$path" commit -m "$idea"
    git -C "$path" push origin main
  fi
}

function pull() {
  git -C "$path" pull origin main
}

function fetch() {
  git -C "$path" fetch origin main
}

function checkfile() {
  if [ -z "$filename" ]; then
    filename=README
  fi
  if [ ! -f "$path/$filename.md" ]; then
    text "$RED" "> The $filename file doesn't exist!"
    text "$BLUE" "> Do you want to create one now? (y/n)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
      text "$BLUE" "> Creating one now..."
      touch "$path/$filename.md"
      echo "# Ideas" > "$path/$filename.md"
      echo "" >> "$path/$filename.md"
      text "$GREEN" "> $filename.md created!"
    fi
  fi
}

function preview() {
  check_remote_path
  checkfile
  "$pager" "$path/$filename.md"
}

function target() {
  if [ "$TARGET_FILE" = "." ]; then
    text "$BLUE" "> Available files:"
    find "$path" -type f -name '*.md' -printf '%P\n' | awk -F. '{print $1}'
    text "$BLUE" "> Name your file"
    read -p ">> " filename
  elif [ -n "$TARGET_FILE" ]; then
    filename="$TARGET_FILE"
  fi
}

function editor() {
  checkfile
	text "$BLUE" "> Idea Summary"
	read -p ">> " idea
	"$editor" "$path/$filename.md"
  git_cmd
}

function eureka() {
  checkfile
  getidea
  echo "$idea"
  echo "$ideacontent"
  sed -i "2a - $ideacontent" "$path/$filename.md"
  git_cmd
}

if [ ! -f "$config" ]; then
  text "$RED" "The configuration file isn't set!"
fi

if [ "$#" -eq 0 ]; then
    text "$RED" "Error: No arguments provided."
    help
fi

while [[ "$1" != "" ]]; do
    case "$1" in
        -e | --editor)
            workspace
            editor
            shift
            ;;
        --fetch)
            workspace
            fetch
            shift
            ;;
        -s | --setup)
            setup
            shift
            ;;
        -p | --private)
            private
            shift
            ;;
        --pull)
            workspace
            pull
            shift
            ;;
        -t | --target)
            TARGET_FILE=$2
            workspace
            target
            shift 2 || text "$RED" "Target requires another argument!"
            ;;
        -v | --view)
            workspace
            preview
            shift
            ;;
        -h | --help)
            help
            exit 0
            ;;
        -a | --add)
            workspace
            eureka
            shift
            ;;
    esac
done
