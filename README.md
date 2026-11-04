# SQL-Based Data Quality Assessment
### Olist Brazilian E-Commerce Dataset

## Project Overview

This project presents a comprehensive SQL-based Data Quality Assessment of the Olist Brazilian E-Commerce dataset using MySQL Workbench.

The assessment focuses on evaluating the completeness, uniqueness, validity, consistency, and referential integrity of customer, order, and payment data. SQL queries were developed to identify potential data quality issues, validate relationships, analyze data patterns, and generate actionable business insights.

The findings are translated into a professional executive report with recommendations for improving data reliability and supporting informed business decision-making.

## Business Objective

The primary objective is to assess the reliability and usability of e-commerce data for business analytics and reporting.

Key objectives include:

- Evaluate data completeness and identify missing or blank values.
- Detect duplicate records and validate unique identifiers.
- Verify referential integrity across relational tables.
- Identify invalid values and unexpected data categories.
- Assess consistency in order lifecycle timestamps.
- Analyze payment patterns and potential anomalies.
- Develop recommendations for strengthening data quality controls.

## Dataset

**Source:** [Olist Brazilian E-Commerce Dataset – Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The analysis covers three relational datasets:

- **Customers:** Customer identifiers and geographic information.
- **Orders:** Order identifiers, order statuses, and lifecycle timestamps.
- **Order Payments:** Payment methods, installment counts, and transaction values.

The dataset contains approximately 100K order records and provides a practical foundation for real-world data quality analysis.

## Tools & Technologies

- MySQL
- MySQL Workbench
- SQL
- Microsoft Excel
- Microsoft Word
- GitHub

## Data Quality Assessment

The assessment includes the following dimensions:

### 1. Data Completeness
Evaluated missing values, NULLs, and blank fields across customer, order, and payment attributes.

### 2. Data Uniqueness
Identified duplicate customer IDs, order IDs, and payment composite keys.

### 3. Referential Integrity
Validated relationships between customers and orders, and between orders and payments.

### 4. Data Validity
Checked order status values, payment types, Brazilian state codes, and ZIP code prefix ranges against defined rules.

### 5. Data Consistency
Reviewed order lifecycle timestamps to identify potential chronology issues and status-date inconsistencies.

### 6. Outlier and Anomaly Detection
Analyzed negative, zero, and unusually high payment values for further review.

### 7. Data Profiling
Examined order status distributions, payment method patterns, customer geography, and payment value statistics.

### 8. Record Reconciliation
Compared imported database record counts against the dataset reference counts.

## Key Findings

The assessment established a positive structural baseline across the selected datasets.

- Imported customer, order, and payment record counts matched the dataset reference counts.
- No unmatched customer-order references were identified in the assessed relationship check.
- No unmatched payment-order references were identified in the assessed relationship check.
- The tested identifiers and composite keys showed no reported duplicates.
- The assessed category and geographic validation checks returned no reported unexpected values.
- Blank timestamp representations require improved completeness validation.
- Nine zero-value payment records and two zero-installment records were identified for contextual review.
- Selected order timestamp sequence exceptions require further investigation.

**Note:** Some exception queries use LIMIT 100 and return sample records rather than complete population counts. Findings are interpreted accordingly.

## Recommendations

Based on the assessment, the following improvements are recommended:

- Implement completeness rules that detect NULL, blank, and placeholder values.
- Establish lifecycle-aware validation rules for order timestamps.
- Investigate timestamp sequence anomalies using source records.
- Define documented business rules for zero-value payments and installment exceptions.
- Automate recurring SQL-based data quality checks.
- Establish a data quality rule catalogue with thresholds, severity levels, and ownership.
- Maintain structured exception reporting and remediation tracking.
- Preserve source data and apply approved corrections through controlled data processing layers.

## Project Structure

```text
Olist-Data-Quality-Assessment/
│
├── README.md
│
├── SQL/
│   └── Olist_Data_Quality_Assessment.sql
│
├── Report/
│   └── Executive_Data_Quality_Assessment_Report.docx
│
├── Results/
│   └── SQL_Output_Results.xlsx
│
└── Screenshots/
    └── SQL_Output_Screenshots/
