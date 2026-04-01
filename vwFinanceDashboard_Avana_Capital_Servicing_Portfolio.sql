CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_Capital_Servicing_Portfolio` AS 
SELECT 'Avana Capital' as AcctName,
  CAST(FORMAT_DATE('%Y' ,LAST_DAY(AsOfDate)) AS INT64) AS FinYear,
  CAST(FORMAT_DATE('%Y%m' ,LAST_DAY(AsOfDate)) AS INT64) AS FinPeriodID,          
  PARSE_DATE("%Y%m", CAST(CAST(FORMAT_DATE('%Y%m' ,LAST_DAY(AsOfDate)) AS INT64) AS STRING)) AS StartDateUI,
  IFNULL(SUM(ExpAmt),0) AS Actual_Servicing_Portfolio
FROM `TMO.DailyExposures` -- Avana Capital
WHERE  AsOfDate = LAST_DAY(AsOfDate) 
GROUP BY 
  CAST(FORMAT_DATE('%Y' ,LAST_DAY(AsOfDate)) AS INT64) ,
  CAST(FORMAT_DATE('%Y%m' ,LAST_DAY(AsOfDate)) AS INT64) ,          
  PARSE_DATE("%Y%m", CAST(CAST(FORMAT_DATE('%Y%m' ,LAST_DAY(AsOfDate)) AS INT64) AS STRING)) 