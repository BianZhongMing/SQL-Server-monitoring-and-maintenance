----在数据库使用较为拥堵的时候，使用以下语句可以导出占用cpu的进程
SELECT DB_NAME(a .dbid ) AS dbname ,
        loginame ,
        spid ,
'kill '+cast(spid as varchar(10)),
        cpu ,
        b. text ,
        lastwaittype ,
        waitresource ,
        a. [status] ,
        hostname AS WebServer ,
        [program_name] AS AppName ,
        [cmd] ,
        'cpu' AS Type
--into #cpu
FROM    master ..sysprocesses AS a
        CROSS APPLY sys .dm_exec_sql_text (sql_handle ) AS b
        INNER JOIN master ..sysdatabases AS c ON a .dbid = c .dbid
                                                --AND a. status <> 'sleeping' --and a.blocked>0
                                                --AND DB_NAME(a .dbid )='Ppdai_Messaging'
                                                --AND b.text LIKE '%Ppdai_Messaging%'
and loginame='datateam_ro'
and a. [status]='sleeping' and (hostname like 'SHN%'  or hostname like 'NJ%')
and program_name in ('Navicat Premium','Microsoft SQL Server Management Studio - 查询')

ORDER BY cpu DESC	