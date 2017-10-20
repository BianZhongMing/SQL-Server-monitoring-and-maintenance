use tempdb
GO

CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO


DBCC FREEPROCCACHE;
GO


DBCC FREESYSTEMCACHE ('ALL');
GO


DBCC FREESESSIONCACHE;
GO

DBCC SHRINKFILE (TEMPDEV, 128);   --- New file size in MB
GO
DBCC SHRINKFILE (TEMPDEV2, 128);   --- New file size in MB
GO
DBCC SHRINKFILE (TEMPDEV3, 128);   --- New file size in MB
GO
DBCC SHRINKFILE (TEMPDEV4, 128);   --- New file size in MB
GO
DBCC SHRINKFILE (templog, 128);   --- New file size in MB
GO

--Check
select * from tempdb.dbo.sysfiles where name like 'tempdev%' 