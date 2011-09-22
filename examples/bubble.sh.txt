#!/bin/bash

CD_APP="$HOME/Applications/CocoaDialog.app"
CD="$CD_APP/Contents/MacOS/CocoaDialog"

### Simple example, one bubble
$CD bubble --debug --title "My first bubble" --text "How do you like it?"

### Changing the colors and icon
$CD bubble --debug --title "Setting colors" --text "Green to light green" \
	--background-top "00cb24" --background-bottom "aefe95" \
	--icon "hazard"

### Let's get a little more fancy.  Here are 2 bubbles, with custom icons,
### custom border colors, custom backgrounds, AND custom text colors.
### We'll even mix stock icons and custom icons.
$CD bubble --debug --titles "Bubble 1" "Second bubble"        \
	--texts "Body of bubble 1" "and body of bubble 2" \
	--border-colors "2100b4" "a25f0a"                 \
	--text-colors "180082" "000000"                   \
	--background-tops "aabdcf" "dfa723"               \
	--background-bottoms "86c7fe" "fdde88"            \
	--icon-files "/Users/markstra/Desktop/icon1.png"  \
	             "$CD_APP/Contents/Resources/globe.icns"

