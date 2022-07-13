USE magist;

# How many orders are in the dataset?
# -> the dataset consists of almost 100000 orders (99441)

SELECT COUNT(*) AS orders_count
	FROM orders;

# Are orders actually delivered?

SELECT * FROM orders;

SELECT order_status, COUNT(*) As orders 
	FROM orders
	GROUP BY order_status
    ORDER BY orders DESC;

# -> about 1200 deliveries were either cancelled or unavailable
# This makes about 1.2% of non-delivered orders

# Is Magist having user growth?

SELECT 
	YEAR(order_purchase_timestamp) AS year_, 
	MONTH(order_purchase_timestamp) AS month_, 
    COUNT(customer_id) 
FROM orders
GROUP BY year_, month_
ORDER BY year_, month_;

# The data from 2016 doesn't seem to be complete. Also we have a rapid decline in customer_id's starting in september 2018.
# These numbers do not seem to represent the actual amount of orders.
# Therefore when looking at such developments we will only consider the timeframe 01/2017 - 08/2018
# In said timeframe we can see a growth of customers, especially in 2017.
# There we start with about 800 customers in January. At the end of the year we already have about 6000 different customers ordering via Magist.
# Customers' orders seem to stabilize in 2018 ranging from about 6000 to over 7000 unique customer_id's
    
    
# How many products are in the products table?

SELECT COUNT(DISTINCT(product_id)) AS products_count FROM products;
# there are 32951 products being sold on that platform

# What are the categories with the most products?

SELECT product_category_name_english, COUNT(products.product_category_name) AS n_orders FROM products
	JOIN product_category_name_translation 
    ON product_category_name_translation.product_category_name = products.product_category_name
	GROUP BY products.product_category_name
    ORDER BY COUNT(products.product_category_name) DESC;
# we can see here that "tech" isn't the focus of the market, since our first real tech-category is at 7th place with 1639 orders.
# For comparison, 1st place has 3029 orders.
SELECT  product_category_name_translation.product_category_name_english AS product_category, COUNT(order_items.order_id) AS n_items_ordered FROM products
	JOIN product_category_name_translation 
		ON product_category_name_translation.product_category_name = products.product_category_name
	JOIN order_items
		ON products.product_id = order_items.product_id
	GROUP BY products.product_category_name
    ORDER BY COUNT(order_items.order_id) DESC;
# Looking at the number of ordered items we can also see that 'tech' doesn't seem to be the main focus.
    
# How many of those products were present in actual transactions?
SELECT COUNT(DISTINCT(product_id)) AS n_products FROM order_items;
# All of the products available on the market have been sold at least once.
    
# What are the prices of the most expensive / cheapest products?
SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;
# min: 0.85, max: 6735

# What are the highest / lowest payment values?

SELECT 
	MAX(payment_value) as highest,
    MIN(payment_value) as lowest
FROM
	order_payments;
# highest: 13664.1, lowest: 0 -> probably a cancelled order

/* What categories of tech products does Magist have?
 We now go into more detail and decide what categories qualify as 'tech' */
 
SELECT 
	DISTINCT product_category_name_english AS category 
    FROM product_category_name_translation
	ORDER BY category ASC;
/*
We decide on these categories as Tech categories: 
'computers'
'computers_accessories'
'consoles_games'
'electronics'
'fixed_telephony'
'pc_gamer'
'tablets_printing_image'
'telephony'

We didn't want to have too many to keep the exposition simple.
*/

# How many products of these tech categories have been sold
# What percentage does that represent from the overall number of products sold?
SELECT COUNT(*) from order_items;

SELECT SUM(order_count) AS orders_tech FROM
	(SELECT product_category_name_translation.product_category_name_english AS product_category, 
	COUNT(order_items.order_id) AS order_count FROM products
		JOIN product_category_name_translation 
			ON product_category_name_translation.product_category_name = products.product_category_name
		JOIN order_items
			ON products.product_id = order_items.product_id
		GROUP BY products.product_category_name
		ORDER BY COUNT(order_items.order_id) DESC) AS orders_by_category
    WHERE product_category IN (
    'computers', 
    'computers_accessories',
	'consoles_games',
	'electronics',
	'fixed_telephony',
	'pc_gamer',
	'tablets_printing_image',
	'telephony');
# There are 16835 orders in these categories, which is about ~15% of total orders


SELECT product_category_name_translation.product_category_name_english AS product_category, COUNT(*) AS n_orders, MIN(order_items.price) AS MinOrder,
	MAX(order_items.price) AS MaxOrder, AVG(order_items.price) AS AverageOrder
    FROM order_items
    JOIN products ON products.product_id = order_items.product_id
    JOIN product_category_name_translation ON product_category_name_translation.product_category_name = products.product_category_name
    WHERE product_category_name_translation.product_category_name_english IN (
    'computers',
	'computers_accessories',
	'consoles_games',
	'electronics',
	'fixed_telephony',
	'pc_gamer',
	'tablets_printing_image',
	'telephony')
	GROUP BY product_category
    ORDER BY n_orders DESC;
