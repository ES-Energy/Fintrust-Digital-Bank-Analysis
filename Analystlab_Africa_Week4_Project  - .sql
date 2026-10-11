
USE [Fintrust_Bank_Analysis ]
GO

--Checking of tables, columns and data types

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('Customer_Cleaned', 'Transaction_Cleaned');

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer_Cleaned'
ORDER BY ORDINAL_POSITION;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Transaction_Cleaned'
ORDER BY ORDINAL_POSITION;



-- Q1. Monthly trend, normalised per active day (CTE + LAG)

USE [Fintrust_Bank_Analysis ];
GO

SELECT
    Channel,
    COUNT(*) AS Total_Transactions,
    ROUND(SUM(Amount_NGN), 2) AS Total_Value_NGN,
    ROUND(AVG(Amount_NGN), 2) AS Average_Value_NGN,
    ROUND(
        100.0 * SUM(
            CASE WHEN Transaction_Status = 'Successful'
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0), 2
    ) AS Success_Rate_Pct,
    ROUND(
        100.0 * SUM(
            CASE WHEN Risk_Review_Flag = 1
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0), 2
    ) AS Risk_Review_Rate_Pct
FROM dbo.Transaction_Cleaned
GROUP BY Channel
ORDER BY Total_Transactions DESC;




---Q2. Risk rate by amount decile (CTE + NTILE)

USE [Fintrust_Bank_Analysis ];
GO

WITH d AS (
    SELECT
        Amount_NGN,
        Risk_Review_Flag,
        NTILE(10) OVER (ORDER BY Amount_NGN) AS Value_Decile
    FROM dbo.Transaction_Cleaned
    WHERE Amount_NGN IS NOT NULL
)
SELECT
    Value_Decile,
    COUNT(*) AS Txns,
    ROUND(MIN(Amount_NGN), 2) AS Min_Amount,
    ROUND(MAX(Amount_NGN), 2) AS Max_Amount,
    ROUND(
        100.0 * SUM(
            CASE WHEN Risk_Review_Flag = 1 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0),
        1
    ) AS Risk_Rate_Pct
FROM d
GROUP BY Value_Decile
ORDER BY Value_Decile;




---Q3. Top-10% value threshold (subquery + PERCENTILE_CONT)

USE [Fintrust_Bank_Analysis ];
GO

WITH p AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.9)
        WITHIN GROUP (ORDER BY Amount_NGN)
        OVER () AS P90
    FROM dbo.Transaction_Cleaned
    WHERE Amount_NGN IS NOT NULL
)
SELECT
    CASE
        WHEN t.Amount_NGN > p.P90 THEN 'Top 10% value'
        ELSE 'Other 90%'
    END AS Value_Group,
    COUNT(*) AS Txns,
    ROUND(
        100.0 * SUM(
            CASE WHEN t.Risk_Review_Flag = 1 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*), 0),
        1
    ) AS Risk_Rate_Pct,
    ROUND(MAX(p.P90), 2) AS Threshold_NGN
FROM dbo.Transaction_Cleaned AS t
CROSS JOIN p
WHERE t.Amount_NGN IS NOT NULL
GROUP BY
    CASE
        WHEN t.Amount_NGN > p.P90 THEN 'Top 10% value'
        ELSE 'Other 90%'
    END;



---Q4. Risk by type and international status (CASE)


SELECT
    Transaction_Type,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN International_Transaction = 0
                 AND Risk_Review_Flag = 1
                THEN 1 ELSE 0
            END
        )
        / NULLIF(
            SUM(CASE WHEN International_Transaction = 0 THEN 1 ELSE 0 END),
            0
        ),
        1
    ) AS Domestic_Risk_Pct,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN International_Transaction = 1
                 AND Risk_Review_Flag = 1
                THEN 1 ELSE 0
            END
        )
        / NULLIF(
            SUM(CASE WHEN International_Transaction = 1 THEN 1 ELSE 0 END),
            0
        ),
        1
    ) AS International_Risk_Pct,

    COUNT(*) AS Txns

FROM dbo.Transaction_Cleaned
GROUP BY Transaction_Type
ORDER BY International_Risk_Pct DESC;






---Q5. Comparing transaction success rate across each channel 


SELECT
    Channel,
    COUNT(*) AS Txns,
    SUM(
        CASE
            WHEN Transaction_Status = 'Successful' THEN 1
            ELSE 0
        END
    ) AS Successful,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Transaction_Status = 'Successful' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS Success_Rate_Pct
FROM dbo.Transaction_Cleaned
GROUP BY Channel
ORDER BY Success_Rate_Pct DESC;






---Q6. Segment comparison, mean against median (two CTEs)


WITH seg AS (
    SELECT
        c.Customer_Segment,
        t.Amount_NGN
    FROM dbo.Customer_Cleaned AS c
    INNER JOIN dbo.Transaction_Cleaned AS t
        ON c.Customer_ID = t.Customer_ID
    WHERE t.Amount_NGN IS NOT NULL
),
med AS (
    SELECT DISTINCT
        Customer_Segment,
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY Amount_NGN)
            OVER (PARTITION BY Customer_Segment) AS Median_Value
    FROM seg
)
SELECT
    s.Customer_Segment,
    COUNT(*) AS Txns,
    ROUND(AVG(s.Amount_NGN), 2) AS Avg_Value,
    ROUND(MAX(m.Median_Value), 2) AS Median_Value
FROM seg AS s
INNER JOIN med AS m
    ON s.Customer_Segment = m.Customer_Segment
GROUP BY s.Customer_Segment
ORDER BY Avg_Value DESC;
   

