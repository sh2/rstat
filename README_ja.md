rstat/lstat
===========

rstatは複数のリモートホストでdstat、iostatとpidstatを実行し、ログファイルをCSV形式で出力するツールです。
lstatは同じ処理を自ホストのみで実行します。各コマンドは以下のオプションで起動されます。

    $ dstat -tfvnrl 1
    $ dstat -tfvnrl 15
    $ iostat -dxk 15
    $ pidstat -hlurdw -p ALL 60

セットアップ
------------

本ツールは、Red Hat Enterprise Linux 6/7と
それらのクローンディストリビューションを対象としています。

まず、測定対象ホストにsysstatとdstatがインストールされている必要があります。

    # yum install sysstat dstat

次に、rstatを実行するには測定対象ホストにパスワードなしのSSHログインができる必要があります。
これを構成するには、通常ssh-keygenコマンドとssh-copy-idコマンドを用います。
現在ログインしている自ホストが測定対象に含まれている場合は、
自ホストにもパスワードなしのSSHログインができる必要があります。

lstatの方は、SSHログインを必要としません。

最後に、現在ログインしている自ホストに各スクリプトを配置してください。
自ホスト以外の測定対象ホストにスクリプトを配置する必要は、ありません。

使い方
------

測定対象ホストを引数としてrstat\_start.shスクリプトを実行すると、測定が開始されます。
カレントディレクトリにd\_で始まるdstatのログファイル、i\_で始まるiostatのログファイルと
p\_で始まるpidstatのログファイルが出力されます。

    $ ./rstat_start.sh host1 host2 ...

測定を終了するには、同じディレクトリでrstat\_stop.shスクリプトを実行します。
引数はありません。

    $ ./rstat_stop.sh

lstatも使い方は同じです。
lstat\_start.shは自ホストのみを対象とするため、指定する引数はありません。

