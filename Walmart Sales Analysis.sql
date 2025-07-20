-- Data Exploration
Select * from walmart;

Select payment_method,
count(*) from walmart
Group by payment_method;

Select distinct(payment_method) from walmart;

Select distinct Branch from walmart;
Select max(quantity), min(quantity) from walmart;


-- Walmart Business Problems

-- Q1. Find diffrent payment method and number of transcations, number of qty sold

SELECT 
		payment_method,
		count(*) as No_of_payments
		,sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Q2. Indentify the highest-rated category in each branch, displaying the branch, category, avg rating 
Select * from 
(
	SELECT branch,
		category,
		avg(rating) as avg_rating,
		RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) as rank 
	FROM walmart
	GROUP BY 1,2)
T WHERE rank=1;

-- Q3. Identify the busiest day for each branch based on the number of transactions.
SELECT * FROM 	walmart;



SELECT * FROM(
SELECT 
	branch,
	TO_CHAR(TO_DATE(date, 'DD-MM-YY'),'Day') as  day_name,
	COUNT(*) AS no_of_transactions,
	RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
) T WHERE rank = 1;

--Q4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q5. Determine the average, minimum, and maximum rating of products for each city. List City, average_rating, min_rating, and max_rating.

SELECT city,
		category,
		avg(rating) as avg_rating,
		min(rating) as min_rating,
		max(rating) as max_rating
FROM walmart
GROUP BY 1,2;

--Q6. Calculate the total profit for each category by considering total_profit as (unit * price * profit_margin). 
-- ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;


-- Q7. Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.
SELECT * FROM (
SELECT 
	branch,
	payment_method,
	count(*) as most_com_method,
	RANK() OVER (PARTITION BY branch ORDER BY count(*) DESC) as rank
	FROM walmart
GROUP BY 1,2
) T WHERE T.rank =1


--Q8. Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Find out each of the shift and number of invoices.
SELECT branch,
	CASE 
		WHEN EXTRACT(HOUR FROM (time::time)) <12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening' 
	END AS day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


--Q9. Identify 5 branch with highest decrease ratio in revenue compare to last year (current year 2023 and last year 2022)
-- revenue decrease ratio (rdr)== (last_rev-cr_rev/ls_rev*100).

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;










































