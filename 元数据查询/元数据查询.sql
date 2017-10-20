--------------Ԫ���ݲ�ѯ
--Ŀ¼��ͼ
select 
schema_name(schema_id) as table_schema_name,--��ʽת��
name as table_name from sys.tables

select name as column_name,
TYPE_NAME(system_type_id) as column_type,
max_length,
collation_name,
is_nullable
 from sys.columns
 where object_id=object_id(N'BOND')

 --��Ϣ�ܹ���ͼ
 select * from INFORMATION_SCHEMA.TABLES;
 select * from INFORMATION_SCHEMA.COLUMNS;
 select * from INFORMATION_SCHEMA.VIEWS; --��ͼ��Ϣ
 --��ͼ��ϸ
 SELECT TABLE_CATALOG DB,
       TABLE_SCHEMA SCHEMANAME,
       TABLE_NAME VIEW_NAME,
       object_definition (object_id (TABLE_NAME)) VIEW_DEFINITION
  FROM INFORMATION_SCHEMA.VIEWS;

--ϵͳ�洢���̺ͺ���
exec sys.sp_tables;
exec sys.sp_help @objname=N'dbo.bond' --����Ϣ
exec sys.sp_columns @table_name=N'bond',@table_owner='dbo' --����Ϣ
exec sys.sp_helpconstraint @objname=N'bond' --Լ����Ϣ

--���ݿ�ʵ���汾����
select SERVERPROPERTY('productlevel') --RTM,SP1,SP2

--���ݿ���ض�����
select DATABASEPROPERTYEX(N'master','collation') --Chinese_PRC_CI_AS

--������ض�����
select OBJECTPROPERTY(object_id(N'dbo.bond'),'TableHasPrimaryKey') --�Ƿ��������

--�е��ض�����
select COLUMNPROPERTY(object_id(N'dbo.bond'),N'ID','AllowsNull')


--------------------Ӧ��
--sqlserver �ܹ�dbo�����б�
select * from(
SELECT t.name           TabName,--����
       s.name           SchName, --Schema��
       c.name           ColName,--����
       c.name+','  ColNameOut,
       tp.name          DataType,
       c.is_nullable isnullable,
       c.max_length,
       c.collation_name,
	   (select sc.colid from syscolumns sc where sc.id=c.object_id and c.name=sc.name) colid--��˳��
  FROM sys.tables t, sys.columns c, sys.schemas s, sys.types tp
 WHERE t.schema_id = s.schema_id
   and t.object_id = c.object_id
   and c.system_type_id = tp.system_type_id
   and tp.name<>'sysname' --ϵͳ��nvarchar�ȼ���sysname����
   ) t
   where tabname = 'bond'
   order by colid
   


--�ܹ�dbo��������ͼ
-- select v.[name]  viewname, s.[name]  [schema] from sys.views as v,sys.schemas as s where v.schema_id = s.schema_id
-- and s.[name] = 'dbo' 
-- and v.[name]='vw_fdmt_bs_bank';


--��ѯ���Ψһ��������
select a.table_name,a.CONSTRAINT_NAME,b.column_name,a.constraint_type
from information_schema.table_constraints a --����ϵͳ��Դ�����ܱ�����
inner join information_schema.constraint_column_usage b
on a.constraint_name = b.constraint_name
where-- a.constraint_type = 'UNIQUE'--Ψһ�� 'PRIMARY KEY'--���� 
a.table_name = 'equ_factor_OBOS'


--��ѯ����ϵͳ������Ϣ����ϸ�� ����sp_helpindex �߼�������ϵͳ������
SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--Ϊ����=1������Ϊ0
       i.is_unique_constraint, --ΨһԼ��=1������Ϊ0
	     b.keyno --�еĴ���,0Ϊinclude����
       --i.is_unique,i.data_space_id,i.name,i.ignore_dup_key,i.is_hypothetical,d.colid �����ֶ�λ��
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
   AND c.name = 'testbzm' --��ָ����  
   and c.type <> 's' --S = ϵͳ��
   and b.keyno<>0
--��ע�⡿and (i.is_primary_key=1 or i.is_unique_constraint=1)--������ΨһԼ��������ڽ���SQL�У�����������Ҫ�ֹ��ٴ���
 ORDER BY c.name, a.name, b.keyno asc