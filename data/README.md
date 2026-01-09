# CSV Data Description

This folder contains the CSV files used in the Netflix Churn Analysis project. Each file represents a stage of the data pipeline or output from SQL views that support the dashboard and analysis.

| CSV File Name                    | Source / SQL View             | Description |
|---------------------------------|-------------------------------|------------|
| high_risk_customers.csv          | v_retention_targets           | Top high-risk customers (e.g., churn risk score ≥ 70) for retention targeting. |
| netflix_customer_segments.csv    | v_netflix_segments            | Customer segmentation table showing high, medium, and low churn risk segments. |
| netflix_kpi_summary.csv          | v_kpi_overview                | KPI summary: total users, churn rate, average engagement, and average satisfaction. |
| netflix_large_user_data.csv      | v_netflix_clean               | Base clean dataset after data cleaning and standardization. Contains all raw features. |
| netflix_features.csv             | v_netflix_features            | Feature-engineered dataset with engagement and satisfaction levels for analysis. |





