SELECT EXTRACT (YEAR FROM o.order_purchase_timestamp) AS tahun, 
COUNT(DISTINCT c.customer_id) / 12 AS rata_rata_pelanggan_per_bulan 
FROM customers c 
INNER JOIN orders_dataset o ON c.customer_id = o.customer_id 
GROUP BY tahun 
ORDER BY tahun;


SELECT EXTRACT(YEAR FROM min_order_purchase_timestamp) AS tahun,
       COUNT(DISTINCT customer_id) AS jumlah_customer_baru
FROM (
    SELECT c.customer_id, 
		   MIN(o.order_purchase_timestamp) AS min_order_purchase_timestamp
    FROM customers c
    INNER JOIN orders_dataset o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) AS customer_first_order
GROUP BY tahun
ORDER BY tahun; 


SELECT tahun,
       AVG(jumlah_customer_baru) AS rata_rata_customer_baru_per_tahun
FROM (
    SELECT EXTRACT(YEAR FROM min_order_purchase_timestamp) AS tahun,
           COUNT(DISTINCT customer_id) AS jumlah_customer_baru
    FROM (
        SELECT c.customer_id,
               MIN(o.order_purchase_timestamp) AS min_order_purchase_timestamp
        FROM customers c
        INNER JOIN orders_dataset o ON c.customer_id = o.customer_id
        GROUP BY c.customer_id
        HAVING COUNT(o.order_id) > 1
    ) AS customer_repeat_orders
    GROUP BY tahun
) AS customer_repeat_orders_per_year
GROUP BY tahun
ORDER BY tahun;


WITH CustomerOrderCounts AS (
    SELECT
        c.customer_id,
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS tahun,
        COUNT(o.order_id) AS jumlah_order
    FROM
        customers c
    INNER JOIN
        orders_dataset o ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id, tahun
)
SELECT
    tahun,
    AVG(jumlah_order) AS rata_rata_frekuensi_order_per_tahun
FROM
    CustomerOrderCounts
GROUP BY
    tahun
ORDER BY
    tahun;
	

WITH Query1 AS (
    -- Subquery pertama (Rata-rata pelanggan per bulan)
    SELECT EXTRACT (YEAR FROM o.order_purchase_timestamp) AS tahun, 
    COUNT(DISTINCT c.customer_id) / 12 AS rata_rata_pelanggan_per_bulan
    FROM customers c 
    INNER JOIN orders_dataset o ON c.customer_id = o.customer_id 
    GROUP BY tahun 
    ORDER BY tahun
),

Query2 AS (
    -- Subquery kedua (Jumlah customer baru)
    SELECT EXTRACT(YEAR FROM min_order_purchase_timestamp) AS tahun,
    COUNT(DISTINCT customer_id) AS jumlah_customer_baru
    FROM (
        SELECT c.customer_id, 
        MIN(o.order_purchase_timestamp) AS min_order_purchase_timestamp
        FROM customers c
        INNER JOIN orders_dataset o ON c.customer_id = o.customer_id
        GROUP BY c.customer_id
    ) AS customer_first_order
    GROUP BY tahun
    ORDER BY tahun
),

Query3 AS (
    -- Subquery ketiga (Rata-rata customer baru per tahun)
    SELECT tahun,
    AVG(jumlah_customer_baru) AS rata_rata_customer_baru_per_tahun
    FROM (
        SELECT EXTRACT(YEAR FROM min_order_purchase_timestamp) AS tahun,
        COUNT(DISTINCT customer_id) AS jumlah_customer_baru
        FROM (
            SELECT c.customer_id,
            MIN(o.order_purchase_timestamp) AS min_order_purchase_timestamp
            FROM customers c
            INNER JOIN orders_dataset o ON c.customer_id = o.customer_id
            GROUP BY c.customer_id
            HAVING COUNT(o.order_id) > 1
        ) AS customer_repeat_orders
        GROUP BY tahun
        ORDER BY tahun
    ) AS customer_repeat_orders_per_year
    GROUP BY tahun
    ORDER BY tahun
),

Query4 AS (
    -- Subquery keempat (Rata-rata frekuensi order per tahun)
    WITH CustomerOrderCounts AS (
        SELECT
            c.customer_id,
            EXTRACT(YEAR FROM o.order_purchase_timestamp) AS tahun,
            COUNT(o.order_id) AS jumlah_order
        FROM
            customers c
        INNER JOIN
            orders_dataset o ON c.customer_id = o.customer_id
        GROUP BY
            c.customer_id, tahun
    )
    SELECT
        tahun,
        AVG(jumlah_order) AS rata_rata_frekuensi_order_per_tahun
    FROM
        CustomerOrderCounts
    GROUP BY
        tahun
    ORDER BY
        tahun
)

-- Menggabungkan hasil dari keempat subquery
SELECT
    Q1.tahun,
    rata_rata_pelanggan_per_bulan,
    jumlah_customer_baru,
    rata_rata_customer_baru_per_tahun,
    rata_rata_frekuensi_order_per_tahun
FROM
    Query1 Q1
JOIN
    Query2 Q2 ON Q1.tahun = Q2.tahun
JOIN
    Query3 Q3 ON Q1.tahun = Q3.tahun
JOIN
    Query4 Q4 ON Q1.tahun = Q4.tahun
ORDER BY
    Q1.tahun;





