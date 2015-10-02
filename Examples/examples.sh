#!/bin/sh

runit(){

  echo "running $@"
  cocoa-dialog $@
}

if [ $# -gt 1 ]; then runit $@; exit; fi

for c in $(cocoa-dialog modes); {

if [[ $c == msgbox || $c =~ (radio|filesave|standard-dropdown|dropdown|secure-inputbox|textbox|progressbar|secure-standard-inputbox|checkbox) ]]
then echo skipping $c
else runit $c --title $c
fi

}

#ok-msgbox
#yesno-msgbox
#notify
#fileselect
#msgbox
#inputbox
#standard-inputbox
