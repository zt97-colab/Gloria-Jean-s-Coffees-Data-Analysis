/*
================================================================================
Final Executive Report Query – Gloria Jean's Coffees
================================================================================
Purpose:
    Combines essential metrics from customer, product, and sales analysis to deliver
    one powerful report for business insight.

Highlights:
    - Revenue, profit, and churn metrics
    - Product performance
    - Top cities and product ratings
    - Customer Segmentation counts (Champion, Loyal, At Risk, etc.)
    - Revenue Forecast (next 3 months)
================================================================================
*/

WITH est_market AS (
    SELECT city_id, population, ROUND(population * 0.25) AS potential_customers
    FROM city
),
customer_metrics AS (
    SELECT 
        c.customer_id,
        ci.city_name,
        COUNT(s.sale_id) AS total_orders,
        SUM(s.total) AS total_spent,
        ROUND(AVG(s.total)::numeric, 2) AS avg_order_value,
        MAX(s.sale_date) AS last_order_date,
        CURRENT_DATE - MAX(s.sale_date) AS days_since_last_order
    FROM sales s
    JOIN customers c ON c.customer_id = s.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY c.customer_id, ci.city_name
),
product_metrics AS (
    SELECT 
        p.product_name,
        COUNT(s.sale_id) AS units_sold,
        ROUND(SUM(p.price * 0.6)::numeric, 2) AS estimated_total_cost,
        ROUND(SUM(p.price - (p.price * 0.6))::numeric, 2) AS estimated_total_profit,
        ROUND(AVG(s.rating)::numeric, 2) AS avg_rating
    FROM sales s
    JOIN products p ON p.product_id = s.product_id
    GROUP BY p.product_name
),
city_performance AS (
    SELECT 
        ci.city_name,
        ROUND(SUM(s.total)::numeric, 2) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_customers,
        ci.estimated_rent,
        ROUND(SUM(s.total)::numeric/COUNT(DISTINCT s.customer_id)::numeric, 2) AS avg_per_customer,
        ROUND(ci.estimated_rent::numeric / COUNT(DISTINCT s.customer_id)::numeric, 2) AS rent_per_customer,
        ROUND(SUM(s.total)::numeric / ci.estimated_rent::numeric, 2) AS revenue_per_rent_unit
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, ci.estimated_rent
),
rfm_base AS (
    SELECT
        s.customer_id,
        ci.city_name,
        MAX(s.sale_date) AS last_order_date,
        COUNT(s.sale_id) AS frequency,
        SUM(s.total) AS monetary
    FROM sales s
    JOIN customers c ON c.customer_id = s.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY s.customer_id, ci.city_name
),
rfm_score AS (
    SELECT 
        rb.customer_id,
        rb.city_name,
        CURRENT_DATE - rb.last_order_date AS recency_days,
        rb.frequency,
        rb.monetary,
        NTILE(3) OVER (PARTITION BY rb.city_name ORDER BY CURRENT_DATE - rb.last_order_date DESC) AS r_score,
        NTILE(3) OVER (PARTITION BY rb.city_name ORDER BY frequency) AS f_score,
        NTILE(3) OVER (PARTITION BY rb.city_name ORDER BY monetary) AS m_score
    FROM rfm_base rb
),
customer_segments AS (
    SELECT 
        r.city_name,
        CASE
            WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Champion'
            WHEN r_score = 3 AND (f_score = 2 OR m_score = 2) THEN 'Loyal'
            WHEN r_score = 2 AND f_score = 2 AND m_score = 2 THEN 'Potential'
            WHEN r_score = 1 THEN 'At Risk'
            ELSE 'Others'
        END AS segment
    FROM rfm_score r
),
segment_counts AS (
    SELECT 
        city_name,
        COUNT(*) FILTER (WHERE segment = 'Champion') AS champion_count,
        COUNT(*) FILTER (WHERE segment = 'Loyal') AS loyal_count,
        COUNT(*) FILTER (WHERE segment = 'Potential') AS potential_count,
        COUNT(*) FILTER (WHERE segment = 'At Risk') AS at_risk_count,
        COUNT(*) FILTER (WHERE segment = 'Others') AS others_count
    FROM customer_segments
    GROUP BY city_name
),
monthly_revenue AS (
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
        r.city_name,
        gs.forecast_months_ahead,
        ROUND((r.slope * (r.last_index + gs.forecast_months_ahead) + r.intercept)::numeric, 2) AS forecasted_revenue
    FROM regression r
    CROSS JOIN LATERAL (SELECT generate_series(1, 3) AS forecast_months_ahead) gs
)
SELECT 
    c.city_name,
    cp.total_revenue,
    cp.total_customers,
    cp.avg_per_customer,
    cp.rent_per_customer,
    cp.revenue_per_rent_unit,
    e.potential_customers,
    ROUND(cp.total_customers::numeric / NULLIF(e.potential_customers,0) * 100, 2) AS penetration_percent,
    COUNT(DISTINCT cm.customer_id) FILTER (WHERE cm.days_since_last_order > 90) AS churn_risk_customers,
    ROUND(AVG(cm.total_spent)::numeric, 2) AS avg_total_spent_per_customer,
    COUNT(DISTINCT pm.product_name) AS active_products,
    MAX(pm.avg_rating) AS top_product_rating,
    SUM(pm.estimated_total_profit) AS total_estimated_profit,
    sc.champion_count,
    sc.loyal_count,
    sc.potential_count,
    sc.at_risk_count,
    sc.others_count,
    f1.forecasted_revenue AS forecast_month_1,
    f2.forecasted_revenue AS forecast_month_2,
    f3.forecasted_revenue AS forecast_month_3
FROM city c
JOIN est_market e ON e.city_id = c.city_id
JOIN city_performance cp ON cp.city_name = c.city_name
LEFT JOIN customer_metrics cm ON cm.city_name = c.city_name
LEFT JOIN sales s ON s.customer_id = cm.customer_id
LEFT JOIN products p ON p.product_id = s.product_id
LEFT JOIN product_metrics pm ON pm.product_name = p.product_name
LEFT JOIN segment_counts sc ON sc.city_name = c.city_name
LEFT JOIN forecast f1 ON f1.city_name = c.city_name AND f1.forecast_months_ahead = 1
LEFT JOIN forecast f2 ON f2.city_name = c.city_name AND f2.forecast_months_ahead = 2
LEFT JOIN forecast f3 ON f3.city_name = c.city_name AND f3.forecast_months_ahead = 3
GROUP BY 
    c.city_name, 
    cp.total_revenue, 
    cp.total_customers, 
    cp.avg_per_customer, 
    cp.rent_per_customer, 
    cp.revenue_per_rent_unit,
    e.potential_customers,
    sc.champion_count,
    sc.loyal_count,
    sc.potential_count,
    sc.at_risk_count,
    sc.others_count,
    f1.forecasted_revenue,
    f2.forecasted_revenue,
    f3.forecasted_revenue
ORDER BY cp.total_revenue DESC;