--Connection SQL: 

with cte 
as 
( 
select client_net_address,login_name 
from Sys.dm_exec_requests r with(nolock) 
right outer join Sys.dm_exec_sessions s with(nolock) 
on r.session_id = s.session_id 
right outer join Sys.dm_exec_connections c with(nolock) 
on s.session_id = c.session_id 
where s.session_id >50 
) , 
cte_login_name 
as 
( 
select login_name,count(1) as login_name_num 
,px=ROW_NUMBER()over(order by count(1) desc ) 
from cte 
group by login_name 
) , 
cte_client_net_address 
as 
( 
select client_net_address,count(1) as client_net_address_num 
,px=ROW_NUMBER()over(order by count(1) desc ) 
from cte 
group by client_net_address 
) 

select 
count(1) as Connetcions 
,(select count(1) from sys.sysprocesses with(nolock) where blocked>0 and sql_handle<>0x0000000000000000000000000000000000000000 ) as Blockeds 
,(select login_name 
from cte_login_name where px=1) as MaxUser 
,(select login_name_num 
from cte_login_name where px=1) as MaxUser_UserConns 
,(select client_net_address 
from cte_client_net_address where px=1) as MaxHost 
,(select client_net_address_num 
from cte_client_net_address where px=1) as MaxHostConns 
,(select login_name 
from cte_login_name where px=2) as SecondUser 
,(select login_name_num 
from cte_login_name where px=2) as SecondUser_UserConns 
,(select client_net_address 
from cte_client_net_address where px=2) as SecondHost 
,(select client_net_address_num 
from cte_client_net_address where px=2) as SecondHostConns 
,(select login_name 
from cte_login_name where px=3) as ThirtyUser 
,(select login_name_num 
from cte_login_name where px=3) as ThirtyUser_UserConns 
,(select client_net_address 
from cte_client_net_address where px=3) as ThirtyHost 
,(select client_net_address_num 
from cte_client_net_address where px=3) as ThirtyHostConns 
,(select SUM(login_name_num) from cte_login_name 
where login_name like '%DBA%' and login_name not in ('dyadmin') ) 
as DBA_UserConns 
from cte 
having count(1)>600 

