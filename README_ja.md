rstat
=====

リモートホストにdstatとiostatを仕掛けます。

セットアップ
------------

Red Hat Enterprise Linux 5、6と、
それらのクローンディストリビューションを対象にしています。
ただし以下に示すiostatの不具合が修正された、5.7以上を推奨します。

[Bug 604637 – extraneous newline in iostat report for long device names](https://bugzilla.redhat.com/show_bug.cgi?id=604637)

測定対象ホストにパスワードなしのSSHログインができる必要があります。
この構成には通常ssh-keygenコマンドとssh-copy-idコマンドを利用します。
現在ログインしているホストが測定対象の場合には、
自分自身にもパスワードなしのSSHログインができる必要があります。

測定対象ホストにdstatとsysstatパッケージが
インストールされている必要があります。
測定対象ホストに本ツールのスクリプトを配置する必要は、ありません。

使い方
------

ホスト名を引数としてrstat\_start.shスクリプトを起動し、測定を開始します。カレントディレクトリにd\_で始まるdstatのログファイルと、i\_で始まるiostatのログファイルが蓄積されます。

    $ ./rstat_start.sh host1 host2 ...

測定を終了するにはrstat\_stop.shスクリプトを起動します。引数はありません。

    $ ./rstat_stop.sh
