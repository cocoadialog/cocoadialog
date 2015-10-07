#!/bin/bash

# Author: Mark Carver	Copyright (c) 2012 Mark Carver. All rights reserved.
# Created: 2011-09-23 Updated: 2012-07-24

CD=${1:-cocoa-dialog}

cocoaDialog() { $CD "${@}"; }

icons() {
  icons=(addressbook
  airport
  archive
  bluetooth
  application
  bonjour
  atom
  burn
  hazard
  caution
  document
  documents
  download
  eject
  everyone
  executable
  favorite
  heart
  fileserver
  filevault
  finder
  folder
  folderopen
  foldersmart
  gear
  general
  globe
  group
  home
  info
  ipod
  movie
  music
  network
  notice
  stop
  x
  sync
  trash
  trashfull
  url
  user
  person
  utilities
  dashboard
  dock
  widget
  help
  installer
  package
  firewire
  usb
  cd
  sound
  printer
  screenshare
  security
  update
  search
  find
  preferences
  airport2
  cocoadialog
  computer);
  for icon in ${icons[*]}; do
    # MsgBox
    dialog=$(cocoaDialog MsgBox --title "Message Box" --debug --float \
        --text "Alert!" \
        --informative-text "This dialog creates a three button message box" \
        --button1 "Button 1" \
        --button2 "Button 2" \
        --button3 "Button 3");
  done;
}
notify() {
  cocoaDialog notify --debug \
    --title "This is the --title" \
    --description "$(printf "This is the --description\n\nClick here to show the callback!")" \
    --sticky \
    --icon notice \
    --click-path "cocoaDialog" \
    --click-arg "msgbox --title cocoaDialog --alert \"I'm a callback\" --label \"This dialog was created when you clicked on the Growl notification!\"  --button1 Close --icon info";
  cocoaDialog notify --debug \
    --title "Incoming Call" \
    --description "Click here to answer!" \
    --sticky \
    --icon SkypeBlue \
    --icon-bundle com.skype.skype \
    --click-path "/Applications/Skype.app";
  cocoaDialog notify --debug \
    --title "cocoaDialog" \
    --description "New Growl notifcation support!";
}
slider() {
  label=$(printf "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Maecenas sed diam eget risus varius blandit sit amet non magna. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Vestibulum id ligula porta felis euismod semper. Nullam id dolor id nibh ultricies vehicula ut id elit. Nullam id dolor id nibh ultricies vehicula ut id elit.")
  cocoaDialog slider --debug --title "cocoaDialog control: slider" \
    --label "${label}" \
    --icon preferences \
    --min 0 \
    --max 100 \
    --timeout 60 \
    --resize \
    --value-required \
    --button1 "Really long button title..." \
    --button2 Cancel;
}
updater() {
  if [[ $(cocoaDialog version) < 3.0.1 ]]; then
    cocoaDialog update --debug --quiet; update=$?;
    if [[ update -eq 0 ]]; then
      echo "cocoaDialog was successfully updated to version: $(cocoaDialog version)";
    elif [[ update -eq 2 ]]; then
      echo "An update for cocoaDialog was not found.";
    fi\
  fi
  exit ${update};
}
textbox() {
  cocoaDialog textbox --debug \
    --title "--title" \
    --label "Test" \
    --icon user \
    --close \
    --resize \
    --value "Testing" \
    --fullscreen \
    --editable \
    --selected \
    --value-required \
    --button1 Okay \
    --button2 Cancel \
    --cancel button2;
  exit;
}
standard_dropdown(){
  cocoaDialog standard-dropdown --debug \
    --icon "help" \
    --exit-onchange \
    --string-output \
    --text "Favorite OS?" \
    --items \
      "GNU/Linux" \
      "OS X" \
      Windows \
      Amiga \
      "TI 89" \
    --timeout 30;
}
filesave() {
  rv=$(cocoaDialog filesave --debug \
    --with-file "me.txt" \
    --with-directory "/Users" \
    --select-multiple \
    --title "Select files" \
    --text "Please select files");
  echo "$rv";
  # cocoaDialog filesave --debug --timeout 5;
}
progress() {
  {
    for (( i = 0; i < 11; i++ )); do
      echo "$((${i}*10)) $((${i}*10))%";
      sleep 1;
    done
  } > >(cocoaDialog progressbar --debug --icon documents --progress 0);
}
ok_msgbox() {
  cocoaDialog ok-msgbox --debug --string-output --no-newline --text "This is a simple first example" \
  --minimize \
  --informative-text "We're just going to echo the string output" --timeout 5;
}
secure_inputbox() {
  cocoaDialog secure-inputbox --debug --title "Password" \
    --label "Please enter password:" \
    --button1 "Okay" \
    --button2 "Cancel" \
    --cancel button2 \
    --resize \
    --icon security \
    --timeout 30 \
    --empty-text "A password is required to log into your account, please enter it now." \
    --value-required;
}
secure_standard_inputbox() {
  cocoaDialog secure-standard-inputbox --help;
}
yesno_msgbox() {
  cocoaDialog yesno-msgbox --title "This is the title" --debug \
    --float \
    --height 125 \
    --width 350 \
    --text "This is the text" \
    --label "This is the label" \
    --icon info \
    --button1 "Button 1" \
    --button2 "Button 2" \
    --button3 "Button 3";
}
dropdown() {
  cocoaDialog dropdown --title "Dropdown" --debug --float \
    --quiet \
    --string-output \
    --label "Select your update:" \
    --items \
      "Mac OS X (10.7)" \
      "Mac OS X (10.6)" \
      "Mac OS X (10.5)" \
    --selected 2 \
    --button1 "Button 1" \
    --button2 "Button 2" \
    --button3 "Button 3";
}
inputbox() {
  cocoaDialog inputbox --debug --title "This is --title"\
    --label "This is --text:" \
    --selected \
    --value-required \
    --button1 "Ok";
}
checkbox() {
  dialog=$(cocoaDialog checkbox --title "This is the --title" --debug \
      --label "This is the --label" \
      --icon update \
      --items \
        "Checkbox 1 (index 0)" \
        "Checkbox 2 (index 1)" \
        "Checkbox 3 (index 2)" \
        "Checkbox 4 (index 3)" \
        "Checkbox 5 (index 4)" \
        "Checkbox 6 (index 5)" \
        "Checkbox 7 (index 6)" \
        "Checkbox 8 (index 7)" \
        "Checkbox 9 (index 8)" \
        "Checkbox 10 (index 9)" \
        "Checkbox 11 (index 10)" \
        "Checkbox 12 (index 11)" \
        "Checkbox 13 (index 12)" \
        "Checkbox 14 (index 13)" \
      --rows 10 \
      --checked 1 4 6 10 13 \
      --mixed 2 5 9 13 \
      --disabled 0 1 5 11 13 \
      --value-required \
      --button1 "Okay" \
      --button2 "Cancel" \
      --timeout 5 \
      --resize \
      --button3 "--button3");
  button=$(echo "${dialog}" | awk 'NR==1{print}');
  # Put results into an array
  checkboxes=($(echo "${dialog}" | awk 'NR>1{print $0}'));
  echo "Button pressed: ${button}"; echo;
  echo "Number of checkboxes: ${#checkboxes[*]}";
  i=0;
  for state in ${checkboxes[*]}; do
    echo "checkbox[${i}] state: ${state}";
    let i+=1;
  done;
}
radio() {
  text=$(printf "This dialog creates a three button radio selection:")
  dialog=$(cocoaDialog radio --title "Radio" --debug --float \
    --text "${text}" \
    --icon "Package" \
    --items \
      "Radio 1 (index 0)" \
      "Radio 2 (index 1)" \
      "Radio 3 (index 2)" \
      "Radio 4 (index 3)" \
      "Radio 5 (index 4)" \
      "Radio 6 (index 5)" \
      "Radio 7 (index 6)" \
      "Radio 8 (index 7)" \
      "Radio 9 (index 8)" \
      "Radio 10 (index 9)" \
      "Radio 11 (index 10)" \
      "Radio 12 (index 11)" \
    --rows 5 \
    --disabled 4 9 \
    --value-required \
    --button1 "Button 1" \
    --button2 "Button 2" \
    --button3 "Button 3");
  # Get the button pressed
  button=$(echo "${dialog}" | awk 'NR==1{print}');
  selection=$(echo "${dialog}" | awk 'NR>1{print $0}');
  echo "Button pressed: ${button}";
  echo "Radio selected: ${selection}";
}

runTests() {
  tests=(
    checkbox
    dropdown
    filesave
    inputbox
    notify
    ok_msgbox
    progress
    radio
    secure_inputbox
    secure_standard_inputbox
    slider
    standard_dropdown
    textbox
    updater
    yesno_msgbox
  )
  button=''
  label="$(printf "This program will allow you to conduct continuous tests on any given cocoaDialog control. Please select the cocoaDialog control you wish to test.\n\nAfter all of the control's tests have completed this dialog will reappear, press Cancel to quit.")";
  while [ "${button}" != "Cancel Test" ]; do
    button=''
    dialog=$(cocoaDialog radio --title "Automated cocoaDialog Testing Script" --float \
      --rows 8 \
      --icon hazard \
      --string-output \
      --button1 "Run Test" \
      --button2 "Cancel Test" \
	    --label "${label}" \
      --items ${tests[*]})
    button="$(echo "${dialog}" | awk 'NR==1{print}')";
    # Run the selected test.
    $(echo "${dialog}" | awk 'NR>1{print $0}');
  done
}
runTests
