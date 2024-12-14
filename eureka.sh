#!/bin/env bash
config="$HOME/.local/share/eureka.conf"
function setup() {
	if [ ! -f "$config" ]; then
    touch "$HOME/.local/share/eureka.conf"

    # Set remote repo

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

    # Set absolute path

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
function pull() {
  git -C "$path" pull origin main
}
