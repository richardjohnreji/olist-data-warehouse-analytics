# Olist Data Warehouse & Analytics

An end-to-end e-commerce analytics project built around the Olist Brazilian E-Commerce dataset.

The project demonstrates the complete journey from **business understanding and raw data ingestion to data warehousing, dimensional modeling, Power BI semantic modeling, DAX, and business analytics**.

The goal is to build an analytics solution that transforms raw business data into reliable information that can support business decision-making.

---

## Project Overview

Olist is an e-commerce marketplace that connects sellers with customers.

The business process can be simplified as:

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

Each stage generates data.

This project takes that raw operational data and builds a structured analytical environment that can be used to answer questions about:

* Business growth
* Sales performance
* Customer behavior
* Product performance
* Seller performance
* Operational efficiency
* Time-based sales trends

---

## Business Objective

The project is designed to help Olist analyze its business performance and identify insights that can support better decision-making.

The analysis focuses on understanding:

* How the business is generating revenue
* Which products and categories drive sales
* Which sellers perform well
* How customer behavior changes over time
* What affects customer satisfaction
* Where operational bottlenecks may exist
* How sales performance changes over time
* Which areas may require business attention or improvement

The project follows the principle:

```text
Business Objective
       ↓
Business Questions
       ↓
KPIs
       ↓
Analysis
       ↓
Dashboard
       ↓
Business Decision
```

---

## Business Questions

The project is designed around five major business themes.

### 1. Business Growth

* Is Olist growing?
* Which categories drive revenue?
* Which regions underperform?
* Where is revenue being lost?

### 2. Customer Experience

* What affects customer satisfaction?
* Which sellers receive poor reviews?
* Which products generate complaints?
* How can customer satisfaction improve?

### 3. Operational Efficiency

* Where are operational bottlenecks?
* How efficient is delivery?
* What causes delays?

### 4. Sales Performance

* How are sales changing over time?
* Which products perform best?
* Which sellers generate the most revenue?

### 5. Strategic Decision Support

* Which areas deserve investment?
* Which problems should be prioritized?
* Which opportunities have the biggest business impact?

---

# Architecture

The project follows a layered Data Warehouse architecture:

```text
                    Olist Source Data
                           │
                           ▼
                    ┌─────────────┐
                    │   BRONZE    │
                    │ Raw Data    │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   SILVER    │
                    │ Cleaned &   │
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

The Gold layer acts as the business-facing analytical layer consumed by Power BI. Bronze and Silver tables are not connected directly to the Power BI model.

---

# Data Warehouse

## Bronze Layer

The Bronze layer stores the source data in its raw form.

The Python ETL pipeline loads the Olist CSV files into SQL Server.

The source data includes entities such as:

* Customers
* Geolocation
* Sellers
* Products
* Product category translations
* Orders
* Order items
* Order payments
* Order reviews

The Bronze loading process was implemented using Python and SQL Server.

---

## Silver Layer

The Silver layer transforms Bronze data into cleaner and standardized business data.

Transformations include:

* Text cleansing
* Standardization
* Data validation
* Deduplication
* Handling data-quality problems
* Foreign-key validation
* Business-oriented transformations

A significant data-quality issue was discovered in the geolocation data.

Duplicate records were caused by differences in city spelling and floating-point coordinate precision. The solution included coordinate normalization and `ROW_NUMBER()` based deduplication.

Product-category foreign-key issues were also investigated and handled during the Silver transformation process.

---

## Gold Layer

The Gold layer provides the analytical data model used by reporting and BI tools.

The project uses a dimensional modeling approach with:

### Dimensions

* `gold.dim_customers`
* `gold.dim_products`
* `gold.dim_sellers`
* `gold.dim_dates`

### Fact

* `gold.fact_sales`

The model is designed around a Star Schema.

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

The fact table contains the measurable business events, while dimensions provide the descriptive context used to analyze those events.

---

# Power BI

The Gold layer is imported into Power BI to create the semantic model.

The current model contains:

```text
gold.dim_customers
gold.dim_products
gold.dim_sellers
gold.dim_dates
gold.fact_sales
```

The Power BI model uses:

* Star Schema
* One-to-Many relationships
* Active relationships
* Single-direction filtering
* Technical keys for relationships
* Hidden technical columns where appropriate
* A dedicated Date Table
* Chronological month sorting

The date table contains fields including:

* Date
* Year
* Quarter
* Month
* Month Name
* Day
* Day of Week
* Weekday
* Is Weekend

The Date Table has been marked appropriately for time-intelligence analysis.

---

# DAX & Semantic Modeling

Reusable business measures are organized in a dedicated Power BI Measure Table using Display Folders.

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

Time Intelligence is currently the next stage of the Power BI development.

Planned analysis includes:

* YTD Sales
* Monthly YoY
* YTD YoY
* Growth analysis
* Trend analysis

The project emphasizes understanding the business meaning and filter context behind DAX rather than simply memorizing formulas.

---

# Current KPI Checkpoints

Current Power BI results include:

| KPI                       |   Result |
| ------------------------- | -------: |
| Total Sales               | ≈ 15.84M |
| Total Orders              |    ≈ 99K |
| Total Customers           |    ≈ 96K |
| Average Order Value       |   160.58 |
| Total Freight Cost        |    2.25M |
| Average Freight per Order |    22.82 |
| Freight % of Sales        |    14.2% |

Example filtered result for `furniture_bedroom`:

| KPI                  | Result |
| -------------------- | -----: |
| Total Sales          | 24.66K |
| Total Orders         |     95 |
| Customers With Sales |     91 |
| Average Order Value  | 259.59 |

These values serve as validation checkpoints during Power BI development.

---

# Key Data Modeling Concepts

One of the important modeling decisions in the project is the distinction between technical identifiers and business identifiers.

For example:

### `customer_id`

Represents an individual customer record and is used for warehouse relationships.

### `customer_unique_id`

Represents the actual unique customer and can appear across multiple customer records.

This distinction is important because one real customer may have multiple customer records associated with different orders.

The project therefore uses the appropriate relationship key while retaining `customer_unique_id` for customer-centric analysis.

---

# Technology Stack

| Area            | Technology                         |
| --------------- | ---------------------------------- |
| Source Data     | Olist Brazilian E-Commerce Dataset |
| Programming     | Python                             |
| Database        | Microsoft SQL Server               |
| ETL             | Python                             |
| Transformation  | SQL                                |
| Data Warehouse  | SQL Server                         |
| Data Modeling   | Dimensional Modeling / Star Schema |
| BI              | Microsoft Power BI                 |
| Analytics       | DAX                                |
| Documentation   | Markdown                           |
| Version Control | Git / GitHub                       |

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
├── dataset
└── requirements.txt
```

