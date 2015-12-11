#!/usr/bin/env bash

WORKDIR=$(dirname $0)

cd $WORKDIR
ruby osx_wrapper.rb -u elias.will:Kappa123k -k

echo "done!"

exit