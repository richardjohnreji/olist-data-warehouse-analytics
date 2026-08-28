# Olist Data Warehouse & Analytics

An end-to-end Data Warehouse and Business Intelligence project built using the Brazilian E-Commerce Public Dataset by Olist.

This project demonstrates the journey from raw operational data to an analytics-ready data warehouse and Power BI reporting solution.

The project covers:

**Business Understanding → Data Warehouse Design → Python ETL → SQL Transformations → Data Quality Handling → Dimensional Modeling → Power BI Semantic Modeling → DAX → Business Analytics**

---

## Project Overview

Olist is a Brazilian e-commerce marketplace that connects customers, sellers, products, payments, deliveries, and customer reviews.

A simplified version of the business process is:

```text
Customer
   ↓
Browse Products
   ↓
Place Order
   ↓
Payment
   ↓
Seller Fulfillment
   ↓
Shipping & Delivery
   ↓
Customer Review
```

Each stage of this process generates operational data.

The goal of this project is to transform that raw data into a structured analytical environment that supports reliable reporting and business analysis.

The final solution separates the raw source data from the analytics layer and follows a layered Data Warehouse architecture.

---

# Business Objective

The objective is to build an analytics solution that helps analyze Olist's business performance and supports data-driven decision-making.

The project focuses on questions related to:

* Sales performance
* Business growth
* Product and category performance
* Customer behavior
* Seller performance
* Freight performance
* Time-based trends
* Regional analysis
* Operational performance

The project follows a business-first analytical approach:

```text
Business Objective
       ↓
Business Questions
       ↓
KPIs
       ↓
Data Model
       ↓
Analysis
       ↓
Dashboard
       ↓
Business Insights
```

---

# Business Questions

The project is structured around several major analytical themes.

## 1. Business Growth

* How is sales performance changing over time?
* Which categories contribute the most to sales?
* How does performance vary across different periods?
* Where are the strongest and weakest areas of the business?

## 2. Sales Performance

* What are total sales and total orders?
* Which product categories generate the highest sales?
* How does sales performance change over time?
* What is the average order value?

## 3. Customer Analysis

* How many customers generated sales?
* How should unique customers be distinguished from customer records?
* How can customer activity be analyzed through the warehouse model?

## 4. Freight Analysis

* How much freight cost is associated with sales?
* What is the average freight cost per order?
* What percentage of sales is represented by freight?

## 5. Strategic Decision Support

* Which areas deserve additional business attention?
* Which categories contribute most significantly to sales?
* How can KPIs and trends support management decisions?

---

# Solution Architecture

The project follows a layered Data Warehouse architecture.

```text
                    Olist Source Data
                           │
                           ▼
                    ┌─────────────┐
                    │   BRONZE    │
                    │  Raw Data   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   SILVER    │
                    │   Cleaned   │
                    │ Standardized│
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    GOLD     │
                    │ Analytics-  │
                    │ Ready Model │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  POWER BI   │
                    │  Semantic   │
                    │    Model    │
                    └──────┬──────┘
                           │
                           ▼
                    Business Analytics
```

### Architecture Principle

Each layer has a specific responsibility:

| Layer    | Purpose                                                      |
| -------- | ------------------------------------------------------------ |
| Bronze   | Store source data in raw form                                |
| Silver   | Clean, standardize, validate, and transform data             |
| Gold     | Provide an analytics-ready dimensional model                 |
| Power BI | Create the semantic model, measures, visuals, and dashboards |

Bronze and Silver tables are not used directly for reporting.

Power BI consumes the analytics-ready Gold layer.

---

# Data Warehouse

## Bronze Layer

The Bronze layer stores the Olist source data with minimal transformation.

The source data includes:

* Customers
* Geolocation
* Sellers
* Products
* Product category translations
* Orders
* Order items
* Order payments
* Order reviews

The ingestion process was implemented using Python and SQL Server.

