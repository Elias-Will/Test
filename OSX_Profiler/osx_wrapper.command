#!/usr/bin/env bash

WORKDIR=$(dirname $0)

cd $WORKDIR
ruby osx_wrapper.rb

echo “#####################################”
echo “You can safely close this window now.”

exit