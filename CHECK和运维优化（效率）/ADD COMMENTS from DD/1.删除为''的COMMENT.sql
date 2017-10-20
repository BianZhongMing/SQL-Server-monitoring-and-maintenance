--É¾³ýÎª''µÄCOMMENT
select '-----------table' delcommsql
union all
select 'EXEC sp_dropextendedproperty ''MS_Description'',''user'',dbo,''table'','''+tbname+ ''';'  delcommsql
from( 
SELECT distinct d.name  tbname
FROM syscolumns a 
left join systypes b on a.xusertype=b.xusertype 
inner join sysobjects d on a.id=d.id and d.xtype='U' and d.name<>'dtproperties' 
left join syscomments e on a.cdefault=e.id 
left join sys.extended_properties g on a.id=g.major_id and a.colid=g.minor_id and g.name='MS_Description'
left join sys.extended_properties f 
on d.id=f.major_id and f.minor_id=0  and f.name='MS_Description'
where f.value is not null
and f.value=''
) t 
union all
select '-----------Column' delcommsql
union all
SELECT 
'EXEC sp_dropextendedproperty ''MS_Description'',''user'',dbo,''table'','''+d.name+''',''column'','''+a.name+''';' delcommsql
FROM syscolumns a 
left join systypes b on a.xusertype=b.xusertype 
inner join sysobjects d on a.id=d.id and d.xtype='U' and d.name<>'dtproperties' 
left join syscomments e on a.cdefault=e.id 
left join sys.extended_properties g on a.id=g.major_id and a.colid=g.minor_id and g.name='MS_Description'
left join sys.extended_properties f 
on d.id=f.major_id and f.minor_id=0  and f.name='MS_Description'
where g.[value] is not null
and g.[value] =''
