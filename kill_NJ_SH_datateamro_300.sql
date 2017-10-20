USE master;
GO
DECLARE @SQL VARCHAR(MAX);
DECLARE @hostname varchar(20),
@proname varchar(200),
@loginame varchar(20),
@dbname varchar(20),
@spid int,
@blocked int,
@i int
set @i=300
while @i>0
begin
SET @SQL=''
 --声明一个游标mycursor，select语句中参数的个数必须要和从游标取出的变量名相同  
declare mycursor cursor for 
with cte as (select replace(hostname,' ','') as hostname ,''''+replace(program_name,' ','')+'''' as program_name 
, loginame, db_name(a.dbid) AS DBname,spid,blocked

from sys.sysprocesses as a with(nolock) 
cross apply sys.dm_exec_sql_text(sql_handle) as b 
where a.blocked>0 and sql_handle<>0x0000000000000000000000000000000000000000 
and waittime>2000 
and (replace(hostname,' ','') like 'NJN%' or replace(hostname,' ','') like 'SH%')
and db_name(a.dbid)='datayesdb'
and loginame='datateam_ro'
) 
select replace(hostname,' ','') as hostname ,''''+replace(program_name,' ','')+'''' as program_name 
, loginame, db_name(a.dbid) AS DBname,spid,blocked

from sys.sysprocesses as a with(nolock) 
cross apply sys.dm_exec_sql_text(sql_handle) as b 
where exists(select blocked from cte where cte.blocked=a.spid) 
and not exists (select spid from cte where cte.spid=a.spid) 
and (replace(hostname,' ','') like 'NJN%' or replace(hostname,' ','') like 'SH%')
and db_name(a.dbid)='datayesdb'
and loginame='datateam_ro'
union all 
select * from cte 
--打开游标  
open mycursor      
--从游标里取出数据赋值到我们刚才声明的2个变量中  
fetch next from mycursor into @hostname,@proname,@loginame,@dbname,@spid,@blocked
while (@@fetch_status=0)  
    begin 

	SET @SQL=''
	SET @SQL=@SQL+'KILL '+ cast(@spid as varchar(10))+';'
	print @SQL
	EXEC(@SQL);
	--waitfor delay '0:0:1' 
--用游标去取下一条记录  -
fetch next from mycursor into @hostname,@proname,@loginame,@dbname,@spid,@blocked

end  
set @i=@i-1
 waitfor delay '0:0:1' 
 --关闭游标  
close mycursor		
--撤销游标  
 DEALLOCATE mycursor
 end
