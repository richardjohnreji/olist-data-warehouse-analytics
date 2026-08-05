# Olist Data Warehouse & Analytics

An end-to-end Data Warehouse and Analytics project built using the Brazilian Olist E-commerce Dataset. This project demonstrates how raw transactional data can be transformed into an analytics-ready data warehouse using SQL Server, Python ETL pipelines, dimensional modeling, and business intelligence principles.

The project follows a modern Medallion Architecture (Bronze, Silver, and Gold) and implements a Star Schema to support analytical reporting and decision-making.

---

## Project Overview

The objective of this project is to design and build a modern data warehouse that simulates how enterprise analytics platforms are developed in real organizations.

The project covers the complete data lifecycle:

- Understanding business requirements
- Designing the data warehouse
- Building ETL pipelines
- Cleaning and validating data
- Creating analytics-ready data models
- Developing business KPIs
- Building interactive dashboards

---

## Business Domain

The dataset represents an e-commerce marketplace and contains information about:

- Customers
- Sellers
- Orders
- Order Items
- Products
- Product Categories
- Payments
- Customer Reviews
- Geolocations

The data warehouse enables business users to analyze sales performance, customer behavior, product performance, seller performance, and delivery metrics.

---

## Project Architecture

```
                Source CSV Files
                        │
                        ▼
                Bronze Layer
              (Raw Source Data)
                        │
                        ▼
                Silver Layer
        (Cleaned & Standardized Data)
                        │
                        ▼
                 Gold Layer
          (Business Data Models)
                        │
                        ▼
             Power BI Dashboards
```

---

## Data Warehouse Layers

### Bronze Layer

The Bronze layer stores raw source data exactly as received from the source files.

Responsibilities:

- Raw data ingestion
- Source preservation
- Historical storage
- No business transformations

---

### Silver Layer

The Silver layer cleans, validates, and standardizes the data before preparing it for analytics.

Responsibilities:

- Data cleaning
- Data validation
- Standardization
- Data quality checks
- Fact and Dimension loading

---

### Gold Layer

The Gold layer provides business-ready datasets for reporting and analytics.

Responsibilities:

- Business KPIs
- Aggregated metrics
- Analytical views
- Dashboard-ready tables

---

## Technologies Used

### Database

- Microsoft SQL Server

### Programming

- Python
- Pandas

### Data Engineering

- ETL Pipelines
- Data Validation
- Data Cleaning
- Logging
- Error Handling

### Data Modeling

- Star Schema
- Fact Tables
- Dimension Tables

### Business Intelligence

- Power BI

### Version Control

- Git
- GitHub

---

## Roles Demonstrated

This project demonstrates responsibilities across multiple data disciplines involved in building a modern analytics platform.

### Data Engineer

- Designed the SQL Server Data Warehouse
- Built Bronze and Silver data layers
- Developed Python ETL pipelines
- Loaded and transformed source data
- Implemented data validation and quality checks
- Created reusable ETL components

### Analytics Engineer

- Designed the dimensional Star Schema
- Created Fact and Dimension tables
- Built analytics-ready datasets
- Standardized business entities
- Optimized data for reporting

### Data Analyst

- Performed business understanding and data exploration
- Designed business KPIs
- Built reporting-ready datasets
- Created dashboards for business analysis
- Generated business insights and recommendations

---

## Repository Structure

```
olist-data-warehouse-analytics/

├── data/
│
├── docs/
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   ├── procedures/
│   └── scripts/
│
├── python/
│   └── olist_dw/
│
├── dashboards/
│
├── tests/
│
├── README.md
│
├── requirements.txt
│
└── LICENSE
```

---

## Skills Demonstrated

### SQL

- Database Design
- Data Warehousing
- Constraints
- Views
- Stored Procedures
- Joins
- Query Optimization

### Python

- ETL Development
- Modular Programming
- Pandas
- Logging
- Exception Handling

### Data Engineering

- Data Warehouse Design
- ETL Pipelines
- Data Quality
- Data Validation
- Medallion Architecture

### Analytics Engineering

- Star Schema Design
- Dimensional Modeling
- Business Data Modeling
- Analytics-ready Data Transformation

### Data Analysis

- Business Understanding
- KPI Development
- Dashboard Design
- Business Reporting
- Data Storytelling

---

## Learning Objectives

This project focuses on learning industry-standard practices in:

- Data Engineering
- Analytics Engineering
- Data Analysis
- SQL Server Development
- Python ETL Development
- Data Warehouse Design
- Business Intelligence
- End-to-End Analytics Solutions

---

## Future Enhancements

Planned improvements include:

- Incremental Data Loading
- Slowly Changing Dimensions (SCD)
- Pipeline Automation
- SQL Server Agent Scheduling
- Unit Testing
- CI/CD Integration
- Docker Support
- Cloud Deployment
- Microsoft Fabric
- Azure Data Factory
- dbt Transformations

---

## Dataset

**Source:** Olist Brazilian E-commerce Dataset

The dataset contains approximately 100,000 e-commerce orders with related customer, seller, payment, review, and product information collected from a Brazilian e-commerce marketplace.

---

## License

This project is licensed under the MIT License.

---

## Acknowledgements

This project uses the Olist Brazilian E-commerce Dataset to demonstrate modern Data Engineering, Analytics Engineering, and Business Intelligence concepts.

The project is intended for educational purposes and portfolio development.
