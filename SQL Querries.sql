USE olist_dqa_project;

-- 00 ROW COUNTS
SELECT 'customers' table_name, COUNT(*) total_records FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments;

-- 01 CUSTOMERS NULL COMPLETENESS
SELECT COUNT(*) total_rows,
SUM(customer_id IS NULL) null_customer_id,
SUM(customer_unique_id IS NULL) null_customer_unique_id,
SUM(customer_zip_code_prefix IS NULL) null_zip,
SUM(customer_city IS NULL OR TRIM(customer_city)='') missing_city,
SUM(customer_state IS NULL OR TRIM(customer_state)='') missing_state
FROM customers;

-- 02 ORDERS NULL COMPLETENESS
SELECT COUNT(*) total_rows,
SUM(order_id IS NULL) null_order_id,
SUM(customer_id IS NULL) null_customer_id,
SUM(order_status IS NULL OR TRIM(order_status)='') missing_status,
SUM(order_purchase_timestamp IS NULL) null_purchase_timestamp,
SUM(order_approved_at IS NULL) null_approved_at,
SUM(order_delivered_carrier_date IS NULL) null_carrier_date,
SUM(order_delivered_customer_date IS NULL) null_delivered_customer_date,
SUM(order_estimated_delivery_date IS NULL) null_estimated_delivery_date
FROM orders;

-- 03 PAYMENTS NULL COMPLETENESS
SELECT COUNT(*) total_rows,
SUM(order_id IS NULL) null_order_id,
SUM(payment_sequential IS NULL) null_payment_sequential,
SUM(payment_type IS NULL OR TRIM(payment_type)='') missing_payment_type,
SUM(payment_installments IS NULL) null_installments,
SUM(payment_value IS NULL) null_payment_value
FROM order_payments;

-- 04 DUPLICATE CUSTOMER ID
SELECT customer_id, COUNT(*) occurrences FROM customers
GROUP BY customer_id HAVING COUNT(*)>1 ORDER BY occurrences DESC;

-- 05 REPEATED CUSTOMER UNIQUE ID (may be legitimate)
SELECT customer_unique_id, COUNT(*) occurrences FROM customers
GROUP BY customer_unique_id HAVING COUNT(*)>1 ORDER BY occurrences DESC LIMIT 100;

-- 06 DUPLICATE ORDER ID
SELECT order_id, COUNT(*) occurrences FROM orders
GROUP BY order_id HAVING COUNT(*)>1 ORDER BY occurrences DESC;

-- 07 DUPLICATE PAYMENT COMPOSITE KEY
SELECT order_id, payment_sequential, COUNT(*) occurrences FROM order_payments
GROUP BY order_id, payment_sequential HAVING COUNT(*)>1 ORDER BY occurrences DESC;

-- 08 ORPHAN ORDER CUSTOMER REFERENCES: COUNT
SELECT COUNT(*) orphan_order_customer_rows FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
WHERE o.customer_id IS NULL OR c.customer_id IS NULL;

-- 09 ORPHAN ORDER CUSTOMER REFERENCES: SAMPLE
SELECT o.order_id, o.customer_id FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
WHERE o.customer_id IS NULL OR c.customer_id IS NULL LIMIT 100;

-- 10 ORPHAN PAYMENT ORDER REFERENCES: COUNT
SELECT COUNT(*) orphan_payment_order_rows FROM order_payments p
LEFT JOIN orders o ON p.order_id=o.order_id
WHERE p.order_id IS NULL OR o.order_id IS NULL;

-- 11 ORPHAN PAYMENT ORDER REFERENCES: SAMPLE
SELECT p.order_id,p.payment_sequential,p.payment_type,p.payment_value
FROM order_payments p LEFT JOIN orders o ON p.order_id=o.order_id
WHERE p.order_id IS NULL OR o.order_id IS NULL LIMIT 100;

-- 12 ORDER STATUS PROFILE
SELECT order_status, COUNT(*) records FROM orders
GROUP BY order_status ORDER BY records DESC;

-- 13 INVALID/UNEXPECTED ORDER STATUS
SELECT order_id,order_status FROM orders
WHERE order_status IS NULL OR LOWER(TRIM(order_status)) NOT IN
('delivered','shipped','canceled','unavailable','invoiced','processing','created','approved')
LIMIT 100;

-- 14 PAYMENT TYPE PROFILE
SELECT payment_type, COUNT(*) records FROM order_payments
GROUP BY payment_type ORDER BY records DESC;

-- 15 INVALID/UNEXPECTED PAYMENT TYPE
SELECT order_id,payment_sequential,payment_type FROM order_payments
WHERE payment_type IS NULL OR LOWER(TRIM(payment_type)) NOT IN
('credit_card','boleto','voucher','debit_card','not_defined') LIMIT 100;

-- 16 NEGATIVE PAYMENT AMOUNTS
SELECT order_id,payment_sequential,payment_value FROM order_payments
WHERE payment_value<0 ORDER BY payment_value;