---

# Project Phases

| Phase   | Area                                      | Status      |
| ------- | ----------------------------------------- | ----------- |
| Phase 1 | Business Understanding & Project Planning | Completed   |
| Phase 2 | Database Design                           | Completed   |
| Phase 3 | Bronze Layer                              | Completed   |
| Phase 4 | Python ETL                                | Completed   |
| Phase 5 | Silver Layer                              | Completed   |
| Phase 6 | Gold Layer                                | Completed   |
| Phase 7 | Power BI Analytics                        | In Progress |

---

# Skills Demonstrated

## Data Engineering

* Python ETL development
* CSV ingestion
* SQL Server integration
* Bronze layer design
* ETL logging
* Data validation
* Error investigation
* Pipeline execution

## Analytics Engineering

* Data cleansing
* Standardization
* Data quality handling
* Dimensional modeling
* Fact and dimension design
* Surrogate/technical keys
* Star Schema
* Gold analytical layer

## Data Analytics / BI

* Power BI
* Semantic modeling
* DAX
* KPI development
* Filter context
* Filter propagation
* Time Intelligence
* Sales analysis
* Customer analysis
* Freight analysis
* Business question development

---

# Data Quality & Engineering Lessons

The project intentionally documents real data problems encountered during implementation rather than assuming that source data is already clean.

Examples include:

* Duplicate geolocation records
* Floating-point precision differences
* City spelling variations
* Missing product category translations
* Foreign-key validation issues
* Distinguishing business identifiers from relationship keys

These issues demonstrate an important practical principle:

> Real-world data engineering involves discovering and solving data-quality problems, not simply loading tables.

---

# Business Analytics Roadmap

The next stages of the project will expand the Power BI analytical layer.

### Time Intelligence

* YTD Sales
* Monthly YoY
* YTD YoY
* Growth trends

### Sales Analytics

* Category performance
* Product performance
* Seller performance
* Regional performance

### Customer Analytics

* Customer behavior
* Customer purchasing patterns
* Customer retention-related analysis

### Operational Analytics

* Delivery performance
* Freight analysis
* Operational bottlenecks

### Customer Experience

* Review performance
* Seller satisfaction
* Product/customer experience relationships

### Executive Reporting

The final objective is to convert the analytical model into portfolio-quality Power BI reports that support business decision-making.

---

# Project Philosophy

This project follows a business-first approach.

The process is:

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
Create KPIs
        ↓
Analyze the Business
        ↓
Communicate Insights
```

The central lesson of the project is:

> Technology supports business decisions. Business problems drive the technology.

---

# Project Status

**Current Status: Phase 7 — Power BI Analytics**

The data warehouse and Gold analytical layer are complete.

The Power BI semantic model and core DAX KPI measures are also established.

The project is currently progressing through Time Intelligence and advanced business analytics before final report/dashboard development.

---

# Future Improvements

Potential future improvements include:

* Additional business-focused Gold views
* Expanded data-quality testing
* Automated pipeline orchestration
* More advanced DAX
* Customer segmentation
* Operational performance analysis
* Advanced Power BI dashboards
* Executive reporting
* Additional documentation
* Automated testing and validation

---

## About the Project

This project was developed as a practical learning and portfolio project to understand how an end-to-end analytics solution is designed and implemented.

It demonstrates the progression from:

**Raw Data → Data Engineering → Data Warehouse → Analytics Engineering → BI Modeling → DAX → Business Analytics**

rather than focusing on a single technology or dashboard.

---
