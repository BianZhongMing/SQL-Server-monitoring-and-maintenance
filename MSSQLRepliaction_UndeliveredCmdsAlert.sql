-- ReplUCmds SQL: 
declare @dbname varchar(200),@publication varchar(200),@srvname	varchar(200);select @dbname='' 
if object_id('tempdb.dbo.#agent') is not null drop table #agent 
if object_id('tempdb.dbo.#his') is not null drop table #his 
if object_id('tempdb.dbo.#max_xact') is not null drop table #max_xact 
if object_id('tempdb.dbo.#last_max_xact') is not null drop table #last_max_xact 
if object_id('tempdb.dbo.#repl') is not null drop table #repl 

SELECT a.id as agent_id,a.publisher_database_id, a.publisher_db, a.publisher_id 
,a.subscriber_id,a.subscriber_db, a.publication 
,b.srvname as publisher,d.srvname as subscriber 
into #agent 
from dbo.MSdistribution_agents a with(nolock)	
inner join master.dbo.sysservers b with(nolock) on a.publisher_id =b.srvid	
inner join master.dbo.sysservers d with(nolock) on a.subscriber_id =d.srvid	
inner join dbo.MSpublications c with(nolock) on a.publisher_db=c.publisher_db 
and a.publication=c.publication 
where a.subscription_type = 0 and c.publication_type=0 
and a.publication = @publication 
and d.srvname =@srvname 

;with cte(agent_id,timestamp) 
as( 
select agent_id, max(timestamp) 
from dbo.MSdistribution_history 
group by agent_id 
) 
select dh.agent_id, dh.timestamp, runstatus, start_time,delivery_rate,xact_seqno as last_xact_seqno 
into #his 
from dbo.MSdistribution_history dh join cte on dh.agent_id=cte.agent_id 
and dh.timestamp=cte.timestamp 

select publisher_database_id ,max(xact_seqno) as max_xact_seqno 
into #max_xact 
from dbo.msrepl_transactions mc with(nolock) 
group by publisher_database_id 

select ah2.*,mx.max_xact_seqno 
into #last_max_xact 
from #agent a 
join #his ah2 on a.agent_id=ah2.agent_id 
join #max_xact mx on a.publisher_database_id=mx.publisher_database_id 

create table #repl(agent_id int,undelivered_transactions int,undelivered_commands int) 

if exists(select * from #last_max_xact where last_xact_seqno<>max_xact_seqno) 
begin 
insert into #repl 
select l.agent_id, count(distinct xact_seqno) as undelivered_transactions,count(*) as undelivered_commands 
from #last_max_xact l 
join dbo.MSsubscriptions s WITH(NOLOCK) 
on s.agent_id = l.agent_id and l.last_xact_seqno<>l.max_xact_seqno 
left join dbo.MSrepl_commands rc WITH (NOLOCK) 
ON (rc.article_id = s.article_id AND rc.publisher_database_id=s.publisher_database_id ) 
where s.status = 2 
and rc.xact_seqno > l.last_xact_seqno 
and rc.xact_seqno <= l.max_xact_seqno 
group by l.agent_id 

if exists (select 1 from #repl where undelivered_commands>=2) 
begin 
select @dbname ,a.publisher	,a.publisher_db	,a.publication	,a.subscriber	,a.subscriber_db	
,case runstatus when 1 then 'Start' when 2 then 'Succeed' when 3 then 'In progress' 
when 4 then 'Idle' when 5 then 'Retry' when 6 then 'Fail' end as runstatus 
,isnull(r.undelivered_transactions,0) as undlv_trans 
,isnull(r.undelivered_commands,0) as undlv_cmds 
,delivery_rate 
,isnull(r.undelivered_commands,0)/(case when delivery_rate is null OR delivery_rate=0 then 1 else 
delivery_rate end) as need_time 
from #agent a 
inner join #repl r on a.agent_id=r.agent_id and r.undelivered_commands>=2 
left join #his h on a.agent_id=h.agent_id 
order by a.publication,a.subscriber 
end 
end 