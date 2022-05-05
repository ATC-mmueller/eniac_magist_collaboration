USE magist;

# How many orders are in the dataset?
SELECT COUNT(order_id) FROM orders;
#the dataset consists of almost 100000 orders (99441)


SELECT * FROM orders;

SELECT order_status, COUNT(order_status) FROM orders
	GROUP BY order_status
    ORDER BY COUNT(order_status) DESC;
# about 1200 deliveries were either cancelled or unavailable


SELECT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), COUNT(*) FROM orders
	GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
    ORDER BY year(order_purchase_timestamp), MONTH(order_purchase_timestamp);
# up to 2018 the platform was steadily growing, with about 7000 orders per month in 2018 (not counting september and october)
    
SELECT COUNT(DISTINCT(product_id)) FROM products;
# there are 32951 products being sold on that platform

SELECT product_category_name_english, COUNT(products.product_category_name) FROM products
	JOIN product_category_name_translation 
    ON product_category_name_translation.product_category_name = products.product_category_name
	GROUP BY products.product_category_name
    ORDER BY COUNT(products.product_category_name) DESC;
# we can see here that "tech" isn't the focus of the market
    
SELECT COUNT(DISTINCT(product_id)) FROM order_items;
# all of the products available on the market have been sold at least once
    
SELECT YEAR(shipping_limit_date), COUNT(DISTINCT(product_id)) FROM order_items
	GROUP BY YEAR(shipping_limit_date);
	#ORDER BY shipping_limit_date DESC;
# here we can also see the market growing....data is basically til august of 2018. so 2/3 of the year 2018 gut more orders than in 2017
    
SELECT  product_category_name_translation.product_category_name_english, COUNT(order_items.order_id) FROM products
	JOIN product_category_name_translation 
		ON product_category_name_translation.product_category_name = products.product_category_name
	JOIN order_items
		ON products.product_id = order_items.product_id
	GROUP BY products.product_category_name
    ORDER BY COUNT(order_items.order_id) DESC;
# here we can see from the result that tech is not the main focus of the market
    
/*
"Tech categories": 'computers'
'computers_accessories'
'consoles_games'
'electronics'
'fixed_telephony'
'pc_gamer'
'tablets_printing_image'
'telephony'
*/

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
    WHERE product_category IN ('computers',
'computers_accessories',
'consoles_games',
'electronics',
'fixed_telephony',
'pc_gamer',
'tablets_printing_image',
'telephony');
# There are 16835 orders in these categories, which is about ~15% of total orders


SELECT product_category_name_translation.product_category_name_english AS product_category, COUNT(*) AS n_orders, MIN(order_items.price) AS MinOrder,
	MAX(order_items.price) AS MaxOrder, AVG(order_items.price) AS AverageOrder, 
    CASE 
		WHEN order_items.price <= 100 THEN 'cheap'
        WHEN order_items.price > 100 AND order_items.price <= 500 THEN 'medium'
        WHEN order_items.price > 500 AND order_items.price <= 1000 THEN 'expensive'
        ELSE 'very expensive' END AS price_category
    FROM order_items
    JOIN products ON products.product_id = order_items.product_id
    JOIN product_category_name_translation ON product_category_name_translation.product_category_name = products.product_category_name
    WHERE product_category_name_translation.product_category_name_english 
		IN ('computers',
'computers_accessories',
'consoles_games',
'electronics',
'fixed_telephony',
'pc_gamer',
'tablets_printing_image',
'telephony')
	GROUP BY product_category#, price_category
    ORDER BY n_orders DESC;#, AverageOrder;
# here we can see that aside from the computer category the average price of the products is in the range 100-200

    

SELECT MIN(price), MAX(price), AVG(price) FROM order_items;
# average price of what isordered is ~120. So it doesn't really differ from the tech category

SELECT CASE
	WHEN price <= 100 THEN '0-100'
    WHEN 100 < price AND price <= 500 THEN '100-500'
    WHEN 500 < price AND price <= 1000 THEN '500-1000'
    WHEN 1000 < price AND price <= 1500 THEN '1000-1500'
    WHEN 1500 < price AND price <= 2000 THEN '1500-2000'
    WHEN 2000 < price AND price <= 2500 THEN '2000-2500'
    WHEN 2500 < price AND price <= 3000 THEN '2500-3000'
    ELSE 'expensive' END AS price_category, COUNT(*)
    FROM order_items
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
    GROUP BY price_category
    ORDER BY COUNT(*) DESC;
# most items cost less than 100
    
SELECT * FROM order_payments
	ORDER BY payment_value DESC;
    
SELECT COUNT(*) FROM sellers;
    # 3095 sellers overall
    
SELECT product_category_name_translation.product_category_name_english AS product_category, COUNT(DISTINCT(sellers.seller_id)) AS n_orders FROM sellers
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
        ORDER BY n_orders DESC;
# might want to kick out the computers category. Since we want to sell accessories and not computers itself....this should reduce the average price
# since pcs are rather expensive

SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, 
	sellers.seller_id, SUM(order_payments.payment_value) AS seller_revenue FROM sellers
	JOIN order_items USING(seller_id)
    JOIN order_payments USING(order_id)
    JOIN orders USING(order_id)
    GROUP BY seller_id, Year_, Month_
    ORDER BY Year_, Month_;
 # here we see the monthly revenue of all sellers   


SELECT Year_,Month_, AVG(Monthly_Revenue) AS Average_Monthly_Revenue_of_all_sellers 
	FROM (SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, sellers.seller_id, SUM(order_payments.payment_value) AS Monthly_Revenue FROM sellers
		JOIN order_items USING(seller_id)
		JOIN orders USING(order_id)
		JOIN order_payments USING(order_id)
		GROUP BY seller_id, YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)
		ORDER BY YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)) AS MonthlyRev
	GROUP BY Year_, Month_;
    
SELECT AVG(Monthly_Revenue)
	FROM (SELECT YEAR(orders.order_purchase_timestamp) AS Year_, MONTH(orders.order_purchase_timestamp) AS Month_, sellers.seller_id, SUM(order_payments.payment_value) AS Monthly_Revenue FROM sellers
		JOIN order_items USING(seller_id)
		JOIN orders USING(order_id)
		JOIN order_payments USING(order_id)
		GROUP BY seller_id, YEAR(orders.order_purchase_timestamp), MONTH(orders.order_purchase_timestamp)
        ) AS MonthlyRev;
# this is the average monthly seller revenue (include the upper query as derived table)
    
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
# monthly revenue of sellers in tech

/*
The following query returns the average monthly revenue of sellers in tech
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
            
SELECT DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS Diff_in_days, COUNT(*) FROM orders
	GROUP BY Diff_in_days
    ORDER BY Diff_in_days;
    
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS Average_delivery_time FROM orders
	WHERE DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) IS NOT NULL;
    
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

SELECT AVG(total_reveue)
FROM 
(SELECT 
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
ORDER BY total_reveue DESC) AS tech_total
;