The purpose of the Bronze layer is to preserve the source data inside the Data Warehouse environment before business transformations are applied.

---

## Silver Layer

The Silver layer transforms raw Bronze data into cleaner and more standardized data.

The transformation process includes:

* Data cleansing
* Text standardization
* Data validation
* Deduplication
* Foreign-key validation
* Handling data-quality issues
* Business-oriented transformations

### Data Quality Example: Geolocation

A significant data-quality issue was identified in the geolocation data.

Duplicate records existed because of factors such as:

* Variations in city spelling
* Floating-point coordinate precision differences

The transformation process included coordinate normalization and `ROW_NUMBER()`-based deduplication.

### Data Quality Example: Product Categories

Product category relationships and foreign-key issues were investigated during the transformation process.

These issues were handled as part of the Silver-layer data preparation before building the analytical model.

This reflects an important real-world engineering principle:

> Data engineering is not only about loading data. It also involves discovering, investigating, and resolving data-quality problems.

---

# Gold Layer

The Gold layer provides the analytics-ready model used by Power BI.

The project uses dimensional modeling and follows a Star Schema design.

## Dimensions

* `gold.dim_customers`
* `gold.dim_products`
* `gold.dim_sellers`
* `gold.dim_dates`

## Fact Table

* `gold.fact_sales`

The model can be represented as:

```text
                   dim_dates
                       │
                       │
                       ▼
dim_customers ───► fact_sales ◄─── dim_products
                       ▲
                       │
                   dim_sellers
```

The fact table stores measurable business events, while dimension tables provide the descriptive context required to analyze those events.

---

# Dimensional Modeling

The Gold layer follows dimensional modeling principles.

## Fact Table

`gold.fact_sales` represents the measurable sales activity used for analysis.

Examples of analytical measures include:

* Product sales
* Freight amounts
* Order-related metrics

## Dimension Tables

The dimensions provide context for analyzing the facts.

### Customer Dimension

Used to analyze customer-related activity.

### Product Dimension

Used to analyze products and product categories.

### Seller Dimension

Used to analyze seller-related performance.

### Date Dimension

Used to analyze business performance across time.

---

# Customer Identifier Design

An important modeling concept in this project is the difference between a technical customer identifier and the actual unique customer identifier.

### `customer_id`

Represents an individual customer record and is used as the appropriate relationship key in the warehouse model.

### `customer_unique_id`

Represents the actual unique customer.

A single real customer can appear in multiple customer records.

This means:

```text
One Real Customer
       │
       ├── Customer Record 1
       ├── Customer Record 2
       └── Customer Record 3
```

The warehouse model therefore preserves both concepts:

* The appropriate technical identifier for relationships
* The unique customer identifier for customer-level analysis

This distinction prevents incorrect customer counts and demonstrates the importance of understanding business keys versus relationship keys.

---

# Power BI Semantic Model

The Gold layer is imported into Power BI to create the semantic model.

The current model contains:

```text
gold.dim_customers
gold.dim_products
gold.dim_sellers
gold.dim_dates
gold.fact_sales
```

The semantic model follows Star Schema principles and uses:

* One-to-many relationships
* Active relationships
* Single-direction filtering
* Technical relationship keys
* Hidden technical columns where appropriate
* A dedicated Date table
* Chronological month sorting

The Date table contains fields including:

* Date
* Year
* Quarter
* Month
* Month Name
* Day
* Day of Week
* Weekday
* Is Weekend

The Date table is configured for time-intelligence analysis.

---

# DAX and KPI Development

Business measures are organized in a dedicated Power BI Measure Table using Display Folders.

This improves model organization and separates reusable business logic from the underlying tables.

## Sales KPIs

* Total Sales
* Total Orders
* Average Order Value

## Customer KPIs

* Total Customers
* Customers With Sales

## Freight KPIs

* Total Freight Cost
* Average Freight per Order
* Freight % of Sales

## Time Intelligence

