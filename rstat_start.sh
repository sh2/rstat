#!/bin/bash

BASH_EXEC=/bin/bash
PERL_EXEC=/usr/bin/perl
PID_FILE=/tmp/rstat_pidfile
PIPE_FILE=/tmp/rstat_pipefile
DATETIME=`date +'%Y%m%d-%H%M%S'`
TARGET_LIST=$@

if [ $# -lt 1 ]; then
    echo 'Usage: ./rstat_start.sh host1 host2 ...'
    exit 1
fi

if [ -f "$PID_FILE" ]; then
    while read PID
    do
        if [ "`ps -p $PID -o comm=`" = 'ssh' ]; then
            kill $PID
        fi
    done < $PID_FILE
    
    rm -f $PID_FILE
fi

for TARGET_HOST in $TARGET_LIST
do
    # dstat
    LOG_FILE_D=d_${DATETIME}_${TARGET_HOST}.csv
    ssh $TARGET_HOST $BASH_EXEC <<_EOF_ >$LOG_FILE_D &
        rm -f $PIPE_FILE
        mkfifo $PIPE_FILE
        cat $PIPE_FILE &
        dstat -tvfn --output $PIPE_FILE 1 1>/dev/null 2>/dev/null
_EOF_
    echo $! >> $PID_FILE
    
    # iostat
    LOG_FILE_I=i_${DATETIME}_${TARGET_HOST}.csv
    ssh $TARGET_HOST $PERL_EXEC <<_EOF_ >$LOG_FILE_I &
        use strict;
        use warnings;
        
        \$| = 1;
        my \$datetime;
        
        open(my \$iostat, 'LANG=C iostat -dxk 1 |') or die \$!;
        
        while (my \$line = <\$iostat>) {
            chomp(\$line);
            
            if (\$line =~ /^Linux/) {
                # Title
                print "Host,\$line\\n";
                print "Datetime,Device,rrqm/s,wrqm/s,r/s,w/s,rkB/s,wkB/s,avgrq-sz,avgqu-sz,await,svctm,%util\\n";
            } elsif (\$line =~ /^Device:/) {
                # Header
                my (\$sec, \$min, \$hour, \$mday, \$mon, \$year) = localtime();
                
                \$datetime = sprintf('%04d/%02d/%02d %02d:%02d:%02d',
                    \$year + 1900, \$mon + 1, \$mday, \$hour, \$min, \$sec);
                
            } elsif (\$line =~ /^\\w.*\\d\$/) {
                # Body
                \$line =~ s/ +/,/g;
                print "\${datetime},\${line}\\n";
            }
        }
        
        close(\$iostat);
_EOF_
    echo $! >> $PID_FILE
done

