#!/bin/sh

iam=`basename $0`

cleanup() {
    rm $iam.sql
}

trap "cleanup" 0

# 第1引数:from
# 第2引数:to
#   いずれもyyyymmddhh24mi形式であること
#
awr_list_from_to() {
    sqlplus -r 1 -s / as sysdba <<- EOT
        column instance_number  format 9
        column dbid     noprint new_value db_id
        column instance_number  noprint new_value inst_num

        column inst_num format 99 ;

        set pages 0 feedback off time off timing off trimspool on

        select  dbid        from v\$database ;
        select  instance_number from v\$instance ;

        spool $iam.sql

        set lines 400 pages 0 feedback off time off timing off trimspool on long 500000 longchunksize 500000
        exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql => 100) ;

        -- report for "each snap FROM between TO"
        --
        -- b.snap_id - 1はawrrpt.sqlの仕様にあわせた(一エントリ古いdba_hist_snapshotのsnap_id/begin_interval_timeを使用しているように見える)
        --
        select
            'spool  awr/awr_' || to_char(b.begin_interval_time, 'yyyymmddhh24mi') || '_' || to_char(b.end_interval_time, 'yyyymmddhh24mi') || '.log' || chr(10) ||
            'select output from table(dbms_workload_repository.awr_report_text(&db_id, ' || trim(to_char(&inst_num)) || ', ' ||
            to_char(b.snap_id - 1) || ', '  ||
            b.snap_id || ', '   ||
            '0));'          || chr(10) ||
            'spool off'
        from
            dba_hist_snapshot b
        where
            b.begin_interval_time   >= to_date('$1', 'yyyymmddhh24mi')
        and b.end_interval_time     <= to_date('$2', 'yyyymmddhh24mi')
        order by
            b.snap_id
        ;

        -- report with "FROM and TO"
        --
        -- min(b.snap_id) - 1はawrrpt.sqlの仕様にあわせた(一エントリ古いdba_hist_snapshotのsnap_id/begin_interval_timeを使用しているように見える)
        --
        select
            'spool  awr/t_awr_' || to_char(min(b.begin_interval_time), 'yyyymmddhh24mi') || '_' || to_char(max(b.end_interval_time), 'yyyymmddhh24mi') || '.log' || chr(10) ||
            'select output from table(dbms_workload_repository.awr_report_text(&db_id, ' || trim(to_char(&inst_num)) || ', ' ||
            to_char(min(b.snap_id) - 1) || ', ' ||
            max(b.snap_id) || ', '  ||
            '8));'          || chr(10) ||
            'spool off'
        from
            dba_hist_snapshot b
        where
            b.begin_interval_time   >= to_date('$1', 'yyyymmddhh24mi')
        and b.end_interval_time     <= to_date('$2', 'yyyymmddhh24mi')
        ;
        spool off
        set termout off
        @$iam.sql
    EOT
}

[ $# -ne 2 ] &&
    echo "usage: $iam yyyymmddhh24mi yyyymmddhh24mi or $iam yyyymmddhh24mi hh" &&
    exit 1

echo "$1" | egrep '20[0-9]{10}' > /dev/null
[ $? -ne 0 ] &&
    echo "usage: $iam yyyymmddhh24 yyyymmddhh24mi or $iam yyyymmddhh24 hh" &&
    exit 1

from=$1
shift

echo "$1" | egrep '20[0-9]{10}' > /dev/null
if [ $? -ne 0 ]; then
    echo "$1" | egrep '^[0-9]{1,2}$' > /dev/null
    if [ $? -ne 0 ]; then
        echo "usage: $iam yyyymmddhh24mi yyyymmddhh24 or $iam yyyymmddhh24 hh" &&
        exit 1
    fi
    from_tmp=`echo $from | sed 's/^\(........\)\(..\)\(..\)$/\1 \2:\3/'`
    to=`date -d "$from_tmp $1 hours" '+%Y%m%d%H%M'`
else
    to=$1
fi

if [ ! -d awr ]; then
    if [ $(basename `pwd`) != "awr" ]; then
        mkdir awr  || echo "mkdir awr failed." || exit 1
    else
        cd ..
    fi
fi
awr_list_from_to $from $to
