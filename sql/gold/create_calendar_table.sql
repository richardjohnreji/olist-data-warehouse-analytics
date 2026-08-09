/*
===============================================================================
Create Calendar Table
===============================================================================
Script Purpose:
    Creates the Gold Calendar table used by the Date Dimension.

    This table stores one row per calendar date and provides
    business-friendly date attributes for reporting and analytics.

Notes:
    • Physical table (Enterprise best practice)
    • Shared by all fact tables
    • Loaded once and reused
===============================================================================
*/

IF OBJECT_ID('gold.calendar', 'U') IS NOT NULL
    DROP TABLE gold.calendar;
GO

CREATE TABLE gold.calendar
(
    calendar_date      DATE        NOT NULL PRIMARY KEY,

    calendar_year      SMALLINT    NOT NULL,
    calendar_quarter   TINYINT     NOT NULL,
    calendar_month     TINYINT     NOT NULL,
    month_name         VARCHAR(20) NOT NULL,

    day_of_month       TINYINT     NOT NULL,
    day_of_week        TINYINT     NOT NULL,
    weekday_name       VARCHAR(20) NOT NULL,

    is_weekend         BIT         NOT NULL
);
GO