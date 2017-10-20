--dba.GetMaxTMstmp_job

SELECT  [db_name]
      ,[schema_name]
      ,[table_name]
      ,[row_count_diff]
      ,[tmstmp_row_count_diff]
      --,[tmstmp_diff]
      ,[record_time_2]
      ,[record_time_1]
      ,[date_time]
  FROM [DBCenter].[dbo].[viewTMstamp_diff_his] where [date_time]>= convert(varchar(10),dateadd(dd,-1,getdate()),120) and [date_time]<convert(varchar(10),getdate(),120)
  and schema_name<>'cdc' and table_name not in (
  'sys_check_result_0','sys_check_result_1','sys_check_result_2','sys_check_result_3','sys_check_result_4','sys_check_result_5','sys_check_result_6','sys_check_result_7'
  )
  order by abs(([tmstmp_row_count_diff]*1.0)/(case when [row_count_diff]=0 then 1 else [row_count_diff] end)) desc
