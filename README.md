# UPI Transaction Pattern Analysis — Churn Signals & Product Recommendations

## Business Problem

A Bengaluru-based UPI payments app competing with PhonePe and GPay faces two critical problems:

1. **Transaction failures are killing trust** — At UPI's scale of 698 million daily transactions, even a 4.95% failure rate means millions of failed payments. Users who fail on your app but succeed on a competitor's switch and never return.
2. **P2M adoption is stalled** — Only 35.06% of transactions are merchant payments. 65% of users are stuck in P2P-only behavior, limiting engagement and merchant revenue.

## Dataset

- **Primary**: Synthetic UPI transactions dataset — 250,000 transactions, January to December 2024, 17 columns including transaction type, merchant category, amount, status, sender bank, device type, network type, age group, and state. Synthetically generated to simulate real UPI transaction patterns while preserving privacy compliance — inspired by NPCI and RBI market data.
- **Reference**: NPCI Monthly Transaction Statistics used for Business Background context in BRD.

## Approach

SQL Analysis (14 queries) → Excel Exploration → BRD Documentation → Tableau Dashboard → Product Recommendations

## Key Findings

- **4.95% overall failure rate** — Education category highest at 5.25%, Food and Grocery at 5.01% (daily habit risk)
- **6 AM has highest failure rate at 5.40%** — bank maintenance window; 7 PM is peak volume at 21,232 transactions
- **Yes Bank users face 5.10% failure** vs HDFC at 4.82%; Web + 3G combination reaches 6.60%
- **P2M adoption at only 35.06%** — 65% of transactions are non-merchant payments
- **36–45 age group** has highest avg ticket Rs.1,424 but worst failure rate 5.13%
- **Maharashtra leads volume** (37,427 txns); Uttar Pradesh has highest failure at 5.22%
- **Large transactions above Rs.25,000 fail at 13.51%** — nearly 3x the platform average
- **480 fraud-flagged transactions** — most common pattern: P2M + Shopping + 4G + Android

## Recommendations

1. **Bank Health Indicator** — Show real-time bank server status on payment screen before transaction initiation. Flag 3G users to switch to WiFi.
2. **Contextual Failure Messaging** — Replace generic error with "Bank under maintenance — retry in 2 minutes" + one-tap retry button. Triggered by hour and day failure patterns.
3. **P2M Re-engagement for 36–45 Segment** — Rs.25 cashback on first Education or Shopping P2M transaction for the highest-value but worst-experience age group.

## SQL Queries

14 queries covering: overall summary, failure by transaction type, failure by merchant category, hourly patterns, day-of-week patterns, monthly trends, P2P vs P2M split, value band distribution, bank failure analysis, device and network analysis, age group behavior, fraud pattern analysis, geographic analysis, and behavioral segmentation.

## Tools Used

`SQL Server Management Studio (SSMS)` `Microsoft Excel` `Tableau Public`

## Project Files

- [BRD Document](docs/BRD_UPIChurnSignals_v1.0.pdf)
- [SQL Queries](sql/UPITransactionsPA.sql)
- [Dashboard Screenshot — Platform Health](dashboard/dashboard_tab1_platform_health.png)
- [Dashboard Screenshot — Time Patterns](dashboard/dashboard_tab2_time_patterns.png)
- [Dashboard Screenshot — Segments](dashboard/dashboard_tab3_segments.png)

## Dataset Note

Dataset is synthetically generated to simulate real UPI transaction patterns while preserving privacy compliance — inspired by NPCI and RBI market data. No real user data is used in this analysis.

Raw dataset (250,000 rows) available at: https://www.kaggle.com/datasets/skullagos5246/upi-transactions-2024-dataset
A 50-row sample is included in the data/ folder to show the data structure.
