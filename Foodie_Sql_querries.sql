-- Case Study #3: Foodie-Fi - Questions
-- Case Study Questions

-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions;



-- 2. What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value
SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS start_of_month, COUNT(*) AS trial_starts
FROM subscriptions
WHERE plan_id = (SELECT plan_id FROM plans WHERE plan_name = 'trial')
GROUP BY DATE_FORMAT(start_date, '%Y-%m-01');

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name
SELECT p.plan_name, COUNT(*) AS events_count
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE YEAR(s.start_date) > 2020
GROUP BY p.plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(DISTINCT customer_id) AS churned_customers_count,
  ROUND((COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) * 100, 1) AS churned_percentage
FROM subscriptions
WHERE end_date IS NOT NULL;

-- 5. How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?
SELECT COUNT(DISTINCT s1.customer_id) AS churned_trial_customers_count,
ROUND((COUNT(DISTINCT s1.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) * 100) AS churned_trial_percentage
FROM subscriptions s1
LEFT JOIN subscriptions s2 ON s1.customer_id = s2.customer_id AND s1.start_date < s2.start_date
WHERE s2.start_date IS NULL AND s1.end_date IS NOT NULL AND s1.plan_id = (SELECT plan_id FROM plans WHERE plan_name = 'trial');

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT COUNT(DISTINCT customer_id) AS total_customers_after_trial,
ROUND((COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE plan_id != (SELECT plan_id FROM plans WHERE plan_name = 'trial'))) * 100, 2) AS percentage_after_trial
FROM subscriptions
WHERE plan_id != (SELECT plan_id FROM plans WHERE plan_name = 'trial');



-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
SELECT plan_name,
  COUNT(DISTINCT customer_id) AS customer_count,
  ROUND((COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions WHERE start_date <= '2020-12-31')) * 100) AS percentage
FROM subscriptions
JOIN plans ON subscriptions.plan_id = plans.plan_id
WHERE start_date <= '2020-12-31'
GROUP BY plan_name;


-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS upgraded_customers_count
FROM subscriptions s1
JOIN subscriptions s2 ON s1.customer_id = s2.customer_id AND s1.start_date < s2.start_date
JOIN plans ON s2.plan_id = plans.plan_id
WHERE YEAR(s1.start_date) = 2020 AND s1.plan_id != s2.plan_id AND plans.plan_name = 'annual';


-- 9. How many days on average does it take for a customer to an
-- annual plan from the day they join Foodie-Fi?
WITH annual_plan AS (
SELECT customer_id,start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3), 
trial_plan AS ( 
            SELECT customer_id,start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0)
SELECT ROUND(AVG(DATEDIFF(annual_date, trial_date)),0) AS avg_upgrade
FROM annual_plan ap
JOIN trial_plan tp ON ap.customer_id = tp.customer_id;


-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
SELECT CONCAT(FLOOR(DATEDIFF(s2.start_date, s1.start_date) / 30) * 30, '-', 
FLOOR(DATEDIFF(s2.start_date, s1.start_date) / 30) * 30 + 29) AS period,
COUNT(*) AS upgrades_count
FROM subscriptions s1
JOIN subscriptions s2 ON s1.customer_id = s2.customer_id AND s1.start_date < s2.start_date
JOIN plans ON s2.plan_id = plans.plan_id
WHERE s1.plan_id != s2.plan_id AND plans.plan_name = 'annual' AND DATEDIFF(s2.start_date, s1.start_date) <= 365
GROUP BY period;


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 
SELECT COUNT(DISTINCT s1.customer_id) AS downgraded_customers_count
FROM subscriptions s1
JOIN subscriptions s2 ON s1.customer_id = s2.customer_id AND s1.start_date < s2.start_date
JOIN plans p1 ON s1.plan_id = p1.plan_id
JOIN plans p2 ON s2.plan_id = p2.plan_id
WHERE YEAR(s1.start_date) = 2020 AND p1.plan_name = 'pro' AND p2.plan_name = 'basic';