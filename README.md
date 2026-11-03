# Movie Rental Business Analysis (SQL Subqueries + Excel)

I analysed a DVD rental business using the Sakila sample database. I answered seven business questions with SQL subqueries, then used Excel to check the results and build a dashboard. A short report turns the numbers into recommendations.

The flow was simple: SQL to get the answers, Excel to shape and check them, then a dashboard and report to explain them.

## What the business wants to know

- Who are the best customers?
- Which films and categories make money, and which don't?
- How do the two stores and the two staff members compare?
- Where should stock, staff and promotions go?

## Tools

- MySQL 8 and MySQL Workbench (queries and the ERD)
- Sakila database (599 customers, 1,000 films, 16,044 rentals)
- Excel online (tables, PivotTables, formulas, charts, dashboard)

## What is in this repo

```
movie-rental-sql-analysis/
├── sql/        movie_rental_queries.sql
├── data/       q1 to q8 exported CSV files
├── excel/      movie_rental_analysis.xlsx
├── report/     movie_rental_report
├── images/    sakila_erd.png, kpi_cards.png, chart_1_2.png, chart_3_4_5.png, chart_6_7.png
└── README.md
```

## The seven questions

| # | Question | SQL technique |
|---|---|---|
| 1 | Customers who spent above the average customer total | Subquery with AVG in HAVING (plus a WHERE version) |
| 2 | Top 10 most rented films vs the overall average | Correlated and scalar subqueries |
| 3 | Films never rented | NOT IN (plus a NOT EXISTS version) |
| 4 | Customers renting more than their store's average | Correlated subquery with a derived table |
| 5 | Revenue by category vs total revenue | Derived table and scalar subquery |
| 6 | Staff with above-average transaction counts | Subquery with AVG in HAVING |
| 7 | Customer lifetime value ranking | Subquery-based rank |

Query 8 in the SQL file is not a business question. It is a one-row-per-rental dataset I exported for the PivotTables and dashboard.

## The Excel workbook

- **Dashboard:** KPI cards, dropdown filters for store, category and rating, and seven charts
- **Checks:** compares the Excel totals with the database (everything passes)
- **Base_Data:** one row per rental, with helper columns for month and weekday
- **Q1 to Q7:** the query results as tables
- **P1 to P5:** monthly revenue table and PivotTables with slicers
- **Chart_Data:** the summary tables behind the dashboard filters and charts

## Main results

- Total revenue is 67,406.56 from 16,044 rentals (about 4.20 per rental).
- July and August 2005 bring in 77.8% of the revenue.
- 285 of 599 customers spend more than the average of 112.53.
- The top film is Bucket Brotherhood with 34 rentals (the average film has about 16).
- 42 films were never rented.
- Sports is the top category at 7.88% of revenue.
- Store 1 earns 54.9% of revenue and Store 2 earns 45.1%.

## What I would recommend

Plan stock and staff around the July and August peak, check the 42 never-rented films before buying more, add copies of the proven top 10, reward and re-engage customers, look into the gap between the stores, and test a midweek offer for the quieter days. The full reasoning is in the report.

## How to run it yourself

1. Install MySQL and load the Sakila schema and data.
2. Run `sql/movie_rental_queries.sql` in Workbench. Turn off the 1,000-row result limit before exporting, or the exports will be cut short.
3. Export each result to `data/` as a CSV.
4. Load the CSV files into the Excel workbook and check the Checks sheet.

## Limits

- There are only five months of data (May to August 2005 and February 2006), with a gap from September 2005 to January 2006.
- Revenue is counted in the month of the rental, and store figures use the customer's home store.
- There is no cost data, so these are revenue results, not profit.

## Author

Devi Bala
