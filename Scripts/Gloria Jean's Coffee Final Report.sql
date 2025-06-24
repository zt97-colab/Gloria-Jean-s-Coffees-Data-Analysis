/*
================================================================================
Final Executive Report Query – Gloria Jean's Coffees
================================================================================
Purpose:
    Combines essential metrics from customer, product, and sales analysis to deliver
    one powerful report for business insight.

Highlights:
    - Revenue, profit, and churn metrics
    - Product performance and customer segmentation
    - Top cities and product ratings
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
)

SELECT 
    c.city_name,
    cp.total_revenue,
    cp.total_customers,
    cp.avg_per_customer,
    cp.rent_per_customer,
    cp.revenue_per_rent_unit,
    e.potential_customers,
    ROUND(cp.total_customers::numeric / e.potential_customers::numeric * 100, 2) AS penetration_percent,
    COUNT(DISTINCT cm.customer_id) FILTER (WHERE cm.days_since_last_order > 90) AS churn_risk_customers,
    ROUND(AVG(cm.total_spent)::numeric, 2) AS avg_total_spent_per_customer,
    COUNT(DISTINCT pm.product_name) AS active_products,
    MAX(pm.avg_rating) AS top_product_rating,
    SUM(pm.estimated_total_profit) AS total_estimated_profit

FROM customer_metrics cm
JOIN city c ON c.city_name = cm.city_name
JOIN est_market e ON e.city_id = c.city_id
JOIN city_performance cp ON cp.city_name = c.city_name
LEFT JOIN sales s ON s.customer_id = cm.customer_id
LEFT JOIN products p ON p.product_id = s.product_id
LEFT JOIN product_metrics pm ON pm.product_name = p.product_name
GROUP BY 
    c.city_name, 
    cp.total_revenue, 
    cp.total_customers, 
    cp.avg_per_customer, 
    cp.rent_per_customer, 
    cp.revenue_per_rent_unit,
    e.potential_customers
ORDER BY cp.total_revenue DESC;
