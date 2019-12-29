#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# meta

function install_brew() {
    if ! which brew >/dev/null; then
        printf "\nInstalling brew ...\n"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}

function brew_install() {
    for tool in "$@"; do
        if ! which $tool >/dev/null; then
            printf "\nInstalling $tool ...\n"
            HOMEBREW_NO_AUTO_UPDATE=1 $(which brew) install $tool
        fi
    done
}

function brew_cask_install() {
    for tool in "$@"; do
        if ! which $tool >/dev/null; then
            printf "\nInstalling $tool ...\n"
            HOMEBREW_NO_AUTO_UPDATE=1 $(which brew) cask install $tool
        fi
    done
}

function setup_meta() {
    install_brew
}

# terminal & shell

function setup_terminal() {
    brew_cask_install hyper
    brew_install fish tmux
}

# awesome dotfiles

function install_ohmyzsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        printf "\nInstalling .oh-my-zsh ...\n"
        curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
    fi
}

function install_ohmyfish() {
    if [ ! -d ~/.local/share/omf ]; then
        printf "\nInstalling .oh-my-fish ...\n"
        curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | $(which fish)
    fi
}

function install_vimrc() {
    if [ ! -d ~/.vim_runtime ]; then
        printf "\nInstalling .vimrc ...\n"
        git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
        sh ~/.vim_runtime/install_awesome_vimrc.sh
    else
        printf "\nUpdating .vimrc ...\n"
        git -C ~/.vim_runtime pull --rebase
    fi
}

function install_dottmux() {
    if [ ! -d ~/.tmux ]; then
        printf "\nInstalling .tmux ...\n"
        git clone --depth=1 https://github.com/gpakosz/.tmux.git ~/.tmux
    else
        printf "\nUpdating .tmux ...\n"
        git -C ~/.tmux pull --rebase
    fi
    ln -svf ~/.tmux/.tmux.conf ~/.tmux.conf
}

function setup_dotfiles() {
    install_ohmyzsh
    install_ohmyfish
    install_vimrc
    install_dottmux
}

# cli

function setup_cli_tools() {
    brew_install autojump tldr rg fd fzf
}

# setup

function setup() {
    setups=(
        setup_meta
        setup_terminal
        setup_dotfiles
        setup_cli_tools
    )
    for setup in "${setups[@]}"; do
        $(expr $setup)
    done
}

# config

EXCLUDE_PATTERNS=(".git/" ".DS_Store" "bootstrap.sh" "README.md" "LICENSE")

function update_dotfiles() {
    printf "\nUpdating .dotfiles in $DIR ...\n"
    git -C "$DIR" pull --rebase --autostash
}

function sync_dotfiles() {
    printf "\nSyncing dotfiles ...\n"
    rsync $(printf "%s\n" "${EXCLUDE_PATTERNS[@]}" | sed 's/^/--exclude=/g') -avhR --no-perms . ~
}

function link_dotfiles() {
    printf "\nLinking dotfiles ...\n"
    find . -type f $(printf "*/%s*\n" "${EXCLUDE_PATTERNS[@]}" | sed 's/^/-not -iwholename /g') -exec ln -vf ~/'{}' '{}' ';'
}

function config() {
    update_dotfiles
    sync_dotfiles
    link_dotfiles
}

function bootstrap() {
    setup
    config
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    bootstrap
else
    read -p "This may overwrites existing files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bootstrap
    fi
fi
unset bootstrap
