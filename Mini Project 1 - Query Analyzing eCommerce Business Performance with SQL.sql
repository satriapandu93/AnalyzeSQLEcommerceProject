SELECT * FROM orders_dataset LIMIT 5;

SELECT EXTRACT (YEAR FROM order_purchase_timestamp) AS tahun, 
EXTRACT (MONTH FROM order_purchase_timestamp) AS bulan, 
COUNT (DISTINCT customer_id) AS jumlah_customer
FROM orders_dataset 
GROUP BY tahun, bulan;
