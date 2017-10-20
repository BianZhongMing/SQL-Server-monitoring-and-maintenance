USE tempdb  
go                                                               
  
-- ÿ��1��������һ�Σ�ֱ���û��ֹ���ֹ�ű�����  
  
WHILE 1 = 1   
BEGIN                                                                     
  
-- Query 1  
-- ���ļ�����tempdbʹ�����  ��MB��
DBCC showfilestats                                              
--extent��һ��extentΪ64k��totalexents*64/1024 �����mb��/16��
DBCC SHRINKFILE (TEMPDEV, 128); --����


  
-- Query 2  
-- �������������ռ������session��Ϣ ���û������ڲ������Լ��汾�洢�� 
SELECT  'tempdb' AS database_name , GETDATE() AS Time , SUM(user_object_reserved_page_count)/128. AS user_objects_mb ,  
        SUM(internal_object_reserved_page_count)/128. AS internal_objects_mb , SUM(version_store_reserved_page_count)/128. AS version_store_kb ,  
        SUM(unallocated_extent_page_count)/128. AS freespace_mb  
FROM    sys.dm_db_file_space_usage  
WHERE   database_id = 2                                                      
  
-- Query 3  
-- ���������ͼ�ܹ���ӳ��ʱtempdb�ռ���������  
SELECT  t1.session_id , t1.internal_objects_alloc_page_count , t1.user_objects_alloc_page_count , t1.internal_objects_dealloc_page_count ,  
        t1.user_objects_dealloc_page_count , t3.login_time , t3.login_name , t3.host_name , t3.nt_domain , t3.nt_user_name , t3.program_name ,  
        t3.status , t3.client_interface_name , t3.cpu_time , t3.memory_usage , t3.total_scheduled_time , t3.total_elapsed_time ,  
        t3.last_request_start_time , t3.last_request_end_time , t3.reads , t3.writes , t3.logical_reads , t3.is_user_process , t3.row_count ,  
        t3.prev_error , t3.original_security_id , t3.original_login_name , t3.last_successful_logon , t3.last_unsuccessful_logon ,  
        t3.unsuccessful_logons , t3.group_id  
FROM    sys.dm_db_session_space_usage t1 ,                                 
-- ��ӳÿ��session�ۼƿռ�����  
        sys.dm_exec_sessions AS t3  
-- ÿ��session����Ϣ  
WHERE   t1.session_id = t3.session_id  
        AND (  
             t1.internal_objects_alloc_page_count > 0  
             OR t1.user_objects_alloc_page_count > 0  
             OR t1.internal_objects_dealloc_page_count > 0  
             OR t1.user_objects_dealloc_page_count > 0  
            )  
  
-- Query 4  
-- �����������в��������ռ������session�������е����  
SELECT  t1.session_id , st.text , GETDATE()  
FROM    sys.dm_db_session_space_usage AS t1 ,  
        sys.dm_exec_requests AS t4  
CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) AS st  
WHERE   t1.session_id = t4.session_id  
        AND t1.session_id > 50  
        AND (  
             t1.internal_objects_alloc_page_count > 0  
             OR t1.user_objects_alloc_page_count > 0  
             OR t1.internal_objects_dealloc_page_count > 0  
             OR t1.user_objects_dealloc_page_count > 0  
            )   
-- Query 5  
-- �����������еĻ�Ŀռ�ʹ������Լ�������ݺ�ִ�мƻ�   
;WITH task_space_usage AS (  
    -- SUM alloc/delloc pages  
    SELECT session_id,  
           request_id,  
           SUM(internal_objects_alloc_page_count) AS alloc_pages,  
           SUM(internal_objects_dealloc_page_count) AS dealloc_pages  
    FROM sys.dm_db_task_space_usage WITH (NOLOCK)  
    WHERE session_id <> @@SPID  
    GROUP BY session_id, request_id  
)  
SELECT TSU.session_id,  
       TSU.alloc_pages * 1.0 / 128 AS [internal object MB space],  
       TSU.dealloc_pages * 1.0 / 128 AS [internal object dealloc MB space],  
       EST.text,  
       -- Extract statement from sql text  
       ISNULL(  
           NULLIF(  
               SUBSTRING(  
                   EST.text,   
                   ERQ.statement_start_offset / 2,   
                   CASE WHEN ERQ.statement_end_offset < ERQ.statement_start_offset THEN 0 ELSE( ERQ.statement_end_offset - ERQ.statement_start_offset ) / 2 END  
               ), ''  
           ), EST.text  
       ) AS [statement text],  
       EQP.query_plan  
FROM task_space_usage AS TSU  
INNER JOIN sys.dm_exec_requests ERQ WITH (NOLOCK)  
    ON  TSU.session_id = ERQ.session_id  
    AND TSU.request_id = ERQ.request_id  
OUTER APPLY sys.dm_exec_sql_text(ERQ.sql_handle) AS EST  
OUTER APPLY sys.dm_exec_query_plan(ERQ.plan_handle) AS EQP  
WHERE EST.text IS NOT NULL OR EQP.query_plan IS NOT NULL  
ORDER BY 3 DESC, 5 DESC  
  
  
WAITFOR DELAY '0:0:1'                                                      
END       