CREATE TABLE revenue_by_year AS
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS tahun,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM
    orders_dataset o
JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    tahun
ORDER BY
    tahun;
	

CREATE TABLE canceled_order_by_years AS	
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS tahun,
    SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS total_canceled
FROM
    orders_dataset
GROUP BY
    tahun
ORDER BY
    tahun;
	
CREATE TABLE highest_revenue_category_by_year AS 
	WITH RevenueByYear AS (
		SELECT 
			EXTRACT(YEAR FROM o.order_purchase_timestamp) AS tahun, 
			p.product_category_name, 
			SUM(oi.price + oi.freight_value) AS total_revenue, 
			RANK() OVER(PARTITION BY EXTRACT(YEAR FROM o.order_purchase_timestamp) 
					   ORDER BY SUM(oi.price + oi.freight_value) DESC) AS revenue_rank 
			FROM 
				orders_dataset o 
			JOIN 
				order_items oi ON o.order_id = oi.order_id 
			JOIN 
				products_dataset p ON oi.product_id = p.product_id 
			WHERE 
				o.order_status = 'delivered' 
			GROUP BY 
				tahun, p.product_category_name 
	) 
	SELECT 
		tahun, 
		product_category_name AS highest_revenue_category 
	FROM 
		RevenueByYear 
	WHERE 
		revenue_rank = 1;


CREATE TABLE canceled_order_by_product AS 
	WITH CanceledByYear AS ( 
		SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS tahun, 
		p.product_category_name, 
		SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS total_canceled 
		FROM 
			orders_dataset o 
		JOIN 
			order_items oi ON o.order_id = oi.order_id 
		JOIN 
			products_dataset p ON oi.product_id = p.product_id 
		WHERE 
			o.order_status = 'canceled' 
		GROUP BY 
			tahun, p.product_category_name 
	)
	SELECT 
	tahun, 
	product_category_name AS most_canceled_category 
	FROM ( 
		SELECT 
		tahun, 
		product_category_name, 
		RANK() OVER (PARTITION BY tahun ORDER BY total_canceled DESC) AS rank 
		FROM 
			CanceledByYear 
	) ranked_data 
	WHERE rank = 1;
	

CREATE TABLE combined_table AS 
	SELECT 
		r.tahun AS year, 
		r.total_revenue, 
		c.total_canceled, 
		h.highest_revenue_category, 
		p.most_canceled_category
	FROM 
		revenue_by_year r
	JOIN 
		canceled_order_by_years c ON r.tahun = c.tahun 
	JOIN 
		highest_revenue_category_by_year h ON r.tahun = h.tahun 
	JOIN 
		canceled_order_by_product p ON r.tahun = p.tahun;
		

SELECT * FROM combined_table;
	