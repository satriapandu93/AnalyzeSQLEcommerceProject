SELECT * FROM payment_dataset LIMIT 5; 


SELECT
    payment_type,
    COUNT(*) AS total_usage
FROM
    payment_dataset
GROUP BY
    payment_type
ORDER BY
    total_usage DESC;



CREATE TABLE t_payment_method AS 
SELECT EXTRACT (YEAR FROM o.order_purchase_timestamp) AS tahun, 
	payment_type, 
	COUNT(p.payment_type) AS total_payment_method 
FROM 
	orders_dataset o
JOIN 
	payment_dataset p ON o.order_id = p.order_id 
GROUP BY 
	tahun, payment_type 
ORDER BY 
	tahun, total_payment_method DESC;
	
SELECT * FROM t_payment_method;
	


	

