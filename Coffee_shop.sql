CREATE DATABASE COFFEE_SALES;
USE COFFEE_SALES;

SELECT * FROM coffee_sales.coffeeshop;

DESC coffee_sales.coffeeshop;

--- DATA VALIDATION ---

#Chaning data type transaction data to date
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_sales.coffeeshop
SET transaction_date = 
STR_TO_DATE(transaction_date,'%m/%d/%Y');

ALTER TABLE coffee_sales.coffeeshop
MODIFY transaction_date DATE;

#ALTER TIME(transaction_time)COLUMNTO DATE DATA TYPE
ALTER TABLE coffee_sales.coffeeshop
MODIFY COLUMN transaction_time TIME;

DESC coffee_sales.coffeeshop;

#CHANGE COLUMN NAME 'i'transcation_id' to transaction_id
ALTER TABLE coffee_sales.coffeeshop
CHANGE COLUMN  `ï»¿transaction_id` transaction_id INT;

#CHEACK FOR NULL VALUE

SELECT
SUM(transaction_id IS NULL)AS null_transaction_is,
SUM(transaction_date IS NULL)AS null_transaction_date,
SUM(transaction_qty IS NULL)AS null_quantity,
SUM(unit_price IS NULL)AS null_unit_price,
SUM(store_location IS NULL)AS null_store_location,
SUM(product_category IS NULL)AS null_product_category
FROM coffee_sales.coffeeshop;

#CHEACK FOR INVALID QUANTITIES
SELECT *FROM COFFEE_SALES.coffeeshop WHERE transaction_qty <= 0;

#cheack for invalid prices
SELECT * FROM COFFEE_SALES.coffeeshop WHERE unit_price <= 0;

#DUPLICATE TRANSCTION CEACK
SELECT TRANSACTION_ID,COUNT(*) AS DUPLICATE_COUNT
FROM coffee_sales.coffeeshop
GROUP BY  transaction_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------
--- DATA TRANSFORMATION (DERIVED FIELDS)

-- CREATE VIEW REVENUE CALULATION
DROP VIEW REVENUE;

CREATE view revenue AS
SELECT 
 transaction_id,
 transaction_date,
 transaction_time,
 transaction_qty,
 store_id,
 store_location
 product_id,
 product_category,
 product_type,
 product_detail,
 unit_price,
 transaction_qty * unit_price AS revenue
  
  FROM COFFEE_SALES.COFFEESHOP;
 CREATE OR REPLACE VIEW REVENUE AS 
 SELECT
     transaction_id,
     transaction_date,
     transaction_time,
	 transaction_qty,
	 store_id,
     store_location,
     product_id,
     product_category,
     product_type,
     product_detail,
     unit_price,
     transaction_qty * unit_price AS REVENUE

	
FROM coffee_sales.coffeeshop;

 SELECT * FROM REVENUE;
 
-- ADD TIME-BASED ATTRIBUTES

CREATE VIEW trend_data AS
SELECT 
    *,
    HOUR(transaction_time) AS sales_hour,
    DAYNAME(transaction_date)AS sales_day,
    MONTH(transaction_date)AS sales_month,
	YEAR(transaction_date)AS sales_year

FROM REVENUE;
    
    SELECT * FROM TREND_DATA;
    ----------------------------------------------------------------------------------------------------------------------------------------------
 # EXPLORATORY BUSINESS ANALYTICS USING SQL
 
 #TOTAL REVENUE
 SELECT SUM(revenue)AS total_revenue
 From revenue;
 
 #2 REVENUE  BY STORE LOCATION
 SELECT
     store_location,
     SUM(revenue)AS total_REVENUE
FROM REVENUE 
GROUP BY store_location
ORDER BY total_revenue DESC; 

#3 REVERSE BY PRODUCT CATEGORY
SELECT
   PRODUCT_CATEGORY,
   SUM(revenue)AS total_revenue
FROM REVENUE 
GROUP BY PRODUCT_CATEGORY
ORDER BY total_revenue DESC; 

# 4 top 10 PRODUCT BY revenue
SELECT
    PRODUCT_DETAIL,
    SUM(REVENUE)AS total_revenue
FROM revenue
GROUP BY PRODUCT_detail
ORDER BY total_revenue DESC 
LIMIT 10;

SELECT * FROM COFFEE_SALES.COFFEESHOP;

#5. HOURLY SALES TREND
SELECT
    SALES_HOUR,
    SUM(REVENUE) AS HOURLY_REVENUE
FROM TREND_DATA
GROUP BY sales_hour
ORDER BY sales_hour;
 
 #6 DAILY SALES TREND
 SELECT
     transaction_daTE,
     SUM(revenue)AS DAILY_revenue
 FROM TREND_DATA   
 GROUP BY transaction_date        
 ORDER BY transaction_date;
 
 #7 MONTHLY SALE TREND
 SELECT
    sales_year,
    sales_month,
    SUM(revenue) AS monthly_revenue
 FROM TREND_DATA
 GROUP BY SALES_YEAR ,SALES_MONTH        
 ORDER BY SALES_YEAR , SALES_MONTH;
 
 SELECT store_location, Sales_day,product_category, sum(revenue) as Total_revenue
from trend_data group by store_location, sales_day, product_category;

 
 
 # TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
 
     SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_sales.coffeeshop
WHERE 
    MONTH(transaction_date) = 5 -- Filtering for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
        
        SELECT dayofweek(curdate()); -- CURRENT DATE
        
        -- CORE KPI CALULATION
        
        #1.total orders
        SELECT
            COUNT(DISTINCT transaction_id) AS total_orders
        FROM coffee_sales.coffeeshop;
        
        #2 TOTAL REVENUE
        SELECT
            ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue
        FROM COFFEE_SALES.COFFEESHOP;
        
        #AVERAGE ORDER VALUE(AOV)
        -- HOW MUCH EACH CUSTOMER SPENDS ON EACH VISIT
        SELECT ROUND(SUM(transaction_qty * unit_price) / COUNT(DISTINCT transaction_id),2)
            ASavg_order_value FROM coffee_sales.coffeeshop;
            
            #4.PEAK SALES HOUR
         SELECT 
             HOUR(transaction_time) AS sales_hour,
             ROUND(SUM(transaction_qty * unit_price),2)AS revenue
         FROM COFFEE_SALES.COFFEESHOP
         GROUP BY SALES_HOUR
         ORDER BY REVENUE DESC
         LIMIT 1;
         
         # 5Weekday vs Weekend Sales 
SELECT
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales.coffeeshop
GROUP BY day_type;

            
            

        
        






                   
    

              
 
 
    
    
 
 
     
     
 
    
    



  

   



