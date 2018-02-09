#!/bin/sh

trap "exit" 2  # Ctrl+C や Del キーを押したときに発生する割り込みシグナル。

sql_format="
set sqlprompt ''
set termout off
set head off
set lines 32767
set pages 0
set time off
set timing off
set verify off
set feedback off
set pages 50000
set sqlprompt ''
set termout on
"

(
echo "$sql_format"  # 共通フォーマット
echo "conn USERNAME/PASSWORD@CONTAINER;"  # コネクション生成

while [ 1 ]
do
    echo "set head off"
    echo "select null from dual;"
    echo "select to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss') from dual;"
    echo "set head on"
    echo "@monitor_sqls"
    sleep 5  # 5秒間スリープ
done
) | sqlplus /nolog  # SQL*Plus にパイプで渡す
