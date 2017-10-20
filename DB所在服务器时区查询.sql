DECLARE  
@TimeZone NVARCHAR(255)  
EXEC  
master.dbo.xp_instance_regread  
N'HKEY_LOCAL_MACHINE'  
,  
N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation'  
,  
N'TimeZoneKeyName'  
,  
@TimeZone  
OUTPUT  
SELECT  
@TimeZone 