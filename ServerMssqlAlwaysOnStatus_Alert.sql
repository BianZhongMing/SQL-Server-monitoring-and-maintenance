--AGStatus SQL: 
select n.group_name,	
n.replica_server_name,	
n.node_name,	
rs.role_desc, 
CASE WHEN rs.is_local = 1 THEN N'LOCAL' ELSE 'REMOTE' END as is_local,	
DB_NAME(drs.database_id) as 'database_name',	
rs.connected_state_desc,	
CASE WHEN drs.is_suspended=0 THEN 'RESUMED' ELSE 
CASE WHEN drs.suspend_reason_desc='SUSPEND_FROM_USER' THEN '�û��ֶ����������ƶ�'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_PARTNER' THEN '��ǿ�ƹ���ת�ƺ�������ݿ⸱��'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_REDO' THEN '�������׶��г���'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_APPLY' THEN '�ڽ���־д���ļ�ʱ��������Ĵ�����־��'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_CAPTURE' THEN '�ڲ����������ϵ���־ʱ����'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_RESTART' THEN '�������������ݿ�ǰ�������ݿ⸱��������Ĵ�����־��'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_UNDO' THEN '�ڳ����׶��г�������Ĵ�����־��'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_REVALIDATION' THEN '����������ʱ��⵽����־���Ĳ�ƥ�䣨����Ĵ�����־��'	
WHEN drs.suspend_reason_desc='SUSPEND_FROM_XRF_UPDATE' THEN '�Ҳ���������־�㣨����Ĵ�����־��'	
ELSE '' END 
END as is_suspended, --�Ƿ����ݿ����ԭ�� 
drs.synchronization_state_desc,	
drs.synchronization_health_desc,	
ISNULL(drs.log_send_queue_size,0) as log_send_queue_size, --�����ݿ�����δ���͵��������ݿ����־��¼�� (KB)	
ISNULL(drs.redo_queue_size,0) as redo_queue_size, --������������־�ļ�����δ��������־��¼�� (KB)	
CASE WHEN ISNULL(drs.log_send_rate,0)=0 THEN 0 
ELSE CAST(ISNULL(drs.log_send_queue_size,0)*1./ISNULL(drs.log_send_rate,0) AS DECIMAL(18,2))	
END as log_send_need_time, --�����ݿ�����־��¼���������Ҫʱ�䣨�룩	
CASE WHEN ISNULL(drs.redo_rate,0)=0 THEN 0 
ELSE CAST(ISNULL(drs.redo_queue_size,0)*1./ISNULL(drs.redo_rate,0) AS DECIMAL(18,2)) 
END as redo_need_time --������������־��¼���������Ҫʱ�䣨�룩	
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