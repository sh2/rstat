#!/bin/bash

PID_FILE=/tmp/pidfile

if [ -f "$PID_FILE" ]; then
    while read PID
    do
        if [ "`ps -p $PID -o comm=`" = 'ssh' ]; then
            kill $PID
        fi
    done < $PID_FILE
    
    rm -f $PID_FILE
fi