The Power BI model also includes time-based analysis using the Date dimension.

The project has progressed beyond basic KPI development into sales trend and growth analysis.

The analytical work includes concepts such as:

* Year-to-date sales
* Year-over-year comparison
* Monthly sales trends
* Sales growth analysis

The focus throughout the project has been on understanding:

* Filter context
* Filter propagation
* Date context
* Measure reusability
* Business meaning behind DAX calculations

rather than simply memorizing formulas.

---

# KPI Validation Checkpoints

The following results were used as validation checkpoints during Power BI development.

| KPI                       |            Result |
| ------------------------- | ----------------: |
| Total Sales               |            15.84M |
| Total Orders              | Approximately 99K |
| Total Customers           | Approximately 96K |
| Average Order Value       |            160.58 |
| Total Freight Cost        |             2.25M |
| Average Freight per Order |             22.82 |
| Freight % of Sales        |             14.2% |

These values were validated against the analytical model during development.

### Example Filter Validation

For the `furniture_bedroom` category:

| KPI                  | Result |
| -------------------- | -----: |
| Total Sales          | 24.66K |
| Total Orders         |     95 |
| Customers With Sales |     91 |
| Average Order Value  | 259.59 |

These filtered results were used to validate that relationships, filter propagation, and DAX measures behaved correctly.

---

# Analytics and Dashboard Development

The Power BI analytics layer includes KPI and performance analysis built on top of the Gold-layer Star Schema.

The dashboard development process focuses on presenting business information in a structured way rather than simply displaying individual charts.

Analytical areas developed in the project include:

* Sales KPIs
* Sales performance
* Category performance
* Time-based analysis
* Year-to-date analysis
* Year-over-year growth
* Freight analysis

The dashboards are designed around business questions and KPI interpretation.

---

# Technology Stack

| Area                  | Technology                         |
| --------------------- | ---------------------------------- |
| Source Data           | Olist Brazilian E-Commerce Dataset |
| Programming           | Python                             |
| Database              | Microsoft SQL Server               |
| ETL                   | Python                             |
| Data Transformation   | SQL                                |
| Data Warehouse        | SQL Server                         |
| Data Modeling         | Dimensional Modeling / Star Schema |
| Business Intelligence | Microsoft Power BI                 |
| Analytics             | DAX                                |
| Documentation         | Markdown                           |
| Version Control       | Git / GitHub                       |

---

# Project Structure

```text
olist-data-warehouse-analytics/
│
├── dashboards/
├── data/
├── docs/
├── python/
├── sql/
│   ├── bronze/
│   ├── gold/
│   ├── procedures/
│   ├── scripts/
│   ├── silver/
│   └── dd_database.sql
│
├── tests/
│
├── README.md
├── .gitignore
├── LICENSE
├── dataset/
└── requirements.txt
```

> The exact repository structure may evolve as additional documentation, validation scripts, and dashboard assets are added.

---

# Project Phases

| Phase   | Area                                       | Status    |
| ------- | ------------------------------------------ | --------- |
| Phase 1 | Business Understanding & Project Planning  | Completed |
| Phase 2 | Database Design                            | Completed |
| Phase 3 | Bronze Layer Design                        | Completed |
| Phase 4 | Python ETL                                 | Completed |
| Phase 5 | Silver Layer                               | Completed |
| Phase 6 | Gold Layer & Dimensional Modeling          | Completed |
| Phase 7 | Power BI Analytics & Dashboard Development | Completed |

---

# Skills Demonstrated

## Data Engineering

* Python ETL development
* CSV data ingestion
* SQL Server integration
* Bronze-layer architecture
* Data loading
* ETL execution
* Error investigation
* Data validation

## Analytics Engineering

* Data cleansing
* Data standardization
* Data-quality investigation
* Deduplication
* Foreign-key validation
* Dimensional modeling
* Fact and dimension design
* Technical and business key analysis
* Star Schema design
* Analytics-ready Gold layer development

