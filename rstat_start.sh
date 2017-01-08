#!/bin/bash

BASH_EXEC=/bin/bash
PERL_EXEC=/usr/bin/perl
PID_FILE=/tmp/rstat_pidfile
PIPE_FILE=/tmp/rstat_pipefile
LOG_STDERR=rstat.err
DATETIME=`date +'%Y%m%d-%H%M%S'`
TARGET_LIST=$@

if [ $# -lt 1 ]; then
    echo 'Usage: ./rstat_start.sh host1 host2 ...'
    exit 1
fi

if [ -f "$PID_FILE" ]; then
    while read PID; do
        if [ "`ps -p $PID -o comm=`" = 'ssh' ]; then
            kill $PID
        fi
    done < $PID_FILE
    
    rm -f $PID_FILE
fi

rm -f $LOG_STDERR

for TARGET_HOST in $TARGET_LIST; do
    # dstat
    LOG_FILE_D=d_${DATETIME}_${TARGET_HOST}.csv
    ssh $TARGET_HOST $BASH_EXEC <<_EOF_ >$LOG_FILE_D 2>>$LOG_STDERR &
        rm -f $PIPE_FILE
        mkfifo $PIPE_FILE
        cat $PIPE_FILE &
        dstat -tfvnrl --output $PIPE_FILE 1 1>/dev/null 2>/dev/null
_EOF_
    echo $! >> $PID_FILE
    
    # iostat
    LOG_FILE_I=i_${DATETIME}_${TARGET_HOST}.csv
    ssh $TARGET_HOST $PERL_EXEC <<_EOF_ >$LOG_FILE_I 2>>$LOG_STDERR &
        use strict;
        use warnings;
        
        \$| = 1;
        my \$header_print = 1;
        my (\$header, \$datetime);
        open(my \$iostat, 'LC_ALL=C iostat -dxk 1 |') or die \$!;
        
        while (my \$line = <\$iostat>) {
            chomp(\$line);
            
            if (\$line =~ /^Linux/) {
                # Title
                print "Host,\$line\\n";
            } elsif (\$line =~ /^Device:/) {
                # Header
                my (\$sec, \$min, \$hour, \$mday, \$mon, \$year) = localtime();
                
                \$datetime = sprintf('%04d/%02d/%02d %02d:%02d:%02d',
                    \$year + 1900, \$mon + 1, \$mday, \$hour, \$min, \$sec);
                
                if (\$header_print) {
                    if (\$line =~ /r_await/) {
                        print "Datetime,Device,rrqm/s,wrqm/s,r/s,w/s,rkB/s,wkB/s,avgrq-sz,avgqu-sz,await,r_await,w_await,svctm,%util\\n";
                    } else {
                        print "Datetime,Device,rrqm/s,wrqm/s,r/s,w/s,rkB/s,wkB/s,avgrq-sz,avgqu-sz,await,svctm,%util\\n";
                    }
                    
                    \$header_print = 0;
                }
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

