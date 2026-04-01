CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Servicing_Portfolio` AS 
WITH cur_period AS (
    SELECT  AcctName,
            FinYear,
            FinPeriodID,
            StartDateUI,
            0 AS Budget_Servicing_Portfolio,
            ROUND(SUM(Actual_Servicing_Portfolio),2) AS Actual_Servicing_Portfolio
    FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_Capital_Servicing_Portfolio`
    GROUP BY AcctName,
            FinYear,
            FinPeriodID,
            StartDateUI
    UNION ALL 
    SELECT  AcctName,
            FinYear,
            FinPeriodID,
            StartDateUI,
            0 AS Budget_Servicing_Portfolio,
            ROUND(SUM(Actual_Servicing_Portfolio),2) AS Actual_Servicing_Portfolio
    FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_CUSO_Servicing_Portfolio`
    GROUP BY AcctName,
            FinYear,
            FinPeriodID,
            StartDateUI      
),
-- prev year
prev_period AS (
SELECT AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(CAST(FinPeriodID AS INT64) + 100 AS STRING))) AS FinYear
    ,CAST(FinPeriodID AS INT64) + 100 AS FinPeriodID
    ,PARSE_DATE("%Y%m", CAST(CAST(FinPeriodID AS INT64) + 100 AS STRING)) AS StartDateUI
    ,SUM(Actual_Servicing_Portfolio) AS Prev_Actual_Servicing_Portfolio
FROM cur_period
GROUP BY AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(CAST(FinPeriodID AS INT64) + 100 AS STRING))) 
    ,CAST(FinPeriodID AS INT64) + 100 
    ,PARSE_DATE("%Y%m", CAST(CAST(FinPeriodID AS INT64) + 100 AS STRING))
)
SELECT coalesce(x.AcctName,y.AcctName) AS AcctName 
    ,coalesce(x.FinYear,y.FinYear) AS FinYear
    ,coalesce(x.FinPeriodID,y.FinPeriodID) AS FinPeriodID
    ,coalesce(x.StartDateUI,y.StartDateUI) AS StartDateUI
    ,IFNULL(SUM(x.Budget_Servicing_Portfolio),0) AS Budget_Servicing_Portfolio
    ,IFNULL(SUM(x.Actual_Servicing_Portfolio),0) AS Actual_Servicing_Portfolio
    -- Prev Year ServicingFee  
    ,IFNULL(SUM(y.Prev_Actual_Servicing_Portfolio),0) AS Prev_Actual_Servicing_Portfolio
FROM cur_period  x
FULL OUTER JOIN prev_period y -- prev year
    on x.AcctName = y.AcctName
    and x.FinPeriodID=y.FinPeriodID
GROUP BY coalesce(x.AcctName,y.AcctName) 
    ,coalesce(x.FinYear,y.FinYear)
    ,coalesce(x.FinPeriodID,y.FinPeriodID)
    ,coalesce(x.StartDateUI,y.StartDateUI)
