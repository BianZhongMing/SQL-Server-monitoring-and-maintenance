--主键约束
SELECT
  tab.name AS [表名],
  idx.name AS [主键名称],
  col.name AS [主键列名]
FROM
  sys.indexes idx
    JOIN sys.index_columns idxCol 
      ON (idx.object_id = idxCol.object_id 
          AND idx.index_id = idxCol.index_id 
          AND idx.is_primary_key = 1)
    JOIN sys.tables tab
      ON (idx.object_id = tab.object_id)
    JOIN sys.columns col
      ON (idx.object_id = col.object_id
          AND idxCol.column_id = col.column_id)
where tab.name='bond'		  ;

--唯一约束
SELECT
  tab.name AS [表名],
  idx.name AS [约束名称],
  col.name AS [约束列名]
FROM
  sys.indexes idx
    JOIN sys.index_columns idxCol 
      ON (idx.object_id = idxCol.object_id 
          AND idx.index_id = idxCol.index_id 
          AND idx.is_unique_constraint = 1)
    JOIN sys.tables tab
      ON (idx.object_id = tab.object_id)
    JOIN sys.columns col
      ON (idx.object_id = col.object_id
          AND idxCol.column_id = col.column_id)
where tab.name='bond';

--外键约束
select 
  oSub.name  AS  [子表名称],
  fk.name AS  [外键名称],
  SubCol.name AS [子表列名],
  oMain.name  AS  [主表名称],
  MainCol.name AS [主表列名]
from 
  sys.foreign_keys fk  
    JOIN sys.all_objects oSub  
        ON (fk.parent_object_id = oSub.object_id)
    JOIN sys.all_objects oMain 
        ON (fk.referenced_object_id = oMain.object_id)
    JOIN sys.foreign_key_columns fkCols 
        ON (fk.object_id = fkCols.constraint_object_id)
    JOIN sys.columns SubCol 
        ON (oSub.object_id = SubCol.object_id  
            AND fkCols.parent_column_id = SubCol.column_id)
    JOIN sys.columns MainCol 
        ON (oMain.object_id = MainCol.object_id  
            AND fkCols.referenced_column_id = MainCol.column_id)

--Check约束
SELECT
  tab.name AS [表名],
  chk.name AS [Check约束名],
  col.name AS [列名],
  chk.definition
FROM
  sys.check_constraints chk
    JOIN sys.tables tab
      ON (chk.parent_object_id = tab.object_id)
    JOIN sys.columns col
      ON (chk.parent_object_id = col.object_id
          AND chk.parent_column_id = col.column_id)
where tab.name='bond'


--默认值
SELECT
  SO.NAME tablename, SM.TEXT  DEFAULTValues, SC.NAME 
FROM
  dbo.sysobjects SO
  INNER JOIN dbo.syscolumns SC ON SO.id = SC.id
  LEFT JOIN dbo.syscomments SM ON SC.cdefault = SM.id
WHERE
  SO.xtype = 'U' AND
  SM.TEXT IS NOT NULL
and SO.NAME ='bond'


SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.columns
   WHERE TABLE_NAME='bond' AND  COLUMNPROPERTY(      
      OBJECT_ID('bond'),COLUMN_NAME,'IsIdentity')=1

6、获取标识列的种子值

可使用函数IDENT_SEED,用法：
SELECT IDENT_SEED ('表名')

7、获取标识列的递增量

可使用函数IDENT_INCR ,用法：
SELECT IDENT_INCR('表名')