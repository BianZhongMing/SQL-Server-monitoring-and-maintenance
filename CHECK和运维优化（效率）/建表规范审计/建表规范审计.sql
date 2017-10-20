/*���������
1.�ֶ�
��1���ֶ�ֻ�������֣���ĸ���»��ߣ��޿ո�==��
��2���ֶ�����ĸ��ͷ
��3���ֶ���ĸ��д
��4���̶��ֶ���ƣ�ID���������ǿգ�������9���̶��ֶΣ�

2.Լ��
��1����������
��2������Ψһ��
*/

with t as (
select t.TabName,t.ColName,t.DataType,t.max_length,t.isnullable,t.is_identity,i.is_primary_key,i.is_unique_constraint
from 
(
SELECT t.name           TabName,--����
       s.name           SchName, --Schema��
       c.name           ColName,--����
       tp.name          DataType,
	   c.max_length,
       c.is_nullable isnullable,
	   c.is_identity --�Ƿ�����
  FROM sys.tables t, sys.columns c, sys.schemas s, sys.types tp
 WHERE t.schema_id = s.schema_id
   and t.object_id = c.object_id
   and c.system_type_id = tp.system_type_id
   and tp.name<>'sysname' --ϵͳ��nvarchar�ȼ���sysname����
) t left join
(
--��ѯ����ϵͳ������Ϣ����ϸ�� ����sp_helpindex �߼�������ϵͳ������
SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--Ϊ����=1������Ϊ0
       i.is_unique_constraint --ΨһԼ��=1������Ϊ0
  FROM sysindexes a
  JOIN sysindexkeys b
    ON a.id = b.id
   AND a.indid = b.indid
  JOIN sysobjects c
    ON b.id = c.id
  JOIN syscolumns d
    ON b.id = d.id
   AND b.colid = d.colid
join sys.indexes i
on i.index_id=a.indid and c.id=i.object_id  --object_id('md_security')
 WHERE a.indid NOT IN (0, 255) --indid = 0 �� 255��Ϊ������Ϊ������
      -- and   c.xtype='U'  /*U = �û���*/ and   c.status>0 --�������û���  
      -- and c.type <> 's' --S = ϵͳ��
   and b.keyno<>0
) i on (t.tabname=i.TableName and t.ColName=i.IndexColumn)
where 
 t.tabname='ExampleTable'
 )

--��1���ֶ�ֻ�������֣���ĸ���»��ߣ��޿ո�==��
--��2���ֶ�����ĸ��ͷ
select '��Error����'+t.tabname+'�����ֶ� ��'+t.ColName+'�� ���ڷǷ��ַ���' results from t 
where t.ColName like '%[^0-9A-Z_]%' or t.ColName like '[^A-Z]%'
UNION ALL
--������Сд���ֶ���Ҫ��д
select distinct '��Error�����չ淶����'+t.tabname+'�����Ƶ���ĸ������ΪСд��ĸ��' results from t 
where t.tabname <>lower(t.tabname) collate Chinese_PRC_CS_AI 
UNION ALL
select '��Error�����չ淶���ֶΡ�'+t.tabname+'.'+t.ColName+'�� ���Ƶ���ĸ������Ϊ��д��ĸ��' results from t 
where t.ColName <>upper(t.ColName) collate Chinese_PRC_CS_AI   
UNION��ALL
 --ID���������ǿգ�����
select case when (
 select count(1) from t where t.ColName='ID' and t.DataType='bigint' and t.isnullable=0 and 
 t.is_identity=1 and t.is_primary_key=1 and t.is_unique_constraint=0 )=1 
 then '�� NOTE�������ǿ�����ID�����ҷ���Ҫ��' else '��Error�������ǿ�����ID�����ڻ򲻷���Ҫ��' end results
UNION ALL
--9���̶��ֶ�
select case when (
select count(1) from t where colname+'~'+datatype+'~'+cast(max_length as varchar(10))+'~'+cast(isnullable as varchar(10))
 in(
'QA_RULE_CHK_FLG~tinyint~1~1',
'CREATE_TIME~datetime~8~0',
'UPDATE_TIME~datetime~8~0',
'QA_MANUAL_FLG~bit~1~1',
'QA_ACTIVE_FLG~bit~1~0',
'ETL_CRC~bigint~8~1',
'CREATE_BY~varchar~50~1',
'UPDATE_BY~varchar~50~1',
'TMSTAMP~timestamp~8~0' )
)=9 then '�� NOTE��9���̶��ֶδ����ҷ���Ҫ��' else '��Error��9���̶��ֶβ�ȫ���ʽ����' end results
UNION ALL
--Լ������
select case when p.ct=0 or u.ct=0 then '��Error��û��������û��ΨһԼ����ҵ����������'
else '�� NOTE�������ֶ�����'+cast(p.ct as varchar(10))+', ΨһԼ���ֶ�����'+cast(u.ct as varchar(10)) end results
 from( 
select count(1) ct from t where t.is_primary_key=1 ) p,
(select count(1) ct from t where t.is_unique_constraint=1) u

