create proc paddComm (
/*  paddComm:�Զ�����COMMENTS
20170310 Created by zhongming.bian
--1.�Զ�����COMMENTS
--2.�������COMMENTS��ص�SQL
--3.�������Ϣ
*/
@Table_name nvarchar(50),@column_name nvarchar(50),@descirbe_name nvarchar(50)
)
as
EXEC sp_addextendedproperty @name=N'MS_Description', @value=@descirbe_name , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=@Table_name, @level2type=N'COLUMN',@level2name=@column_name
select 'EXEC sp_addextendedproperty @name=N''MS_Description'', @value='''+@descirbe_name+''' , @level0type=N''SCHEMA'',@level0name=N''dbo'', @level1type=N''TABLE'',@level1name='''+@Table_name+''', @level2type=N''COLUMN'',@level2name='''+@column_name+'''' AddCommSQL
EXEC ptabinfo @Table_name
;

--Call Demo��
--addComm testbzm,id,����


