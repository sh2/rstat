#!/bin/bash

PIDFILE=lstat.pid

if [ -f "$PIDFILE" ]; then
    while read PID; do
        COMMAND=$(ps -p $PID -o comm=)
        
        if [ "$COMMAND" = 'python' -o "$COMMAND" = 'dstat' -o "$COMMAND" = 'perl' ]; then
            kill $PID
        fi
    done <$PIDFILE
    
    rm -f $PIDFILE
fi

