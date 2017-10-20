--Edit By bzm 20160602
--exec sp_spaceused 'equ_div' 实现
select a.name 表名,
       a.rows 行数,
       ltrim(str(reservedpages * 8192 / 1024. / 1024., 15, 3) + ' MB') 保留空间,--reserved
       ltrim(str(pages * 8192 / 1024. /1024. , 15, 3) + ' MB') 数据空间,--data
       ltrim(str((usedpages - pages) * 8192 / 1024. /1024. , 15, 3) + ' MB') 索引空间,--index_size
       ltrim(str((reservedpages - usedpages) * 8192 / 1024. /1024. , 15, 3) + ' MB') 未用空间--unused
  from (select p.object_id,
               sum(a.total_pages) reservedpages,
               sum(a.used_pages) usedpages,
               sum(CASE
                   -- XML-Index and FT-Index internal tables are not considered "data", but is part of "index_size"
                     When it.internal_type IN
                          (202, 204, 211, 212, 213, 214, 215, 216) Then
                      0
                     When a.type <> 1 Then
                      a.used_pages
                     When p.index_id < 2 Then
                      a.data_pages
                     Else
                      0
                   END) pages
          from sys.partitions p
          join sys.allocation_units a
            on p.partition_id = a.container_id
          left join sys.internal_tables it
            on p.object_id = it.object_id
         group by p.object_id) c,
       (SELECT a.name, b.rows, a.id --表行数统计
          FROM sysobjects AS a
         INNER JOIN sysindexes AS b
            ON a.id = b.id
         WHERE (a.type = 'u')
           AND (b.indid IN (0, 1))) a
 where a.id = c.object_id
   and reservedpages<>0
   and a.name = 'equ_div'