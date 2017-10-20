-- SqlMirror: 
SELECT 
x2.name AS DataBaseName 
, CASE x1.mirroring_state WHEN 0 THEN N'已挂起' WHEN 1 THEN N'与其他伙伴断开' 
WHEN 2 THEN N'正在同步' WHEN 3 THEN N'挂起故障转移' WHEN 4 THEN N'已同步' 
WHEN 5 THEN N'伙伴未同步,强制故障转移会丢失小部分数据' WHEN 6 THEN N'伙伴已同步,可进行故障转移' END AS Mirror_state 
, x1.mirroring_role_desc 
, CASE x1.mirroring_safety_level WHEN 0 THEN N'未知状态' WHEN 1 THEN N'异步高性能' WHEN 2 THEN N'同步高安全' END AS mirroring_safety 
, mirroring_partner_name 
, CASE replace(isnull(mirroring_witness_name, ''),' ','') WHEN '' THEN N'见证服务器不存在' ELSE mirroring_witness_name END AS mirroring_witness_name 
, CASE mirroring_witness_state WHEN 0 THEN CASE WHEN replace(isnull(mirroring_witness_name, ''),' ','') = '' THEN 'No Witness' ELSE N'未知' END 
WHEN 1 THEN N'已连接' WHEN 2 THEN N'已断开' END AS mirroring_witness_state 
, cast(mirroring_failover_lsn AS VARCHAR(MAX)) AS mirroring_failover_lsn 

FROM 
sys.database_mirroring AS x1 WITH (NOLOCK) 
INNER JOIN sys.databases AS x2 WITH (NOLOCK) 
ON x1.database_id = x2.database_id 
AND x1.mirroring_role =1 and x1.mirroring_state in (0,1,3); 
