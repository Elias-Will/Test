#!/usr/bin/env bash

WORKDIR=$(dirname $0)

cd $WORKDIR
ruby android_wrapper.rb

echo “#####################################”
echo “You can safely close this window now.”

exit