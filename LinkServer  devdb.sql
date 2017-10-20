/****** Object: Linked Server [devdb]   Script Date: 2017/6/15 10:57:05 ******/
USE [master]
GO

/****** Object:  LinkedServer [devdb]    Script Date: 2017/6/15 11:21:47 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'devdb', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'10.24.21.100'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'devdb',@useself=N'False',@locallogin=NULL,@rmtuser=N'dba_monitor',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'devdb', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


