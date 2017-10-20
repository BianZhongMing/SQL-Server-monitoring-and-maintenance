Use datayesdb 
GO

--Check
select size/1024./1024. "SIZE(GB)" from dbo.sysfiles where name like 'datayesdb_log%' ;--不准确
--46

ALTER DATABASE datayesdb SET RECOVERY SIMPLE WITH NO_WAIT
ALTER DATABASE datayesdb SET RECOVERY SIMPLE
DBCC SHRINKFILE(N'datayesdb_log' , 0,TRUNCATEONLY)  --未实际收缩原因可能现在有连接使用，需要kill
--DBCC SHRINKFILE (datayesdb_log, 1);  --将日志文件收缩到1M
GO
ALTER DATABASE datayesdb SET RECOVERY FULL WITH NO_WAIT  
ALTER DATABASE datayesdb SET RECOVERY FULL 

--Check
select size/1024./1024. "SIZE(GB)" from dbo.sysfiles where name like 'datayesdb_log%' ;
--44