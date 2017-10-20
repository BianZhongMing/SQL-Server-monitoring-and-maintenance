--------------元数据查询
--目录视图
select 
schema_name(schema_id) as table_schema_name,--格式转换
name as table_name from sys.tables

select name as column_name,
TYPE_NAME(system_type_id) as column_type,
max_length,
collation_name,
is_nullable
 from sys.columns
 where object_id=object_id(N'BOND')

 --信息架构视图
 select * from INFORMATION_SCHEMA.TABLES;
 select * from INFORMATION_SCHEMA.COLUMNS;
 select * from INFORMATION_SCHEMA.VIEWS; --视图信息
 --视图明细
 SELECT TABLE_CATALOG DB,
       TABLE_SCHEMA SCHEMANAME,
       TABLE_NAME VIEW_NAME,
       object_definition (object_id (TABLE_NAME)) VIEW_DEFINITION
  FROM INFORMATION_SCHEMA.VIEWS;

--系统存储过程和函数
exec sys.sp_tables;
exec sys.sp_help @objname=N'dbo.bond' --表信息
exec sys.sp_columns @table_name=N'bond',@table_owner='dbo' --列信息
exec sys.sp_helpconstraint @objname=N'bond' --约束信息

--数据库实例版本级别
select SERVERPROPERTY('productlevel') --RTM,SP1,SP2

--数据库的特定属性
select DATABASEPROPERTYEX(N'master','collation') --Chinese_PRC_CI_AS

--对象的特定属性
select OBJECTPROPERTY(object_id(N'dbo.bond'),'TableHasPrimaryKey') --是否存在主键

--列的特定属性
select COLUMNPROPERTY(object_id(N'dbo.bond'),N'ID','AllowsNull')


--------------------应用
--sqlserver 架构dbo的所有表
select * from(
SELECT t.name           TabName,--表名
       s.name           SchName, --Schema名
       c.name           ColName,--列名
       c.name+','  ColNameOut,
       tp.name          DataType,
       c.is_nullable isnullable,
       c.max_length,
       c.collation_name,
	   (select sc.colid from syscolumns sc where sc.id=c.object_id and c.name=sc.name) colid--列顺序
  FROM sys.tables t, sys.columns c, sys.schemas s, sys.types tp
 WHERE t.schema_id = s.schema_id
   and t.object_id = c.object_id
   and c.system_type_id = tp.system_type_id
   and tp.name<>'sysname' --系统中nvarchar等价于sysname类型
   ) t
   where tabname = 'bond'
   order by colid
   


--架构dbo的所有视图
-- select v.[name]  viewname, s.[name]  [schema] from sys.views as v,sys.schemas as s where v.schema_id = s.schema_id
-- and s.[name] = 'dbo' 
-- and v.[name]='vw_fdmt_bs_bank';


--查询表的唯一键和主键
select a.table_name,a.CONSTRAINT_NAME,b.column_name,a.constraint_type
from information_schema.table_constraints a --会用系统资源，可能被堵塞
inner join information_schema.constraint_column_usage b
on a.constraint_name = b.constraint_name
where-- a.constraint_type = 'UNIQUE'--唯一键 'PRIMARY KEY'--主键 
a.table_name = 'equ_factor_OBOS'


--查询所有系统索引信息（明细） 利用sp_helpindex 逻辑，避免系统表死锁
SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--为主键=1，其他为0
       i.is_unique_constraint, --唯一约束=1，其他为0
	     b.keyno --列的次序,0为include的列
       --i.is_unique,i.data_space_id,i.name,i.ignore_dup_key,i.is_hypothetical,d.colid 索引字段位置
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
 WHERE a.indid NOT IN (0, 255) --indid = 0 或 255则为表，其他为索引。
      -- and   c.xtype='U'  /*U = 用户表*/ and   c.status>0 --查所有用户表  
   AND c.name = 'testbzm' --查指定表  
   and c.type <> 's' --S = 系统表
   and b.keyno<>0
--【注意】and (i.is_primary_key=1 or i.is_unique_constraint=1)--主键和唯一约束会出现在建表SQL中，其他索引需要手工再创建
 ORDER BY c.name, a.name, b.keyno asc