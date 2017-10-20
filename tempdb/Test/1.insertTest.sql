SELECT  GETDATE()  
go  
  
SELECT  *  
INTO    #Myai  
FROM   ai AS o  
  
-- 创建一个temp table,ai 是一个很大的表这样效果更明显  
-- 这个操作应该会申请user objects page  
go  
  
WAITFOR DELAY '0:0:2'  
  
SELECT  GETDATE()  
go  
  
DROP TABLE #Myai  
-- 删除一个temp table  
-- 这个操作后user object page数量应该会下降  
go  

WAITFOR DELAY '0:0:2'  
  
SELECT  GETDATE()  
go  
 
 set statistics  io on
 set statistics time on
select a.ai from ai a join (
SELECT top 999 o.ai,o.security_id
FROM    ai AS o    
cross JOIN ai_d AS s  
where o.id between 1000000 and 9990000
) as b on (a.security_id>b.security_id/10)
-- 这里做了一个比较大的join.  
-- 应该会有internal objects的申请.  
go  


  
SELECT  GETDATE()  
-- join 语句做完以后internal objects page数目应该下降 