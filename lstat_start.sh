#!/bin/bash

DATETIME=$(date +'%Y%m%d-%H%M%S')
HOSTNAME=$(hostname -s)
PIDFILE=lstat.pid
LOGFILE_ERR=lstat.err
LOGFILE_D01=d_${DATETIME}_${HOSTNAME}_01.csv
LOGFILE_D15=d_${DATETIME}_${HOSTNAME}_15.csv
LOGFILE_I15=i_${DATETIME}_${HOSTNAME}_15.csv

if [ -f "$PIDFILE" ]; then
    while read PID; do
        COMMAND=$(ps -p $PID -o comm=)
        
        if [ "$COMMAND" = 'python' -o "$COMMAND" = 'perl' ]; then
            kill $PID
        fi
    done <$PIDFILE
    
    rm -f $PIDFILE
fi

# dstat 1
dstat -tfvnrl --output $LOGFILE_D01 1 >/dev/null 2>>$LOGFILE_ERR &
echo $! >>$PIDFILE

# dstat 15
dstat -tfvnrl --output $LOGFILE_D15 15 >/dev/null 2>>$LOGFILE_ERR &
echo $! >>$PIDFILE

# iostat 15
perl <<_EOF_ >$LOGFILE_I15 2>>$LOGFILE_ERR &
use strict;
use warnings;

\$| = 1;
my \$header_print = 1;
my \$datetime;
open(my \$iostat, 'LC_ALL=C iostat -dxk 15 |') or die \$!;

\$SIG{'TERM'} = sub {
    close(\$iostat);
    exit(0);
};

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
            my \$header = \$line;
            \$header =~ s/[: ]+/,/g;
            print "Datetime,\${header}\\n";
            \$header_print = 0;
        }
    } elsif (\$line =~ /^\\w.*\\d\$/) {
        # Body
        \$line =~ s/ +/,/g;
        print "\${datetime},\${line}\\n";
    }
}
_EOF_

echo $! >>$PIDFILE

