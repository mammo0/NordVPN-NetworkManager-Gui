#!/bin/bash

# check which path to desktop files exists
if [ -d /usr/local/share/applications ]
then
    DESK_PATH=/usr/local/share/applications
else
    DESK_PATH=/usr/share/applications
fi

echo "Removing desktop shortcut from "$DESK_PATH

sudo rm $DESK_PATH/nordvpn.desktop
