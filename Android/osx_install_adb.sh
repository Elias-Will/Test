#!/usr/bin/env bash

echo "Checking if ADB is already installed ..."
if [ -f /usr/local/bin/adb ]
then
    echo "Package already installed. Stopping now."
    exit 1
fi

echo "Dependency Check: Brew"
if [ -f $(which brew) ]
then
    echo "Brew installed"
else
    echo "Brew is not installed."
    echo "Installing Brew now:"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [ ! -f $(which brew) ]
then
    echo "Could not install brew"
    echo "Aborting. Check logs"
    exit -1
else
    echo "Installing Cask"
    brew install caskroom/cask/brew-cask
fi

echo "Installing ADB with Homebrew CASK:"
brew cask install android-platform-tools --appdir=/Applications
if [ $? -ne 0 ]; then
    echo "It seems that no cask is available anymore for this package, trying with brew"
    brew install android-platform-tools
fi