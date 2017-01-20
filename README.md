rstat/lstat
===========

rstat is a tool that runs dstat, iostat and pidstat on multiple remote hosts and outputs the log files in CSV format.
lstat runs the same processes on the localhost only. Each command is executed with the following options.

    $ dstat -tfvnrl 1
    $ dstat -tfvnrl 15
    $ iostat -dxk 15
    $ pidstat -hlurdw -p ALL 60

Setup
-----

These tools are targeted at Red Hat Enterprise Linux 6/7 and their clone distributions.

First, sysstat and dstat must be installed on the hosts to be measured.

    # yum install sysstat dstat

Next, in order to execute rstat,
it is necessary to have SSH login without password on the hosts to be measured.
To configure this, you usually use the ssh-keygen command and the ssh-copy-id command.
If the localhost is included in the measurement targets,
you also need to have SSH login without password on the localhost.

For lstat, SSH login is not required.

Finally, please place each script on the localhost.
There is no need to place scripts on the hosts to be measured other than the localhost.

How to use
----------

To start the measurement, execute the rstat\_start.sh script with the hosts to be measured as arguments.
The tool outputs log files of dstat starting with d\_, log files of iostat starting with i\_
and log files of pidstat starting with p\_ in the current directory.

    $ ./rstat_start.sh host1 host2 ...

To end the measurement, execute the rstat\_stop.sh script in the same directory.
There is no argument.

    $ ./rstat_stop.sh

The usage of lstat is the same.
Since lstat\_start.sh targets only the localhost, there are no arguments to specify.

