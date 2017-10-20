--Lock Object
select   request_session_id  spid,OBJECT_NAME(resource_associated_entity_id) tableName 
from   sys.dm_tran_locks with(nolock) where resource_type='OBJECT'
and OBJECT_NAME(resource_associated_entity_id)='mkt_hkequd'

