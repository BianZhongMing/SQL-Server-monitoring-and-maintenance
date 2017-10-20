/*表审计内容
1.字段
（1）字段只包含数字，字母，下划线（无空格==）
（2）字段以字母开头
（3）字段字母大写
（4）固定字段审计（ID，自增，非空，主键；9个固定字段）

2.约束
（1）存在主键
（2）存在唯一键
*/

with t as (
select t.TabName,t.ColName,t.DataType,t.max_length,t.isnullable,t.is_identity,i.is_primary_key,i.is_unique_constraint
from 
(
SELECT t.name           TabName,--表名
       s.name           SchName, --Schema名
       c.name           ColName,--列名
       tp.name          DataType,
	   c.max_length,
       c.is_nullable isnullable,
	   c.is_identity --是否自增
  FROM sys.tables t, sys.columns c, sys.schemas s, sys.types tp
 WHERE t.schema_id = s.schema_id
   and t.object_id = c.object_id
   and c.system_type_id = tp.system_type_id
   and tp.name<>'sysname' --系统中nvarchar等价于sysname类型
) t left join
(
--查询所有系统索引信息（明细） 利用sp_helpindex 逻辑，避免系统表死锁
SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--为主键=1，其他为0
       i.is_unique_constraint --唯一约束=1，其他为0
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
      -- and c.type <> 's' --S = 系统表
   and b.keyno<>0
) i on (t.tabname=i.TableName and t.ColName=i.IndexColumn)
where 
 t.tabname='ExampleTable'
 )

--（1）字段只包含数字，字母，下划线（无空格==）
--（2）字段以字母开头
select '【Error】表“'+t.tabname+'”的字段 “'+t.ColName+'” 存在非法字符！' results from t 
where t.ColName like '%[^0-9A-Z_]%' or t.ColName like '[^A-Z]%'
UNION ALL
--表名是小写，字段名要大写
select distinct '【Error】按照规范，表“'+t.tabname+'”名称的字母部分需为小写字母！' results from t 
where t.tabname <>lower(t.tabname) collate Chinese_PRC_CS_AI 
UNION ALL
select '【Error】按照规范，字段“'+t.tabname+'.'+t.ColName+'” 名称的字母部分需为大写字母！' results from t 
where t.ColName <>upper(t.ColName) collate Chinese_PRC_CS_AI   
UNION　ALL
 --ID，自增，非空，主键
select case when (
 select count(1) from t where t.ColName='ID' and t.DataType='bigint' and t.isnullable=0 and 
 t.is_identity=1 and t.is_primary_key=1 and t.is_unique_constraint=0 )=1 
 then '● NOTE：自增非空主键ID存在且符合要求' else '【Error】自增非空主键ID不存在或不符合要求' end results
UNION ALL
--9个固定字段
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
)=9 then '● NOTE：9个固定字段存在且符合要求' else '【Error】9个固定字段不全或格式有误！' end results
UNION ALL
--约束检验
select case when p.ct=0 or u.ct=0 then '【Error】没有主键或没有唯一约束（业务主键）！'
else '● NOTE：主键字段数：'+cast(p.ct as varchar(10))+', 唯一约束字段数：'+cast(u.ct as varchar(10)) end results
 from( 
select count(1) ct from t where t.is_primary_key=1 ) p,
(select count(1) ct from t where t.is_unique_constraint=1) u

