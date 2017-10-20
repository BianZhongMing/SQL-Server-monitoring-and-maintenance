-- 查看性能记数器
SELECT * FROM sys.dm_os_performance_counters

-- 执行过的线程所遇到的所有等待(不是当前正在运行的线程, 为自上次重置统计信息或启动服务器以来累积的数据),可分析靠前的几个等待较高的事件。
select * from sys.dm_os_wait_stats order by wait_time_ms desc

-- 重置该动态视图
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
GO
-- 正在等待某些资源的任务的等待队列
select * from sys.dm_os_waiting_tasks order by wait_duration_ms desc

内存使用：  
查看当前由 SQL Server 分配的内存对象(KB): select sum((page_size_in_bytes/1024)*max_pages_allocated_count) from sys.dm_os_memory_objects;
查看系统内存当前信息: select * from sys.dm_os_sys_memory (这个动态视图只在sql 2008中才有)
select
cpu_count,
hyperthread_ratio,
scheduler_count,
physical_memory_in_bytes / 1024 / 1024 as physical_memory_mb,
virtual_memory_in_bytes / 1024 / 1024 as virtual_memory_mb,
bpool_committed * 8 / 1024 as bpool_committed_mb,
bpool_commit_target * 8 / 1024 as bpool_target_mb,
bpool_visible * 8 / 1024 as bpool_visible_mb
from sys.dm_os_sys_info

限制SQL Server使用的最小,最大内存(MB)：
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'min server memory', 300;
GO
sp_configure 'max server memory', 850;
GO
RECONFIGURE;
GO


CPU使用情况:
SELECT TOP 50
total_worker_time/execution_count AS '每次执行占用CPU(微秒)',
execution_count       as '执行次数',
total_worker_time     as '总共占用CPU(微秒)',
creation_time         as '创建时间',
last_execution_time   as '最后执行时间',
min_worker_time       as '最低每次占用CPU',
max_worker_time       as '最高每次占用cpu',
total_physical_reads  as '总共io物理读取次数',
total_logical_reads   as '总共逻辑读取次数',
total_logical_writes  as '总共逻辑写次数',
total_elapsed_time    as '完成此计划的执行所占用的总时间(微秒)',
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS 'SQL内容'
FROM sys.dm_exec_query_stats
ORDER BY 1 DESC


--下面的查询显示SQL 等待分析和前10 个等待的资源
select top 10 *
from sys.dm_os_wait_stats
where wait_type not in ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK','SLEEP_SYSTEMTASK','WAITFOR')
order by wait_time_ms desc;

SQL Server中的活动会话数:
exec   sp_who   'active'
print @@rowcount

SQL Server等待情况
select * from sys.dm_os_waiting_tasks ; --当前等待事件
select * from sys.dm_os_wait_stats  --历史等待次数,是sqlserver启动后的累计值,需使用下一条语句清空
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);

找出进程阻塞:
运行下面的查询可确定阻塞的会话
select blocking_session_id, wait_duration_ms, session_id from
sys.dm_os_waiting_tasks
where blocking_session_id is not null

spid 正在阻塞另一个 spid，可在数据库中创建以下存储过程，然后执行该存储过程。此存储过程会报告此阻塞情况。键入 sp_who 可找出 @spid；@spid 是可选参数。

create proc dbo.sp_block (@spid bigint=NULL)
as
select
   t1.resource_type,
   'database'=db_name(resource_database_id),
   'blk object' = t1.resource_associated_entity_id,
   t1.request_mode,
   t1.request_session_id,
   t2.blocking_session_id    
from
   sys.dm_tran_locks as t1,
   sys.dm_os_waiting_tasks as t2
where
   t1.lock_owner_address = t2.resource_address and
   t1.request_session_id = isnull(@spid,t1.request_session_id)

以下是使用此存储过程的示例。
exec sp_block
exec sp_block @spid = 7

select sum((page_size_in_bytes/1024)*max_pages_allocated_count) from sys.dm_os_memory_objects;
select * from sys.dm_os_sys_info;
select * from sys.dm_os_performance_counters


