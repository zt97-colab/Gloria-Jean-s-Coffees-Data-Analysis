/*
===============================================================================
Customer Segmentation Report – RFM Analysis
===============================================================================
Purpose:
    - This report segments customers based on Recency, Frequency, and Monetary (RFM) metrics
      to better understand engagement and value.

Highlights:
    1. Calculates:
       - Recency = Days since last purchase.
       - Frequency = Number of purchases.
       - Monetary = Total spend by customer.
    2. Assigns scores (1–3) for each RFM dimension using NTILE-based ranking.
    3. Builds an RFM code (e.g., 333 = top score in all 3 dimensions).
    4. Classifies customers into behavior-based segments:
       - Champion, Loyal, Potential, At Risk, Others.
    5. Lays the foundation for targeted marketing, retention, and rewards programs.

Use Cases:
    - Prioritize top-tier customers for loyalty perks or promotions.
    - Re-engage “At Risk” customers with discounts or emails.
    - Identify “Potential” customers to nurture into loyal buyers.
===============================================================================
*/


WITH rfm_base AS (
    SELECT
        s.customer_id,
        MAX(s.sale_date) AS last_order_date,
        COUNT(s.sale_id) AS frequency,
        SUM(s.total) AS monetary
    FROM sales s
    GROUP BY s.customer_id
),
rfm_score AS (
    SELECT 
        rb.customer_id,
        CURRENT_DATE - rb.last_order_date AS recency_days,
        rb.frequency,
        rb.monetary,
        -- Scoring (basic quantile logic)
        NTILE(3) OVER (ORDER BY CURRENT_DATE - rb.last_order_date DESC) AS r_score,
        NTILE(3) OVER (ORDER BY frequency) AS f_score,
        NTILE(3) OVER (ORDER BY monetary) AS m_score
    FROM rfm_base rb
),
customer_segments AS (
    SELECT 
        r.customer_id,
        recency_days,
        frequency,
        monetary,
        r_score, f_score, m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_code,
        CASE
            WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Champion'
            WHEN r_score = 3 AND (f_score = 2 OR m_score = 2) THEN 'Loyal'
            WHEN r_score = 2 AND f_score = 2 AND m_score = 2 THEN 'Potential'
            WHEN r_score = 1 THEN 'At Risk'
            ELSE 'Others'
        END AS segment
    FROM rfm_score r
)
SELECT * FROM customer_segments
ORDER BY segment;
