--tempdb test  demo
-------------create db & user
create database userdb;

--创建登陆帐户（create login）
create login test with password='abcd123$', default_database=userdb;

use userdb;

--为登陆账户创建数据库用户（create user）
create user test for login test with default_schema=dbo;

--通过加入数据库角色，赋予数据库用户“db_owner”权限
exec sp_addrolemember 'db_owner', 'test';

---------sync data
select ID,
SECURITY_ID,
DATA_DATE,
AI,
AI_PAR
from bond_ai where id<=10000000
-->ai

SELECT  *  
INTO    ai_d  
FROM   ai 
where id >1000000 and id%2=0
--(1421765 行受影响)





