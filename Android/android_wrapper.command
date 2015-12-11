#!/usr/bin/env bash

WORKDIR=$(dirname $0)

cd $WORKDIR
ruby android_wrapper.rb -k -u elias.will:Kappa123k

echo "done!"

exit