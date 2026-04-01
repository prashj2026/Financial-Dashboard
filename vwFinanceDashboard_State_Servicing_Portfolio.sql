CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_State_Servicing_Portfolio` AS 
WITH cur_period AS (
    SELECT  AcctName,
            State,
            FinYear,
            FinPeriodID,
            StartDateUI,
            0 AS Budget_Servicing_Portfolio,
            ROUND(SUM(Actual_Servicing_Portfolio),2) AS Actual_Servicing_Portfolio
    FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_Capital_State_Servicing_Portfolio`
    GROUP BY AcctName,
            State,
            FinYear,
            FinPeriodID,
            StartDateUI
    UNION ALL 
    SELECT  AcctName,
            State,
            FinYear,
            FinPeriodID,
            StartDateUI,
            0 AS Budget_Servicing_Portfolio,
            ROUND(SUM(Actual_Servicing_Portfolio),2) AS Actual_Servicing_Portfolio
    FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_CUSO_State_Servicing_Portfolio`
    GROUP BY AcctName,
            State,
            FinYear,
            FinPeriodID,
            StartDateUI      
)
SELECT x.AcctName 
    ,x.State
    ,x.FinYear
    ,x.FinPeriodID
    ,x.StartDateUI
    ,IFNULL(SUM(x.Actual_Servicing_Portfolio),0) AS Actual_Servicing_Portfolio
FROM cur_period  x
GROUP BY x.AcctName 
    ,x.State
    ,x.FinYear
    ,x.FinPeriodID
    ,x.StartDateUI
