--Lock SQL
/*select spid,text from sys.sysprocesses a with(nolock) 
cross apply sys.dm_exec_sql_text(sql_handle)
where spid in(639)
*/

--Lock table 的详细session信息
SELECT Replace(SUBSTRING(b.TEXT, 1, 340), '''', '''') AS sqlmessage,
       substring(c.LockObject,1,len(c.LockObject)-1) as AllLockObject,
       replace(hostname, ' ', '') AS hostname,
       '''' + replace(program_name, ' ', '') + '''' AS program_name,
       loginame,
       db_name(a.dbid) AS DBname,
       spid,
       blocked,
       waittime / 1000 AS waittime,
       a.status,
       a.lastwaittype,
       a.cmd,
       cpu
FROM   sys.sysprocesses AS a WITH(nolock) 
CROSS apply sys.dm_exec_sql_text(sql_handle) AS b
CROSS apply (select distinct OBJECT_NAME(c.resource_associated_entity_id)+','
        from   sys.dm_tran_locks c with(nolock)
        where  c.resource_type = 'OBJECT' and c.request_session_id = a.spid
        for xml path('')) AS C(LockObject)
where  spid in (742);

--###查看进程中正在执行的完整SQL：  dbcc inputbuffer(进程号)
dbcc inputbuffer(SPID)

