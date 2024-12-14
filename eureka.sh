#!/bin/env bash

editor=${EDITOR:-vi}
pager=${PAGER:-less}

config="$HOME/.local/share/eureka.conf"

if [ ! -f "$config" ]; then
  echo "$(tput setaf 196)The configuration file isn't set!$(tput sgr0)"
fi


function setup() {
	if [ ! -f "$config" ]; then
    touch "$HOME/.local/share/eureka.conf"

		echo "$(tput setaf 87)> Insert your remote repo address (e.g. https://github.com/$USER/eureka/$(tput sgr0)"
    read -p ">> " irepo

		echo "$(tput setaf 87)> Select the directory you want to clone your repo to (e.g. /home/$USER/)$(tput sgr0)"
		echo "$(tput setaf 87)> The result will be: /home/$USER/your-repo-name$(tput sgr0)"
    read -p ">> " clone
    echo "$(tput setaf 87)> Cloning your repo now...$(tput sgr0)"
    git -C "$clone" clone "$irepo"
    if [ "$?" -eq 0 ]; then
      echo "$(tput setaf 82)> You repo has been cloned to $clone$(tput sgr0)"
    else
      echo "$(tput setaf 196)> An error occured! Try cloning manually$(tput sgr0)"
    fi

		while true; do
      echo "$(tput setaf 87)> Insert the absolute path to your repo (e.g. /home/$USER/eureka/$(tput sgr0)"
      read -p ">> " ipath
      if [ ! -d "$ipath" ]; then
        echo "$(tput setaf 87)> This isn't a directory!$(tput sgr0)"
      fi
      echo "path = $ipath" >> "$config" && echo "$(tput setaf 82)> The provided path has been saved to $config$(tput sgr0)"
      exit 0
    done

  else
    echo "$(tput setaf 82)> You already have a configuration file!$(tput sgr0)"
    echo "$(tput setaf 82)> Do you want to overwrite it? (y/n):$(tput sgr0)"
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
	echo "$(tput setaf 87)> Idea Summary$(tput sgr0)"
	read -p ">> " idea
	echo "$(tput setaf 87)> Idea Content$(tput sgr0)"
  read -p ">> " ideacontent
}

function dogit() {
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

function preview() {
  "$pager" "$path/README.md"
}

function target() {
  path=$(grep "path" "$config" | awk -F ' = ' '{print $2}')
  if [ ! -d "$path" ]; then
    echo "$(tput setaf 196)The path doesn't exist!$(tput sgr0)"
    exit 1
  fi
	echo "$(tput setaf 87)> Available files:$(tput sgr0)"
  find "$path" -type f -name '*.md' -printf '%P\n' | awk -F. '{print $1}'
	echo "$(tput setaf 87)> Name your file$(tput sgr0)"
	read -p ">> " filename
	echo "$(tput setaf 87)> Summary$(tput sgr0)"
	read -p ">> " idea
  if [ ! -f "$path/$filename.md" ]; then
    echo "$(tput setaf 196)> The $filename file doesn't exist!$(tput sgr0)"
    echo "$(tput setaf 87)> Do you want to create one now? (y/n)$(tput sgr0)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
      echo "$(tput setaf 87)> Creating one now...$(tput sgr0)"
      touch "$path/$filename.md"
      echo "$(tput setaf 82)> $filename.md created!$(tput sgr0)"
    fi
  fi
	"$editor" "$path/$filename.md"
  dogit
	exit 0
}

function editor() {
  path=$(grep "path" "$config" | awk -F ' = ' '{print $2}')
  if [ ! -d "$path" ]; then
    echo "$(tput setaf 196)The path doesn't exist!$(tput sgr0)"
    exit 1
  fi
	echo "$(tput setaf 87)> Idea Summary$(tput sgr0)"
	read -p ">> " idea
	"$editor" "$path/README.md"
  dogit
	exit 0
}

function eureka() {
  path=$(grep "path" "$config" | awk -F ' = ' '{print $2}')
  if [ ! -d "$path" ]; then
    echo "$(tput setaf 196)The path doesn't exist!$(tput sgr0)"
    exit 1
  fi
  getidea
  if [ ! -f "$path/README.md" ]; then
    echo "$(tput setaf 196)> The README file doesn't exist!$(tput sgr0)"
    echo "$(tput setaf 87)> Do you want to create one now? (y/n)$(tput sgr0)"
    read -p ">> " create
    if [ "$create" = "y" ]; then
      echo "$(tput setaf 87)> Creating one now...$(tput sgr0)"
      touch "$path/README.md"
      echo "# Ideas" > "$path/README.md"
      echo "" >> "$path/README.md"
      echo "$(tput setaf 82)> README.md created!$(tput sgr0)"
    fi
  fi
  sed -i "2a - $ideacontent" "$path/README.md"
  dogit
	exit 0
}

if [ "$1" = "-v" ] || [ "$1" = "--view" ]; then
	preview
# elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
# 	help
elif [ "$1" = "" ]; then
	eureka
elif [ "$1" = "-e" ] || [ "$1" = "--edit" ]; then
	editor
elif [ "$1" = "-s" ] || [ "$1" = "--setup" ]; then
  setup
fi
