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
DEFINE _EDITOR=vi