# here we can see that aside from the computer category the average price of the products is in the range 100-200

SELECT MIN(price), MAX(price), AVG(price) FROM order_items;
# average price of what is ordered is ~120. So it doesn't really differ from the tech category.
# It seems like Magist may not be the best place to sell high-end electronic products. 


# Are expensive tech products popular?
SELECT 
	CASE
		WHEN price <= 100 THEN '0-100'
		WHEN 100 < price AND price <= 500 THEN '100-500'
		WHEN 500 < price AND price <= 1000 THEN '500-1000'
		WHEN 1000 < price AND price <= 1500 THEN '1000-1500'
		WHEN 1500 < price AND price <= 2000 THEN '1500-2000'
		WHEN 2000 < price AND price <= 2500 THEN '2000-2500'
		WHEN 2500 < price AND price <= 3000 THEN '2500-3000'
		ELSE '>3000' END AS price_category, COUNT(*) AS n_orders
    FROM order_items
    JOIN products USING(product_id)
    JOIN product_category_name_translation USING(product_category_name)
    WHERE product_category_name_translation.product_category_name_english IN (
        'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
    GROUP BY price_category
    ORDER BY n_orders DESC;
/* 
Looking at all the orders inside the tech-categories, we see that the vast majority of items is on the cheaper end 
of the spectrum. These cheaper items could be spare-parts, cables, etc. 
*/
    
    
# How many sellers are there?
    
SELECT COUNT(*) FROM sellers;
    # 3095 sellers overall
    
SELECT product_category_name_translation.product_category_name_english AS product_category, COUNT(DISTINCT(sellers.seller_id)) AS n_sellers FROM sellers
	JOIN order_items USING(seller_id)
    JOIN products USING(product_id)
    JOIN product_category_name_translation USING(product_category_name)
		WHERE product_category_name_translation.product_category_name_english 
		IN ('computers',
			'computers_accessories',
			'consoles_games',
			'electronics',
			'fixed_telephony',
			'pc_gamer',
			'tablets_printing_image',
			'telephony')
		GROUP BY product_category
        ORDER BY n_sellers DESC;
# We see that about 800 sellers sell at least one product that is contained in a tech-category

# What is the average monthly income of all sellers?

SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, 
	sellers.seller_id, SUM(order_payments.payment_value) AS seller_revenue FROM sellers
	JOIN order_items USING(seller_id)
    JOIN order_payments USING(order_id)
    JOIN orders USING(order_id)
    GROUP BY seller_id, Year_, Month_
    ORDER BY Year_, Month_;
 # here we see the monthly revenue of all sellers. Most of them have a very low monthly revenue it seems.


SELECT Year_,Month_, AVG(Monthly_Revenue) AS Average_Monthly_Revenue_of_all_sellers 
	FROM (SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, sellers.seller_id, SUM(order_payments.payment_value) AS Monthly_Revenue FROM sellers
		JOIN order_items USING(seller_id)
		JOIN orders USING(order_id)
		JOIN order_payments USING(order_id)
		GROUP BY seller_id, YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)
		ORDER BY YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)) AS MonthlyRev
	GROUP BY Year_, Month_;
# average monthly revenue of all sellers. Its' peak is at about 1500. But this only includes sellers that actually sold 
# sth in that month. There might be sellers that don't sell anything in certain months, which 
# would lower the average.
    
    
SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, sellers.seller_id AS seller_tech, 
	SUM(order_payments.payment_value) AS Monthly_Revenue FROM sellers
		JOIN order_items USING(seller_id)
        JOIN products USING(product_id)
        JOIN product_category_name_translation USING(product_category_name)
        JOIN orders USING(order_id)
        JOIN order_payments USING(order_id)
			WHERE product_category_name_translation.product_category_name_english 
				IN ('computers',
'computers_accessories',
'consoles_games',
'electronics',
'fixed_telephony',
'pc_gamer',
'tablets_printing_image',
'telephony')
			GROUP BY seller_tech, Year_, Month_
			ORDER BY Year_, Month_;
