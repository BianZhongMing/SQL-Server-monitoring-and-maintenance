-- �鿴���ܼ�����
SELECT * FROM sys.dm_os_performance_counters

-- ִ�й����߳������������еȴ�(���ǵ�ǰ�������е��߳�, Ϊ���ϴ�����ͳ����Ϣ�����������������ۻ�������),�ɷ�����ǰ�ļ����ȴ��ϸߵ��¼���
select * from sys.dm_os_wait_stats order by wait_time_ms desc

-- ���øö�̬��ͼ
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);
GO
-- ���ڵȴ�ĳЩ��Դ������ĵȴ�����
select * from sys.dm_os_waiting_tasks order by wait_duration_ms desc

�ڴ�ʹ�ã�  
�鿴��ǰ�� SQL Server ������ڴ����(KB): select sum((page_size_in_bytes/1024)*max_pages_allocated_count) from sys.dm_os_memory_objects;
�鿴ϵͳ�ڴ浱ǰ��Ϣ: select * from sys.dm_os_sys_memory (�����̬��ͼֻ��sql 2008�в���)
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

����SQL Serverʹ�õ���С,����ڴ�(MB)��
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


CPUʹ�����:
SELECT TOP 50
total_worker_time/execution_count AS 'ÿ��ִ��ռ��CPU(΢��)',
execution_count       as 'ִ�д���',
total_worker_time     as '�ܹ�ռ��CPU(΢��)',
creation_time         as '����ʱ��',
last_execution_time   as '���ִ��ʱ��',
min_worker_time       as '���ÿ��ռ��CPU',
max_worker_time       as '���ÿ��ռ��cpu',
total_physical_reads  as '�ܹ�io�����ȡ����',
total_logical_reads   as '�ܹ��߼���ȡ����',
total_logical_writes  as '�ܹ��߼�д����',
total_elapsed_time    as '��ɴ˼ƻ���ִ����ռ�õ���ʱ��(΢��)',
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS 'SQL����'
FROM sys.dm_exec_query_stats
ORDER BY 1 DESC


--����Ĳ�ѯ��ʾSQL �ȴ�������ǰ10 ���ȴ�����Դ
select top 10 *
from sys.dm_os_wait_stats
where wait_type not in ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK','SLEEP_SYSTEMTASK','WAITFOR')
order by wait_time_ms desc;

SQL Server�еĻ�Ự��:
exec   sp_who   'active'
print @@rowcount

SQL Server�ȴ����
select * from sys.dm_os_waiting_tasks ; --��ǰ�ȴ��¼�
select * from sys.dm_os_wait_stats  --��ʷ�ȴ�����,��sqlserver��������ۼ�ֵ,��ʹ����һ��������
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);

�ҳ���������:
��������Ĳ�ѯ��ȷ�������ĻỰ
select blocking_session_id, wait_duration_ms, session_id from
sys.dm_os_waiting_tasks
where blocking_session_id is not null

spid ����������һ�� spid���������ݿ��д������´洢���̣�Ȼ��ִ�иô洢���̡��˴洢���̻ᱨ���������������� sp_who ���ҳ� @spid��@spid �ǿ�ѡ������

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

������ʹ�ô˴洢���̵�ʾ����
exec sp_block
exec sp_block @spid = 7

select sum((page_size_in_bytes/1024)*max_pages_allocated_count) from sys.dm_os_memory_objects;
select * from sys.dm_os_sys_info;
select * from sys.dm_os_performance_counters


