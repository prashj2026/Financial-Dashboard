CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinancialPeriod` AS 
SELECT * 
FROM `avana-data-warehouse-prod.ACUMATICA.FinancialPeriod` 
WHERE Active = true 
ORDER BY FinYear DESC, PeriodNbr DESC