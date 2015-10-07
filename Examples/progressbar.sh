#!/bin/sh

# written by Kevin Hendricks, modified for Project inclusion by Alex Gray, 10/2/2015

PIPE=/tmp/hpipe # create a named pipe
rm -f $PIPE
mkfifo $PIPE

# create a background job which takes its input     the named pipe
"$1" progressbar --percent 0 --stoppable --title $(basename $0) --text "Please wait..." < $PIPE &

# associate file descriptor 3 with that pipe and send a character through the pipe
exec 3<> $PIPE
#echo -n . >&3

# do all of your work here
for x in $(seq 50); { X=$((x*2)); echo "$X Percent done:$X" > $PIPE; sleep .01; }

# now turn off the progress bar by closing file descriptor 3
exec 3>&-

# wait for all background jobs to exit
wait && rm -f $PIPE
