#!/bin/bash

CD=cocoa-dialog

NO=( radio progressbar notify slider )
YA=( ok-msgbox filesave yesno-msgbox standard-dropdown secure-inputbox dropdown textbox msgbox \
     fileselect secure-standard-inputbox standard-inputbox inputbox checkbox )

if [[ $# -gt 1 ]]; then $CD $@
else

  for c in $(cocoa-dialog modes); do
      if [[ $c =~ ${NO[@]} ]]
      then tput rev && echo "skipping $c" && tput sgr0
      else $CD $c --title $c
      fi
  done
  tput setaf 4 && echo "Warnging: skipped ${OFF[@]}" && tput sgr0
fi

#ok-msgbox
#yesno-msgbox
#notify
#fileselect
#msgbox
#inputbox
#standard-inputbox


#    [[ $c == msgbox ||
#       $c =~ (radio|filesave|standard-dropdown|dropdown|secure-inputbox|textbox|progressbar|secure-standard-inputbox|checkbox) ]] \
#    && { tput rev && echo skipping $c && tput sgr0; }  \
    || $CD $c --title $c

