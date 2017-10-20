create procedure pcddlsql (
@tabname varchar(50) 
)
as 

set nocount on --优化存储过程
-------------------------------------获取建表DDL
if ( object_id('tempdb.dbo.#t') is not null)
begin
DROP TABLE #t
end

select  'create table [' + so.name + '] (' + o.list + ')' 
    + CASE WHEN tc.Constraint_Name IS NULL THEN '' ELSE 'ALTER TABLE ' + so.Name + ' ADD CONSTRAINT ' + tc.Constraint_Name  + ' PRIMARY KEY ' + ' (' + LEFT(j.List, Len(j.List)-1) + ')' END 
	TABLE_DDL
into #t from    sysobjects so
cross apply
    (SELECT 
        '  ['+column_name+'] ' + 
        data_type + case data_type
            when 'sql_variant' then ''
            when 'text' then ''
            when 'ntext' then ''
            when 'xml' then ''
            when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
            else coalesce('('+case when character_maximum_length = -1 then 'MAX' else cast(character_maximum_length as varchar) end +')','') end + ' ' +
        case when exists ( 
        select id from syscolumns
        where object_name(id)=so.name
        and name=column_name
        and columnproperty(id,name,'IsIdentity') = 1 
        ) then
        'IDENTITY(' + 
        cast(ident_seed(so.name) as varchar) + ',' + 
        cast(ident_incr(so.name) as varchar) + ')'
        else ''
        end + ' ' +
         (case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 'NULL ' + 
          case when information_schema.columns.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT '+ information_schema.columns.COLUMN_DEFAULT ELSE '' END + ', ' 

     from information_schema.columns where table_name = so.name
     order by ordinal_position
    FOR XML PATH('')) o (list)
left join
    information_schema.table_constraints tc
on  tc.Table_name       = so.Name
AND tc.Constraint_Type  = 'PRIMARY KEY'
cross apply
    (select '[' + Column_Name + '], '
     FROM   information_schema.key_column_usage kcu
     WHERE  kcu.Constraint_Name = tc.Constraint_Name
     ORDER BY
        ORDINAL_POSITION
     FOR XML PATH('')) j (list)
where   xtype = 'U'
AND name=@tabname


-------------------------------------获取索引，约束(主键)的DDL
--declare @tabname varchar(50)
--set @tabname='eco_data_all_acmr'--表名

if ( object_id('tempdb.dbo.#IDX') is not null)
begin
DROP TABLE #IDX
DROP TABLE #IDX2
DROP TABLE #IDX3
end

SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--为主键=1，其他为0
       i.is_unique_constraint, --唯一约束=1，其他为0
       i.type_desc, --索引聚集属性
	     b.keyno --列的次序,0为include的列
       into #IDX
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
on i.index_id=a.indid and c.id=i.object_id  
 WHERE a.indid NOT IN (0, 255) --indid = 0 或 255则为表，其他为索引。
      -- and   c.xtype='U'  /*U = 用户表*/ and   c.status>0 --查所有用户表  
   AND c.name = @tabname --查指定表  
   and c.type <> 's' --S = 系统表
 ORDER BY c.name, a.name,b.keyno asc

--索引包含列汇聚
SELECT IndexName,
       TableName,
       is_primary_key,       --为主键=1，其他为0
       is_unique_constraint,    --唯一约束=1，其他为0
       type_desc,
       [IndexColumn] =
          stuff (
             (SELECT ',' + [IndexColumn]
                FROM (select * from #IDX where keyno<>0) n
               WHERE     t.IndexName = n.IndexName
                     AND t.TableName = n.TableName
                     AND t.is_primary_key = n.is_primary_key
                     AND t.is_unique_constraint = n.is_unique_constraint
              FOR XML PATH ( '' )),
             1,
             1,
             '')
			 into #IDX2
  FROM (select * from #IDX where keyno<>0) t
GROUP BY IndexName,
         TableName,
         is_primary_key,
         is_unique_constraint,
         type_desc

--include的列 
 SELECT IndexName,
       TableName,
       is_primary_key,       --为主键=1，其他为0
       is_unique_constraint,    --唯一约束=1，其他为0
       [IndexColumn] =
          stuff (
             (SELECT ',' + [IndexColumn]
                FROM (select * from #IDX where keyno=0) n
               WHERE     t.IndexName = n.IndexName
                     AND t.TableName = n.TableName
                     AND t.is_primary_key = n.is_primary_key
                     AND t.is_unique_constraint = n.is_unique_constraint
              FOR XML PATH ( '' )),
             1,
             1,
             '')
			 into #IDX3
  FROM (select * from #IDX where keyno=0) t
GROUP BY IndexName,
         TableName,
         is_primary_key,
         is_unique_constraint

--UNION 
-----------------TABLE
select replace(Table_Ddl_Sql,'ALTER TABLE','-- ALTER TABLE')  TABLE_DDL
from(
--去掉主键约束
 select 'USE '+db_name() +CHAR(13) +'GO' + CHAR(13) +
 (--区别有主键和没主键
case when (select count(a.constraint_type)
from information_schema.table_constraints a 
inner join information_schema.constraint_column_usage b
on a.constraint_name = b.constraint_name
where a.constraint_type = 'PRIMARY KEY'--主键 
and a.table_name = @tabname)=1 then
replace(table_ddl,', )ALTER TABLE',')'+CHAR(13)+'ALTER TABLE')
else SUBSTRING(table_ddl,1,len(table_ddl)-3)+')' end
 ) Table_Ddl_Sql from #t
) t
union all
-----------------INDEX
 select case 
 when a.is_primary_key=1 then 'ALTER TABLE '+a.tablename+' ADD CONSTRAINT '+a.indexname+' PRIMARY KEY '+(case when a.type_desc='CLUSTERED' then '' else 'NONCLUSTERED' end)+' ('+a.IndexColumn+')'
 when a.is_unique_constraint=1 then 'ALTER TABLE '+a.tablename+' ADD CONSTRAINT '+a.indexname+' UNIQUE '+(case when a.type_desc='CLUSTERED' then 'CLUSTERED' else 'NONCLUSTERED' end)+'('+a.IndexColumn+') WITH(ONLINE=ON,FillFactor=90)'
 else 'create '+(case when a.type_desc='CLUSTERED' then 'CLUSTERED' else 'NONCLUSTERED' end)+' index '+a.indexname+' on '+a.tablename+'('+a.IndexColumn+') '+
 (case when b.IndexColumn is null then '' else 'include('+b.IndexColumn+') ' end)+'WITH(ONLINE=ON,FillFactor=90)' end TABLE_DDL
  from #IDX2 a left join #IDX3 b on a.indexname=b.indexname
 -- where a.is_primary_key=0 --去掉主键
 GO

 