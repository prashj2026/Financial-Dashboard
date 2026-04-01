/*
SELECT AcctName,
    SUM(TurnOver)  as total_income
FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_PrevPeriod_NetIncome_OperatingCash_EBITDA`  
WHERE FinPeriodID >= 202401
    AND FinPeriodID <= 202412
--    AND AccountType = 'I' -- I:Income , E:Expense, A:Asset , L:Liability
--    AND AccountClassID = 'EXTAX' -- Taxes
--    AND AccountClassID = 'Depreciation' -- EXDEPR:Depreciation and Amortization 
--    AND AccountClassID = 'CASHASSET' -- Operating Cash
GROUP BY AcctName
*/
CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_PrevPeriod_NetIncome_OperatingCash_EBITDA` AS 
WITH cur_period AS (
SELECT AcctName
    ,FinYear
    ,FinPeriodID
    ,StartDateUI
    ,SUM(Actual_Income) AS Actual_Income
    ,SUM(Actual_Expense) AS Actual_Expense
    ,SUM(Actual_NetIncomeLoss) AS Actual_NetIncomeLoss
    ,SUM(Actual_EBITDA) AS Actual_EBITDA
    ,SUM(Actual_OperatingCash) AS Actual_OperatingCash
FROM ACUMATICA.vwFinanceDashboard_NetIncome_OperatingCash_EBITDA 
GROUP BY AcctName
    ,FinYear
    ,FinPeriodID
    ,StartDateUI
),
-- prev year
prev_period AS (
SELECT AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(FinPeriodID + 100 AS STRING))) AS FinYear
    ,FinPeriodID + 100 AS FinPeriodID
    ,PARSE_DATE("%Y%m", CAST(FinPeriodID + 100 AS STRING)) AS StartDateUI
    ,SUM(Actual_Income) AS Prev_Income
    ,SUM(Actual_Expense) AS Prev_Expense
    ,SUM(Actual_NetIncomeLoss) AS Prev_NetIncomeLoss
    ,SUM(Actual_EBITDA) AS Prev_EBITDA
    ,SUM(Actual_OperatingCash) AS Prev_OperatingCash
FROM ACUMATICA.vwFinanceDashboard_NetIncome_OperatingCash_EBITDA 
GROUP BY AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(FinPeriodID + 100 AS STRING)))
    ,FinPeriodID
    ,PARSE_DATE("%Y%m", CAST(FinPeriodID + 100 AS STRING))
),
-- prev month
prev_month AS (
SELECT AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(CAST(
            FORMAT_DATE('%Y%m',
                DATE_ADD(
                PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
                INTERVAL 1 MONTH
                )
            ) AS INT64
        ) AS STRING))) AS FinYear
    ,CAST(
            FORMAT_DATE('%Y%m',
                DATE_ADD(
                PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
                INTERVAL 1 MONTH
                )
            ) AS INT64
        ) AS FinPeriodID
    ,DATE_ADD(
            PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
            INTERVAL 1 MONTH
            ) AS StartDateUI
    ,SUM(Actual_Income) AS Prev_Income
    ,SUM(Actual_Expense) AS Prev_Expense
    ,SUM(Actual_NetIncomeLoss) AS Prev_NetIncomeLoss
    ,SUM(Actual_EBITDA) AS Prev_EBITDA
    ,SUM(Actual_OperatingCash) AS Prev_OperatingCash
FROM ACUMATICA.vwFinanceDashboard_NetIncome_OperatingCash_EBITDA 
GROUP BY AcctName
    ,EXTRACT(YEAR FROM PARSE_DATE('%Y%m', CAST(CAST(
            FORMAT_DATE('%Y%m',
                DATE_ADD(
                PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
                INTERVAL 1 MONTH
                )
            ) AS INT64
        ) AS STRING)))
    ,CAST(
            FORMAT_DATE('%Y%m',
                DATE_ADD(
                PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
                INTERVAL 1 MONTH
                )
            ) AS INT64
        )
     ,DATE_ADD(
            PARSE_DATE('%Y%m', CAST(FinPeriodID AS STRING)),
            INTERVAL 1 MONTH
            )   
)
SELECT coalesce(x.AcctName,y.AcctName,z.AcctName) AS AcctName 
    ,coalesce(x.FinYear,y.FinYear,z.FinYear) AS FinYear
    ,coalesce(x.FinPeriodID,y.FinPeriodID,z.FinPeriodID) AS FinPeriodID
    ,coalesce(x.StartDateUI,y.StartDateUI,z.StartDateUI) AS StartDateUI
-- Prev Year Income
    ,IFNULL(SUM(x.Actual_Income),0) AS Actual_Income
    ,IFNULL(SUM(y.Prev_Income),0) AS Actual_Income_Prev_Year
    ,ROUND(IFNULL(SUM(x.Actual_Income),0) - IFNULL(SUM(y.Prev_Income),0),2) AS Actual_vs_Prev_Year_Income_Variance

-- Prev Year Expense
    ,IFNULL(SUM(x.Actual_Expense),0) AS Actual_Expense
    ,IFNULL(SUM(y.Prev_Expense),0) AS Actual_Expense_Prev_Year
    ,ROUND(IFNULL(SUM(x.Actual_Expense),0) - IFNULL(SUM(y.Prev_Expense),0),2) AS Actual_vs_Prev_Year_Expense_Variance

-- Prev Year NetIncomeLoss
    ,IFNULL(SUM(x.Actual_NetIncomeLoss),0) AS Actual_NetIncomeLoss
    ,IFNULL(SUM(y.Prev_NetIncomeLoss),0) AS Actual_NetIncomeLoss_Prev_Year
    ,ROUND(IFNULL(SUM(x.Actual_NetIncomeLoss),0) - IFNULL(SUM(y.Prev_NetIncomeLoss),0),2) AS Actual_vs_Prev_Year_NetIncomeLoss_Variance  

-- Prev Year EBITDA
    ,IFNULL(SUM(x.Actual_EBITDA),0) AS Actual_EBITDA
    ,IFNULL(SUM(y.Prev_EBITDA),0) AS Actual_EBITDA_Prev_Year
    ,ROUND(IFNULL(SUM(x.Actual_EBITDA),0) - IFNULL(SUM(y.Prev_EBITDA),0),2) AS Actual_vs_Prev_Year_EBITDA_Variance

-- Prev Year OperatingCash
    ,IFNULL(SUM(x.Actual_OperatingCash),0) AS Actual_OperatingCash
    ,IFNULL(SUM(y.Prev_OperatingCash),0) AS Actual_OperatingCash_Prev_Year
    ,ROUND(IFNULL(SUM(x.Actual_OperatingCash),0) - IFNULL(SUM(y.Prev_OperatingCash),0),2) AS Actual_vs_Prev_Year_OperatingCash_Variance

-- Prev Month OperatingCash
    ,IFNULL(SUM(z.Prev_OperatingCash),0) AS Actual_OperatingCash_Prev_Month
    ,ROUND(IFNULL(SUM(x.Actual_OperatingCash),0) - IFNULL(SUM(z.Prev_OperatingCash),0),2) AS Actual_vs_Prev_Month_OperatingCash_Variance

FROM cur_period  x
FULL OUTER JOIN prev_period y -- prev year
    on x.AcctName = y.AcctName
    and x.FinPeriodID=y.FinPeriodID
FULL OUTER JOIN prev_month z -- prev month
    on x.AcctName = z.AcctName
    and x.FinPeriodID=z.FinPeriodID
GROUP BY coalesce(x.AcctName,y.AcctName,z.AcctName) 
    ,coalesce(x.FinYear,y.FinYear,z.FinYear)
    ,coalesce(x.FinPeriodID,y.FinPeriodID,z.FinPeriodID)
    ,coalesce(x.StartDateUI,y.StartDateUI,z.StartDateUI)