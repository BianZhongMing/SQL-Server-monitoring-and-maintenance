--��SQL��ҵʵ��ɾ�������ļ�

--1. xp_delete_file  
--�ŵ㣺�����Ժ�  
--ȱ�㣺����ɾ��SQL Server֮�ⴴ�����ļ�������RAR  
--��ע��ά���ƻ��еġ�����ά����Ҳ�ǵ��ô� ��չ�洢���� ��ɾ���ļ���  
DECLARE @oldDate DATETIME  
SET @oldDate = GETDATE()-7  --ɾ��7��ǰ����
EXECUTE MASTER.dbo.xp_delete_file   
    0,                            --0: �����ļ���1: ά���ƻ��ı�����  
    N'D:\database_bak\',          --�ļ�·��  
    N'bak',                       --�ļ���չ��  
    @oldDate,                     --�ڴ�ʱ��֮ǰ���ļ�һ��ɾ��  
    1                             --ɾ�����ļ����е��ļ�  
  
--2. xp_cmdshell  
--�ŵ㣺�ǳ�������ɾ���κ����͵��ļ�  
--ȱ�㣺Ҫ��Ȩ�޽ϴ󣬿�������ڰ�ȫ����  
--��ע�����Ƽ��� SQL Server ��ʹ�á�  
DECLARE @directory NVARCHAR(50)     --Ŀ¼  
DECLARE @days NVARCHAR(10)          --����������  
DECLARE @extensions NVARCHAR(MAX)   --��չ��  
DECLARE @scripts NVARCHAR(4000)       
SET @directory=N'd:\database_bak'  
SET @days = N'7'  
SET @extensions = N'bak'  
SET @scripts=N'forfiles /p "'+@directory+'" /s /m *.'+@extensions+' /d -'+@days+' /c "cmd /c del @path"'  
EXEC xp_cmdshell @scripts  
  
--3. PowerShell  
--�ŵ㣺�ǳ�������ɾ���κ����͵��ļ�  
--ȱ�㣺�������� SqlServer2005  
--��ע������ҵ�Ĳ����У����ͱ���ѡ�� "PowerShell"
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