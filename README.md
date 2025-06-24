# Gloria Jean's Coffees Sales & Customer Analytics

## 🌐 Project Background

Gloria Jean's Coffees is a well-known coffeehouse chain aiming to grow its presence in cities across Bangladesh. While the brand has developed a decent customer base and product portfolio, there is significant potential for growth in both customer retention and operational efficiency. The goal of this project is to analyze historical sales, customer behavior, and market size in order to:

* Identify high-performing and underperforming cities
* Improve product profitability
* Increase customer retention
* Optimize rent-to-revenue efficiency

This end-to-end analysis leverages transactional, demographic, and product data to deliver business-ready insights for decision-makers. The project simulates a real-world scenario where a data analyst presents a stakeholder-facing analysis to inform market strategy, operations, and customer engagement.

> This repository functions as a professional deliverable. Stakeholders (e.g., CEOs, COOs, or marketing analysts) can review insights within one click. Technical SQL scripts are available in a separate folder.

---

## 📊 Data Structure Overview

The dataset is composed of **4 relational tables**, joined using foreign keys:

### Entity Relationship Diagram (ERD):

![Entity Relationship Diagram](docs/Data%20Structure.png)

### Data Types Covered:

Demographic: Population, city rank, customer-city relationship

Transaction: Total sales, sale dates, product IDs

Product: Name, pricing

Engagement: Ratings, churn behavior, repeat purchase behavior

### Data Scale:
Analyzed over 10,000 sales records encompassing multiple cities, customers, and products.



---

## 📈 Executive Summary

This dashboard provides a business-focused view of customer behavior, product profitability, and market performance across key cities in Bangladesh. Drawing from over 10,000 sales records and demographic data, it delivers insights that help prioritize investments, improve operational efficiency, and reduce churn risk.

📌 Key Takeaways:

**Revenue & Cost Efficiency**
Faridpur generates the highest revenue and has the strongest rent-to-revenue ratio, making it the most operationally efficient city.

**Customer Retention Risk**
~17% of customers are flagged as “At Risk” due to 90+ days of inactivity, signaling the need for targeted retention campaigns.

**Product Profitability**
Cappuccino and Latte lead in both sales volume and profit, while lower-rated items like Iced Mocha need bundling or promotional rework.

**Market Penetration**
Dhaka shows the highest potential market (7.7M coffee drinkers), but moderate conversion. Sylhet, on the other hand, has high actual customer count and low rent per customer, indicating successful engagement.

**Forecasting Insights**
3-month revenue forecasts per city show steady growth in Dhaka and Sylhet, and a peak in Faridpur, suggesting strong near-term ROI potential.

This dashboard simulates a real-world stakeholder report. Each chart is interactive—clicking a city or segment filters all views—allowing executives and analysts to explore performance drivers and take action with one click.Below is the overview page from the Tableau dashboard and more examples are included throughout thr report. The entire interactive dashboard can be downloaded here: https://public.tableau.com/shared/YR7ZRB4J5?:display_count=n&:origin=viz_share_link


![Tableau Dashboard Overview](docs/Gloria%20Jean's%20EDA%20Tableau.png)

---

## 🕰️ Insights Deep Dive

### Advanced SQL Techniques:

* Implemented linear regression using REGR_SLOPE and REGR_INTERCEPT functions for 3-month revenue forecasting per city.

* Developed Recency-Frequency-Monetary (RFM) segmentation using NTILE window functions to score and classify customers into five behavioral groups: Champion, Loyal, Potential, At Risk, and Others.

* Leveraged window functions, conditional aggregation (FILTER, CASE), and joins to compute detailed business KPIs and segment counts.

### Forecasting:

* Built a 3-month city-level revenue projection model based on historical monthly sales trends to aid leadership in budgeting and resource allocation.

### Customer Churn Detection:

* Defined churn as customers with no purchases in the last 90+ days. 

* Quantified churn risk by city to prioritize retention marketing campaigns.

### Rent-to-Revenue Efficiency:

* Calculated metrics such as rent per customer and revenue per rent unit to identify operationally efficient cities and inform cost optimization.

### Product Profitability:

* Estimated product profitability by assuming 60% of price as cost, identifying top-performing and underperforming products for targeted product strategy

### Sales & Revenue:

* Monthly revenue trends revealed **seasonality**, with **growth spikes around holidays**.
* Cities like **Faridpur and Dhaka** have consistent YoY growth. Sylhet is stable but with opportunities on low-traffic days.

### Product Performance:

* Products like **Cappuccino** and **Latte** showed both **high volume and profit margins**.
* Some items like **Iced Mocha** were sold often but rarely rated, indicating a need for **feedback incentives**.

### Customer Behavior:

* High-value customers were identified by **total spend and order frequency**.
* **Repeat purchase rates are strong**, especially for certain popular products.
* A churn detection query flagged inactive customers (≥90 days) who should be targeted via reactivation campaigns.

### Market Penetration:

* Cities like **Dhaka and Sylhet** show healthy conversion rates from potential market to actual customers.
* Others (e.g., **Jessore**) have large populations but low penetration → ideal for targeted expansion.

### Operational Efficiency:

* Calculated **rent per customer** and **revenue per rent unit**.
* **Faridpur's low rent and high revenue per customer** make it operationally optimal.

---

## 🔄 Recommendations


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



| Area                 | Recommendation                                                                  |
| -------------------- | ------------------------------------------------------------------------------- |
| **Marketing**        | Launch targeted churn reactivation emails and loyalty rewards in Dhaka & Sylhet |
| **Product Strategy** | Bundle low-rated products with top-sellers to boost sales and reviews           |
| **Expansion**        | Focus new store locations in low-penetration cities with large potential market |
| **Operations**       | Reinvest in Faridpur, reduce cost overhead in underperforming cities            |
| **Staffing**         | Use day-of-week order volume to optimize staff scheduling                       |

---

## 🧬 Caveats & Assumptions

* Assumed **product cost = 60% of price** to estimate profitability
* Data may not reflect **recent real-world market changes** beyond the sales window
* Rating metrics assume consistent rating scale across customers
* Churn defined as **no orders for 90+ days**, may not apply to seasonal buyers

---

## 📝 Final Notes

This project demonstrates strong **SQL-based analysis**, real-world **business insight**, and a stakeholder-ready format. It addresses core responsibilities of a data analyst:

* Understanding business questions
* Analyzing structured data
* Communicating findings clearly
* Recommending data-driven actions

---