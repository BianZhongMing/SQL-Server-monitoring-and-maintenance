--获取视图SQL sqlserver
with tt as
(
SELECT
 name ViewName, TEXT CreateSQL
FROM
 syscomments s1
JOIN sysobjects s2 ON s1.id = s2.id
WHERE
 name in ('VIEW_NAME'
)
 ),
 t as
(
SELECT
 ViewName, CreateSQL
FROM tt where ViewName in 
(select ViewName from tt group by ViewName having count(ViewName)>1)
 )
--当行的数据不做拼接（拼接会丢失字符）
SELECT ViewName, CreateSQL
FROM tt where ViewName in 
(select ViewName from tt group by ViewName having count(ViewName)=1)
--多行数据拼接
 --check:查找'&'看是否存在非法字符
union all
/* select ViewName,case when createSQL not like '%CREATE view%' then replace(createSQL,'REATE view','CREATE view') 
   else createSQL end createSQL
 from (*/
 select ViewName,replace(replace(replace(replace(CreateSQL,'&#x0D;',''),'#x0D;',''),'&lt;','<'),'&gt;','>') createSQL
 from (
 select ViewName,[CreateSQL]=
 stuff((select ''+CreateSQL from t a where 
        a.ViewName=t.ViewName 
for xml path('')), 1, 1, '')  
 from t
 group by ViewName
 )a
 --)b