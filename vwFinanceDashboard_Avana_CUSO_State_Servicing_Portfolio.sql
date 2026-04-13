
CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_CUSO_State_Servicing_Portfolio` AS 
SELECT 'AVANA CUSO LLC' AcctName,
   property_state AS State,
  CAST(FORMAT_DATE('%Y' ,CAST(ReportDate AS DATE)) AS INT64) AS FinYear,
  CAST(FORMAT_DATE('%Y%m' ,CAST(ReportDate AS DATE)) AS INT64) AS FinPeriodID,          
  PARSE_DATE("%Y%m", CAST(CAST(FORMAT_DATE('%Y%m' ,CAST(ReportDate AS DATE)) AS INT64) AS STRING)) AS StartDateUI,
  SUM(SEC_HLDR_CURR_PRIN_BAL) AS Actual_Servicing_Portfolio
FROM  `FICS.Monthly_ALM_Report`  
GROUP BY property_state ,
  CAST(FORMAT_DATE('%Y' ,CAST(ReportDate AS DATE)) AS INT64) ,
  CAST(FORMAT_DATE('%Y%m' ,CAST(ReportDate AS DATE)) AS INT64) ,          
  PARSE_DATE("%Y%m", CAST(CAST(FORMAT_DATE('%Y%m' ,CAST(ReportDate AS DATE)) AS INT64) AS STRING)) 