#!/bin/bash

CD=/Applications/CocoaDialog.app/Contents/MacOS/CocoaDialog

dialog=$($CD checkbox --title "Three Button Control - Checkbox" --float \
    --text "This dialog allows multiple checkbox states:" \
    --items \
      "Checkbox 1 (index 0)" \
      "Checkbox 2 (index 1)" \
      "Checkbox 3 (index 2)" \
      "Checkbox 4 (index 3)" \
      "Checkbox 5 (index 4)" \
      "Checkbox 6 (index 5)" \
      "Checkbox 7 (index 6)" \
    --checked 1 4 6 \
    --allow-mixed \
    --mixed 2 5 \
    --disabled 0 1 5 \
    --button1 "Button 1" \
    --button2 "Button 2" \
    --button3 "Button 3");

# Get the button pressed
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