A. 获取有关按平均 CPU 时间排在最前面的五个查询的信息
以下示例返回前五个查询的 SQL 语句文本和平均 CPU 时间。
SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
   SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
       ((CASE qs.statement_end_offset
         WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time/execution_count DESC;


B. 提供批处理执行统计信息
以下示例返回按批执行的 SQL 查询的文本，并提供有关它们的统计信息。
SELECT s2.dbid, 
   s1.sql_handle,  
   (SELECT TOP 1 SUBSTRING(s2.text,statement_start_offset / 2+1 ,
     ( (CASE WHEN statement_end_offset = -1
        THEN (LEN(CONVERT(nvarchar(max),s2.text)) * 2)
        ELSE statement_end_offset END)  - statement_start_offset) / 2+1))  AS sql_statement,
   execution_count,
   plan_generation_num,
   last_execution_time,  
   total_worker_time,
   last_worker_time,
   min_worker_time,
   max_worker_time,
   total_physical_reads,
   last_physical_reads,
   min_physical_reads,  
   max_physical_reads,  
   total_logical_writes,
   last_logical_writes,
   min_logical_writes,
   max_logical_writes  
FROM sys.dm_exec_query_stats AS s1
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2  
WHERE s2.objectid is null
ORDER BY s1.sql_handle, s1.statement_start_offset, s1.statement_end_offset;

-- 数据库文件性能,文件io性能统计(必须重启sql server服务,才能清零该计数器)
select DB_NAME(database_id) DB_NAME, file_id,io_stall_read_ms ,num_of_reads
,cast(io_stall_read_ms/(1.0+num_of_reads) as numeric(10,1)) as 'avg_read_stall_ms'
,io_stall_write_ms,num_of_writes
,cast(io_stall_write_ms/(1.0+num_of_writes) as numeric(10,1)) as 'avg_write_stall_ms'
,io_stall_read_ms + io_stall_write_ms as io_stalls
,num_of_reads + num_of_writes as total_io
,cast((io_stall_read_ms+io_stall_write_ms)/(1.0+num_of_reads + num_of_writes) as numeric(10,1)) as 'avg_io_stall_ms'
from sys.dm_io_virtual_file_stats(null,null)
order by avg_io_stall_ms desc;


-- 查看分区表money，各个分区的行数和边界值.
select partition = $partition.分区函数名(userid)
     ,rows      = count(*)
     ,minval    = min(userid)
     ,maxval    = max(userid)
from dbo.money with(nolock)
group by $partition.分区函数名(userid)
order by partition;

-- 数据库文件性能,文件io性能统计(必须重启sql server服务,才能清零该计数器),
SELECT DB_NAME(vfs.DbId) DatabaseName, mf.name,
mf.physical_name, vfs.BytesRead, vfs.BytesWritten,
vfs.IoStallMS, vfs.IoStallReadMS, vfs.IoStallWriteMS,
vfs.NumberReads, vfs.NumberWrites,
(Size*8)/1024 Size_MB
FROM ::fn_virtualfilestats(NULL,NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.DbId
AND mf.FILE_ID = vfs.FileId
GO

-- 性能计数器动态视图,  和使用windows性能计数器效果一致。
SELECT [counter_name], [cntr_value] FROM sys.dm_os_performance_counters
 WHERE ([instance_name] = '' OR [instance_name] = '_Total') AND (
        ([object_name] LIKE ('%Plan Cache%') AND [counter_name] IN
         ('Cache Hit Ratio', 'Cache Hit Ratio Base')) OR
        ([object_name] LIKE ('%Buffer Manager%') AND [counter_name] IN
         ('Buffer Cache Hit Ratio', 'Buffer Cache Hit Ratio Base', 'Page reads/sec', 'Page writes/sec')) OR
        ([object_name] LIKE ('%General Statistics%') AND [counter_name] IN
         ('Active Temp Tables', 'User Connections')) OR
        ([object_name] LIKE ('%Databases%') AND [counter_name] IN
         ('Transactions/sec', 'Log Cache Hit Ratio', 'Log Cache Hit Ratio Base', 'Log Flushes/sec',
           'Log Bytes Flushed/sec', 'Backup/Restore Throughput/sec')) OR
        ([object_name] LIKE ('%Access Methods%') AND [counter_name] IN
         ('Full Scans/sec', 'Range Scans/sec', 'Probe Scans/sec', 'Index Searches/sec', 'Page Splits/sec')) OR
        ([object_name] LIKE ('%Memory Manager%') AND [counter_name] IN
         ('Target Server Memory (KB)', 'Target Server Memory(KB)', 'Total Server Memory (KB)')) OR
        ([object_name] LIKE ('%SQL Statistics%') AND [counter_name] IN
         ('SQL Compilations/sec', 'SQL Re-Compilations/sec'))
        )


--查看IO状况
SELECT TOP 20
 [Total IO] = (qs.total_logical_reads + qs.total_logical_writes)
 , [Average IO] = (qs.total_logical_reads + qs.total_logical_writes) /
                                           qs.execution_count
 , qs.execution_count
 , SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,      
 ((CASE WHEN qs.statement_end_offset = -1
   THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
   ELSE qs.statement_end_offset
   END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
 , qt.text AS [Parent Query]
 , DB_NAME(qt.dbid) AS DatabaseName
 , qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY [Total IO] DESC




常规服务器动态管理对象包括：
dm_db_*：数据库和数据库对象
dm_exec_*：执行用户代码和关联的连接
dm_os_*：内存、锁定和时间安排
dm_tran_*：事务和隔离
dm_io_*：网络和磁盘的输入/输出

此部分介绍为监控 SQL Server 运行状况而针对这些动态管理视图和函数运行的一些常用查询。
下面的查询显示 CPU 平均占用率最高的前 50 个 SQL 语句。
SELECT TOP 50
total_worker_time/execution_count AS [Avg CPU Time],
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, *
FROM sys.dm_exec_query_stats
ORDER BY [Avg CPU Time] DESC


下面的查询显示一些可能占用大量 CPU 使用率的运算符（例如 ‘%Hash Match%’、‘%Sort%’）以找出可疑对象。
select *
from
     sys.dm_exec_cached_plans
     cross apply sys.dm_exec_query_plan(plan_handle)
where
     cast(query_plan as nvarchar(max)) like '%Sort%'
     or cast(query_plan as nvarchar(max)) like '%Hash Match%'


运行下面的 DMV 查询以查看 CPU、计划程序内存和缓冲池信息。
select
cpu_count,
hyperthread_ratio,
scheduler_count,
physical_memory_in_bytes / 1024 / 1024 as physical_memory_mb,
virtual_memory_in_bytes / 1024 / 1024 as virtual_memory_mb,
bpool_committed * 8 / 1024 as bpool_committed_mb,
bpool_commit_target * 8 / 1024 as bpool_target_mb,
bpool_visible * 8 / 1024 as bpool_visible_mb
from sys.dm_os_sys_info


下面的示例查询显示已重新编译的前 25 个存储过程。plan_generation_num 指示该查询已重新编译的次数。
select top 25
sql_text.text,
sql_handle,
plan_generation_num,
execution_count,
dbid,
objectid
from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(sql_handle) as sql_text
where plan_generation_num > 1
order by plan_generation_num desc


下面的 DMV 查询可用于查找哪些批处理/请求生成的 I/O 最多。如下所示的 DMV 查询可用于查找可生成最多 I/O 的前五个请求。调整这些查询将提高系统性能。
select top 5
   (total_logical_reads/execution_count) as avg_logical_reads,
   (total_logical_writes/execution_count) as avg_logical_writes,
   (total_physical_reads/execution_count) as avg_phys_reads,
    Execution_count,
   statement_start_offset as stmt_start_offset,
   sql_handle,
   plan_handle
from sys.dm_exec_query_stats  
order by  (total_logical_reads + total_logical_writes) Desc
