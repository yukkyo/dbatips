#/bin/bash

# 事前設定
# 1. 下記リンクから sqlcl をダウンロードして解凍
# http://www.oracle.com/technetwork/jp/developer-tools/sql-developer/downloads/index.html
# 2. このスクリプトと同じディレクトリに配置する

FNAME=tmp_login.sql
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# 初期設定やカレントディレクトリ変更
SQL_STR="
cd ${SCRIPT_DIR}
set lines           400
set long            500000
set longchunksize   500000
set history         on
set pages           50000
set serveroutput    on
set sqlblanklines   on
set termout         on
set trimspool       on
set verify          off

set termout         off
alter session set nls_timestamp_tz_format =  'yyyymmddhh24miss.ff' ;
set termout         on

set sqlprompt       '&_USER(&_CONNECT_IDENTIFIER)> '
set sqlformat ansiconsole
DEFINE _EDITOR=vi
"

echo "$SQL_STR" > ${FNAME}
# sql USERNAME/PASSWORD@CONTAINER @${SCRIPT_DIR}/${FNAME}
sqlcl/bin/sql sys/Fujimoto_DBA@//localhost:1521/oracle_pdb as sysdba @${SCRIPT_DIR}/${FNAME}

trap "rm ${FNAME}; exit 1" 0
