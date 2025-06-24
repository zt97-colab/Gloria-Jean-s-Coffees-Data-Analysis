-- Gloria Jean's Coffee -- Data Analysis 

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports & Data Analysis


-- Q1. Market Size Estimation – Estimated Coffee Drinkers (25% of population)
-- How large is the potential customer base in each city based on population data?

SELECT 
	city_name,
	population,
	ROUND(population * 0.25 / 1000000, 2) AS estimated_coffee_drinkers_millions,
	city_rank
FROM city
ORDER BY estimated_coffee_drinkers_millions DESC;

-- Q2. Revenue Breakdown by City (Total, Average per Customer)
-- Which cities generate the most revenue, and what is the average revenue per customer?

WITH revenue_per_city AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT s.customer_id) AS unique_customers,
		ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id)::numeric, 2) AS avg_revenue_per_customer
	FROM sales s
	JOIN customers c ON s.customer_id = c.customer_id
	JOIN city ci ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT * FROM revenue_per_city
ORDER BY total_revenue DESC;

-- Q3. Product Profitability (Assume Price = Revenue, Cost = 60% of Price)
-- Which coffee products bring the highest estimated profit considering assumed cost margins?

SELECT 
	p.product_name,
	COUNT(s.sale_id) AS units_sold,
	ROUND(SUM(p.price * 0.6)::numeric, 2) AS estimated_total_cost,
	ROUND(SUM(p.price - (p.price * 0.6))::numeric, 2) AS estimated_total_profit

FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY estimated_total_profit DESC;

-- Q4. Customer Lifetime Value (CLV)
-- Who are the most valuable customers by city in terms of total and average spend?

SELECT 
	c.customer_id,
	ci.city_name,
	COUNT(s.sale_id) AS orders,
	SUM(s.total) AS total_spent,
	ROUND(AVG(s.total)::numeric, 2) AS avg_order_value
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY 1, 2
ORDER BY total_spent DESC;

-- Q5. Monthly Revenue Trend per City
-- How does revenue fluctuate monthly by city, and where are growth opportunities?

WITH monthly_sales AS (
	SELECT 
		ci.city_name,
		DATE_TRUNC('month', sale_date) AS month,
		SUM(s.total) AS total_revenue
	FROM sales s
	JOIN customers c ON s.customer_id = c.customer_id
	JOIN city ci ON ci.city_id = c.city_id
	GROUP BY 1, 2
),
monthly_growth AS (
	SELECT
		city_name,
		month,
		total_revenue,
		LAG(total_revenue) OVER (PARTITION BY city_name ORDER BY month) AS prev_month_revenue,
		CASE 
			WHEN LAG(total_revenue) OVER (PARTITION BY city_name ORDER BY month) IS NULL THEN NULL
			ELSE ROUND( ((total_revenue - LAG(total_revenue) OVER (PARTITION BY city_name ORDER BY month)) / LAG(total_revenue) OVER (PARTITION BY city_name ORDER BY month))::numeric, 2 )
		END AS mom_growth_percent
	FROM monthly_sales
)
SELECT * FROM monthly_growth
ORDER BY city_name, month;

-- Q6. Customer Churn Risk – Last Purchase > 90 Days Ago
-- Which customers haven’t purchased in over 90 days and may be at risk of churn?

SELECT 
	c.customer_id,
	ci.city_name,
	MAX(s.sale_date) AS last_order_date,
	CURRENT_DATE - MAX(s.sale_date) AS days_since_last_order
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY 1, 2
HAVING CURRENT_DATE - MAX(s.sale_date) > 90
ORDER BY days_since_last_order DESC;

-- Q7. Most Active Customers by Rating Submitted (Quality vs Quantity)
-- How do customer ratings vary, and who are the most engaged customers?

SELECT 
	c.customer_id,
	ci.city_name,
	COUNT(s.sale_id) AS orders,
	AVG(s.rating) AS avg_rating,
	SUM(s.total) AS total_spent
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY 1, 2
ORDER BY avg_rating DESC, total_spent DESC;

-- Q8. Rent-to-Revenue Efficiency
-- How efficiently is rent being converted into revenue across cities?

WITH revenue_city AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS revenue,
		COUNT(DISTINCT s.customer_id) AS customers
	FROM sales s
	JOIN customers c ON s.customer_id = c.customer_id
	JOIN city ci ON ci.city_id = c.city_id
	GROUP BY 1
),
city_rent AS (
	SELECT city_name, estimated_rent FROM city
)
SELECT 
	rc.city_name,
	rc.revenue,
	cr.estimated_rent,
	rc.customers,
	ROUND(cr.estimated_rent::numeric / rc.customers::numeric, 2) AS rent_per_customer,
	ROUND(rc.revenue::numeric / cr.estimated_rent::numeric, 2) AS revenue_per_rent_unit
FROM revenue_city rc
JOIN city_rent cr ON rc.city_name = cr.city_name
ORDER BY revenue_per_rent_unit DESC;

