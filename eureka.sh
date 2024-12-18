#!/bin/env bash

editor=${EDITOR:-vi}
pager=${PAGER:-less}
config="$HOME/.local/share/eureka.conf"

RED="$(tput setaf 196)"
BLUE="$(tput setaf 87)"
GREEN="$(tput setaf 82)"

function text() {
  local color=$1
  local text=$2
  local reset=$(tput sgr0)
  echo -e "${color}${text}${reset}"
}

function help() {
cat << EOF
CLI tool to input and store your ideas without leaving the terminal\n
Usage: $0 [-p] [option]
Available options:
-a,  --add                      - Add new ideas without an editor
-e,  --editor                   - Edit ideas using EDITOR (default:vi)
-h,  --help                     - Display this message and exits
-s,  --setup                    - Set configuration up
-p,  --private                  - Private repository modal
-t,  --target                   - Edit a specified file
-v,  --view                     - Preview ideas using PAGER (default:less)
--fetch                         - Fetch eureka repo
--pull                          - Pull eureka repo
EOF
}

function setup() {
	if [ ! -f "$config" ]; then
    touch "$HOME/.local/share/eureka.conf"

		text "$BLUE" "> Insert your remote repo address (e.g. https://github.com/$USER/eureka/"
    read -p ">> " irepo

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

		while true; do
      text "$BLUE" "> Insert the name of your repo (e.g. eureka)"
      read -p ">> " iname
      echo "path = $clone/$iname" >> "$config" && text "$GREEN" "> The provided path has been saved to $config"
      exit 0
    done

  else
    text "$GREEN" "> You already have a configuration file!"
    text "$GREEN" "> Do you want to overwrite it? (y/n):"
    read -p ">> " overwrite
    if [ "$overwrite" = "y" ]; then
      rm "$config"
      setup
    else
      exit 0
    fi
	fi
}

function getidea() {
	echo "${BLUE}> Idea Summary"
	read -p ">> " idea
	echo "${BLUE}> Idea Content"
  read -p ">> " ideacontent
}

function git_cmd() {
	git -C "$path" add .
	git -C "$path" commit -m "$idea"
	git -C "$path" push origin main
}

function pull() {
  git -C "$path" pull origin main
}

function fetch() {
  git -C "$path" fetch origin main
}

function checkpath() {
  path=$(grep "path" "$config" | awk -F ' = ' '{print $2}')
  if [ ! -d "$path" ]; then
    text "$RED" "The path doesn't exist!"
    exit 1
  fi
}

function preview() {
  checkpath
  "$pager" "$path/README.md"
}

function checkfile() {
  if [ ! -f "$path/README.md" ]; then
    text "$RED" "> The README file doesn't exist!"
    text "$BLUE" "> Do you want to create one now? (y/n)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
      text "$BLUE" "> Creating one now..."
      touch "$path/README.md"
      echo "# Ideas" > "$path/README.md"
      echo "" >> "$path/README.md"
      text "$GREEN" "> README.md created!"
    fi
  fi
}

function target() {
  checkpath
	text "$BLUE" "> Available files:"
  find "$path" -type f -name '*.md' -printf '%P\n' | awk -F. '{print $1}'
	text "$BLUE" "> Name your file"
	read -p ">> " filename
	text "$BLUE" "> Summary"
	read -p ">> " idea
  if [ ! -f "$path/$filename.md" ]; then
    text "$RED" "> The $filename file doesn't exist!"
    text "$BLUE" "> Do you want to create one now? (y/n)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
      text "$BLUE" "> Creating one now..."
      touch "$path/$filename.md"
      text "$GREEN" "> $filename.md created!"
    fi
  fi
	"$editor" "$path/$filename.md"
  git_cmd
	exit 0
}

function editor() {
  checkpath
	text "$BLUE" "> Idea Summary"
	read -p ">> " idea
	"$editor" "$path/README.md"
  git_cmd
	exit 0
}

function eureka() {
  checkpath
  checkfile
  getidea
  sed -i "2a - $ideacontent" "$path/README.md"
  git_cmd
	exit 0
}

if [ ! -f "$config" ]; then
  text "$RED" "The configuration file isn't set!"
fi

if [ "$1" = "" ]; then
	eureka
elif [ "$1" = "-v" ] || [ "$1" = "--view" ]; then
	preview
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	help
elif [ "$1" = "-p" ] || [ "$1" = "--pull" ]; then
	pull
elif [ "$1" = "-f" ] || [ "$1" = "--fetch" ]; then
	fetch
elif [ "$1" = "-e" ] || [ "$1" = "--edit" ]; then
	editor
elif [ "$1" = "-t" ] || [ "$1" = "--target" ]; then
  target
elif [ "$1" = "-s" ] || [ "$1" = "--setup" ]; then
  setup
fi