A. ��ȡ�йذ�ƽ�� CPU ʱ��������ǰ��������ѯ����Ϣ
����ʾ������ǰ�����ѯ�� SQL ����ı���ƽ�� CPU ʱ�䡣
SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
   SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
       ((CASE qs.statement_end_offset
         WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time/execution_count DESC;


B. �ṩ������ִ��ͳ����Ϣ
����ʾ�����ذ���ִ�е� SQL ��ѯ���ı������ṩ�й����ǵ�ͳ����Ϣ��
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

-- ���ݿ��ļ�����,�ļ�io����ͳ��(��������sql server����,��������ü�����)
select DB_NAME(database_id) DB_NAME, file_id,io_stall_read_ms ,num_of_reads
,cast(io_stall_read_ms/(1.0+num_of_reads) as numeric(10,1)) as 'avg_read_stall_ms'
,io_stall_write_ms,num_of_writes
,cast(io_stall_write_ms/(1.0+num_of_writes) as numeric(10,1)) as 'avg_write_stall_ms'
,io_stall_read_ms + io_stall_write_ms as io_stalls
,num_of_reads + num_of_writes as total_io
,cast((io_stall_read_ms+io_stall_write_ms)/(1.0+num_of_reads + num_of_writes) as numeric(10,1)) as 'avg_io_stall_ms'
from sys.dm_io_virtual_file_stats(null,null)
order by avg_io_stall_ms desc;


-- �鿴������money�����������������ͱ߽�ֵ.
select partition = $partition.����������(userid)
     ,rows      = count(*)
     ,minval    = min(userid)
     ,maxval    = max(userid)
from dbo.money with(nolock)
group by $partition.����������(userid)
order by partition;

-- ���ݿ��ļ�����,�ļ�io����ͳ��(��������sql server����,��������ü�����),
SELECT DB_NAME(vfs.DbId) DatabaseName, mf.name,
mf.physical_name, vfs.BytesRead, vfs.BytesWritten,
vfs.IoStallMS, vfs.IoStallReadMS, vfs.IoStallWriteMS,
vfs.NumberReads, vfs.NumberWrites,
(Size*8)/1024 Size_MB
FROM ::fn_virtualfilestats(NULL,NULL) vfs
INNER JOIN sys.master_files mf ON mf.database_id = vfs.DbId
AND mf.FILE_ID = vfs.FileId
GO

-- ���ܼ�������̬��ͼ,  ��ʹ��windows���ܼ�����Ч��һ�¡�
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


--�鿴IO״��
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




�����������̬������������
dm_db_*�����ݿ�����ݿ����
dm_exec_*��ִ���û�����͹���������
dm_os_*���ڴ桢������ʱ�䰲��
dm_tran_*������͸���
dm_io_*������ʹ��̵�����/���

�˲��ֽ���Ϊ��� SQL Server ����״���������Щ��̬������ͼ�ͺ������е�һЩ���ò�ѯ��
����Ĳ�ѯ��ʾ CPU ƽ��ռ������ߵ�ǰ 50 �� SQL ��䡣
SELECT TOP 50
total_worker_time/execution_count AS [Avg CPU Time],
(SELECT SUBSTRING(text,statement_start_offset/2,(CASE WHEN statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), text)) * 2 ELSE statement_end_offset end -statement_start_offset)/2) FROM sys.dm_exec_sql_text(sql_handle)) AS query_text, *
FROM sys.dm_exec_query_stats
ORDER BY [Avg CPU Time] DESC


����Ĳ�ѯ��ʾһЩ����ռ�ô��� CPU ʹ���ʵ������������ ��%Hash Match%������%Sort%�������ҳ����ɶ���
select *
from
     sys.dm_exec_cached_plans
     cross apply sys.dm_exec_query_plan(plan_handle)
where
     cast(query_plan as nvarchar(max)) like '%Sort%'
     or cast(query_plan as nvarchar(max)) like '%Hash Match%'


��������� DMV ��ѯ�Բ鿴 CPU���ƻ������ڴ�ͻ������Ϣ��
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


�����ʾ����ѯ��ʾ�����±����ǰ 25 ���洢���̡�plan_generation_num ָʾ�ò�ѯ�����±���Ĵ�����
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


����� DMV ��ѯ�����ڲ�����Щ������/�������ɵ� I/O ��ࡣ������ʾ�� DMV ��ѯ�����ڲ��ҿ�������� I/O ��ǰ������󡣵�����Щ��ѯ�����ϵͳ���ܡ�
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
