--����Լ��
SELECT
  tab.name AS [����],
  idx.name AS [��������],
  col.name AS [��������]
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

--ΨһԼ��
SELECT
  tab.name AS [����],
  idx.name AS [Լ������],
  col.name AS [Լ������]
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

--���Լ��
select 
  oSub.name  AS  [�ӱ�����],
  fk.name AS  [�������],
  SubCol.name AS [�ӱ�����],
  oMain.name  AS  [��������],
  MainCol.name AS [��������]
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

--CheckԼ��
SELECT
  tab.name AS [����],
  chk.name AS [CheckԼ����],
  col.name AS [����],
  chk.definition
FROM
  sys.check_constraints chk
    JOIN sys.tables tab
      ON (chk.parent_object_id = tab.object_id)
    JOIN sys.columns col
      ON (chk.parent_object_id = col.object_id
          AND chk.parent_column_id = col.column_id)
where tab.name='bond'


--Ĭ��ֵ
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

6����ȡ��ʶ�е�����ֵ

��ʹ�ú���IDENT_SEED,�÷���
SELECT IDENT_SEED ('����')

7����ȡ��ʶ�еĵ�����

��ʹ�ú���IDENT_INCR ,�÷���
SELECT IDENT_INCR('����')