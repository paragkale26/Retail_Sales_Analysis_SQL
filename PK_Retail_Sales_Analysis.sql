create database retail_sales;

use retail_sales;

drop table if exists fact_salesTb;

create table fact_salesTb(
	trans_id int primary key not null,
	sale_date date,
    sale_time time,
    customer_id int,
    gender varchar(10),
    age int,
    category varchar(50),
    quantity int,
    price_per_unit float,
    cogs float,
	total_sales float
);

# Imported data into fact_salesTb using Data import wizard
select * from fact_salesTb;

#---------------------- Exploring the Data --------------------------------
# Number of records
select count(*) from fact_salesTb;

# Number of distinct customer ID
select count(distinct customer_id) from fact_salesTb;

# Distint categories
select count(distinct category) from fact_salesTb;
select distinct category from fact_salesTb;

# Checking for any NULL values
select * from fact_salesTB
where
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
    
# Deleting NULL values if any
set SQL_SAFE_UPDATES = 0;
Delete from fact_salesTb
where
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
    
#---------------------- Data Analysis --------------------------------    
# Q1. Write a SQL query to retrieve all data for sales made on '2023-05-04(YYYY-MM-DD):
select * from fact_salesTb
where
	sale_date = '2023-05-04';
    
# Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' 
# and the quantity sold is more than 4 in the month of Nov-2022:
select * from fact_salesTb
where
	category = 'Clothing' and
    quantity >= 4 and
    date_format(sale_date, '%Y-%m') = '2022-11';


# Q3. Write a SQL query to calculate the total sales (total_sale), Total orders and total quantity for each category.
select 
	category, 
    sum(total_sales) as 'Total Sales',
    sum(quantity) as 'Total Quantity',
    count(*) as 'Total Orders'
from fact_salesTb
group by category;	

# Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
set @category_name = 'Beauty';

select round(avg(age)) as 'Average Age'
from fact_salesTb
where category = @category_name;

# Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from fact_salesTb
where
	total_sales > 1000;
    
# Q6. Write a SQL query to find the total number of transactions made by each gender in each category.
select 
	category, gender,
    count(trans_id) as 'Transactions'
from fact_salesTb
group by	
	category, gender
order by Transactions;
    
# Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select
	year(sale_date) as 'Year',
    month(sale_date) as 'Month',
    round(avg(total_sales),1) as 'Average_Sales'
from fact_salesTb
group by Year, Month
order by Average_Sales desc;

# Find out best selling month in each year
SELECT
	Year,
    Month,
    Average_Sale
FROM
(
	SELECT
		EXTRACT(YEAR FROM sale_date) AS 'Year',
        EXTRACT(MONTH from sale_date) AS 'Month',
        ROUND(AVG(total_sales), 2) AS 'Average_Sale',
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sales) DESC) AS ranks
	FROM
		fact_salesTb
	GROUP BY
		year, month        
) AS t1
WHERE
	ranks = 1;
    
# Q8. Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sales) as 'Total_Sales'
from fact_salesTb
group by customer_id
order by Total_Sales desc
limit 5;

# Q9 Write a SQL query to find the number of unique customers who purchased items from each category.
select
	category,
    count(distinct(customer_id)) as 'Customers'
from fact_salesTb
group by category;

# Q10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
select
	case
		when hour(sale_time) < 12 then 'Morning'
		when hour(sale_time) between 12 and 17 then 'Afternoon'
		else 'Evening'
    end as 'Shift',
    count(trans_id)    
from fact_salesTb
group by Shift;


