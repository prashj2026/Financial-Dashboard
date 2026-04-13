/*
SELECT AcctName
    ,AccountClassID
    ,GLCode
    ,ROUND(sum(Actual_Income),2) Total_Income
    ,ROUND(sum(Actual_Expense),2) Total_Expenses
    ,ROUND(sum(Actual_NetIncomeLoss),2) NetIncomeLoss
    ,ROUND(sum(Actual_EBITDA),2) EBITDA
    ,ROUND(sum(Actual_OperatingCash),2) OperatingCash
FROM `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_NetIncome_OperatingCash_EBITDA_with_GLCode`  
WHERE FinPeriodID >= 202501
    AND FinPeriodID <= 202501
    AND AcctName='Avana Capital'
GROUP BY ROLLUP(AcctName,AccountClassID,GLCode)
ORDER BY 3 DESC,4 DESC,7 DESC
*/
CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_NetIncome_OperatingCash_EBITDA_with_GLCode` AS 
WITH ledger_summary AS (
SELECT
     GL.BranchID
    ,BRH.AcctName as AcctName
    ,GL.FinYear
    ,GL.FinPeriodID
    ,PARSE_DATE("%Y%m", CAST(GL.FinPeriodID AS STRING)) AS StartDateUI
    ,CAST(SUBSTR(CAST(GL.FinPeriodID AS STRING), 1, 4) AS INT64) AS year
    ,CAST(SUBSTR(CAST(GL.FinPeriodID AS STRING), 5, 2) AS INT64) AS month
    ,CASE 
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'ININTEREST' THEN 'Interest Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'ORIGINATIONINC' THEN 'Origination Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'SVCINCOME' THEN 'Servicing Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'INTERCOFEES' THEN 'Servicing Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'OTHINCOME' THEN 'Other Income'
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'SALARIES' THEN 'Salaries' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXPROF' THEN 'Professional Fees' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXTRAVEL' THEN 'Travel and Entertainment' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'PREMISESANDFA' THEN 'Premises and Fixtures' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXDEPR' THEN 'Depreciation' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'MRKTANDOTHERS' THEN 'Marketing and Other Expenses'
            ELSE AC.AccountClassID 
        END AS AccountClassID
    ,AC.AccountCD AS GLCode
    -- Income    
    ,SUM(CASE WHEN AC.TYPE='I' AND GL.LedgerID = 24 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Actual_Income
    ,SUM(CASE WHEN AC.TYPE='I' AND GL.LedgerID = 29 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Budget_Income
    ,SUM(CASE WHEN AC.TYPE='I' AND GL.LedgerID = 35 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Forecast_Income

    -- Expense    
    ,SUM(CASE WHEN AC.TYPE='E' AND GL.LedgerID = 24 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Actual_Expense
    ,SUM(CASE WHEN AC.TYPE='E' AND GL.LedgerID = 29 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Budget_Expense
    ,SUM(CASE WHEN AC.TYPE='E' AND GL.LedgerID = 35 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Forecast_Expense

    -- Taxes
    ,SUM(CASE WHEN AC.AccountClassID = 'EXTAX' AND GL.LedgerID = 24 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Actual_Taxes
    ,SUM(CASE WHEN AC.AccountClassID = 'EXTAX' AND GL.LedgerID = 29 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Budget_Taxes
    ,SUM(CASE WHEN AC.AccountClassID = 'EXTAX' AND GL.LedgerID = 35 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Forecast_Taxes

    -- Depreciation
    ,SUM(CASE WHEN AC.AccountClassID = 'EXDEPR' AND GL.LedgerID = 24 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Actual_Depreciation
    ,SUM(CASE WHEN AC.AccountClassID = 'EXDEPR' AND GL.LedgerID = 29 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Budget_Depreciation
    ,SUM(CASE WHEN AC.AccountClassID = 'EXDEPR' AND GL.LedgerID = 35 THEN 
                                            IF(AC.Type = 'I' OR AC.Type = 'L', 
                                            GL.TranPtdCredit - GL.TranPtdDebit, 
                                            GL.TranPtdDebit - GL.TranPtdCredit)
                ELSE NULL END                            
    ) AS Forecast_Depreciation
    
    -- Operating Cash (No Budget)
    ,SUM(CASE WHEN AC.AccountClassID IN ('CASHASSET' ,'RESTRICTEDCASH') AND GL.LedgerID = 24 THEN YtdBalance
                                            ELSE NULL END                            
    ) AS Actual_OperatingCash
    ,0 AS Budget_OperatingCash
    ,SUM(CASE WHEN AC.AccountClassID IN ('CASHASSET' ,'RESTRICTEDCASH') AND GL.LedgerID = 35 THEN YtdBalance
                                            ELSE NULL END                            
    ) AS Forecast_OperatingCash

FROM `avana-data-warehouse-prod.ACUMATICA.GLHistory` AS GL
LEFT JOIN `avana-data-warehouse-prod.ACUMATICA.Branch` AS BRH ON BRH.BranchID = GL.BranchID
LEFT JOIN `avana-data-warehouse-prod.ACUMATICA.Account` AS AC ON AC.AccountID = GL.AccountID
GROUP BY GL.BranchID
    ,BRH.AcctName
    ,GL.FinYear
    ,GL.FinPeriodID
    ,PARSE_DATE("%Y%m", CAST(GL.FinPeriodID AS STRING)) 
    ,CAST(SUBSTR(CAST(GL.FinPeriodID AS STRING), 1, 4) AS INT64) 
    ,CAST(SUBSTR(CAST(GL.FinPeriodID AS STRING), 5, 2) AS INT64) 
    ,CASE 
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'ININTEREST' THEN 'Interest Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'ORIGINATIONINC' THEN 'Origination Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'SVCINCOME' THEN 'Servicing Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'INTERCOFEES' THEN 'Servicing Income'
            WHEN AC.TYPE = 'I' AND AC.AccountClassID = 'OTHINCOME' THEN 'Other Income'
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'SALARIES' THEN 'Salaries' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXPROF' THEN 'Professional Fees' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXTRAVEL' THEN 'Travel and Entertainment' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'PREMISESANDFA' THEN 'Premises and Fixtures' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'EXDEPR' THEN 'Depreciation' 
            WHEN AC.TYPE = 'E' AND AC.AccountClassID = 'MRKTANDOTHERS' THEN 'Marketing and Other Expenses'
            ELSE AC.AccountClassID 
        END 
    ,AC.AccountCD
)
SELECT
     cy.AcctName
    ,cy.FinYear
    ,cy.FinPeriodID
    ,cy.StartDateUI
    ,cy.AccountClassID
    ,cy.GLCode
-- Income
    -- Actual Income
    ,IFNULL(cy.Actual_Income,0) AS Actual_Income 

    -- Actual vs Budget Income
    ,IFNULL(cy.Budget_Income,0) AS Budget_Income 
    ,ROUND(IFNULL(cy.Actual_Income,0) - IFNULL(cy.Budget_Income,0),2) AS Actual_vs_Budget_Income_Variance

    -- Actual vs Forecast Income
    ,IFNULL(cy.Forecast_Income,0) AS Forecast_Income 
    ,ROUND(IFNULL(cy.Actual_Income,0) - IFNULL(cy.Forecast_Income,0),2) AS Actual_vs_Forecast_Income_Variance



-- Expense
    -- Actual Expense
    ,IFNULL(cy.Actual_Expense,0) AS Actual_Expense 

    -- Actual vs Budget Income
    ,IFNULL(cy.Budget_Expense,0) AS Budget_Expense 
    ,ROUND(IFNULL(cy.Actual_Expense,0) - IFNULL(cy.Budget_Expense,0),2) AS Actual_vs_Budget_Expense_Variance

    -- Actual vs Forecast Income
    ,IFNULL(cy.Forecast_Expense,0) AS Forecast_Expense 
    ,ROUND(IFNULL(cy.Actual_Expense,0) - IFNULL(cy.Forecast_Expense,0),2) AS Actual_vs_Forecast_Expense_Variance



-- Net Income Loss
    -- Actual NetIncomeLoss
    ,ROUND(IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0),2) AS Actual_NetIncomeLoss 

    -- Actual vs Budget NetIncomeLoss
    ,ROUND(IFNULL(cy.Budget_Income,0) - IFNULL(cy.Budget_Expense,0),2) AS Budget_NetIncomeLoss 
    ,ROUND((IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0)) - (IFNULL(cy.Budget_Income,0) - IFNULL(cy.Budget_Expense,0)),2) AS Actual_vs_Budget_NetIncomeLoss_Variance

    -- Actual vs Forecast NetIncomeLoss
    ,ROUND(IFNULL(cy.Forecast_Income,0) - IFNULL(cy.Forecast_Expense,0),2) AS Forecast_NetIncomeLoss 
    ,ROUND((IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0)) - (IFNULL(cy.Forecast_Income,0) - IFNULL(cy.Forecast_Expense,0)),2) AS Actual_vs_Forecast_NetIncomeLoss_Variance



-- EBITDA
    -- Actual EBITDA
    ,ROUND((IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0)) + IFNULL(Actual_Taxes,0) + IFNULL(Actual_Depreciation,0) ,2) AS Actual_EBITDA 

    -- Actual vs Budget EBITDA
    ,ROUND((IFNULL(cy.Budget_Income,0) - IFNULL(cy.Budget_Expense,0)) + IFNULL(Budget_Taxes,0) + IFNULL(Budget_Depreciation,0),2) AS Budget_EBITDA 
    ,ROUND(
               ROUND((IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0)) + IFNULL(Actual_Taxes,0) + IFNULL(Actual_Depreciation,0) ,2) -- Actual_EBITDA 
            - ROUND((IFNULL(cy.Budget_Income,0) - IFNULL(cy.Budget_Expense,0)) + IFNULL(Budget_Taxes,0) + IFNULL(Budget_Depreciation,0),2) -- Budget_EBITDA
        ,2) AS Actual_vs_Budget_EBITDA_Variance

    -- Actual vs Forecast EBITDA
    ,ROUND((IFNULL(cy.Forecast_Income,0) - IFNULL(cy.Forecast_Expense,0)) + IFNULL(Forecast_Taxes,0) + IFNULL(Forecast_Depreciation,0) ,2) AS Forecast_EBITDA 
    ,ROUND(
             ROUND((IFNULL(cy.Actual_Income,0) - IFNULL(cy.Actual_Expense,0)) + IFNULL(Actual_Taxes,0) + IFNULL(Actual_Depreciation,0) ,2) -- Actual_EBITDA
            - ROUND((IFNULL(cy.Forecast_Income,0) - IFNULL(cy.Forecast_Expense,0)) + IFNULL(Forecast_Taxes,0) + IFNULL(Forecast_Depreciation,0) ,2) -- Forecast_EBITDA
        ,2) AS Actual_vs_Forecast_EBITDA_Variance


-- Operating Cash
    -- Actual Operating Cash
    ,IFNULL(cy.Actual_OperatingCash,0) AS Actual_OperatingCash 

    -- Actual vs Budget Operating Cash
    ,0 AS Budget_OperatingCash 
    ,0 AS Actual_vs_Budget_OperatingCash_Variance

    -- Actual vs Forecast Operating Cash
    ,IFNULL(cy.Forecast_OperatingCash,0) AS Forecast_OperatingCash 
    ,ROUND(IFNULL(cy.Actual_OperatingCash,0) - IFNULL(cy.Forecast_OperatingCash,0),2) AS Actual_vs_Forecast_OperatingCash_Variance


FROM ledger_summary cy