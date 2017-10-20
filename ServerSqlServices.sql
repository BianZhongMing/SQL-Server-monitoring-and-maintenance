--Sql Service : 
get-wmiobject -Namespace root/MSCluster -class MSCluster_Resource -Credential $psc -ComputerName 10.21.139.74 
|where {($_.type -eq 'SQL Server Availability Group' -and $_.State -ne 2}|select-object Name,Type,State; 