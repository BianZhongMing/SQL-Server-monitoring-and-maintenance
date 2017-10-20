--ADD COMMENTS from DD
use datayesdb
go

select '----------------------------------------------create table comments' addCommentsSQL
union all
SELECT isnull('exec sp_addextendedproperty N''MS_Description'', N'''+b.NAME_CN+''', N''user'', N''dbo'', N''table'', N'''+b.NAME_EN +''', NULL, NULL;','') addCommentsSQL
FROM
	[datayesdb].[dbo].[sys_table] b
WHERE b.NAME_EN not in
(--已经存在comments的表
SELECT
A.name
FROM sys.tables A
JOIN sys.extended_properties C ON C.major_id = A.object_id  and minor_id=0 and c.name='MS_Description'
WHERE isnull(C.value,'') <> '' --存在comments
)
and b.NAME_EN in(/*数据库实际存在表*/select tabname from vtabinfo group by tabname)

union all
select '----------------------------------------------create column comments' addCommentsSQL
union all

SELECT
isnull('EXEC sys.sp_addextendedproperty @name=N''MS_Description'', @value=N'''+a.NAME_CN+''' , @level0type=N''SCHEMA'',@level0name=N''dbo'', @level1type=N''TABLE'',@level1name=N'''+b.NAME_EN+
''', @level2type=N''COLUMN'',@level2name=N'''+a.SHORT_NAME_EN+''';' ,'') addCommentsSQL
FROM
	[datayesdb].[dbo].[sys_column] a,
	[datayesdb].[dbo].[sys_table] b 
WHERE
	a.TABLE_ID = b.TABLE_ID
--AND b.NAME_en = 'md_sec_id_map'
and b.NAME_EN in(/*数据库实际存在表*/select tabname from vtabinfo group by tabname)
and b.NAME_EN+'.'+a.SHORT_NAME_EN not in (
--已经存在comments的字段
SELECT d.name+'.'+ a.name tabname_colname
FROM syscolumns a 
left join systypes b on a.xusertype=b.xusertype 
inner join sysobjects d on a.id=d.id and d.xtype='U' and d.name<>'dtproperties' 
left join syscomments e on a.cdefault=e.id 
left join sys.extended_properties g on a.id=g.major_id and a.colid=g.minor_id and g.name='MS_Description'
left join sys.extended_properties f 
on d.id=f.major_id and f.minor_id=0  and f.name='MS_Description'
where 
isnull(g.[value],'')<> ''--存在comments
--and d.name='bond' --如果只查询指定表,加上此条件,表名 
)