/* 
monthly revenue of sellers in tech (that sold sth in that month). Again, these include only those sellers that sold sth that month. 
If we comment the  GROUP BY and the ORDER BY our, we can see
that the overall income of all tech sellers in that timeframe is about 3,000,000.
Divide this by the 800 tech sellers and the number of months in the timeframe (here we take 01/2017 - 08/2018 -> 20 months)
Then the actual average income of a tech sellers lies at only ~187.5,
which is not enough to make a living off of it.


/*
In the following we took the average of the query above. As mentioned this average_revenue can be misleading.
*/
SELECT ROUND(AVG(Monthly_Revenue),2) AS Average_Revenue_Tech FROM 
	(SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, sellers.seller_id AS seller_tech, 
	SUM(order_payments.payment_value) AS Monthly_Revenue FROM sellers
		JOIN order_items USING(seller_id)
        JOIN products USING(product_id)
        JOIN product_category_name_translation USING(product_category_name)
        JOIN orders USING(order_id)
        JOIN order_payments USING(order_id)
			WHERE product_category_name_translation.product_category_name_english 
				IN ('computers',
					'computers_accessories',
					'consoles_games',
					'electronics',
					'fixed_telephony',
					'pc_gamer',
					'tablets_printing_image',
					'telephony')
			GROUP BY seller_tech, Year_, Month_
			ORDER BY Year_, Month_) AS Monthly_Revenue_Tech;
            

 # Here we see what the tech sellers actually made in that timeframe
SELECT 
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS total_reveue
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN (
        'computers',
        'computers_accessories',
        'consoles_games',
        'electronics',
        'fixed_telephony',
        'pc_gamer',
        'tablets_printing_image',
        'telephony')
GROUP BY oi.seller_id
ORDER BY total_reveue DESC
;            

SELECT AVG(total_revenue) FROM
	(SELECT 
    oi.seller_id,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN (
        'computers',
        'computers_accessories',
        'consoles_games',
        'electronics',
        'fixed_telephony',
        'pc_gamer',
        'tablets_printing_image',
        'telephony')
GROUP BY oi.seller_id
ORDER BY total_revenue DESC) AS seller_total;
# The above query shows that tech sellers only make 3867 in roughly 2 years.
          


# What’s the average time between the order being placed and the product being delivered?          
          
SELECT DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS Diff_in_days, COUNT(*) FROM orders
	GROUP BY Diff_in_days
    ORDER BY Diff_in_days;
    
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS Average_delivery_time FROM orders
	WHERE DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) IS NOT NULL;
# A delivery takes about 12 days on average, which is probably not fast enough for european standards.
    
SELECT COUNT(*) FROM orders;    

SELECT CASE
		WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) - DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp) > 0 THEN 'not in time'
        WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) - DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp) <= 0 THEN 'in time'
        ELSE 'not delivered' END AS on_time, COUNT(order_id) FROM orders
        GROUP BY on_time;
# we see that most of the packages delivered are on time --> almost 90% 
#if we exclude the cancelled and not delivered one, the percentage is even higher --> ~93%
        
SELECT product_category_name_translation.product_category_name_english AS product_category, 
	products.product_weight_g AS weight, 
    products.product_length_cm AS length, 
    products.product_height_cm AS height, 
    products.product_width_cm AS width
	FROM orders
    JOIN order_items USING(order_id)
    JOIN products USING(product_id)
    JOIN product_category_name_translation USING(product_category_name)
	WHERE DATEDIFF(orders.order_delivered_customer_date, orders.order_purchase_timestamp) - DATEDIFF(orders.order_estimated_delivery_date, orders.order_purchase_timestamp) > 0
		AND product_category_name_translation.product_category_name_english 
				IN ('computers_accessories'); #, 'telephony, cool_stuff' , 'electronics', 'audio', 'computers', 
			#'pc_gamer', 'industry_commerce_and_business', 'fixed_telephony', 'signaling_and_security', 'security_and_services');
    /*
    When playing around, we see that only about 800 of nearly 12000 were delivered later than the estimate --> ~ 6,67 %
    If we reduce ourselves to the category 'computer accessories', we have about 500 out of 7827 --> ~ 6,44 %
    
    Not many of these packages weigh more than 10kg: only around 10 of these delayed 500 packages
    Not a single of these packages is longer/wider/higher than 1m
    There seems to be no obvious connection between delayed packages and item measurements.
    */

SELECT product_category_name_translation.product_category_name_english AS product_category, COUNT(*),
	products.product_weight_g AS weight, 
    products.product_length_cm AS length, 
    products.product_height_cm AS height, 
    products.product_width_cm AS width
	FROM orders
    JOIN order_items USING(order_id)
    JOIN products USING(product_id)
    JOIN product_category_name_translation USING(product_category_name)
	WHERE DATEDIFF(orders.order_delivered_customer_date, orders.order_purchase_timestamp) - DATEDIFF(orders.order_estimated_delivery_date, orders.order_purchase_timestamp) > 0
		AND product_category_name_translation.product_category_name_english 
				IN ('computers',
'computers_accessories',
'consoles_games',
'electronics',
'fixed_telephony',
'pc_gamer',
'tablets_printing_image',
'telephony')
	GROUP BY product_category
    ORDER BY weight DESC;


SELECT * FROM order_reviews;