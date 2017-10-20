--AGStatus SQL: 
select n.group_name,	
n.replica_server_name,	
n.node_name,	
rs.role_desc, 
CASE WHEN rs.is_local = 1 THEN N'LOCAL' ELSE 'REMOTE' END as is_local,	
DB_NAME(drs.database_id) as 'database_name',	
rs.connected_state_desc,	
CASE WHEN drs.is_suspended=0 THEN 'RESUMED' ELSE 
CASE WHEN drs.suspend_reason_desc='SUSPEND_FROM_USER' THEN '用户手动挂起数据移动'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_PARTNER' THEN '在强制故障转移后挂起数据库副本'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_REDO' THEN '在重做阶段中出错'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_APPLY' THEN '在将日志写入文件时出错（请参阅错误日志）'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_CAPTURE' THEN '在捕获主副本上的日志时出错'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_RESTART' THEN '在重新启动数据库前挂起数据库副本（请参阅错误日志）'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_UNDO' THEN '在撤消阶段中出错（请参阅错误日志）'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_REVALIDATION' THEN '在重新连接时检测到了日志更改不匹配（请参阅错误日志）'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_XRF_UPDATE' THEN '找不到公共日志点（请参阅错误日志）'	
ELSE '' END 
END as is_suspended, --是否数据库挂起及原因 
drs.synchronization_state_desc,	
drs.synchronization_health_desc,	
ISNULL(drs.log_send_queue_size,0) as log_send_queue_size, --主数据库中尚未发送到辅助数据库的日志记录量 (KB)	
ISNULL(drs.redo_queue_size,0) as redo_queue_size, --辅助副本的日志文件中尚未重做的日志记录量 (KB)	
CASE WHEN ISNULL(drs.log_send_rate,0)=0 THEN 0 
ELSE CAST(ISNULL(drs.log_send_queue_size,0)*1./ISNULL(drs.log_send_rate,0) AS DECIMAL(18,2))	
END as log_send_need_time, --主数据库中日志记录发送完成需要时间（秒）	
CASE WHEN ISNULL(drs.redo_rate,0)=0 THEN 0 
ELSE CAST(ISNULL(drs.redo_queue_size,0)*1./ISNULL(drs.redo_rate,0) AS DECIMAL(18,2)) 
END as redo_need_time --辅助副本中日志记录重做完成需要时间（秒）	
from sys.dm_hadr_availability_replica_cluster_nodes n 
join sys.dm_hadr_availability_replica_cluster_states cs 
on n.replica_server_name = cs.replica_server_name 
join sys.dm_hadr_availability_replica_states rs 
on rs.replica_id = cs.replica_id 
join sys.dm_hadr_database_replica_states drs 
on rs.replica_id=drs.replica_id 
where rs.connected_state_desc<>'CONNECTED'	
or drs.synchronization_health_desc<>'HEALTHY'	
or drs.is_suspended<>0	
or CASE WHEN ISNULL(drs.log_send_rate,0)=0 THEN 0 ELSE CAST(ISNULL(drs.log_send_queue_size,0)*1./ISNULL(drs.log_send_rate,0) AS DECIMAL(18,2)) END>100 
or CASE WHEN ISNULL(drs.redo_rate,0)=0 THEN 0 ELSE CAST(ISNULL(drs.redo_queue_size,0)*1./ISNULL(drs.redo_rate,0) AS DECIMAL(18,2)) END>100	