-- Q9. City Sales Penetration (Customers vs Estimated Market)
-- What percentage of the estimated coffee drinking population is actually purchasing?

WITH estimated_market AS (
	SELECT city_id, ROUND(population * 0.25) AS est_market FROM city
),
actual_customers AS (
	SELECT city_id, COUNT(DISTINCT customer_id) AS total_customers FROM customers GROUP BY 1
)
SELECT 
	c.city_name,
	e.est_market,
	a.total_customers,
	ROUND(a.total_customers::numeric / e.est_market::numeric * 100, 2) AS penetration_percentage
FROM estimated_market e
JOIN actual_customers a ON e.city_id = a.city_id
JOIN city c ON c.city_id = e.city_id
ORDER BY penetration_percentage DESC;

-- Q10. Top Performing Cities – Strategic Market Comparison
-- Which top cities should be prioritized based on revenue, customer base, rent, and market size?

WITH city_perf AS (
	SELECT 
		ci.city_name,
		SUM(s.total) AS revenue,
		COUNT(DISTINCT s.customer_id) AS customers,
		ROUND(SUM(s.total)::numeric / COUNT(DISTINCT s.customer_id), 2) AS avg_per_customer
	FROM sales s
	JOIN customers c ON s.customer_id = c.customer_id
	JOIN city ci ON ci.city_id = c.city_id
	GROUP BY 1
),
city_potential AS (
	SELECT 
		city_name, 
		estimated_rent, 
		ROUND(population * 0.25 / 1000000, 2) AS est_coffee_drinkers
	FROM city
)
SELECT 
	cp.city_name,
	cp.estimated_rent,
	cp.est_coffee_drinkers,
	cf.revenue,
	cf.customers,
	cf.avg_per_customer,
	ROUND(cp.estimated_rent::numeric / cf.customers, 2) AS rent_per_customer
FROM city_potential cp
JOIN city_perf cf ON cp.city_name = cf.city_name
ORDER BY revenue DESC
LIMIT 3;

-- Q11. Ratings Distribution – Product Quality Feedback
-- What products have the highest average customer rating and volume?

SELECT 
	p.product_name,
	AVG(s.rating) AS avg_rating,
	COUNT(s.sale_id) AS total_rated_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.rating IS NOT NULL
GROUP BY 1
ORDER BY avg_rating DESC;

-- Q12. Order Volume by Day of Week – Operational Planning
-- Which days of the week see the highest order volumes?

SELECT 
	TO_CHAR(sale_date, 'Day') AS day_of_week,
	COUNT(*) AS order_count
FROM sales
GROUP BY 1
ORDER BY order_count DESC;

-- Q13. Revenue Volatility – Std Dev of Monthly Revenue
-- Which cities show the most volatility in monthly revenue, indicating risk or seasonality?

WITH monthly_revenue AS (
	SELECT 
		ci.city_name,
		DATE_TRUNC('month', s.sale_date) AS month,
		SUM(s.total) AS revenue
	FROM sales s
	JOIN customers c ON c.customer_id = s.customer_id
	JOIN city ci ON ci.city_id = c.city_id
	GROUP BY 1, 2
)
SELECT 
	city_name,
	ROUND(STDDEV(revenue)::numeric, 2) AS revenue_std_dev
FROM monthly_revenue
GROUP BY city_name
ORDER BY revenue_std_dev DESC;

-- Q14. Hidden Underperformers – Cities with High Population but Low Penetration and Revenue
-- Which cities are failing to convert their market potential into actual revenue or customer base?

WITH est_market AS (
	SELECT city_id, population, ROUND(population * 0.25) AS potential_customers FROM city
),
actuals AS (
	SELECT c.city_id, COUNT(DISTINCT cu.customer_id) AS actual_customers, SUM(s.total) AS revenue
	FROM customers cu
	JOIN city c ON c.city_id = cu.city_id
	LEFT JOIN sales s ON s.customer_id = cu.customer_id
	GROUP BY c.city_id
)
SELECT 
	c.city_name,
	e.population,
	e.potential_customers,
	a.actual_customers,
	ROUND(a.actual_customers::numeric / e.potential_customers::numeric * 100, 2) AS penetration_rate,
	COALESCE(a.revenue, 0) AS total_revenue
FROM est_market e
JOIN actuals a ON a.city_id = e.city_id
JOIN city c ON c.city_id = e.city_id
WHERE a.actual_customers::numeric / e.potential_customers::numeric < 0.4
ORDER BY penetration_rate ASC, total_revenue ASC;

-- Q15. Silent Cities – Cities with Customers but No Recent Sales
-- Where do we have a presence but no current traction?

SELECT 
	ci.city_name,
	COUNT(DISTINCT cu.customer_id) AS customers_registered,
	MAX(s.sale_date) AS last_sale_date,
	CURRENT_DATE - MAX(s.sale_date) AS days_since_last_sale
