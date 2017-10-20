/****** Object: Procedure [dbo].[get_idx_tbl_info]   Script Date: 2017/6/16 16:46:23 ******/
USE [datayesdb];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[get_idx_tbl_info] 

AS
BEGIN

exec sp_MSforeachtable 'insert into DBCenter..tmp_index_stats SELECT ''?'',a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N''datayesdb''), 
      OBJECT_ID(N''?''), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b with (nolock)
      ON a.object_id = b.object_id AND a.index_id = b.index_id' 

exec sp_MSforeachtable 'insert into DBCenter..index_stats_his ([tbl_name],[idx_id],[idx_name],[avg_fragmentation_pct]) SELECT ''?'',a.index_id, name, avg_fragmentation_in_percent  
FROM sys.dm_db_index_physical_stats (DB_ID(N''datayesdb''), 
      OBJECT_ID(N''?''), NULL, NULL, NULL) AS a  
    JOIN sys.indexes AS b with (nolock)
      ON a.object_id = b.object_id AND a.index_id = b.index_id' 

insert into  [DBCenter].[dbo].[viewTableSpace] ([table_name],[row_count],[reserved_space],[used_space],[index_space],[unused_space])
exec sp_MSforeachtable "exec sp_spaceused '?'"

insert into  [DBCenter].[dbo].[viewTableSpace_his] ([table_name],[row_count],[reserved_space],[used_space],[index_space],[unused_space])
exec sp_MSforeachtable "exec sp_spaceused '?'"

--select distinct tbl_name,'ALTER INDEX ['+ idx_name +'] ON '+ tbl_name+' REBUILD 'from DBCenter..index_stats_his
--where tbl_name like '%eco_%' and avg_fragmentation_pct >50 and idx_name is not null 
--order by tbl_name

--truncate table DBCenter..tmp_index_stats
--truncate table DBCenter..index_stats_his 
--truncate table [DBCenter].[dbo].[viewTableSpace]
--truncate table [DBCenter].[dbo].[viewTableSpace_his]
END

GO

