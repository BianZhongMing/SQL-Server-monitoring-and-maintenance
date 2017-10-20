create view vtabinfo as
select * from(
SELECT t.name           TabName,--����
       s.name           SchName, --Schema��
       c.name           ColName,--����
	     c.name+','  ColNameOut,
       tp.name          DataType,
       c.is_nullable isnullable,
       c.is_identity, --�Ƿ�����
       c.max_length,
       c.collation_name,
	   (select sc.colid from syscolumns sc where sc.id=c.object_id and c.name=sc.name) colid--��˳��
  FROM sys.tables t, sys.columns c, sys.schemas s, sys.types tp
 WHERE t.schema_id = s.schema_id
   and t.object_id = c.object_id
   and c.system_type_id = tp.system_type_id
   and tp.name<>'sysname' --ϵͳ��nvarchar�ȼ���sysname����
   ) t

   