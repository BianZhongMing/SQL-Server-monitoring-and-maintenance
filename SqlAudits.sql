use datayesdb
go
 
SELECT CONVERT(datetime,SWITCHOFFSET(CONVERT(datetimeoffset, event_time),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS '触发审核的日期和时间' ,
--b.connect_time,
        sequence_number AS '单个审核记录中的记录顺序' ,
        action_id AS '操作的 ID' ,
        succeeded AS '触发事件的操作是否成功' ,
        permission_bitmask AS '权限掩码' ,
        is_column_permission AS '是否为列级别权限' ,
        a.session_id AS '发生该事件的会话的 ID' ,
        server_principal_id AS '执行操作的登录上下文 ID' ,
        database_principal_id AS '执行操作的数据库用户上下文 ID' ,
        target_server_principal_id AS '执行 GRANT/DENY/REVOKE 操作的服务器主体' ,
        target_database_principal_id AS '执行 GRANT/DENY/REVOKE 操作的数据库主体' ,
        object_id AS '发生审核的实体的 ID(服务器对象，DB,数据库对象，架构对象)' ,
        class_type AS '可审核实体的类型' ,
        session_server_principal_name AS '会话的服务器主体' ,
        server_principal_name AS '当前登录名' ,
        server_principal_sid AS '当前登录名 SID' ,
        database_principal_name AS '当前用户' ,
        target_server_principal_name AS '操作的目标登录名' ,
        target_server_principal_sid AS '目标登录名的 SID' ,
        target_database_principal_name AS '操作的目标用户' ,
        server_instance_name AS '审核的服务器实例的名称' ,
        database_name AS '发生此操作的数据库上下文' ,
        schema_name AS '此操作的架构上下文' ,
        object_name AS '审核的实体的名称' ,
        statement AS 'TSQL 语句（如果存在）' ,
        additional_information AS '单个事件的唯一信息，以 XML 的形式返回' ,
        file_name AS '记录来源的审核日志文件的路径和名称' ,
        audit_file_offset AS '包含审核记录的文件中的缓冲区偏移量' ,
        user_defined_event_id AS '作为 sp_audit_write 参数传递的用户定义事件 ID' ,
        user_defined_information AS '于记录用户想要通过使用 sp_audit_write 存储过程记录在审核日志中的任何附加信息',
		b.CLIENT_NET_ADDRESS AS 'ClientIPAddress' --into MyAudit..Audit_DYDB_UPDL
FROM   sys.[fn_get_audit_file]('D:\SqlAudits\*.sqlaudit',
                                DEFAULT, DEFAULT) a left join SYS.DM_EXEC_CONNECTIONS b
								on a.session_id=b.session_id
where 
CONVERT(datetime,SWITCHOFFSET(CONVERT(datetimeoffset, event_time),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) between dateadd(mi, -10,getdate()) and getdate()
