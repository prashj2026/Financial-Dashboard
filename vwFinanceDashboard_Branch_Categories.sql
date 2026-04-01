CREATE VIEW `avana-data-warehouse-prod.ACUMATICA.vwFinanceDashboard_Branch_Categories` AS 
SELECT
    IFNULL(b.Category, 'Other') AS Category,
    a.BranchCD,
    a.AcctName
FROM `avana-data-warehouse-prod.ACUMATICA.Branch`      AS a
LEFT JOIN `avana-data-warehouse-prod.ACUMATICA.Categories` AS b
       ON TRIM(a.BranchCD) = b.BranchCD
WHERE b.BranchCD IS NOT NULL
ORDER BY
    b.Category;