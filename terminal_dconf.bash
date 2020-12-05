#!/usr/bin/env bash

#
# Set up gnome terminal with DConf
#

UUID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
THEME_PATH=/org/gnome/terminal/legacy/profiles:/:$UUID

dconf write $THEME_PATH/use-theme-colors "false"
dconf write $THEME_PATH/background-color "'#102030'"
dconf write $THEME_PATH/foreground-color "'#CACACA'"
dconf write $THEME_PATH/palette "['#00010a','#ea6c73','#91b362','#f9af4f','#53bdfa','#fae994','#90e1c6','#c7c7c7','#686868','#f07178','#c2d94c','#ffb454','#59c2ff','#ffee99','#95e6cb','#ffffff']"
dconf write $THEME_PATH/default-size-rows "30"
dconf write $THEME_PATH/default-size-columns "120"

unset THEME_PATH
unset UUID