-- 17 ZERO PAYMENT AMOUNTS (flag for review)
SELECT order_id,payment_sequential,payment_type,payment_value FROM order_payments
WHERE payment_value=0 LIMIT 100;

-- 18 INVALID INSTALLMENT COUNTS (zero/negative)
SELECT order_id,payment_sequential,payment_installments FROM order_payments
WHERE payment_installments<=0 ORDER BY payment_installments;

-- 19 DELIVERY DATE BEFORE PURCHASE
SELECT order_id,order_status,order_purchase_timestamp,
order_delivered_carrier_date,order_delivered_customer_date
FROM orders WHERE
(order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date<order_purchase_timestamp)
OR (order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date<order_purchase_timestamp)
LIMIT 100;

-- 20 CUSTOMER DELIVERY BEFORE CARRIER DATE
SELECT order_id,order_status,order_delivered_carrier_date,order_delivered_customer_date
FROM orders WHERE order_delivered_customer_date IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL
AND order_delivered_customer_date<order_delivered_carrier_date LIMIT 100;

-- 21 DELIVERED STATUS WITH NULL CUSTOMER DELIVERY DATE
SELECT order_id,order_status,order_delivered_customer_date FROM orders
WHERE LOWER(TRIM(order_status))='delivered'
AND order_delivered_customer_date IS NULL LIMIT 100;

-- 22 DELIVERY DATE PRESENT WITH NON-DELIVERED STATUS (review)
SELECT order_id,order_status,order_delivered_customer_date FROM orders
WHERE order_delivered_customer_date IS NOT NULL
AND LOWER(TRIM(order_status))<>'delivered' LIMIT 100;

-- 23 APPROVAL BEFORE PURCHASE (review)
SELECT order_id,order_purchase_timestamp,order_approved_at FROM orders
WHERE order_approved_at IS NOT NULL AND order_approved_at<order_purchase_timestamp LIMIT 100;

-- 24 LATE DELIVERIES VS ESTIMATED DATE
SELECT order_id,order_status,order_delivered_customer_date,order_estimated_delivery_date
FROM orders WHERE order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date>order_estimated_delivery_date LIMIT 100;

-- 25 CUSTOMER STATE PROFILE
SELECT customer_state,COUNT(*) records FROM customers
GROUP BY customer_state ORDER BY records DESC;

-- 26 UNEXPECTED BRAZILIAN STATE CODES
SELECT customer_id,customer_state FROM customers
WHERE customer_state IS NULL OR UPPER(TRIM(customer_state)) NOT IN
('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO')
LIMIT 100;

-- 27 MISSING/BLANK CUSTOMER CITY
SELECT customer_id,customer_city FROM customers
WHERE customer_city IS NULL OR TRIM(customer_city)='' LIMIT 100;

-- 28 ZIP PREFIX OUT OF 0..99999 RANGE
SELECT customer_id,customer_zip_code_prefix FROM customers
WHERE customer_zip_code_prefix IS NULL OR customer_zip_code_prefix<0
OR customer_zip_code_prefix>99999 LIMIT 100;

-- 29 PAYMENT VALUE DISTRIBUTION SUMMARY
SELECT MIN(payment_value) min_value,MAX(payment_value) max_value,
AVG(payment_value) avg_value,STDDEV_POP(payment_value) population_stddev,
COUNT(*) payment_rows FROM order_payments;

-- 30 TOP 20 HIGHEST PAYMENTS (potential outliers; review)
SELECT order_id,payment_sequential,payment_type,payment_value
FROM order_payments ORDER BY payment_value DESC LIMIT 20;

-- 31 ORDER STATUS COUNTS AND PERCENTAGES
SELECT order_status,COUNT(*) order_count,
ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM orders),2) pct_of_orders
FROM orders GROUP BY order_status ORDER BY order_count DESC;

-- 32 ORDERS WITH NO PAYMENT ROW (review statuses may not require payment)
SELECT o.order_id,o.order_status FROM orders o
LEFT JOIN order_payments p ON o.order_id=p.order_id
WHERE p.order_id IS NULL LIMIT 100;

-- 33 ORDERS WITH MULTIPLE PAYMENT ROWS (can be legitimate)
SELECT order_id,COUNT(*) payment_rows,SUM(payment_value) total_payment_value
FROM order_payments GROUP BY order_id HAVING COUNT(*)>1
ORDER BY payment_rows DESC LIMIT 100;

-- 34 IMPORT COUNT COMPARED WITH ORIGINAL DATASET REFERENCE COUNTS
-- Reference: customers 99,441; orders 99,441; payments 103,886.
SELECT 'customers' table_name,COUNT(*) imported_rows,99441 reference_rows,COUNT(*)-99441 difference FROM customers
UNION ALL SELECT 'orders',COUNT(*),99441,COUNT(*)-99441 FROM orders
UNION ALL SELECT 'order_payments',COUNT(*),103886,COUNT(*)-103886 FROM order_payments;



