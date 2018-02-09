col now         for a14
col username    for a30
col PID_S     for a6
col PID_C     for a11
col p_status    for a1
col machine     for a15
col program     for a30
col logon_time  for a10
col cur_state   for a18
col status      for a8
col sql_id      for a13
col command     for a20
col sid         for 9990
col serial#     for 99990
col pid         for 999
col server      for a1
col chldno      for 99

select
    s.sid
    , s.serial#
    , substr(s.username, 1, 30)                         username
    , p.pid
    , substrb(s.status, 1, 1)                           p_status
    , substr(to_char(p.spid), 1, 6)                     pid_s
    , s.process                                         pid_c
    , substr(s.machine, 1, 15)                          machine
    , decode(sign(length(s.program)-30)
             , -1, s.program
             , 0, s.program
             , substr(s.program, 1, 19) || '...' ||  substr(s.program, -8, 8)
             ) program
    , to_char(s.logon_time,  'mmddhh24miss')            logon_time
    , to_char(s.sql_exec_start,  'mmddhh24miss')        exec_start
    , s.sql_id
    , s.sql_child_number                                chldno
    , decode(s.lockwait, null, '', 'x')                 lw
    , q.plan_hash_value
    , substr(cmd.command_name, 1, 20)                   command
    , substr(s.server, 1, 1)                            server
    , l.time_remaining
    , q.executions
    , (sysdate - s.sql_exec_start) * 24 * 60 * 60       elapsed
    , trunc(tx.used_ublk * 8192 / 1024 / 1024, 1)       undo_sz
    , trunc(tu.blocks * 8192 / 1024 / 1024, 1)          tmp_sz
from
    gv$session s
    LEFT OUTER JOIN gv$process p
        ON s.paddr = p.addr
        AND s.inst_id = p.inst_id
    LEFT OUTER JOIN gv$sqlcommand cmd
        ON s.inst_id = cmd.inst_id
        AND s.command = cmd.command_type
    LEFT OUTER JOIN (
        select sum(used_ublk) used_ublk, ses_addr
        from gv$transaction
        group by ses_addr
    ) tx ON s.saddr = tx.ses_addr
    LEFT OUTER JOIN (
        select
            sum(blocks) blocks
            , session_addr
            , sql_id
        from
            gv$tempseg_usage
        group by
            session_addr
            , sql_id
    ) tu ON s.saddr = tu.session_addr
        AND s.sql_id = tu.sql_id
    LEFT OUTER JOIN (
        select
            inst_id
            , sql_id
            , plan_hash_value
            , address
            , hash_value
            , max(users_executing) users_executing
            , max(executions) executions
        from
            gv$sql
        where
            plan_hash_value <> 0
            AND users_executing > 0
        group by
            inst_id
            , sql_id
            , plan_hash_value
            , address
            , hash_value
    ) q ON s.sql_id = q.sql_id
        AND s.sql_address = q.address
        AND s.sql_hash_value = q.hash_value
        AND s.inst_id = q.inst_id
    LEFT OUTER JOIN (
        select
            inst_id
            , sid
            , serial#
            , sql_id
            , sum(time_remaining) time_remaining
        from
            gv$session_longops
        group by
            inst_id
            , sid
            , serial#
            , sql_id
    ) l ON s.inst_id = l.inst_id
        AND s.sid     = l.sid
        AND s.serial# = l.serial#
        AND s.sql_id  = l.sql_id
where
    s.username     is not null
    AND s.audsid   !=  userenv('SESSIONID')
    AND s.type     <> 'BACKGROUND'
    AND s.status   <> 'INACTIVE'
    AND s.username not in ('SYS')
order by
    exec_start
    , p.spid
    , s.sid
    , s.serial#
;

col now         clear
col username    clear
col PID_S       clear
col PID_C       clear
col p_status    clear
col machine     clear
col program     clear
col logon_time  clear
col cur_state   clear
col status      clear
col sql_id      clear
col command     clear
col sid         clear
col serial#     clear
col pid         clear
col server      clear
col chldno      clear
