��һ������ sp_who2 ������ݻ�ԭ��sid�����ڴ����е����������п���



 

�ڶ����������²�ѯ�������������� percent_complete�У�
SELECT 
session_id, request_id, start_time, status, command
, percent_complete, estimated_completion_time,wait_time,  cpu_time, total_elapsed_time, scheduler_id
,sql_handle
--,statement_start_offset, statement_end_offset, plan_handle
, database_id, user_id --,connection_id
, blocking_session_id
, wait_type, last_wait_type, wait_resource, open_transaction_count, open_resultset_count, transaction_id
--, context_info
--, task_address
, reads, writes, logical_reads
--, text_size, language, date_format, date_first, quoted_identifier, arithabort, ansi_null_dflt_on, ansi_defaults, ansi_warnings, ansi_padding, ansi_nulls, concat_null_yields_null, transaction_isolation_level, lock_timeout, deadlock_priority, row_count, prev_error, nest_level, granted_query_memory, executing_managed_code, group_id, query_hash, query_plan_hash
 FROM sys.dm_exec_requests WHERE session_id=63
or session_id=63