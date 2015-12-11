#!/usr/bin/env bash

echo "Checking if libimobiledevice is already installed ..."
if [ -f /usr/local/bin/ideviceinfo ]
then
    echo "Package already installed. Stopping now."
    exit 1
fi

echo "Dependency Check: Brew"
if [ ! -z $(which brew) ]
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
fi

echo "Installing libimobiledevice with Homebrew:"
brew install libimobiledevice