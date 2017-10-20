--用SQL作业实现删除过期文件

--1. xp_delete_file  
--优点：兼容性好  
--缺点：不能删除SQL Server之外创建的文件，包括RAR  
--备注：维护计划中的“清理维护”也是调用此 扩展存储过程 来删除文件。  
DECLARE @oldDate DATETIME  
SET @oldDate = GETDATE()-7  --删除7天前数据
EXECUTE MASTER.dbo.xp_delete_file   
    0,                            --0: 备份文件，1: 维护计划文本报告  
    N'D:\database_bak\',          --文件路径  
    N'bak',                       --文件扩展名  
    @oldDate,                     --在此时间之前的文件一律删除  
    1                             --删除子文件夹中的文件  
  
--2. xp_cmdshell  
--优点：非常灵活，可以删除任何类型的文件  
--缺点：要求权限较大，开启后存在安全隐患  
--备注：不推荐在 SQL Server 中使用。  
DECLARE @directory NVARCHAR(50)     --目录  
DECLARE @days NVARCHAR(10)          --保留多少天  
DECLARE @extensions NVARCHAR(MAX)   --扩展名  
DECLARE @scripts NVARCHAR(4000)       
SET @directory=N'd:\database_bak'  
SET @days = N'7'  
SET @extensions = N'bak'  
SET @scripts=N'forfiles /p "'+@directory+'" /s /m *.'+@extensions+' /d -'+@days+' /c "cmd /c del @path"'  
EXEC xp_cmdshell @scripts  
  
--3. PowerShell  
--优点：非常灵活，可以删除任何类型的文件  
--缺点：不适用于 SqlServer2005  
--备注：在作业的步骤中，类型必须选择 "PowerShell"
----------------------
$timeOutDay = 7  
$filePath = "d:\database_bak"  
$allFile = Get-ChildItem -Path $filePath  
  
foreach($file in $allFile)  
{  
    $daySpan = ((Get-Date) - $file.LastWriteTime).Days  
    if ($daySpan -gt $timeOutDay)  
    {  
        Remove-Item $file.FullName -Recurse -Force  
    }  
}  
----------------------