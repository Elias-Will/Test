#!/usr/bin/env bash

RECEIVER="guillem.riera@kupferwerk.com"

if [ ! -z "$1" ]; then
    RECEIVER="$1"
fi

CLOSE_THIS_WINDOW="You can safely close this window now."
SEND_THIS_EMAIL="An email with the generated files as attachment will be created. Please send it to: $RECEIVER"
WORKDIR=$(dirname $0)
OUTLOOK="/Applications/Microsoft Outlook.app"
MAIL="/Applications/Mail.app"

cd "$WORKDIR"
ruby android_profiler_for_kupferwerk_jira.rb -f

#cd "$WORKDIR"
#if [ -d "$OUTLOOK" ]; then
#    open *{csv,json} -a "$OUTLOOK"
#else
#    open *{csv,json} -a "$MAIL"
#fi

echo $SEND_THIS_EMAIL | tr '[:lower:]' '[:upper:]'
echo $CLOSE_THIS_WINDOW

exit