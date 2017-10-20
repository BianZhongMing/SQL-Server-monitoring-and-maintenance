create procedure pcddlsql (
@tabname varchar(50) 
)
as 

set nocount on --�Ż��洢����
-------------------------------------��ȡ����DDL
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


-------------------------------------��ȡ������Լ��(����)��DDL
--declare @tabname varchar(50)
--set @tabname='eco_data_all_acmr'--����

if ( object_id('tempdb.dbo.#IDX') is not null)
begin
DROP TABLE #IDX
DROP TABLE #IDX2
DROP TABLE #IDX3
end

SELECT a.name  IndexName,
       c.name  TableName,
       d.name  IndexColumn,
       i.is_primary_key,--Ϊ����=1������Ϊ0
       i.is_unique_constraint, --ΨһԼ��=1������Ϊ0
       i.type_desc, --�����ۼ�����
	     b.keyno --�еĴ���,0Ϊinclude����
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
 WHERE a.indid NOT IN (0, 255) --indid = 0 �� 255��Ϊ������Ϊ������
      -- and   c.xtype='U'  /*U = �û���*/ and   c.status>0 --�������û���  
   AND c.name = @tabname --��ָ����  
   and c.type <> 's' --S = ϵͳ��
 ORDER BY c.name, a.name,b.keyno asc

--���������л��
SELECT IndexName,
       TableName,
       is_primary_key,       --Ϊ����=1������Ϊ0
       is_unique_constraint,    --ΨһԼ��=1������Ϊ0
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

--include���� 
 SELECT IndexName,
       TableName,
       is_primary_key,       --Ϊ����=1������Ϊ0
       is_unique_constraint,    --ΨһԼ��=1������Ϊ0
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
--ȥ������Լ��
 select 'USE '+db_name() +CHAR(13) +'GO' + CHAR(13) +
 (--������������û����
case when (select count(a.constraint_type)
from information_schema.table_constraints a 
inner join information_schema.constraint_column_usage b
on a.constraint_name = b.constraint_name
where a.constraint_type = 'PRIMARY KEY'--���� 
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
 -- where a.is_primary_key=0 --ȥ������
 GO

 