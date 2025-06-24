/*
===============================================================================
Revenue Forecast Report – 3-Month Projection
===============================================================================
Purpose:
    - This report forecasts total revenue for each city for the next 3 months 
      using linear regression on historical monthly revenue.

Highlights:
    1. Aggregates historical monthly revenue per city.
    2. Applies linear regression using REGR_SLOPE and REGR_INTERCEPT to estimate trend.
    3. Projects revenue for the next 3 months per city based on trend continuation.
    4. Identifies cities with upward, stable, or declining revenue patterns.

Use Cases:
    - Helps leadership with strategic planning, resource allocation, and budgeting.
    - Reveals which markets are growing and need investment vs. declining markets that need attention.
===============================================================================
*/


WITH monthly_revenue AS (
    SELECT 
        ci.city_name,
        DATE_TRUNC('month', s.sale_date) AS month,
        SUM(s.total) AS revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, DATE_TRUNC('month', s.sale_date)
),
indexed_revenue AS (
    SELECT 
        city_name,
        month,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY city_name ORDER BY month) AS time_index
    FROM monthly_revenue
),
regression AS (
    SELECT
        city_name,
        REGR_SLOPE(revenue, time_index) AS slope,
        REGR_INTERCEPT(revenue, time_index) AS intercept,
        MAX(time_index) AS last_index
    FROM indexed_revenue
    GROUP BY city_name
),
forecast AS (
    SELECT
        city_name,
        generate_series(1, 3) AS forecast_months_ahead
    FROM regression
),
forecasted_revenue AS (
    SELECT
        f.city_name,
        f.forecast_months_ahead,
        r.slope,
        r.intercept,
        ROUND((r.slope * (r.last_index + f.forecast_months_ahead) + r.intercept)::numeric, 2) AS forecasted_revenue
    FROM forecast f
    JOIN regression r ON f.city_name = r.city_name
)
SELECT 
    city_name,
    forecast_months_ahead,
    forecasted_revenue
FROM forecasted_revenue
ORDER BY city_name, forecast_months_ahead;
