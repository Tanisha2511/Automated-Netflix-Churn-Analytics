/* =========================================================
   NETFLIX CUSTOMER CHURN – ADVANCED SQL PROJECT
   ========================================================= */

/* =========================
   STEP 1: DATA CHECK
   ========================= */
   
USE excel_db;

SELECT COUNT(*) AS total_customers
FROM user_data;

/*=======================================================================
INITIAL DATA EXPLORATION (EDA)
========================================================================*/
-- Churn distribution
SELECT 
    churn_status,
    COUNT(*) AS users
FROM user_data
GROUP BY churn_status;

-- Check missing or invalid values
SELECT *
FROM user_data
WHERE customer_satisfaction_score IS NULL
   OR daily_watch_time_hours IS NULL
   OR engagement_rate IS NULL;
   
SET SQL_SAFE_UPDATES = 0;

-- Standardize churn values
UPDATE user_data
SET churn_status = LOWER(churn_status);

-- Normalize payment history
UPDATE user_data
SET payment_history = 
    CASE 
        WHEN payment_history = 'On-Time' THEN 'on_time'
        ELSE 'delayed'
    END;

SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;

/*===============================================================
DATA STANDARDIZATION (DATA CLEANING – VALUES)
==============================================================*/
SET SQL_SAFE_UPDATES = 0;

-- Standardize churn values
UPDATE user_data
SET churn_status = LOWER(churn_status);

-- Normalize payment history
UPDATE user_data
SET payment_history = 
    CASE 
        WHEN payment_history = 'On-Time' THEN 'on_time'
        ELSE 'delayed'
    END;

SET SQL_SAFE_UPDATES = 1;

-- Create clean analytical view
CREATE OR REPLACE VIEW netflix_clean_data AS
SELECT
    customer_id,
    subscription_length_months,
    customer_satisfaction_score,
    daily_watch_time_hours,
    engagement_rate,
    LOWER(device_used_most_often) AS device_used_most_often,
    LOWER(region) AS region,
    payment_history,
    subscription_plan,
    churn_status,
    support_queries_logged,
    age,
    monthly_income,
    promotional_offers_used,
    number_of_profiles_created
FROM user_data;

select * from netflix_clean_data;
SELECT payment_history, COUNT(*) AS users
FROM netflix_clean_data
GROUP BY payment_history;

/*====================================================================
FEATURE ENGINEERING (ADVANCED ANALYSIS)
===================================================================*/
CREATE OR REPLACE VIEW v_netflix_features AS
SELECT *,
    CASE
        WHEN daily_watch_time_hours >= 4 THEN 'high'
        WHEN daily_watch_time_hours >= 2 THEN 'medium'
        ELSE 'low'
    END AS engagement_level,
    CASE
        WHEN customer_satisfaction_score >= 8 THEN 'satisfied'
        WHEN customer_satisfaction_score >= 5 THEN 'neutral'
        ELSE 'unsatisfied'
    END AS satisfaction_level
FROM netflix_clean_data;

CREATE OR REPLACE VIEW v_netflix_features AS
SELECT
    *,
    
    -- ✅ SAFE PAYMENT NORMALIZATION (VIEW LEVEL)
    CASE
        WHEN LOWER(payment_history) IN ('on-time', 'on_time') THEN 'on_time'
        WHEN LOWER(payment_history) = 'delayed' THEN 'delayed'
        ELSE payment_history
    END AS payment_status_clean,

    -- Satisfaction bucket
    CASE
        WHEN customer_satisfaction_score >= 8 THEN 'satisfied'
        WHEN customer_satisfaction_score >= 5 THEN 'neutral'
        ELSE 'unsatisfied'
    END AS satisfaction_level

FROM netflix_clean_data;

select * from v_netflix_features;

/*====================================================================
CHURN RISK SCORING MODEL (BUSINESS LOGIC)
======================================================================*/
CREATE OR REPLACE VIEW v_netflix_churn_score AS
SELECT *,
    (
        CASE WHEN engagement_level = 'low' THEN 30 ELSE 0 END +
        CASE WHEN satisfaction_level = 'unsatisfied' THEN 30 ELSE 0 END +
        CASE WHEN payment_history = 'delayed' THEN 20 ELSE 0 END +
        CASE WHEN support_queries_logged >= 5 THEN 20 ELSE 0 END
    ) AS churn_risk_score
FROM v_netflix_features;

/*========================================================
CUSTOMER SEGMENTATION (INSIGHTS)
=====================================================*/
CREATE OR REPLACE VIEW v_netflix_segments AS
SELECT *,
    CASE
        WHEN churn_risk_score >= 70 THEN 'high_risk'
        WHEN churn_risk_score >= 40 THEN 'medium_risk'
        ELSE 'low_risk'
    END AS churn_segment
FROM v_netflix_churn_score;
SELECT * FROM v_netflix_segments;


/*======================================================
KPI DASHBOARD VIEW (EXECUTIVE METRICS)
======================================================*/
CREATE OR REPLACE VIEW v_kpi_overview AS
SELECT
    COUNT(*) AS total_users,
    ROUND(SUM(churn_status='yes')*100.0/COUNT(*),2) AS churn_rate,
    ROUND(AVG(daily_watch_time_hours),2) AS avg_watch_time,
    ROUND(AVG(customer_satisfaction_score),2) AS avg_satisfaction
FROM netflix_clean_data;

SELECT * FROM v_kpi_overview;

/*=======================================================
BUSINESS INSIGHTS QUERIES (EDA + ANALYSIS)
========================================================*/

-- Churn by Subscription Plan
SELECT 
    subscription_plan,
    ROUND(
        SUM(CASE WHEN churn_status = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM netflix_clean_data
GROUP BY subscription_plan;


-- Engagement vs Churn
SELECT 
    engagement_level,
    churn_status,
    COUNT(*) AS users
FROM v_netflix_features
GROUP BY engagement_level, churn_status;

-- Satisfaction Impact on Churn
SELECT
    satisfaction_level,
    ROUND(
        SUM(CASE WHEN churn_status = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM v_netflix_features
GROUP BY satisfaction_level;

-- Payment Behavior Risk
SELECT
    payment_history,
    churn_status,
    COUNT(*) AS users
FROM netflix_clean_data
GROUP BY payment_history, churn_status;

-- Support Usage vs Churn
SELECT
    CASE
        WHEN support_queries_logged >= 5 THEN 'High Support Usage'
        ELSE 'Low Support Usage'
    END AS support_bucket,
    churn_status,
    COUNT(*) AS users
FROM netflix_clean_data
GROUP BY support_bucket, churn_status;

-- HIGH-RISK CUSTOMER TARGET LIST (ACTIONABLE OUTPUT
CREATE OR REPLACE VIEW v_retention_targets AS
SELECT
    customer_id,
    churn_risk_score,
    subscription_plan,
    monthly_income
FROM v_netflix_segments
WHERE churn_segment = 'high_risk'
ORDER BY churn_risk_score DESC
LIMIT 50;

SELECT * FROM v_retention_targets;


-- ADVANCED ANALYTICS (WINDOW FUNCTIONS)
-- Rank customers by churn risk indicators
SELECT *,
    RANK() OVER (
        ORDER BY
            customer_satisfaction_score ASC,
            daily_watch_time_hours ASC,
            engagement_rate ASC
    ) AS churn_risk_rank
FROM netflix_clean_data;

-- TOP VALUE CUSTOMERS (BUSINESS VALUE)

-- Top 10 most valuable customers 
SELECT * FROM netflix_clean_data 
ORDER BY monthly_income DESC, 
daily_watch_time_hours DESC
 LIMIT 10;

















