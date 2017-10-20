use datayesdb
go
 
SELECT CONVERT(datetime,SWITCHOFFSET(CONVERT(datetimeoffset, event_time),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS '������˵����ں�ʱ��' ,
--b.connect_time,
        sequence_number AS '������˼�¼�еļ�¼˳��' ,
        action_id AS '������ ID' ,
        succeeded AS '�����¼��Ĳ����Ƿ�ɹ�' ,
        permission_bitmask AS 'Ȩ������' ,
        is_column_permission AS '�Ƿ�Ϊ�м���Ȩ��' ,
        a.session_id AS '�������¼��ĻỰ�� ID' ,
        server_principal_id AS 'ִ�в����ĵ�¼������ ID' ,
        database_principal_id AS 'ִ�в��������ݿ��û������� ID' ,
        target_server_principal_id AS 'ִ�� GRANT/DENY/REVOKE �����ķ���������' ,
        target_database_principal_id AS 'ִ�� GRANT/DENY/REVOKE ���������ݿ�����' ,
        object_id AS '������˵�ʵ��� ID(����������DB,���ݿ���󣬼ܹ�����)' ,
        class_type AS '�����ʵ�������' ,
        session_server_principal_name AS '�Ự�ķ���������' ,
        server_principal_name AS '��ǰ��¼��' ,
        server_principal_sid AS '��ǰ��¼�� SID' ,
        database_principal_name AS '��ǰ�û�' ,
        target_server_principal_name AS '������Ŀ���¼��' ,
        target_server_principal_sid AS 'Ŀ���¼���� SID' ,
        target_database_principal_name AS '������Ŀ���û�' ,
        server_instance_name AS '��˵ķ�����ʵ��������' ,
        database_name AS '�����˲��������ݿ�������' ,
        schema_name AS '�˲����ļܹ�������' ,
        object_name AS '��˵�ʵ�������' ,
        statement AS 'TSQL ��䣨������ڣ�' ,
        additional_information AS '�����¼���Ψһ��Ϣ���� XML ����ʽ����' ,
        file_name AS '��¼��Դ�������־�ļ���·��������' ,
        audit_file_offset AS '������˼�¼���ļ��еĻ�����ƫ����' ,
        user_defined_event_id AS '��Ϊ sp_audit_write �������ݵ��û������¼� ID' ,
        user_defined_information AS '�ڼ�¼�û���Ҫͨ��ʹ�� sp_audit_write �洢���̼�¼�������־�е��κθ�����Ϣ',
		b.CLIENT_NET_ADDRESS AS 'ClientIPAddress' --into MyAudit..Audit_DYDB_UPDL
FROM   sys.[fn_get_audit_file]('D:\SqlAudits\*.sqlaudit',
                                DEFAULT, DEFAULT) a left join SYS.DM_EXEC_CONNECTIONS b
								on a.session_id=b.session_id
where 
CONVERT(datetime,SWITCHOFFSET(CONVERT(datetimeoffset, event_time),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) between dateadd(mi, -10,getdate()) and getdate()
