#!/bin/sh

FNAME=tmp_login.sql
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# 初期設定やカレントディレクトリ変更
SQL_STR="
cd ${SCRIPT_DIR}
set time            on
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
"

echo "$SQL_STR" > ${FNAME}
sql USERNAME/PASSWORD@CONTAINER @${SCRIPT_DIR}/${FNAME}

# 以下はなぜか失敗する
# echo "$SQL_STR" | sql USERNAME/PASSWORD@CONTAINER

trap "rm ${FNAME}; exit 1" 0 
