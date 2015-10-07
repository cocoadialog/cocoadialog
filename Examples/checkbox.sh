#!/bin/bash

CD=/Volumes/Bay2.R_2000_4X4/Applications/cocoaDialog.app/Contents/MacOS/cocoaDialog

CD=cocoa-dialog

dialog=$($CD checkbox  --button1 "Button 1"  --items "Checkbox 1 (index 0)")

#dialog=$($CD checkbox   \
#    --float             \
#    --allow-mixed       \
#    --mixed     2 5     \
#    --checked   1 4 6   \
#    --disabled  0 1 5   \
#    --title     "Three Button Control - Checkbox"               \
#    --text      "This dialog allows multiple checkbox states:"  \
#    --button1   "Button 1"  \
#    --button2   "Button 2"  \
#    --button3   "Button 3"  \
#    --items     "Checkbox 1 (index 0)" \
#                "Checkbox 2 (index 1)" \
#                "Checkbox 3 (index 2)" \
#                "Checkbox 4 (index 3)" \
#                "Checkbox 5 (index 4)" \
#                "Checkbox 6 (index 5)" \
#                "Checkbox 7 (index 6)")


#    $(for x in {0..7}; { echo -n "'Checkbox %x (index $((x-1))) ' \\"; }) \

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