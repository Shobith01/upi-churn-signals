Query 1 — Overall Platform Summary

-- Business Question: What is the overall health of transactions on the platform?
-- These 6 numbers go into your Tableau KPI cards and BRD Section 2

SELECT
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'SUCCESS' THEN 1 ELSE 0 END)                 AS successful_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED'  THEN 1 ELSE 0 END)                 AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_processed_INR,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_transaction_value_INR
FROM transactions;

Query 2 — Failure Rate by Transaction_type

-- Business Question: Are failures more common in P2P, P2M, Bill Payment or Recharge?
-- Tells us which payment flow needs the most urgent fix

SELECT
    [transaction_type],
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_amount_INR
FROM transactions
GROUP BY [transaction_type]
ORDER BY failure_rate_pct DESC;

Query 3 — Failure Rate by Merchant Category

-- Business Question: Which merchant categories have the highest failure rates?
-- High failure in Grocery/Food = immediate churn risk (daily-use habits)

SELECT
    merchant_category,
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_transaction_value_INR
FROM transactions
GROUP BY merchant_category
ORDER BY failure_rate_pct DESC;

Query 4 — Hourly Transaction Pattern 

-- Business Question: At what hours does volume peak and does failure spike at the same time?
-- hour_of_day column already exists in your dataset so no DATEPART needed

SELECT
    hour_of_day,
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR
FROM transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;


Query 5 — Day of Week Pattern

-- Business Question: Which days see highest volumes and values?
-- day_of_week column already exists - no DATENAME needed

SELECT
    day_of_week,
    is_weekend,
    COUNT(*)                                                                          AS total_transactions,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_value_INR,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct
FROM transactions
GROUP BY day_of_week, is_weekend
ORDER BY
    CASE day_of_week
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END;
	
Query 6 — Monthly Transaction Trend

-- Business Question: Is the platform growing month over month?
-- FORMAT extracts year-month from the timestamp column

SELECT
    FORMAT([timestamp], 'yyyy-MM')                                                   AS month,
    COUNT(*)                                                                          AS total_transactions,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_count,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct
FROM transactions
GROUP BY FORMAT([timestamp], 'yyyy-MM')
ORDER BY month;

Query 7 — P2P vs P2M Split

-- Business Question: What % of volume and value is P2P vs P2M?
-- Low P2M share = merchant adoption gap = revenue opportunity missed

SELECT
    [transaction_type],
    COUNT(*)                                                                          AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)                               AS pct_of_total_volume,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR,
    ROUND(SUM([amount_INR]) * 100.0 / SUM(SUM([amount_INR])) OVER(), 2)         AS pct_of_total_value
FROM transactions
GROUP BY [transaction_type];

Query 8 — Transaction Value Band Distribution

-- Business Question: Is this platform used for micro-payments or large transfers?
-- Drives understanding of user behavior and risk exposure

SELECT
    CASE
        WHEN [amount_INR] < 500              THEN '1_Micro (Under Rs.500)'
        WHEN [amount_INR] BETWEEN 500 AND 5000  THEN '2_Small (Rs.500-Rs.5000)'
        WHEN [amount_INR] BETWEEN 5001 AND 25000 THEN '3_Medium (Rs.5001-Rs.25000)'
        ELSE                                        '4_Large (Above Rs.25000)'
    END                                                                               AS value_band,
    COUNT(*)                                                                          AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)                               AS pct_of_total,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct
FROM transactions
GROUP BY
    CASE
        WHEN [amount_INR] < 500              THEN '1_Micro (Under Rs.500)'
        WHEN [amount_INR] BETWEEN 500 AND 5000  THEN '2_Small (Rs.500-Rs.5000)'
        WHEN [amount_INR] BETWEEN 5001 AND 25000 THEN '3_Medium (Rs.5001-Rs.25000)'
        ELSE                                        '4_Large (Above Rs.25000)'
    END
ORDER BY value_band;

Query 9 — Sender Bank Failure Analysis

-- Business Question: Which bank's users experience the most failures?
-- Directly supports Recommendation 1 - Bank Health Indicator feature

