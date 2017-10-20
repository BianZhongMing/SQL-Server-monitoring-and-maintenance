-- SqlMirror: 
SELECT 
x2.name AS DataBaseName 
, CASE x1.mirroring_state WHEN 0 THEN N'�ѹ���' WHEN 1 THEN N'���������Ͽ�' 
WHEN 2 THEN N'����ͬ��' WHEN 3 THEN N'�������ת��' WHEN 4 THEN N'��ͬ��' 
WHEN 5 THEN N'���δͬ��,ǿ�ƹ���ת�ƻᶪʧС��������' WHEN 6 THEN N'�����ͬ��,�ɽ��й���ת��' END AS Mirror_state 
, x1.mirroring_role_desc 
, CASE x1.mirroring_safety_level WHEN 0 THEN N'δ֪״̬' WHEN 1 THEN N'�첽������' WHEN 2 THEN N'ͬ���߰�ȫ' END AS mirroring_safety 
, mirroring_partner_name 
, CASE replace(isnull(mirroring_witness_name, ''),' ','') WHEN '' THEN N'��֤������������' ELSE mirroring_witness_name END AS mirroring_witness_name 
, CASE mirroring_witness_state WHEN 0 THEN CASE WHEN replace(isnull(mirroring_witness_name, ''),' ','') = '' THEN 'No Witness' ELSE N'δ֪' END 
WHEN 1 THEN N'������' WHEN 2 THEN N'�ѶϿ�' END AS mirroring_witness_state 
, cast(mirroring_failover_lsn AS VARCHAR(MAX)) AS mirroring_failover_lsn 

FROM 
sys.database_mirroring AS x1 WITH (NOLOCK) 
INNER JOIN sys.databases AS x2 WITH (NOLOCK) 
ON x1.database_id = x2.database_id 
AND x1.mirroring_role =1 and x1.mirroring_state in (0,1,3); 
