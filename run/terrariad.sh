#!/bin/sh

send="`printf \"$*\r\"`"
attach='script /dev/null -qc "screen -r terraria"'
inject="screen -S terraria -X stuff $send"

if [ "$1" = "attach" ] ; then cmd="$attach" ; else cmd="$inject" ; fi

if [ "`stat -c '%u' /var/run/screen/S-terraria/`" = "$UID" ]
then
    $cmd
else
    exec "$cmd"
fi