SELECT
    sender_bank,
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_ticket_size_INR
FROM transactions
GROUP BY sender_bank
ORDER BY failure_rate_pct DESC;

Query 10 — Device & Network Failure Analysis

-- Business Question: Do Android/iOS users and 4G/5G/WiFi networks show different failure rates?
-- Guides engineering team on infrastructure priorities

SELECT
    device_type,
    network_type,
    COUNT(*)                                                                          AS total_transactions,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct
FROM transactions
GROUP BY device_type, network_type
ORDER BY failure_rate_pct DESC;

Query 11 — Age Group Spending & Failure Behavior

-- Business Question: Which age group transacts most and which is most failure-prone?
-- Drives targeted re-engagement messaging strategy

SELECT
    sender_age_group,
    COUNT(*)                                                                          AS total_transactions,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_ticket_size_INR,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    SUM(CASE WHEN [transaction_type] = 'P2M' THEN 1 ELSE 0 END)                     AS p2m_transactions,
    ROUND(
        SUM(CASE WHEN [transaction_type] = 'P2M' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS p2m_adoption_pct
FROM transactions
GROUP BY sender_age_group
ORDER BY
    CASE sender_age_group
        WHEN '18-25' THEN 1
        WHEN '26-35' THEN 2
        WHEN '36-45' THEN 3
        WHEN '46-55' THEN 4
        WHEN '56+'   THEN 5
    END;
	
	
Query 12 — Fraud Transaction Analysis

-- Business Question: What patterns exist in the 480 flagged fraud transactions?
-- fraud_flag = 1 means flagged as suspicious

SELECT
    [transaction_type],
    merchant_category,
    network_type,
    device_type,
    COUNT(*)                                                                          AS fraud_flagged_count,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_fraud_amount_INR,
    ROUND(MIN([amount_INR]), 2)                                                    AS min_fraud_amount,
    ROUND(MAX([amount_INR]), 2)                                                    AS max_fraud_amount
FROM transactions
WHERE fraud_flag = 1
GROUP BY [transaction_type], merchant_category, network_type, device_type
ORDER BY fraud_flagged_count DESC;


Query 13 — Geographic (State) Analysis

-- Business Question: Which states generate the most transactions and which have highest failure rates?

SELECT
    sender_state,
    COUNT(*)                                                                          AS total_transactions,
    ROUND(SUM([amount_INR]), 2)                                                    AS total_value_INR,
    SUM(CASE WHEN transaction_status = 'FAILED' THEN 1 ELSE 0 END)                  AS failed_transactions,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_ticket_size_INR
FROM transactions
GROUP BY sender_state
ORDER BY total_transactions DESC;

Query 14 — Behavioral Segmentation

-- Business Question: Can we segment transactions into behavioral personas?
-- Since no user_id exists, we segment by sender_bank + sender_age_group combination
-- as a proxy for user behavior clusters

SELECT
    sender_bank,
    sender_age_group,
    [transaction_type]                                                                AS dominant_txn_type,
    COUNT(*)                                                                          AS transaction_count,
    ROUND(AVG(CAST([amount_INR] AS FLOAT)), 2)                                     AS avg_ticket_size_INR,
    ROUND(
        SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 2)                                                         AS failure_rate_pct,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)                                 AS fraud_flagged_count,
    CASE
        WHEN COUNT(*) >= 5000
             AND SUM(CASE WHEN [transaction_type] = 'P2M' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) > 0.4
             THEN 'High-Volume Merchant Payer'
        WHEN COUNT(*) >= 3000
             AND SUM(CASE WHEN [transaction_type] = 'P2P' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) > 0.6
             THEN 'Social Sender'
        WHEN SUM(CASE WHEN transaction_status = 'FAILED' THEN 1.0 ELSE 0 END) / COUNT(*) > 0.08
             THEN 'Failure-Prone Segment'
        WHEN COUNT(*) < 1000
             THEN 'Low Activity Segment'
        ELSE 'Occasional User Segment'
    END                                                                               AS segment_persona
FROM transactions
GROUP BY sender_bank, sender_age_group, [transaction_type]
ORDER BY transaction_count DESC;
