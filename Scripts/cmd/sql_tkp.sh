#!/bin/sh

ORACLE_SID=MGODB
cmd=`basename $0`
now=`date +%Y%m%d%H%M%S`
my_tmp=$$_${now}.log

(
exec > $my_tmp
echo -n "args:"
for w in $* ; do
		echo -n $w " "
done
echo ""
)

schema=$1; shift
sqlfile=`echo $1 | sed 's/.sql$//'`; shift

sqlplus_log=${sqlfile}.${now}.log
module_token=$$_$now
[ "${module_token_prefix}x" = "x" ] || module_token=${module_token_prefix}_${module_token}

admin_user=USERNAME/PASSWORD@CONTAINER

mv $my_tmp $sqlplus_log

trace_dump() {
	udump_dir=`awk			'/^UDUMP DIR.*= /				{ sub(/UDUMP DIR.*= /,			""); print }' $sqlplus_log`
	session_pid=`awk		'/^SESSION_PID.*= /				{ sub(/SESSION_PID.*= /,		""); print }' $sqlplus_log`
	session_id=`awk			'/^SESSION_ID.*= /				{ sub(/SESSION_ID.*= /,			""); print }' $sqlplus_log`
	serial_no=`awk			'/^SERIAL#.*= /					{ sub(/SERIAL#.*= /,			""); print }' $sqlplus_log`

	prof_ela="`basename $1`".$now.prof_ela
	mon="`basename $1`".$now.mon
	plan="`basename $1`".$now.plan
	if [ -f ${sqlplus_log}.err ]; then
		prof_ela=$prof_ela.abort
		mon=$mon.abort
		plan=$plan.abort
		tail -50 $sqlplus_log
	fi

	sqlplus -r 2 -s $admin_user <<- EOT | expand -t8 > $mon
	EOT

	echo "
	set long 999999
	set longchunksize 999999
	set pages 0
	set lines 400
	set trimspool on
	set feedback off
	set timing off
	set time off
	
	set long 999999 longchunksize 999999 pages 0 lines 400
	select dbms_sqltune.report_sql_monitor(session_id => '$session_id', session_serial => '$serial_no', report_level=> 'ALL') from dual ;
	" | sqlplus -r 2 -s $admin_user | expand -t8 > $mon

	trc_tmp=/tmp/$cmd.$$.${session_id}_${serial_no}_tmp.trc
	(
		cd $udump_dir
		trcsess output=$trc_tmp module=${module_token} *_${module_token}.trc
	)

	{
		echo "
		set long 999999
		set longchunksize 999999
		set pages 0
		set lines 400
		set trimspool on
		set feedback off
		set timing off
		set time off
		"
		
		grep 'sqlid=' $trc_tmp																						| \
			grep -v 'uid=0'																							| \
				egrep -v '(3paf9ma44kpqh|5qgz1p0cut7mx|5w9ryudb9ajfr|9vdcmgynp4fyn|dtfrbb0kjvnbj|gv7dd3rq1ucsr)'	| \
					sed 's/.*sqlid=//'																				| \
						sort																						| \
							uniq																					| \
								sed "s/^/select * from table(dbms_xplan.display_cursor(/; s/"'$'"/, format => 'last, all, allstats, outline'));/"
	} | sqlplus -r 2 -s $admin_user | expand -t8 > $plan

	tkprof $trc_tmp $prof_ela width=2000 sys=yes waits=yes sort=exeela,fchela,prsela,execpu,fchcpu,prscpu 2> /dev/null 1>&2

	cat $sqlplus_log $prof_ela > ${prof_ela}.tmp
	mv ${prof_ela}.tmp $prof_ela

	rm -f ${sqlplus_log}.err $trc_tmp

	echo ""
	echo "`basename $1`".$now.\*
}

trap 'touch ${sqlplus_log}.err; exit 1'			2
trap 'trace_dump $sqlfile'		0

# (sqlplus -r 2 -s $admin_user || touch ${sqlplus_log}.err ) << !EOT | tee -a $sqlplus_log
(sqlplus -r 1 -s $admin_user || touch ${sqlplus_log}.err ) << !EOT

	set head off feedback off pages 0 sqlblankline on verify off timing off time off lines 400 trimspool on

	spool $sqlplus_log

	select
		'UDUMP DIR		= ' || value
	from
		v\$diag_info
	where
		name = 'Diag Trace'
	;

	select /*+ rule */
		'SESSION_PID	= ' || p.spid	|| chr(10) ||
		'SESSION_ID = '		|| s.sid	|| chr(10) ||
		'SERIAL#		= ' || s.serial#
	from
		v\$session s
		, v\$process p
		, v\$sqlarea a
	where
		s.paddr				= p.addr
	and s.sql_address		= a.address
	and s.sql_hash_value	= a.hash_value
	and s.username			is not null
	and s.audsid			= userenv('SESSIONID')
	;

	alter session set current_schema = $schema ;
	alter session set timed_statistics = true ;
	alter session set tracefile_identifier = '$module_token' ;

	exec dbms_application_info.set_module('$module_token', null);
	exec dbms_session.session_trace_enable(waits => true) ;

	column start_time		new_val start_time noprint
	column end_time			new_val end_time noprint

	select to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss') start_time from dual ;

	set termout off arraysize 5000
	set serveroutput off

	whenever sqlerror exit 1

	alter session set statistics_level = all ;
	@$sqlfile $@

	-- select * from table(dbms_xplan.display_cursor(format => 'ALL, ALLSTATS, LAST')) ;

	select to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss') end_time from dual ;

	set timing off time off termout on

	exec dbms_session.session_trace_disable() ;

	select
		'elapsed: ' || round((to_date('&end_time', 'yyyy/mm/dd hh24:mi:ss') - to_date('&start_time', 'yyyy/mm/dd hh24:mi:ss')) * 24 * 60 * 60, 1) || ' sec'
	from
		dual ;
	spool off
!EOT
