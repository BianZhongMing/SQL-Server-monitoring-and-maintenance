Use datayesdb 
GO

--Check
select size/1024./1024. "SIZE(GB)" from dbo.sysfiles where name like 'datayesdb_log%' ;--��׼ȷ
--46

ALTER DATABASE datayesdb SET RECOVERY SIMPLE WITH NO_WAIT
ALTER DATABASE datayesdb SET RECOVERY SIMPLE
DBCC SHRINKFILE(N'datayesdb_log' , 0,TRUNCATEONLY)  --δʵ������ԭ���������������ʹ�ã���Ҫkill
--DBCC SHRINKFILE (datayesdb_log, 1);  --����־�ļ�������1M
GO
ALTER DATABASE datayesdb SET RECOVERY FULL WITH NO_WAIT  
ALTER DATABASE datayesdb SET RECOVERY FULL 

--Check
select size/1024./1024. "SIZE(GB)" from dbo.sysfiles where name like 'datayesdb_log%' ;
--44