# SOLUTION OF SUPERSTORESDB

# Task 1: Understanding the data in hand
# A. Describe the data in hand in your own words. (Word Limit is 500)

# 1. cust_dimen: Details of all the customers
		
#   Customer_Name (TEXT): Name of the customer
#   Province (TEXT): Province of the customer
#   Region (TEXT): Region of the customer
#   Customer_Segment (TEXT): Segment of the customer
#   Cust_id (TEXT): Unique Customer ID
	
# 2. market_fact: Details of each and every order item sold
	
#   Ord_id (TEXT): Order ID
#   Prod_id (TEXT): Prod ID
#   Ship_id (TEXT): Shipment ID
#   Cust_id (TEXT): Customer ID
#	Sales (DOUBLE): Sales from the Item sold
#   Discount (DOUBLE): Discount on the Item sold
#   Order_Quantity (INT): Order Quantity of the Item sold
#   Profit (DOUBLE): Profit from the Item sold
#   Shipping_Cost (DOUBLE): Shipping Cost of the Item sold
#   Product_Base_Margin (DOUBLE): Product Base Margin on the Item sold
        
# 3. orders_dimen: Details of order placed
		
#   Order_ID (INT): Order ID
#   Order_Date (TEXT): Order Date
#   Order_Priority (TEXT): Priority of the Order
#   Ord_id (TEXT): Unique Order ID
	
# 4. prod_dimen: Details of product category and sub category with product id
		
#   Product_Category (TEXT): Product Category
#	Product_Sub_Category (TEXT): Product Sub Category
#   Prod_id (TEXT): Unique Product ID
	
# 5. shipping_dimen: Details of shipping of orders
		
#   Order_ID (INT): Order ID
#   Ship_Mode (TEXT): Shipping Mode
#   Ship_Date (TEXT): Shipping Date
#   Ship_id (TEXT): Unique Shipment ID



# B. Identify and list the Primary Keys and Foreign Keys for this dataset 
# (Hint: If a table don’t have Primary Key or Foreign Key, then specifically mention it in your answer.)

# 1. cust_dimen
#	Primary Key: Cust_id
#   Foreign Key: NA
	
# 2. market_fact
#	Primary Key: NA
#   Foreign Key: Ord_id, Prod_id, Ship_id, Cust_id
	
# 3. orders_dimen
#	Primary Key: Ord_id
#   Foreign Key: NA
	
# 4. prod_dimen
#	Primary Key: Prod_id, Product_Sub_Category
#   Foreign Key: NA
	
# 5. shipping_dimen
#	Primary Key: Ship_id
#   Foreign Key: NA




# Task 2: Basic Analysis
# Write the SQL queries for the following:

# A. Find the total and the average sales (display total_sales and avg_sales)
select sum(sales) as total_sales, avg(sales) as avg_sales from market_fact;

# B. Display the number of customers in each region in decreasing order of no_of_customers. 
# The result should contain columns Region, no_of_customers
select Region,count(*) as no_of_customers from cust_dimen 
group by Region 
order by no_of_customers desc;

# C. Find the region having maximum customers (display the region name and max(no_of_customers)
select Region,count(*) as no_of_customers from cust_dimen 
group by Region 
order by no_of_customers desc limit 1;
	
# D. Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold)
select Prod_id as product_id, count(*) as no_of_products_sold from market_fact 
group by Prod_id 
order by no_of_products_sold desc;

# E. Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased 
# (display the customer name, no_of_tables purchased)
select cd.Customer_Name, count(*) as no_of_tables_purchased from cust_dimen as cd 
inner join market_fact as mf 
on cd.Cust_id=mf.Cust_id where cd.Region='ATLANTIC'
and Prod_id=(select Prod_id from prod_dimen 
where Product_Sub_Category='TABLES') 
group by mf.Cust_id,cd.Customer_Name;


# Task 3: Advanced Analysis
# Write sql queries for the following:

# A. Display the product categories in descending order of profits 
# (display the product category wise profits i.e. product_category, profits)?
select pd.Product_Category,sum(mf.Profit) as profits from prod_dimen as pd 
join market_fact as mf 
on mf.Prod_id=pd.Prod_id
group by pd.Product_Category 
order by profits desc;

	
# B. Display the product category, product sub-category and the profit within each sub-category in three columns. 
select Product_Category,Product_Sub_Category,sum(Profit) as Profits from prod_dimen as pd 
join market_fact as mf on  pd.Prod_id=mf.Prod_id
group by Product_Category,Product_Sub_Category;

# C. Where is the least profitable product subcategory shipped the most? For the least profitable product sub-category, display the region-wise no_of_shipments and the profit made in each region in decreasing order of profits
# (i.e. region, no_of_shipments, profit_in_each_region)
# o Note: You can hardcode the name of the least profitable product sub-category
Select cd.Region, count(distinct sd.Ship_id) as no_of_shipments, SUM(mf.Profit) as profit_in_each_region
from market_fact as mf
inner join
cust_dimen as cd on mf.cust_id = cd.cust_id
inner join
shipping_dimen as sd on mf.ship_id = sd.ship_id
inner join
prod_dimen as pd on mf.prod_id = pd.prod_id
where
pd.product_sub_category in 
(select pd.product_sub_category from market_fact as mf 
inner join
prod_dimen as pd on mf.prod_id = pd.prod_id
group by pd.product_sub_category
having sum(mf.profit) <= all (select sum(mf.profit) as profits 
from market_fact as mf
inner join
prod_dimen as pd on mf.prod_id = pd.prod_id
group by pd.product_sub_category))
group by cd.region
order by profit_in_each_region desc;