FROM customers cu
JOIN city ci ON ci.city_id = cu.city_id
LEFT JOIN sales s ON cu.customer_id = s.customer_id
GROUP BY 1
HAVING MAX(s.sale_date) IS NULL OR CURRENT_DATE - MAX(s.sale_date) > 60
ORDER BY days_since_last_sale DESC NULLS LAST;

-- Q16. Customer Acquisition Velocity - Track customer growth over time to detect acceleration or stagnation.
-- How Fast Are We Gaining New Customers?

WITH first_orders AS (
    SELECT 
        customer_id,
        MIN(sale_date) AS first_order_date
    FROM sales
    GROUP BY customer_id
)
SELECT 
    DATE_TRUNC('month', first_order_date) AS first_seen_month,
    COUNT(*) AS new_customers
FROM first_orders
GROUP BY 1
ORDER BY first_seen_month;

-- Q.17 Repeat Purchase Behavior – One-Timers vs Repeat Buyers
-- What proportion of customers are loyal repeat buyers vs one-time buyers?

WITH customer_order_count AS (
	SELECT customer_id, COUNT(*) AS order_count
	FROM sales
	GROUP BY customer_id
)
SELECT 
	COUNT(CASE WHEN order_count = 1 THEN 1 END) AS one_time_buyers,
	COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_buyers,
	ROUND(COUNT(CASE WHEN order_count > 1 THEN 1 END)::numeric / COUNT(*) * 100, 2) AS repeat_rate_percentage
FROM customer_order_count;

-- Q.18 Find products most frequently bought again by the same customer.
-- Which Products Drive Repeat Business?

WITH repeat_sales AS (
	SELECT customer_id, product_id, COUNT(*) AS times_bought
	FROM sales
	GROUP BY customer_id, product_id
	HAVING COUNT(*) > 1
),
product_scores AS (
	SELECT 
		p.product_name,
		COUNT(*) AS repeat_buyers,
		AVG(r.times_bought) AS avg_repeat_purchases
	FROM repeat_sales r
	JOIN products p ON p.product_id = r.product_id
	GROUP BY p.product_name
)
SELECT * FROM product_scores
ORDER BY repeat_buyers DESC, avg_repeat_purchases DESC;

-- Q19. Underutilized Products – Sold but Never Rated
-- Which products are being sold but not getting any ratings at all?

SELECT 
    p.product_name,
    COUNT(s.sale_id) AS total_sales,
    COUNT(s.rating) FILTER (WHERE s.rating IS NOT NULL) AS total_rated,
    ROUND(
        COUNT(s.rating)::numeric / NULLIF(COUNT(s.sale_id), 0) * 100, 
        2
    ) AS rating_ratio_percent
FROM products p
JOIN sales s ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING 
    COUNT(s.sale_id) > 0 -- must have sales
    AND (COUNT(s.rating)::numeric / COUNT(s.sale_id) < 0.20) -- less than 20% ratings
ORDER BY rating_ratio_percent ASC;

-- Q20. Best ROI Cities – Revenue Relative to Number of Sales
-- Where are customers spending more per visit?

SELECT 
	ci.city_name,
	COUNT(s.sale_id) AS total_orders,
	SUM(s.total) AS total_revenue,
	ROUND(SUM(s.total)::numeric / COUNT(s.sale_id), 2) AS avg_order_value
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY avg_order_value DESC;



/*
-- Recommendation

City 1: Dhaka  
    1. Largest estimated coffee-drinking population at approximately 7.7 million – a strong indicator of market potential.  
    2. High total number of customers (68), reflecting solid customer reach and brand visibility.  
    3. Rent per customer is reasonably efficient at 330, supporting scalable operations.  
    4. Shows consistent revenue month-to-month with moderate volatility – stable growth market.  
    5. Recommend deeper engagement through loyalty rewards and targeted digital ads to capitalize on existing market.

City 2: Faridpur  
    1. Lowest average rent per customer, indicating excellent cost-to-revenue efficiency.  
    2. Generates the highest total revenue, suggesting strong customer spending patterns.  
    3. High average revenue per customer – customers spend more per visit.  
    4. Highest revenue per rent unit, showing exceptional operational efficiency.  
    5. Suggest sustaining product diversity and introducing premium offerings to increase average order value.

City 3: Sylhet  
    1. Highest total customers (69), confirming strong penetration and awareness.  
    2. Very low rent per customer at 156, enabling profitable expansion.  
    3. Average sales per customer is strong (~11.6k), showing valuable customer base.  
    4. Opportunity to strengthen customer retention via feedback loops and weekday promotions.  
    5. Suggest increasing digital presence and promotional campaigns, especially on low-traffic days.

Additional Recommendations:  
    - Explore underperforming cities with low penetration but high potential market size.  
    - Use churn report to contact inactive customers (>90 days) with email campaigns or limited-time offers.  
    - Invest in top-rated products from ratings report and bundle them with low performers.  
    - Optimize staff and stock planning based on order trends from day-of-week insights.  
    - Track revenue volatility to better manage cash flow and marketing allocation.
*/

