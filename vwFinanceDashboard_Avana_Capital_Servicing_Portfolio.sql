CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Avana_Capital_Servicing_Portfolio` AS 
-- Monthly servicing portfolio balance for Avana Capital
WITH base AS (
    SELECT
        LAST_DAY(CAST(ReportDate AS DATE)) AS period_end_date,
        src.LoanNumber,
        src.PrincipalBalance
    FROM `avana-data-warehouse-prod.TMO.LoanTape` src
    WHERE CAST(ReportDate AS DATE) = LAST_DAY(CAST(ReportDate AS DATE))
)
SELECT
    'Avana Capital'                                               AS AcctName,
    CAST(FORMAT_DATE('%Y',   period_end_date) AS INT64)           AS FinYear,
    CAST(FORMAT_DATE('%Y%m', period_end_date) AS INT64)           AS FinPeriodID,
    PARSE_DATE('%Y%m', FORMAT_DATE('%Y%m', period_end_date))      AS StartDateUI,
    IFNULL(SUM(PrincipalBalance), 0)                              AS Actual_Servicing_Portfolio
FROM base
GROUP BY
    CAST(FORMAT_DATE('%Y',   period_end_date) AS INT64),
    CAST(FORMAT_DATE('%Y%m', period_end_date) AS INT64),
    PARSE_DATE('%Y%m', FORMAT_DATE('%Y%m', period_end_date))
  