## Business Intelligence and Analytics

* Power BI
* Semantic modeling
* Relationship design
* DAX
* KPI development
* Measure organization
* Filter context
* Filter propagation
* Time intelligence
* Year-to-date analysis
* Year-over-year analysis
* Sales performance analysis
* Category analysis
* Freight analysis
* Dashboard development

---

# Key Engineering Lessons

This project involved working through practical data and modeling problems rather than assuming that the source data was already analytics-ready.

Important lessons included:

### 1. Raw Data Is Not Reporting Data

Operational source tables are designed to support transactions.

Analytical models are designed to answer business questions.

A transformation layer is required between them.

### 2. Data Quality Must Be Investigated

Duplicate records, inconsistent text, precision differences, and missing relationships can affect downstream analysis.

These issues must be identified and handled before building analytical models.

### 3. Relationship Keys Matter

A technical identifier and a business identifier can represent different concepts.

Choosing the wrong key can produce incorrect results.

### 4. Star Schemas Simplify Analytics

Separating facts from dimensions makes the model easier to understand and improves analytical flexibility.

### 5. DAX Depends on Context

Measures do not simply calculate fixed values.

Their results depend on the filters and relationships active in the report.

---

# Portfolio Value

This project demonstrates more than dashboard creation.

It shows an end-to-end analytical workflow:

```text
Raw Data
   ↓
Data Ingestion
   ↓
Data Cleaning & Validation
   ↓
Data Warehouse
   ↓
Dimensional Modeling
   ↓
Power BI Semantic Model
   ↓
DAX Measures
   ↓
Business Analysis
   ↓
Dashboard
```

The project demonstrates skills across multiple areas:

* Data Engineering
* SQL Development
* ETL
* Data Warehousing
* Data Quality
* Dimensional Modeling
* Analytics Engineering
* Power BI
* DAX
* Business Analysis
* Data Visualization
* Git and GitHub documentation

---

# Project Status

**Status: Core Data Warehouse and Power BI Analytics Development Completed**

The project currently includes:

* Bronze Data Layer
* Python-based data ingestion
* Silver data transformations
* Data-quality handling
* Gold analytical layer
* Star Schema
* Power BI semantic model
* DAX KPI development
* KPI validation
* Time-based analysis
* Power BI dashboard development

Further enhancements can be added to extend the analytical scope.

---

# Future Improvements

Potential future improvements include:

* Expanded customer segmentation
* Customer retention and repeat-purchase analysis
* Delivery performance analysis
* Customer review analysis
* Additional seller-performance analysis
* Automated pipeline orchestration
* Expanded automated data-quality testing
* Additional Gold-layer business views
* Advanced DAX calculations
* Additional executive dashboards
* Enhanced documentation and data lineage

---

# Dataset

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains information related to:

* Customers
* Orders
* Order items
* Payments
* Products
* Sellers
* Geolocation
* Product categories
* Customer reviews

The original dataset is publicly available on Kaggle.

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

# Project Philosophy

The project follows a business-first approach.

```text
Understand the Business
        ↓
Understand the Data
        ↓
Design the Architecture
        ↓
Build the Data Warehouse
        ↓
Create the Analytical Model
        ↓
Build the Semantic Model
        ↓
Create Business Measures
        ↓
Analyze Performance
        ↓
Communicate Insights
```

The central principle behind this project is:

> Technology is used to support business decisions. The business problem determines how the technology should be applied.

---

# About This Project

This project was developed as a portfolio project focused on understanding how an end-to-end analytics solution is designed and implemented.

Rather than focusing on a single tool, the project demonstrates the complete progression from raw data to business analysis:

**Raw Data → Data Engineering → Data Warehouse → Analytics Engineering → Semantic Modeling → DAX → Business Intelligence**

The objective was to build and understand the full analytics workflow, including the technical decisions, data-quality issues, modeling concepts, and business reasoning involved in creating a reliable analytical solution.
