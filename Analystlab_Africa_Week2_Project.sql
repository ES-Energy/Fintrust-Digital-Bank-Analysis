
USE [Fintrust_Bank_Analysis ]
GO

--CHECKING OF TABLES, COLUMNS AND DATA TYPE

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



-- Q1. CUSTOMER BEHAVIOUR: TRANSACTION PER CUSTOMER BY SEGMENT

SELECT 
    c.Customer_Segment,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    COUNT(DISTINCT t.Customer_ID) AS Customers_With_Txns,
    ROUND(
        COUNT(t.Transaction_ID) * 1.0 /
        NULLIF(COUNT(DISTINCT t.Customer_ID), 0),
        2
    ) AS Avg_Txns_Per_Customer
FROM dbo.Customer_Cleaned AS c
INNER JOIN dbo.Transaction_Cleaned AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Avg_Txns_Per_Customer DESC;



---Q2. MONTHLY TRANSACTION TREND
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Transaction_DateTime) AS Rows_With_Date
FROM dbo.Transaction_Cleaned_New;

SELECT
    FORMAT(t.Transaction_DateTime, 'yyyy-MM') AS Txn_Month,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    ROUND(SUM(t.Amount_NGN), 2) AS Total_Value_NGN
FROM dbo.Transaction_Cleaned_New AS t
WHERE t.Transaction_DateTime IS NOT NULL
GROUP BY
    FORMAT(t.Transaction_DateTime, 'yyyy-MM')
ORDER BY
    Txn_Month;



---Q3. TRANSACTION VALUE BY CUSTOMER SEGMENT

SELECT
    c.Customer_Segment,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    ROUND(SUM(t.Amount_NGN), 2) AS Total_Value_NGN,
    ROUND(AVG(t.Amount_NGN), 2) AS Avg_Value_NGN
FROM dbo.Customer_Cleaned AS c
INNER JOIN dbo.Transaction_Cleaned_New AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY
    c.Customer_Segment
ORDER BY
    Total_Value_NGN DESC;



---Q4. TRANSACTION TYPE ANALYSIS

SELECT
    t.Transaction_Type,
    COUNT(t.Transaction_ID) AS Txn_Count,
    ROUND(
        COUNT(t.Transaction_ID) * 100.0 /
        SUM(COUNT(t.Transaction_ID)) OVER (),
        2
    ) AS Pct_Of_All_Txns,
    ROUND(SUM(t.Amount_NGN), 2) AS Total_Value_NGN,
    ROUND(AVG(t.Amount_NGN), 2) AS Avg_Value_NGN
FROM dbo.Transaction_Cleaned_New AS t
GROUP BY
    t.Transaction_Type
ORDER BY
    Txn_Count DESC;



---Q5. CHANNEL PERFORMANCE

SELECT
    t.Channel,
    COUNT(t.Transaction_ID) AS Total_Txns,
    SUM(
        CASE
            WHEN t.Transaction_Status = 'Successful'
            THEN 1
            ELSE 0
        END
    ) AS Successful_Txns,
    ROUND(
        SUM(
            CASE
                WHEN t.Transaction_Status = 'Successful'
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        COUNT(t.Transaction_ID),
        2
    ) AS Success_Rate_Pct,
    ROUND(
        SUM(
            CASE
                WHEN t.Risk_Review_Flag = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        COUNT(t.Transaction_ID),
        2
    ) AS Risk_Review_Rate_Pct
FROM dbo.Transaction_Cleaned_New AS t
GROUP BY
    t.Channel
ORDER BY
    Total_Txns DESC;




---Q6. TRANSACTION STATUS ANALYSIS

SELECT
    t.Transaction_Status,
    COUNT(t.Transaction_ID) AS Txn_Count,
    ROUND(
        COUNT(t.Transaction_ID) * 100.0 /
        SUM(COUNT(t.Transaction_ID)) OVER (),
        2
    ) AS Pct_Of_All_Txns,
    ROUND(AVG(t.Amount_NGN), 2) AS Avg_Value_NGN
FROM dbo.Transaction_Cleaned_New AS t
GROUP BY
    t.Transaction_Status
ORDER BY
    Txn_Count DESC;




---Q7. CUSTOMER SEGMENT CONTRIBUTION

SELECT
    c.Customer_Segment,
    COUNT(DISTINCT c.Customer_ID) AS Num_Customers,
    ROUND(SUM(t.Amount_NGN), 2) AS Total_Value_NGN,
    ROUND(
        SUM(t.Amount_NGN) * 100.0 /
        SUM(SUM(t.Amount_NGN)) OVER (),
        2
    ) AS Pct_Of_Total_Value
FROM dbo.Customer_Cleaned AS c
INNER JOIN dbo.Transaction_Cleaned_New AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY
    c.Customer_Segment
ORDER BY
    Total_Value_NGN DESC;





---Q8. RISK REVIEW BY TRANSACTION TYPE AND CHANNEL

SELECT TOP 10
    t.Transaction_Type,
    t.Channel,
    COUNT(t.Transaction_ID) AS Total_Txns,
    SUM(
        CASE
            WHEN t.Risk_Review_Flag = 1
            THEN 1
            ELSE 0
        END
    ) AS Flagged_Txns,
    ROUND(
        SUM(
            CASE
                WHEN t.Risk_Review_Flag = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0 /
        COUNT(t.Transaction_ID),
        2
    ) AS Risk_Review_Rate_Pct
FROM dbo.Transaction_Cleaned_New AS t
GROUP BY
    t.Transaction_Type,
    t.Channel
HAVING
    COUNT(t.Transaction_ID) >= 30
ORDER BY
    Risk_Review_Rate_Pct DESC;






    ---OVERALL FINTRUST TRANSACTION SUMMARY

    SELECT
    COUNT(*) AS Total_Transactions,

    COUNT(DISTINCT t.Customer_ID) AS Total_Customers_With_Transactions,

    ROUND(SUM(t.Amount_NGN), 2) AS Total_Transaction_Value_NGN,

    ROUND(AVG(t.Amount_NGN), 2) AS Average_Transaction_Value_NGN,

    SUM(
        CASE
            WHEN t.Transaction_Status = 'Successful'
            THEN 1
            ELSE 0
        END
    ) AS Successful_Transactions,

    ROUND(
        SUM(
            CASE
                WHEN t.Transaction_Status = 'Successful'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Overall_Success_Rate_Pct,

    SUM(
        CASE
            WHEN t.Risk_Review_Flag = 1
            THEN 1
            ELSE 0
        END
    ) AS Risk_Reviewed_Transactions,

    ROUND(
        SUM(
            CASE
                WHEN t.Risk_Review_Flag = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Overall_Risk_Review_Rate_Pct

FROM dbo.Transaction_Cleaned_New AS t;


SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('Customer_Cleaned', 'Transaction_Cleaned', 'Transaction_Cleaned_New');

SELECT DB_NAME() AS Current_Database;