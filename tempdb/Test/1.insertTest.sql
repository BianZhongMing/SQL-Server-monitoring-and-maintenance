SELECT  GETDATE()  
go  
  
SELECT  *  
INTO    #Myai  
FROM   ai AS o  
  
-- ����һ��temp table,ai ��һ���ܴ�ı�����Ч��������  
-- �������Ӧ�û�����user objects page  
go  
  
WAITFOR DELAY '0:0:2'  
  
SELECT  GETDATE()  
go  
  
DROP TABLE #Myai  
-- ɾ��һ��temp table  
-- ���������user object page����Ӧ�û��½�  
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
-- ��������һ���Ƚϴ��join.  
-- Ӧ�û���internal objects������.  
go  


  
SELECT  GETDATE()  
-- join ��������Ժ�internal objects page��ĿӦ���½� 