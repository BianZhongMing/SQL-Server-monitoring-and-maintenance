declare @dbName nvarchar(MAX)='InsideTSQL2008';

SELECT 'KILL '+CAST(spid as Varchar(10))  FROM master..sysprocesses    
WHERE dbid=DB_ID(@dbName)  