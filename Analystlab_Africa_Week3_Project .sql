
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
 
 USE [Fintrust_Bank_Analysis ];
GO

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



---WEEK 3 PROJECT SUMMARY

---Q9. CUSTOMER VALUE TIERS (CTE + NTILE WINDOW FUNCTION) 

---CTE (to calculate total transaction value and count per customer, then assign quartiles based on total value)

USE [Fintrust_Bank_Analysis ]
GO

SELECT
    c.Customer_ID,
    c.Customer_Segment,
    COUNT(t.Transaction_ID) AS Txn_Count,
    SUM(t.Amount_NGN) AS Total_Value
FROM dbo.Customer_Cleaned AS c
INNER JOIN dbo.Transaction_Cleaned_New AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Segment
ORDER BY
    Total_Value DESC;


---NTILE (used to divide customers into 4 roughly equal groups based on their total transaction value) 

WITH customer_totals AS (
    SELECT
        c.Customer_ID,
        c.Customer_Segment,
        COUNT(t.Transaction_ID) AS Txn_Count,
        SUM(t.Amount_NGN) AS Total_Value
    FROM dbo.Customer_Cleaned AS c
    INNER JOIN dbo.Transaction_Cleaned_New AS t
        ON c.Customer_ID = t.Customer_ID
    GROUP BY
        c.Customer_ID,
        c.Customer_Segment
),
tiered AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY Total_Value) AS Value_Quartile
    FROM customer_totals
)
SELECT
    Value_Quartile,
    COUNT(*) AS Num_Customers,
    ROUND(AVG(Total_Value), 2) AS Avg_Customer_Value,
    ROUND(AVG(Txn_Count), 2) AS Avg_Txn_Count,
    ROUND(SUM(Total_Value), 2) AS Tier_Total_Value
FROM tiered
GROUP BY
    Value_Quartile
ORDER BY
    Value_Quartile DESC;


---Q10. MONTH OVER MONTH TRANSACTION GROWTH (CTE + LAG WINDOW FUNCTION)

WITH monthly AS (
    SELECT
        FORMAT(Transaction_DateTime, 'yyyy-MM') AS Txn_Month,
        COUNT(*) AS Txn_Count,
        SUM(Amount_NGN) AS Total_Value
    FROM dbo.Transaction_Cleaned_New
    GROUP BY FORMAT(Transaction_DateTime, 'yyyy-MM')
)
SELECT
    Txn_Month,
    Txn_Count,
    ROUND(Total_Value, 2) AS Total_Value,
    ROUND(
        Total_Value - LAG(Total_Value) OVER (ORDER BY Txn_Month),
        2
    ) AS Value_Change,
    ROUND(
        (Total_Value - LAG(Total_Value) OVER (ORDER BY Txn_Month))
        * 100.0
        / NULLIF(LAG(Total_Value) OVER (ORDER BY Txn_Month), 0),
        2
    ) AS MoM_Growth_Pct
FROM monthly
ORDER BY Txn_Month;



---Q11. CUMULATIVE VALUE TREND (CTE + SUM OVER WINDOW FUNCTION)

