# Netflix Customer Churn – Advanced SQL Project

## Explanation & Business Insights

---

## 1️⃣ Project Overview

**Goal:** Analyze Netflix customer data to identify churn drivers, calculate churn risk, and generate actionable retention targets.

**Tools Used:** SQL (data cleaning, feature engineering, scoring) and Power BI (dashboard visuals).

**Key Steps:**
1. Data Cleaning & Standardization
2. Feature Engineering (Engagement & Satisfaction Levels)
3. Churn Scoring Model
4. Customer Segmentation
5. KPI Overview
6. Business Insights & Actionable Outputs

---

## 2️⃣ Step-by-Step Explanation with Outcomes

### STEP 1: DATA CHECK & INITIAL EXPLORATION

**Query Example:**
```sql
SELECT COUNT(*) AS total_customers FROM user_data;
SELECT churn_status, COUNT(*) AS users FROM user_data GROUP BY churn_status;
```
**Explanation:** Checked total customers and churn distribution.
**Outcome:** Total customers: `X`; Churned users: `Y%`.

### STEP 2: DATA CLEANING / STANDARDIZATION

**Query Example:**
```sql
UPDATE user_data SET churn_status = LOWER(churn_status);
UPDATE user_data SET payment_history = CASE WHEN payment_history = 'On-Time' THEN 'on_time' ELSE 'delayed' END;
```
**Explanation:** Standardized churn and payment history values.
**Outcome:** Ready for analysis and risk calculations.

### STEP 3: CLEAN ANALYTICAL VIEW

**Query Example:**
```sql
CREATE OR REPLACE VIEW netflix_clean_data AS
SELECT customer_id, subscription_length_months, customer_satisfaction_score,
       daily_watch_time_hours, engagement_rate, LOWER(device_used_most_often) AS device_used_most_often,
       LOWER(region) AS region, payment_history, subscription_plan, churn_status,
       support_queries_logged, age, monthly_income, promotional_offers_used, number_of_profiles_created
FROM user_data;
```
**Explanation:** Created a clean dataset for analysis.
**Outcome:** `netflix_clean_data` contains all standardized customer features.

### STEP 4: FEATURE ENGINEERING

**Query Example:**
```sql
CREATE OR REPLACE VIEW v_netflix_features AS
SELECT *,
    CASE WHEN daily_watch_time_hours >= 4 THEN 'high'
         WHEN daily_watch_time_hours >= 2 THEN 'medium'
         ELSE 'low' END AS engagement_level,
    CASE WHEN customer_satisfaction_score >= 8 THEN 'satisfied'
         WHEN customer_satisfaction_score >= 5 THEN 'neutral'
         ELSE 'unsatisfied' END AS satisfaction_level
FROM netflix_clean_data;
```
**Explanation:** Added engagement and satisfaction levels.
**Outcome:** Ready for segmentation and churn scoring.

### STEP 5: CHURN RISK SCORING

**Query Example:**
```sql
CREATE OR REPLACE VIEW v_netflix_churn_score AS
SELECT *,
    (CASE WHEN engagement_level='low' THEN 30 ELSE 0 END +
     CASE WHEN satisfaction_level='unsatisfied' THEN 30 ELSE 0 END +
     CASE WHEN payment_history='delayed' THEN 20 ELSE 0 END +
     CASE WHEN support_queries_logged>=5 THEN 20 ELSE 0 END) AS churn_risk_score
FROM v_netflix_features;
```
**Explanation:** Calculated total churn risk score based on business logic.
**Outcome:** High scores indicate high-risk customers.

### STEP 6: CUSTOMER SEGMENTATION

**Query Example:**
```sql
CREATE OR REPLACE VIEW v_netflix_segments AS
SELECT *,
    CASE WHEN churn_risk_score >= 70 THEN 'high_risk'
         WHEN churn_risk_score >= 40 THEN 'medium_risk'
         ELSE 'low_risk' END AS churn_segment
FROM v_netflix_churn_score;
```
**Explanation:** Segmented customers into high, medium, and low risk.
**Outcome:** Enables targeted retention strategies.

### STEP 7: KPI OVERVIEW

**Query Example:**
```sql
CREATE OR REPLACE VIEW v_kpi_overview AS
SELECT COUNT(*) AS total_users,
       ROUND(SUM(churn_status='yes')*100.0/COUNT(*),2) AS churn_rate,
       ROUND(AVG(daily_watch_time_hours),2) AS avg_watch_time,
       ROUND(AVG(customer_satisfaction_score),2) AS avg_satisfaction
FROM netflix_clean_data;
```
**Explanation:** Aggregated KPIs for executive insights.
**Outcome:** Metrics for dashboard: total users, churn rate, avg engagement & satisfaction.

### STEP 8: BUSINESS INSIGHTS

| Question | Query Used | Insight |
|----------|------------|--------|
| Which subscription plan churns most? | Churn by subscription plan | Basic plan has highest churn → retention needed |
| Does engagement impact churn? | Engagement vs Churn | Low engagement → higher churn |
| Does satisfaction affect churn? | Satisfaction impact on churn | Unsatisfied users → highest churn |
| Does payment behavior affect churn? | Payment behavior risk | Delayed payments → higher churn |
| Do support queries indicate churn risk? | Support usage vs churn | High support usage → higher churn |

### STEP 9: HIGH-RISK TARGETS

**Query Example:**
```sql
CREATE OR REPLACE VIEW v_retention_targets AS
SELECT customer_id, churn_risk_score, subscription_plan, monthly_income
FROM v_netflix_segments
WHERE churn_segment='high_risk'
ORDER BY churn_risk_score DESC
LIMIT 50;
```
**Explanation:** Top 50 high-risk customers for retention campaigns.
**Outcome:** Actionable customer list for marketing and engagement.

### STEP 10: ADVANCED ANALYTICS

**Window Function:**
```sql
SELECT *, RANK() OVER (ORDER BY customer_satisfaction_score ASC, daily_watch_time_hours ASC, engagement_rate ASC) AS churn_risk_rank
FROM netflix_clean_data;
```
**Explanation:** Ranked customers based on multiple churn indicators.

**Top Value Customers:**
```sql
SELECT * FROM netflix_clean_data ORDER BY monthly_income DESC, daily_watch_time_hours DESC LIMIT 10;
```
**Insight:** High-value users prioritized for retention.

### STEP 11: CONCLUSION & RECOMMENDATIONS

**Key Insights:**
1. Low engagement and low satisfaction → highest churn risk
2. Payment delays and high support usage → additional churn indicators
3. High-value customers need proactive retention

**Recommendations:**
- Target high-risk users with personalized campaigns
- I