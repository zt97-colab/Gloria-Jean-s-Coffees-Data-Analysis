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

* **Demographic**: Population, city rank, customer-city relationship
* **Transaction**: Total sales, sale dates, product IDs
* **Product**: Name, pricing
* **Engagement**: Rating, churn behavior, repeat behavior

---

## 📈 Executive Summary

**Key Takeaways:**

* **Faridpur** generated the highest total revenue and had the **best rent-to-revenue efficiency**, making it a high ROI city.
* **Dhaka** has the **largest potential market** (\~7.7M coffee drinkers), strong brand presence, and stable revenue, making it an ideal city for digital marketing and loyalty campaigns.
* **Sylhet** shows the **highest number of customers** with good repeat purchasing behavior and low rent per customer.
* **Top-selling products** are also the most profitable. However, some underperforming products have low rating-to-sale ratios and need bundling or reevaluation.
* **17% of customers have not purchased in over 90 days** — churn campaigns are necessary.
* **Sunday is the highest order volume day**, suggesting potential for Sunday-focused promotions.

---

## 🕰️ Insights Deep Dive

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