WITH monthly AS (
    SELECT
        DATEFROMPARTS(
            YEAR(Transaction_DateTime),
            MONTH(Transaction_DateTime),
            1
        ) AS Txn_Month,
        SUM(Amount_NGN) AS Total_Value
    FROM dbo.Transaction_Cleaned_New
    WHERE Transaction_DateTime IS NOT NULL
    GROUP BY
        YEAR(Transaction_DateTime),
        MONTH(Transaction_DateTime)
)
SELECT
    FORMAT(Txn_Month, 'yyyy-MM') AS Txn_Month,
    ROUND(Total_Value, 2) AS Monthly_Value,
    ROUND(
        SUM(Total_Value) OVER (
            ORDER BY Txn_Month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS Cumulative_Value
FROM monthly
ORDER BY Txn_Month;


---Q12. HIGH VALUE TRANSACTION PATTERNS

WITH threshold AS (
    SELECT
        PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY Amount_NGN)
        OVER () AS P90
    FROM dbo.Transaction_Cleaned_New
),
high_value AS (
    SELECT DISTINCT P90
    FROM threshold
)
SELECT TOP 10
    t.Transaction_Type,
    t.Channel,
    COUNT(*) AS High_Value_Txns,
    ROUND(AVG(t.Amount_NGN), 2) AS Avg_High_Value,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN t.Risk_Review_Flag = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Risk_Review_Rate_Pct
FROM dbo.Transaction_Cleaned_New AS t
CROSS JOIN high_value AS h
WHERE t.Amount_NGN > h.P90
GROUP BY
    t.Transaction_Type,
    t.Channel
HAVING COUNT(*) >= 10
ORDER BY
    High_Value_Txns DESC;



---Q13. SUCCESSFUL VS NOT SUCCESSFUL TRANSACTION VALUE COMPARISON

WITH categorized AS (
    SELECT
        CASE
            WHEN Transaction_Status = 'Successful'
            THEN 'Successful'
            ELSE 'Not Successful'
        END AS Status_Group,
        Amount_NGN,
        Transaction_Type
    FROM dbo.Transaction_Cleaned_New
)
SELECT
    Status_Group,
    Transaction_Type,
    COUNT(*) AS Txn_Count,
    ROUND(AVG(Amount_NGN), 2) AS Avg_Value,
    ROUND(SUM(Amount_NGN), 2) AS Total_Value
FROM categorized
GROUP BY
    Status_Group,
    Transaction_Type
ORDER BY
    Transaction_Type,
    Status_Group;


---Q14. SEGMENT BY CHANNEL PIVOT

SELECT
    c.Customer_Segment,
    SUM(CASE WHEN t.Channel = 'Mobile App' THEN 1 ELSE 0 END) AS Mobile_App,
    SUM(CASE WHEN t.Channel = 'POS' THEN 1 ELSE 0 END) AS POS,
    SUM(CASE WHEN t.Channel = 'Web' THEN 1 ELSE 0 END) AS Web,
    SUM(CASE WHEN t.Channel = 'ATM' THEN 1 ELSE 0 END) AS ATM,
    SUM(CASE WHEN t.Channel = 'USSD' THEN 1 ELSE 0 END) AS USSD,
    COUNT(*) AS Total_Txns
FROM dbo.Customer_Cleaned AS c
INNER JOIN dbo.Transaction_Cleaned_New AS t
    ON c.Customer_ID = t.Customer_ID
GROUP BY
    c.Customer_Segment
ORDER BY
    Total_Txns DESC;


---Q15. INTERNATIONAL ACTIVITY BY TRANSACTION TYPE

SELECT
    Transaction_Type,
    SUM(
        CASE
            WHEN International_Transaction = 1 THEN 1
            ELSE 0
        END
    ) AS Intl_Txns,

    COUNT(*) AS Total_Txns,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN International_Transaction = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Intl_Pct,

    ROUND(
        AVG(
            CASE
                WHEN International_Transaction = 1
                THEN Amount_NGN
            END
        ),
        2
    ) AS Avg_Intl_Value,

    ROUND(
        AVG(
            CASE
                WHEN International_Transaction = 0
                THEN Amount_NGN
            END
        ),
        2
    ) AS Avg_Domestic_Value

FROM dbo.Transaction_Cleaned_New

GROUP BY
    Transaction_Type

ORDER BY
    Intl_Pct DESC;



---Q16. TOP 10 CUSTOMERS BY TRANSACTION VALUE (CTE + RANK WINDOW FUNCTION)

WITH customer_totals AS (
    SELECT
        c.Customer_ID,
        c.Customer_Segment,
        c.City,
        COUNT(t.Transaction_ID) AS Txn_Count,
        SUM(t.Amount_NGN) AS Total_Value,
        RANK() OVER (
            ORDER BY SUM(t.Amount_NGN) DESC
        ) AS Value_Rank
    FROM dbo.Customer_Cleaned AS c
    INNER JOIN dbo.Transaction_Cleaned_New AS t
        ON c.Customer_ID = t.Customer_ID
    GROUP BY
        c.Customer_ID,
        c.Customer_Segment,
        c.City
)
SELECT
    Value_Rank,
    Customer_ID,
    Customer_Segment,
    City,
    Txn_Count,
    ROUND(Total_Value, 2) AS Total_Value
FROM customer_totals
WHERE Value_Rank <= 10
ORDER BY
    Value_Rank;