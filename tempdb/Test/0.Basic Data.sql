--tempdb test  demo
-------------create db & user
create database userdb;

--������½�ʻ���create login��
create login test with password='abcd123$', default_database=userdb;

use userdb;

--Ϊ��½�˻��������ݿ��û���create user��
create user test for login test with default_schema=dbo;

--ͨ���������ݿ��ɫ���������ݿ��û���db_owner��Ȩ��
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
--(1421765 ����Ӱ��)





