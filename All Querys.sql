--ALL Documentation 

------Query for daily transaction
--## ORDER
SELECT      	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
        	   dt.name AS delivery_name,
        	   pm.name AS payment_method,
        	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl,
        	   SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount,      	  
        	   SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (96) THEN o.po_no ELSE NULL END)) AS trx_rejected
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20211026' and '20211027'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),
        	   dt.name, pm.name
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC;
 


---##TOTAL USER
select count(distinct id) as user
from users
where 1=1
AND TO_CHAR(created_at, 'YYYYMMDD') between ‘20200301’ and  ‘20211103'
 
##USER ADD
SELECT      	TO_CHAR(o.created_at, 'YYYYMMDD') AS date,
        	   COUNT(DISTINCT o.id) AS user_add,
        	   COUNT(DISTINCT od.user_id) AS user_add_act_all,
        	   COUNT(DISTINCT ods.user_id) AS user_add_act_cmpl
 
FROM users o
LEFT JOIN
(SELECT user_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
-- AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY user_id) od
ON o.id = od.user_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = od.fst_dt
LEFT JOIN
(SELECT user_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY user_id) ods
ON o.id = ods.user_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = ods.fst_dt
where 1=1
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20211015' and '20211017'
-- AND TO_CHAR(o.created_at, 'YYYYMM') = '202012'
 
GROUP BY TO_CHAR(o.created_at, ‘YYYYMMDD');
 

--########## DAILY SCRUM BERDASARKAN WAKTU
SELECT 	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
 	   dt.name AS delivery_name,
 	   pm.name AS payment_method,
 	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl,
 	   SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount,     
 	   SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (96) THEN o.po_no ELSE NULL END)) AS trx_rejected
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
-- AND status_id IN (88,99, 87, 98)
 --AND status_id IN (2,8,9,1,11,96)
and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2021-12-09 07:00:00' and '2021-12-09 09:59:59'
--AND TO_CHAR(o.created_at at time zone 'asia/jakarta' at time zone 'utc', 'YYYYMMDD') between '2021-12-14 07:00:00 ' and '2021-12-14 12:00:00'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),
 	   dt.name, pm.name
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC
 
 
BEGIN;
SET LOCAL enable_hashjoin TO OFF;
select u.fullname, u.phone_number, u.email,o.id as order_id, o.order_date, os.city as sender_city, o.distance, o.total_amount, s.name as status_order, i.voucher_code, d.name as delivery_name, pm.name as payment_name, iss.weight
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN order_price_details i ON o.id = i.order_id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN order_statuses s ON o.status_id = s.id
LEFT JOIN item_specifications iss ON o.item_specification_id = iss.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
where o.status_id IN (2,1,8,9,11,96, 29, 31,32,34,39, 20) and d.id = 16 and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2021-10-01 00:00:00' and '2021-10-25 23:59:59';
SET LOCAL enable_hashjoin TO ON;
END;
 
 
 
 
--#QUERY UNTUK MONTHLY REPORT => SHEET CANCEL REASON
-- Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
        	   dt.name AS delivery_name,
        	   st.name AS status,
        	   cr.name AS cancel_reason,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl
 
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN order_statuses st ON o.status_id= st.id
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202110’
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
        	   dt.name, st.name, cr.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMM') -- , COUNT(DISTINCT o.po_no) DESC;
 
 
--#QUERY UNTUK MONTHLY REPORT => ITEM TYPE
 -- Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
        	   dt.name AS delivery_name,
        	   is.name AS item_specifications,
        	   it.name AS item_type_name,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
 
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN item_specifications is ON o.item_specification_id = is.id
LEFT JOIN item_types it ON o.item_specification_id= it.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96) AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202110'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
        	   dt.name, is.name, it.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMM') -- , COUNT(DISTINCT o.po_no) DESC;
 
 
 
--#QUERY UNTUK DATA CUSTOMER YANG TRANSAKSI DALAM SATU BULAN DENGAN BESERTA FREKUENSINYA
 
-- \Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
        	   us.name AS user_id,
           	dt.name AS delivery_name,
        	   fn.name AS fullname,
        	   ph.name AS phone_number,
 	          e.name AS email,
        	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
        	 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN users us ON o.user_id = us.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20201101' and '20201130'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(user_id),
        	   us.name, dt.name, fn.name, ph.name, e.name, pm.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC;
 
 
--#Customer Bulan 11 Instant
 
SELECT
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
            	   u.fullname AS fullname,
       	u.phone_number AS phone_number,
       	u.email AS email,
            	 COUNT(DISTINCT o.user_id) AS user_act, COUNT(DISTINCT o.po_no) AS trx
 
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
where 1=1
 
 
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) 
AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202011’
AND o.delivery_type_id IN
('1','2','12','13','14','15','16','17','18','19','20','21','22','23','43','51')
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'), u.fullname, u.phone_number, u.email
ORDER BY trx desc;
 
 
 
 
 
--################## 3PL
AND o.delivery_type_id IN
('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50')
 
 
 
 
--#QUERY VOUCHER QTT 
 
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl,
       	u.fullname AS fullname,
       	u.phone_number AS phone_number,
       	u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
--and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
--and voucher_code ilike '%SELALUGRAB%'
and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code, fullname, phone_number, email
 
 
 
--#QUERY UNTUK USER_ID CANCEL REASON (SAYA PERLU MENGUBAH ALAMAT PESANAN)
 
SELECT 	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
dt.name AS delivery_name,
--      pm.name AS payment_method,
os.name AS status,
cr.name AS cancel_reason,
u.id AS user_id
 
FROM orders o
LEFT JOIN users u on o.user_id = u.id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
LEFT JOIN order_statuses os ON o.status_id = os.id
where 1=1
AND cancel_reason_id IN (6)
AND status_id IN (51,87,20,91,6,88,99, 87, 98)
-- AND status_id IN (20)
AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20210930'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),dt.name, os.name, cr.name, u.id
 
 
 
--##### JUMLAH TRANSACTION/MONTH
SELECT
    	to_char(o.created_at, 'YYYYMM') as month,         
 		COUNT(DISTINCT o.user_id) AS user_trx
 
 
FROM orders o
where 1=1
and to_char(o.created_at, 'YYYY') = '2021'
 
group by
    to_char(o.created_at, ‘YYYYMM');
 
 
 
 
--###### JUMLAH TRANSACTION/DAILY
SELECT
    	to_char(o.created_at, 'YYYYMMDD') as day,
 		COUNT(DISTINCT o.user_id) AS user_trx
 
 
FROM orders o
where 1=1
and to_char(o.created_at, 'YYYYMM') between '202101' and '202109'
 
group by
        	to_char(o.created_at, 'YYYYMMDD')
 
 
 
--##### JUMLAH TRANSACTION AND TOTAL AMOUNT PER MERCHANT
select m.name as merchant_name,
count(distinct customer_id) as trx, sum(total_price)
       	from orders o
       	LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
       	left join merchants m on o.merchant_id = m.id
       	where mos.title not ilike '%pesanan selesai%'
       	AND TO_CHAR(o.created_at, 'YYYYMMDD') BETWEEN '20210801' and '20210831'
        	group by m.name
 
 
--#### TOTAL AMOUNT AND TRANSACTION PER USER
select o.customer_id as customer_id,
count(distinct order_code) as trx, sum(subtotal_price)
       	from orders o
       	LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
       	left join merchants m on o.merchant_id = m.id
       	where mos.title  ilike '%pesanan selesai%'
       	--AND TO_CHAR(o.created_at, 'YYYYMMDD') BETWEEN '20211001' and '20211031'
        	group by o.customer_id
 
 
--####### QUERY FOR COMPLETED TRANSACTION AND CANCEL TRANSACTION PER CITY
 
select
--   	pm.name as payment_method,
   	oss.city,
   	dt.name,
   	cr.name,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)) as trx_completed,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)) as trx_cancelled
from orders o
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211106'
--and dt.name ilike '%lalamove%'
 
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
--   	pm.name,
   	oss.city, dt.name, cr.name
 
 
--#Query for total transaction per city and Kecamatan
select
--   	pm.name as payment_method,
   	oss.city,
   	--dt.name,
   	--cr.name,
   	oss.district_city as kecamatan,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)) as trx_completed,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)) as trx_cancelled
from orders o
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20210808' and '20211108'
and oss.city ilike '%depok'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
--   	pm.name, dt.name, cr.name
   	oss.city,  oss.district_city
 
 
 
###### Transactions Cancel per Voucher
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	--count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	--) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (51,87,20,91,6,88,99, 87, 98)
and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
       opd.voucher_code, o.po_no
 
 
Ili
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	--count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	--) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (51,87,20,91,6,88,99, 87, 98)
and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
       opd.voucher_code, o.po_no
 
 
 
#### QUERY VOUCHER UNTUK DELIVERY WITH DETAILS INFORMATION ABOUT USER 
select to_char(opd.created_at, 'YYYYMMDD') as date,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	pm.name AS payment_method,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl,
 SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount
  	-- count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	--) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
and pm.name ilike '%OVO%'
--and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMMDD') between '20211001' and '20211015'
group by to_char(opd.created_at, 'YYYYMMDD'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code, o.po_no, pm.name
 
##### QUERY VOUCHER UNTUK ENS WITH DETAILS INFORMATION ABOUT USER 
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	o.customer_id,
   	--ci.name AS menu,
   	m.name AS merchant,
   	o.order_code,
   	p.name AS users,
   	p.email AS email,
   	p.phone_number,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
left join profiles p ON c.profile_id = p.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211111' and '20211113'
and voucher_code ilike '%berasabaanget%'
 
group by to_char(o.created_at, 'YYYYMMDD'), o.customer_id,
   	dt.voucher_code, m.name, p.name, p.email, p.phone_number, o.order_code--, ci.name, o.order_cod
 
 
##### TRX voucher Festival durian
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	--o.customer_id,
   	--ci.name AS menu,
   	m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') = '20211114'
and voucher_code ilike '%festivaldurian%'
 
group by to_char(o.created_at, 'YYYYMMDD'), --o.customer_id,
       dt.voucher_code, m.name--, o.order_code--, ci.name, o.order_cod
 
 
#### Delivery EnS yang MrSpeedy (Borzo)
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	dm.name,
   	--o.customer_id,
   	--ci.name AS menu,
   	m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211116'
and dm.name ilike '%MrSpeedy%'
 
group by to_char(o.created_at, 'YYYYMMDD'), --o.customer_id,
       dt.voucher_code, m.name, dm.name--, o.order_code--, ci.name, o.order_cod
 
 
########new active user EnS
SELECT 	TO_CHAR(o.created_at, 'YYYYMMDD') AS date,
       	
 	   COUNT(DISTINCT o.customer_id) AS user_add,
 	   COUNT(DISTINCT od.customer_id) AS user_add_act_all,
 	   COUNT(DISTINCT ods.customer_id) AS user_add_act_cmpl
 
 
FROM orders o
LEFT JOIN
(SELECT customer_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
-- AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY customer_id) od
ON o.customer_id = od.customer_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = od.fst_dt
LEFT JOIN
(SELECT customer_id, MIN(TO_CHAR(o.created_at, 'YYYYMMDD')) as fst_dt
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
WHERE 1=1
AND mos.title ilike '%Pesanan Selesai%'
GROUP BY customer_id) ods
ON o.customer_id = ods.customer_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = ods.fst_dt
where 1=1
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 AND TO_CHAR(o.created_at, 'YYYYMMDD')  between '20211104' and '20211110'
-- AND TO_CHAR(o.created_at, 'YYYYMM') = '202012'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD')
 
 
 
### DETAIL TRX DI MERCHANT (KAK PAT)
SELECT o.order_code,
   	o.created_at AS created_at,
   	o.payment_method_name,
   	o.payment_status,
   	o.subtotal_price,
   	o.total_price,
   	o.total_price_without_tax,
   	o.commission_fee,
   	o.total_price_after_commission_fee,
   	o.subtotal_price_after_commission_fee,
   	mos.title AS current_status,
   	mos.merchant_id,
       mos.sequence,
--   	dm.name AS delivery_name,
   	o.delivery_code,
   	oa.amount AS delivery_pay_amount,
   	cast (o.order_type_details->'delivery_method'->>'initial_price' as integer) - cast(o.order_type_details->'delivery_method'->>'price' as integer) AS discount_delivery
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
WHERE 1=1
--and mos.sequence ilike '%completed%'
and o.payment_status = 'CAPTURE'
and oa.type ilike '%delivery%'
and mos.merchant_id IN (2562)
AND TO_CHAR(o.order_date, 'YYYYMMDD') BETWEEN '20211114' and '20211119'
-- LIMIT 10
 
 
####JUMLAH TRANSAKSI DENGAN VOUCHER DI DELIVERY
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl
   	--count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	--) as trx_cncl,
       	--u.fullname AS fullname,
       	--u.phone_number AS phone_number,
       	--u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
and voucher_code ilike '%GRABOKE%'
or voucher_code ilike '%GRABGERCEP%'
OR voucher_code ilike '%GRABGESIT%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202111'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code--, fullname, phone_number, email
 
 
SELECT o.order_code,
   	o.created_at AS created_at,
   	o.payment_method_name,
   	o.payment_status,
   	o.subtotal_price,
   	o.total_price,
   	o.total_price_without_tax,
   	o.commission_fee,
   	o.total_price_after_commission_fee,
   	o.subtotal_price_after_commission_fee,
   	mos.title AS current_status,
   	mos.merchant_id,
       mos.sequence,
--   	dm.name AS delivery_name,
   	o.delivery_code,
   	oa.amount AS delivery_pay_amount,
   	cast (o.order_type_details->'delivery_method'->>'initial_price' as integer) - cast(o.order_type_details->'delivery_method'->>'price' as integer) AS discount_delivery
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
WHERE 1=1
--and mos.sequence ilike '%completed%'
and o.payment_status = 'CAPTURE'
and oa.type ilike '%delivery%'
--and mos.merchant_id IN (2562)
AND TO_CHAR(o.order_date, 'YYYYMMDD') BETWEEN '20210901' and '20210931'
 
 
#####Voucher EnS with no AWB delivery
select to_char(o.created_at, 'YYYYMM') as month,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	o.delivery_code,
   	--o.customer_id,
   	--ci.name AS menu,
   	--m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl
   	--count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
   	-- as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMM') = '202111'
and voucher_code ilike '%ovoHAPPY%'
 
group by to_char(o.created_at, 'YYYYMM'), --o.customer_id,
   	dt.voucher_code, o.delivery_code--, m.name, o.order_code--, ci.name, o.order_cod
 
 
 
####First Transaksi Delivery
select u.id,
   	u.fullname,
   	join_date,
   	fst_dt,
   	extract(day from fst_dt_-join_date_) as dif_date
	--   extract(month from fst_dt_-join_date_) as dif_month
from
(
select  u.id,
    	u.fullname,
    	to_char(u.created_at,'YYYYMMDD') as join_date,
    	u.created_at as join_date_,
    	min(to_char(o.created_at,'YYYYMMDD')) as fst_dt,
    	min(o.created_at) as fst_dt_
    	-- extract(day from min(o.created_at) - u.created_at) as diff
from users u
left join orders o on o.user_id = u.id
where 1=1
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) --—complete
and to_char(o.created_at,'YYYYMMDD') between '20211101' and '20211130'
and to_char(u.created_at,'YYYYMMDD') >= '20200301'
group by u.id, u.fullname, to_char(u.created_at,'YYYYMMDD'), u.created_at
-- having min(to_char(o.created_at,'YYYYMMDD')) is not null
-- limit 100
) u
 
##### Borzo berdasarkan jarak
select COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
from orders o
left join order_senders oss on o.order_sender_id = oss.id
 
where 1=1
and status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211130'
and o.distance <= 10
--and (oss.city ilike '%jakarta%'
--or oss.city ilike '%jkt%'
--or oss.city ilike '%bogor%'
--or oss.city ilike '%depok%'
--or oss.city ilike '%tangerang%'
--or oss.city ilike '%bekasi%'
--)
and o.delivery_type_id in ('16')
 
 
##### No HP Driver
select
 to_char(o.created_at, 'YYYYMM') as month,
   	dt.name as delivery_name,
   	--oss.city,
   	ou.driver_phone,
 	   count(distinct ou.driver_phone) as total_driver
   	
from orders o
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
left join (select partner_po_no, max(driver_phone) as driver_phone
from order_updates
where 1=1
and to_char(created_at, 'YYYYMM') = '202111'
group by partner_po_no) ou on ou.partner_po_no = o.gosend_code
 
where 1=1
and to_char(o.created_at, 'YYYYMM') = '202111'
AND o.status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
--and to_char(o.created_at, 'YYYYMM') between '202011' and '202012'
and dt.name ilike '%borzo%'
group by
 to_char(o.created_at, 'YYYYMM'),
   	dt.name,
   	--oss.city
   	ou.driver_phone
   	
 
#### Completed Transaction for Armada Baru
select DISTINCT o.po_no,
d.name as delivery_name,
o.user_id,
u.fullname,
os.city as sender_city,
ors.city as receiver_city,
-- u.phone_number,
o.distance,
o.total_amount,
x.name as category_name,
--o.status_id,
--ot.name AS status_name,
-- o.payment_method_id,
pm.name AS payment_method_name,
--o.cancel_detail,
o.order_date  AS order_date
 
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN order_receivers ors ON o.order_receiver_id = ors.id
LEFT JOIN item_specifications i ON o.item_specification_id = i.id
LEFT JOIN item_types x ON i.item_type_id = x.id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN order_statuses ot ON o.status_id = ot.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
WHERE 1=1
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20201201' and '20201231'
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) --—complete
AND o.delivery_type_id IN ('1','2','12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60') -- On Demand
and (os.city ilike '%Jakarta Barat%'
or os.city ilike '%West Java%')


 
 
 
Query for daily
 
## ORDER
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
        	   dt.name AS delivery_name,
        	   pm.name AS payment_method,
        	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl,
        	   SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount,      	  
        	   SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (96) THEN o.po_no ELSE NULL END)) AS trx_rejected
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20211026' and '20211027'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),
        	   dt.name, pm.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC
 
##TOTAL USER
select count(distinct id) as user
from users
where 1=1
AND TO_CHAR(created_at, 'YYYYMMDD') between ‘20200301’ and  ‘20211103'
 
##USER ADD
SELECT      	TO_CHAR(o.created_at, 'YYYYMMDD') AS date,
        	   COUNT(DISTINCT o.id) AS user_add,
        	   COUNT(DISTINCT od.user_id) AS user_add_act_all,
        	   COUNT(DISTINCT ods.user_id) AS user_add_act_cmpl
 
 
FROM users o
LEFT JOIN
(SELECT user_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
-- AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY user_id) od
ON o.id = od.user_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = od.fst_dt
LEFT JOIN
(SELECT user_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY user_id) ods
ON o.id = ods.user_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = ods.fst_dt
where 1=1
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20211015' and '20211017'
-- AND TO_CHAR(o.created_at, 'YYYYMM') = '202012'
 
GROUP BY TO_CHAR(o.created_at, ‘YYYYMMDD')
 
########## DAILY SCRUM BERDASARKAN WAKTU
SELECT 	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
 	   dt.name AS delivery_name,
 	   pm.name AS payment_method,
 	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl,
 	   SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount,     
 	   SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
 	   COUNT(DISTINCT (CASE WHEN status_id IN (96) THEN o.po_no ELSE NULL END)) AS trx_rejected
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
-- AND status_id IN (88,99, 87, 98)
 --AND status_id IN (2,8,9,1,11,96)
and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2021-12-09 07:00:00' and '2021-12-09 09:59:59'
--AND TO_CHAR(o.created_at at time zone 'asia/jakarta' at time zone 'utc', 'YYYYMMDD') between '2021-12-14 07:00:00 ' and '2021-12-14 12:00:00'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),
 	   dt.name, pm.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC
 
 
 
Status Order ID yang Finished
2 => Fininished
1 => On Progress
8 => Enroute Pickup
9 => Enroute Drop
11 => Finding Driver
96 => Rejected
29 => Shipment Ordered to Pick Up
31 => Shipment Dropped at Store
32 => Shipment picked-up
34 => Shipment arrived at destination location
39 => Shipment departed from gateway location
20 => Payment Success
 
Transaksi cancel=
51 = A Problem in Delivery
87 = Cancelled By Partner
20 = Payment Success
91 = Reorder
6 = Picked Failed
88 = Cancelled, refund
99 = Cancelled
87 = Cancelled by Partner
98 =  Driver not found, order auto refund.
Query untuk 1. Berapa trx User pengguna Borzo di Bulan July (156.514)? (nama dan no HP)
 
 
 
 
BEGIN;
SET LOCAL enable_hashjoin TO OFF;
select u.fullname, u.phone_number, u.email,o.id as order_id, o.order_date, os.city as sender_city, o.distance, o.total_amount, s.name as status_order, i.voucher_code, d.name as delivery_name, pm.name as payment_name, iss.weight
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN order_price_details i ON o.id = i.order_id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN order_statuses s ON o.status_id = s.id
LEFT JOIN item_specifications iss ON o.item_specification_id = iss.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
where o.status_id IN (2,1,8,9,11,96, 29, 31,32,34,39, 20) and d.id = 16 and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2021-10-01 00:00:00' and '2021-10-25 23:59:59';
SET LOCAL enable_hashjoin TO ON;
END;
 
2. Berapa banyak User pengguna Borzo di bulan July yang melakukan transaksi lagi di bulan Oktober? (nama dan no HP)
 
3. Berapa banyak User pengguna Borzo di bulan July yang tidak melakukan transaksi lagi di bulan Oktober? (nama dan no HP)
 
 
 
 
#QUERY UNTUK MONTHLY REPORT => SHEET CANCEL REASON
 
-- Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
        	   dt.name AS delivery_name,
        	   st.name AS status,
        	   cr.name AS cancel_reason,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl
 
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN order_statuses st ON o.status_id= st.id
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202110’
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
        	   dt.name, st.name, cr.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMM') -- , COUNT(DISTINCT o.po_no) DESC
 
 
#QUERY UNTUK MONTHLY REPORT => ITEM TYPE
 -- Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
        	   dt.name AS delivery_name,
        	   is.name AS item_specifications,
        	   it.name AS item_type_name,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
 
 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN item_specifications is ON o.item_specification_id = is.id
LEFT JOIN item_types it ON o.item_specification_id= it.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202110'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
        	   dt.name, is.name, it.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMM') -- , COUNT(DISTINCT o.po_no) DESC
 
 
 
#QUERY UNTUK DATA CUSTOMER YANG TRANSAKSI DALAM SATU BULAN DENGAN BESERTA FREKUENSINYA
 
-- Orders
 
SELECT      	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
        	   us.name AS user_id,
           	dt.name AS delivery_name,
        	   fn.name AS fullname,
        	   ph.name AS phone_number,
 	          e.name AS email,
        	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
        	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
        	 
FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN users us ON o.user_id = us.id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
 AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20201101' and '20201130'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 
GROUP BY TO_CHAR(user_id),
        	   us.name, dt.name, fn.name, ph.name, e.name, pm.name
 
ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC
 
 
 
 
#Customer Bulan 11 Instant
 
SELECT
TO_CHAR(o.created_at, 'YYYYMM') AS Month,
            	   u.fullname AS fullname,
       	u.phone_number AS phone_number,
       	u.email AS email,
            	 COUNT(DISTINCT o.user_id) AS user_act, COUNT(DISTINCT o.po_no) AS trx
 
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
where 1=1
 
 
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) 
AND TO_CHAR(o.created_at, 'YYYYMM') = ‘202011’
AND o.delivery_type_id IN
('1','2','12','13','14','15','16','17','18','19','20','21','22','23','43','51')
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'), u.fullname, u.phone_number, u.email
ORDER BY trx desc
 
 
 
 
 
################## 3PL
AND o.delivery_type_id IN
('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50')
 
 
 
 
#QUERY VOUCHER MBA VANIA DWP
 
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl,
       	u.fullname AS fullname,
       	u.phone_number AS phone_number,
       	u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
--and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
--and voucher_code ilike '%SELALUGRAB%'
and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code, fullname, phone_number, email
 
 
 
#QUERY UNTUK USER_ID CANCEL REASON (SAYA PERLU MENGUBAH ALAMAT PESANAN)
 
SELECT 	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
dt.name AS delivery_name,
--      pm.name AS payment_method,
os.name AS status,
cr.name AS cancel_reason,
u.id AS user_id
 
FROM orders o
LEFT JOIN users u on o.user_id = u.id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
LEFT JOIN order_statuses os ON o.status_id = os.id
where 1=1
AND cancel_reason_id IN (6)
AND status_id IN (51,87,20,91,6,88,99, 87, 98)
-- AND status_id IN (20)
AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20210930'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),dt.name, os.name, cr.name, u.id
 
 
 
##### JUMLAH TRANSACTION/MONTH
SELECT
    	to_char(o.created_at, 'YYYYMM') as month,         
 		COUNT(DISTINCT o.user_id) AS user_trx
 
 
FROM orders o
where 1=1
and to_char(o.created_at, 'YYYY') = '2021'
 
group by
        	to_char(o.created_at, ‘YYYYMM')
 
 
 
 
###### JUMLAH TRANSACTION/DAILY
SELECT
    	to_char(o.created_at, 'YYYYMMDD') as day,
 		COUNT(DISTINCT o.user_id) AS user_trx
 
 
FROM orders o
where 1=1
and to_char(o.created_at, 'YYYYMM') between '202101' and '202109'
 
group by
        	to_char(o.created_at, 'YYYYMMDD')
 
 
 
##### JUMLAH TRANSACTION AND TOTAL AMOUNT PER MERCHANT
select m.name as merchant_name,
count(distinct customer_id) as trx, sum(total_price)
       	from orders o
       	LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
       	left join merchants m on o.merchant_id = m.id
       	where mos.title not ilike '%pesanan selesai%'
       	AND TO_CHAR(o.created_at, 'YYYYMMDD') BETWEEN '20210801' and '20210831'
        	group by m.name
 
 
#### TOTAL AMOUNT AND TRANSACTION PER USER
select o.customer_id as customer_id,
count(distinct order_code) as trx, sum(subtotal_price)
       	from orders o
       	LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
       	left join merchants m on o.merchant_id = m.id
       	where mos.title  ilike '%pesanan selesai%'
       	--AND TO_CHAR(o.created_at, 'YYYYMMDD') BETWEEN '20211001' and '20211031'
        	group by o.customer_id
 
 
####### QUERY FOR COMPLETED TRANSACTION AND CANCEL TRANSACTION PER CITY
 
select
--   	pm.name as payment_method,
   	oss.city,
   	dt.name,
   	cr.name,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)) as trx_completed,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)) as trx_cancelled
from orders o
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211106'
--and dt.name ilike '%lalamove%'
 
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
--   	pm.name,
   	oss.city, dt.name, cr.name
 
 
#Query for total transaction per city and Kecamatan
select
--   	pm.name as payment_method,
   	oss.city,
   	--dt.name,
   	--cr.name,
   	oss.district_city as kecamatan,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)) as trx_completed,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)) as trx_cancelled
from orders o
LEFT JOIN cancel_reasons cr ON o.cancel_reason_id = cr.id
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20210808' and '20211108'
and oss.city ilike '%depok'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMM'),
--   	pm.name, dt.name, cr.name
   	oss.city,  oss.district_city
 
 
 
###### Transactions Cancel per Voucher
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	--count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	--) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (51,87,20,91,6,88,99, 87, 98)
and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
       opd.voucher_code, o.po_no
 
 
Ili
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	--count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	--) as trx_compl,
   	count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (51,87,20,91,6,88,99, 87, 98)
and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202110'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
       opd.voucher_code, o.po_no
 
 
 
#### QUERY VOUCHER UNTUK DELIVERY WITH DETAILS INFORMATION ABOUT USER 
select to_char(opd.created_at, 'YYYYMMDD') as date,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	o.po_no AS po_number,
   	pm.name AS payment_method,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl,
 SUM(CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN total_amount ELSE NULL END) AS total_amount
  	-- count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	--) as trx_cncl
      	-- u.fullname AS fullname,
      	-- u.phone_number AS phone_number,
      	-- u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
and pm.name ilike '%OVO%'
--and voucher_code ilike '%JNEANDALAN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMMDD') between '20211001' and '20211015'
group by to_char(opd.created_at, 'YYYYMMDD'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code, o.po_no, pm.name
 
##### QUERY VOUCHER UNTUK ENS WITH DETAILS INFORMATION ABOUT USER 
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	o.customer_id,
   	--ci.name AS menu,
   	m.name AS merchant,
   	o.order_code,
   	p.name AS users,
   	p.email AS email,
   	p.phone_number,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
left join profiles p ON c.profile_id = p.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211111' and '20211113'
and voucher_code ilike '%berasabaanget%'
 
group by to_char(o.created_at, 'YYYYMMDD'), o.customer_id,
   	dt.voucher_code, m.name, p.name, p.email, p.phone_number, o.order_code--, ci.name, o.order_cod
 
 
##### TRX voucher Festival durian
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	--o.customer_id,
   	--ci.name AS menu,
   	m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') = '20211114'
and voucher_code ilike '%festivaldurian%'
 
group by to_char(o.created_at, 'YYYYMMDD'), --o.customer_id,
       dt.voucher_code, m.name--, o.order_code--, ci.name, o.order_cod
 
 
#### Delivery EnS yang MrSpeedy (Borzo)
select to_char(o.created_at, 'YYYYMMDD') as date,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	dm.name,
   	--o.customer_id,
   	--ci.name AS menu,
   	m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl,
   	count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
    	as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211116'
and dm.name ilike '%MrSpeedy%'
 
group by to_char(o.created_at, 'YYYYMMDD'), --o.customer_id,
       dt.voucher_code, m.name, dm.name--, o.order_code--, ci.name, o.order_cod
 
 
########new active user EnS
SELECT 	TO_CHAR(o.created_at, 'YYYYMMDD') AS date,
       	
 	   COUNT(DISTINCT o.customer_id) AS user_add,
 	   COUNT(DISTINCT od.customer_id) AS user_add_act_all,
 	   COUNT(DISTINCT ods.customer_id) AS user_add_act_cmpl
 
 
FROM orders o
LEFT JOIN
(SELECT customer_id, MIN(TO_CHAR(created_at, 'YYYYMMDD')) as fst_dt
FROM orders
WHERE 1=1
-- AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
GROUP BY customer_id) od
ON o.customer_id = od.customer_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = od.fst_dt
LEFT JOIN
(SELECT customer_id, MIN(TO_CHAR(o.created_at, 'YYYYMMDD')) as fst_dt
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
WHERE 1=1
AND mos.title ilike '%Pesanan Selesai%'
GROUP BY customer_id) ods
ON o.customer_id = ods.customer_id AND TO_CHAR(o.created_at, 'YYYYMMDD') = ods.fst_dt
where 1=1
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'
 AND TO_CHAR(o.created_at, 'YYYYMMDD')  between '20211104' and '20211110'
-- AND TO_CHAR(o.created_at, 'YYYYMM') = '202012'
 
GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD')
 
 
 
### DETAIL TRX DI MERCHANT (KAK PAT)
SELECT o.order_code,
   	o.created_at AS created_at,
   	o.payment_method_name,
   	o.payment_status,
   	o.subtotal_price,
   	o.total_price,
   	o.total_price_without_tax,
   	o.commission_fee,
   	o.total_price_after_commission_fee,
   	o.subtotal_price_after_commission_fee,
   	mos.title AS current_status,
   	mos.merchant_id,
       mos.sequence,
--   	dm.name AS delivery_name,
   	o.delivery_code,
   	oa.amount AS delivery_pay_amount,
   	cast (o.order_type_details->'delivery_method'->>'initial_price' as integer) - cast(o.order_type_details->'delivery_method'->>'price' as integer) AS discount_delivery
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
WHERE 1=1
--and mos.sequence ilike '%completed%'
and o.payment_status = 'CAPTURE'
and oa.type ilike '%delivery%'
and mos.merchant_id IN (2562)
AND TO_CHAR(o.order_date, 'YYYYMMDD') BETWEEN '20211114' and '20211119'
-- LIMIT 10
 
 


####JUMLAH TRANSAKSI DENGAN VOUCHER DI DELIVERY
select to_char(opd.created_at, 'YYYYMM') as month,
   	(case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
   	opd.voucher_code,
   	count(distinct (case when o.status_id in (2,1,8,9,11,96, 29, 31,32,34,39) then o.po_no else null end)
   	) as trx_compl
   	--count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
   	--) as trx_cncl,
       	--u.fullname AS fullname,
       	--u.phone_number AS phone_number,
       	--u.email AS email
 
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
where 1=1
and status_id in (2,1,8,9,11,96, 29, 31,32,34,39)
and voucher_code ilike '%GRABOKE%'
or voucher_code ilike '%GRABGERCEP%'
OR voucher_code ilike '%GRABGESIT%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMM') = '202111'
group by to_char(opd.created_at, 'YYYYMM'), (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
   	opd.voucher_code--, fullname, phone_number, email
 
 
SELECT o.order_code,
   	o.created_at AS created_at,
   	o.payment_method_name,
   	o.payment_status,
   	o.subtotal_price,
   	o.total_price,
   	o.total_price_without_tax,
   	o.commission_fee,
   	o.total_price_after_commission_fee,
   	o.subtotal_price_after_commission_fee,
   	mos.title AS current_status,
   	mos.merchant_id,
       mos.sequence,
--   	dm.name AS delivery_name,
   	o.delivery_code,
   	oa.amount AS delivery_pay_amount,
   	cast (o.order_type_details->'delivery_method'->>'initial_price' as integer) - cast(o.order_type_details->'delivery_method'->>'price' as integer) AS discount_delivery
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
LEFT JOIN order_deliveries od ON o.id = od.order_id
LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
LEFT JOIN order_adjustments oa ON o.id = oa.order_id
WHERE 1=1
--and mos.sequence ilike '%completed%'
and o.payment_status = 'CAPTURE'
and oa.type ilike '%delivery%'
--and mos.merchant_id IN (2562)
AND TO_CHAR(o.order_date, 'YYYYMMDD') BETWEEN '20210901' and '20210931'
 
 
#####Voucher EnS with no AWB delivery
select to_char(o.created_at, 'YYYYMM') as month,
    	'Eats' as eat_noneat,
       dt.voucher_code,
   	o.delivery_code,
   	--o.customer_id,
   	--ci.name AS menu,
   	--m.name,
   	--o.order_code,
   	count (distinct (case when mos.title = 'Pesanan Selesai' then o.order_code else null end))
    	as trx_compl
   	--count (distinct (case when mos.title <> 'Pesanan Selesai' then o.order_code else null end))
   	-- as trx_cncl
 
FROM orders o
LEFT JOIN merchant_order_steps mos ON o.current_step_id = mos.id
--LEFT JOIN order_deliveries od ON o.id = od.order_id
--LEFT JOIN delivery_methods dm ON od.delivery_method_id = dm.id
--LEFT JOIN order_adjustments oa ON o.id = oa.order_id
--left join customers c on o.customer_id = c.id
left join discount_transactions dt on dt.order_id = o.id
left join merchants m ON o.merchant_id = m.id
left join catalog_items ci ON o.id = ci.id
 
 
where 1=1
and to_char(o.created_at, 'YYYYMM') = '202111'
and voucher_code ilike '%ovoHAPPY%'
 
group by to_char(o.created_at, 'YYYYMM'), --o.customer_id,
   	dt.voucher_code, o.delivery_code--, m.name, o.order_code--, ci.name, o.order_cod
 
 
 
####First Transaksi Delivery
select u.id,
   	u.fullname,
   	join_date,
   	fst_dt,
   	extract(day from fst_dt_-join_date_) as dif_date
	--   extract(month from fst_dt_-join_date_) as dif_month
from
(
select  u.id,
    	u.fullname,
    	to_char(u.created_at,'YYYYMMDD') as join_date,
    	u.created_at as join_date_,
    	min(to_char(o.created_at,'YYYYMMDD')) as fst_dt,
    	min(o.created_at) as fst_dt_
    	-- extract(day from min(o.created_at) - u.created_at) as diff
from users u
left join orders o on o.user_id = u.id
where 1=1
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) --—complete
and to_char(o.created_at,'YYYYMMDD') between '20211101' and '20211130'
and to_char(u.created_at,'YYYYMMDD') >= '20200301'
group by u.id, u.fullname, to_char(u.created_at,'YYYYMMDD'), u.created_at
-- having min(to_char(o.created_at,'YYYYMMDD')) is not null
-- limit 100
) u
 
##### Borzo berdasarkan jarak
select COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) THEN o.po_no ELSE NULL END)) AS trx
from orders o
left join order_senders oss on o.order_sender_id = oss.id
 
where 1=1
and status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
and to_char(o.created_at, 'YYYYMMDD') between '20211101' and '20211130'
and o.distance <= 10
--and (oss.city ilike '%jakarta%'
--or oss.city ilike '%jkt%'
--or oss.city ilike '%bogor%'
--or oss.city ilike '%depok%'
--or oss.city ilike '%tangerang%'
--or oss.city ilike '%bekasi%'
--)
and o.delivery_type_id in ('16')
 
 
##### No HP Driver
select
 to_char(o.created_at, 'YYYYMM') as month,
   	dt.name as delivery_name,
   	--oss.city,
   	ou.driver_phone,
 	   count(distinct ou.driver_phone) as total_driver
   	
from orders o
left join order_senders oss on o.order_sender_id = oss.id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
left join (select partner_po_no, max(driver_phone) as driver_phone
from order_updates
where 1=1
and to_char(created_at, 'YYYYMM') = '202111'
group by partner_po_no) ou on ou.partner_po_no = o.gosend_code
 
where 1=1
and to_char(o.created_at, 'YYYYMM') = '202111'
AND o.status_id IN (2,1,8,9,11,96, 29, 31,32,34,39)
--and to_char(o.created_at, 'YYYYMM') between '202011' and '202012'
and dt.name ilike '%borzo%'
group by
 to_char(o.created_at, 'YYYYMM'),
   	dt.name,
   	--oss.city
   	ou.driver_phone
   	
 
#### Completed Transaction for Armada Baru
select DISTINCT o.po_no,
d.name as delivery_name,
o.user_id,
u.fullname,
os.city as sender_city,
ors.city as receiver_city,
-- u.phone_number,
o.distance,
o.total_amount,
x.name as category_name,
--o.status_id,
--ot.name AS status_name,
-- o.payment_method_id,
pm.name AS payment_method_name,
--o.cancel_detail,
o.order_date  AS order_date
 
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN order_receivers ors ON o.order_receiver_id = ors.id
LEFT JOIN item_specifications i ON o.item_specification_id = i.id
LEFT JOIN item_types x ON i.item_type_id = x.id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN order_statuses ot ON o.status_id = ot.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
WHERE 1=1
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20201201' and '20201231'
AND status_id IN (2,1,8,9,11,96, 29, 31,32,34,39) --—complete
AND o.delivery_type_id IN ('1','2','12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60') -- On Demand
and (os.city ilike '%Jakarta Barat%'
or os.city ilike '%West Java%')

========================================================================================================================================================================================================================

Mencari New User Active based on sucess Daily Scrum
SELECT 	

	   COUNT(DISTINCT o.user_id) AS user_act , COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount
FROM orders o
left join users u on o.user_id = u.id
where 1=1
AND  TO_CHAR(u.created_at, 'YYYY-MM-DD') = '2022-05-29'
AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52)
AND TO_CHAR(o.created_at, 'YYYY-MM-DD') = '2022-05-29'


Mencari All New User Active Daily Scrum
SELECT 	

	   COUNT(DISTINCT o.user_id) AS user_act , COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount
FROM orders o
left join users u on o.user_id = u.id
where 1=1
AND  TO_CHAR(u.created_at, 'YYYY-MM-DD') = '2022-05-30'
--AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52)
AND TO_CHAR(o.created_at, 'YYYY-MM-DD') = '2022-05-30'


Mengisi partner report vi BI dan Daily Scrum (db delivery wehelpyou)
SELECT 	
TO_CHAR(o.created_at, 'YYYYMMDD') AS day,
	   dt.name AS delivery_name,
	   pm.name AS payment_method,
	   -- COUNT(DISTINCT (CASE WHEN status_id IN (2,8,9,1,11,96) THEN o.po_no ELSE NULL END)) AS trx,
	   COUNT(DISTINCT (CASE WHEN status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) THEN o.po_no ELSE NULL END)) AS trx,
	   COUNT(DISTINCT (CASE WHEN status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) THEN o.po_no ELSE NULL END)) AS trx_cncl,
	   SUM(CASE WHEN status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) THEN total_amount ELSE NULL END) AS total_amount,	  
	   SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
	   COUNT(DISTINCT (CASE WHEN status_id IN (96) THEN o.po_no ELSE NULL END)) AS trx_rejected

FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
-- AND status_id IN (88,99, 87, 98)
-- AND status_id IN (2,8,9,1,11,96)
AND TO_CHAR(o.order_date, 'YYYYMMDD') between '20220301' and '20220331'
--AND TO_CHAR(o.created_at, 'YYYYMMDD') = '20211014'

GROUP BY TO_CHAR(o.created_at, 'YYYYMMDD'),
	   dt.name, pm.name

ORDER BY  TO_CHAR(o.created_at, 'YYYYMMDD') -- , COUNT(DISTINCT o.po_no) DESC

Mencari Data Active User Delivery TH (db delivery)
SELECT 	
	   COUNT(DISTINCT o.user_id) AS user_act , COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount

FROM orders o
where 1=1
AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52)
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20220401' and '20220430'

Mencari data untuk transaksi jam terbanyak semua layanan delivery dan 3PL
select o.id AS order_id, o.gosend_code, o.po_no, d.name AS Service, o.total_amount,it.name , pm.name AS payment, ou.name AS status, os.name, os.phone,os.address,os.location , i.weight, o.distance, TO_CHAR (o.order_date, 'HH:MI:SS') AS date, cri.name AS cancel_reason, os.city AS Origin, os.district_city AS Kecamatan
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN item_specifications i ON o.item_specification_id = i.id
LEFT JOIN item_types x ON i.item_type_id = x.id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
LEFT JOIN order_statuses ou ON o.status_id = ou.id
LEFT JOIN order_receivers ors ON o.order_receiver_id = ors.id
LEFT JOIN cancel_reasons cri ON o.cancel_reason_id = cri.id
LEFT JOIN item_types it ON i.item_type_id = it.id
where o.status_id NOT IN (5,89,21) and o.delivery_type_id IN (12,13,14,15,17,18,19,20,21, 62,16,54,55,56,57,58,59,60,22,23,51,52,53,43,69,44,45,46,47,48,25,26,27,28,29,30,31,32,33,34,35,36,37,38,61,49,50,39,40,41,42,63,64,65,66,67,68) and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2022-01-01 00:00:00' and '2022-01-31 23:59:59'

Mencari Status cancel on Demand per month (db delivery)
select
	   dt.name AS delivery_name,
	   --pm.name AS payment_method,
	   COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount

FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
AND status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) --cncl
--AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) --—complete
--AND o.delivery_type_id IN ('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','61','63','64','65','66','67','68') --3Pl
AND o.delivery_type_id IN ('12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '62','69') -- On Demand
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20220101' and '20220131'

GROUP BY
	   dt.name
--pm.name

ORDER BY  dt.name DESC

Mencari Status Finish on Demand per month (db delivery)
select
	   dt.name AS delivery_name,
	   --pm.name AS payment_method,
	   COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount

FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
--AND status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) --cncl
AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) --—complete
--AND o.delivery_type_id IN ('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','61','63','64','65','66','67','68') --3Pl
AND o.delivery_type_id IN ('12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '62','69') -- On Demand
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20220101' and '20220131'

GROUP BY
	   dt.name
--pm.name

ORDER BY  dt.name DESC

Mencari Status Finish 3PL per month

select
	   dt.name AS delivery_name,
	   --pm.name AS payment_method,
	   COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount

FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
--AND status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) --cncl
AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) --—complete
AND o.delivery_type_id IN ('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','61','63','64','65','66','67','68') --3Pl
--AND o.delivery_type_id IN ('12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '62','69') -- On Demand
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20220101' and '20220131'

GROUP BY
	   dt.name
--pm.name

ORDER BY  dt.name DESC

Mencari Status Cancel 3PL per month

select
	   dt.name AS delivery_name,
	   --pm.name AS payment_method,
	   COUNT(DISTINCT o.po_no) AS trx, SUM(total_amount) AS total_amount

FROM orders o
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
LEFT JOIN payment_methods pm ON pm.id = o.payment_method_id
where 1=1
AND status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) --cncl
--AND status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) --—complete
AND o.delivery_type_id IN ('3','4','5','6','7','8','9','10','11','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','61','63','64','65','66','67','68') --3Pl
--AND o.delivery_type_id IN ('12','13','14','15','16','17','18','19','20','21','22','23','43','51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '62','69') -- On Demand
AND TO_CHAR(o.created_at, 'YYYYMMDD') between '20220101' and '20220131'

GROUP BY
	   dt.name
--pm.name

ORDER BY  dt.name DESC


Mencari voucher untuk delivery dan 3pl finish

select
      (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
      opd.voucher_code,
      count(distinct (case when o.status_id in (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) then o.po_no else null end)
      ) as trx_compl,
      SUM(CASE WHEN status_id IN (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52) THEN total_amount ELSE NULL END) AS total_amount,	  
      dt.name as delivery_name
    -- count(distinct (case when o.status_id in (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) then o.po_no else null end)
     -- ) as trx_cncl,
      --    SUM(CASE WHEN status_id IN (25,26,27,28,29,30,31,32,33,34,35,36,37,38,61) THEN total_amount ELSE NULL END) AS potential_total_amount,
      --o.user_id as user_id,
          --u.fullname AS fullname,
         -- u.phone_number AS phone_number,
        --  u.email AS email

from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
where 1=1
and status_id in (2,1,8,9,11, 29, 31,32,33,34,35,36,37,38,39,40,41,50,51,52)
and voucher_code ilike '%HARIKONSUMEN%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMMDD') between '20220401' and '20220430'
group by  (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
      opd.voucher_code, dt.name--, o.user_id, fullname, phone_number, email\

Mencari voucher untuk delivery dan 3pl Cancel


select
      (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end) as eat_noneat,
      opd.voucher_code,
      count(distinct (case when o.status_id in (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) then o.po_no else null end)
      ) as trx_compl,
      SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98) THEN total_amount ELSE NULL END) AS total_amount,	  
      dt.name as delivery_name
    -- count(distinct (case when o.status_id in (51,87,20,91,6,88,99, 87, 98) then o.po_no else null end)
     -- ) as trx_cncl,
      --    SUM(CASE WHEN status_id IN (51,87,20,91,6,88,99, 87, 98) THEN total_amount ELSE NULL END) AS potential_total_amount,
      --o.user_id as user_id,
          --u.fullname AS fullname,
         -- u.phone_number AS phone_number,
        --  u.email AS email
from order_price_details opd
left join orders o on opd.order_id = o.id
left join users u on o.user_id = u.id
left join order_statuses oss on o.status_id = oss.id
left join partner_webhooks pw on pw.po_no = o.po_no
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id
where 1=1
and status_id in (51,87,20,91,6,88,99,97,95,85,84,80,77,45,44,23, 98)
and voucher_code ilike '%pilihovo%'
--and voucher_code is not null
and to_char(o.created_at, 'YYYYMMDD') between '20211104' and '20211110'
group by  (case when pw.external_partner_id = '5' then 'Eats' else 'Delivery' end),
      opd.voucher_code, dt.name--, o.user_id, fullname, phone_number, email\


Mencari monthly partner
select o.id AS order_id, o.gosend_code, o.po_no, d.name AS Service, o.total_amount,it.name , pm.name AS payment, ou.name AS status, os.name, os.phone,os.address,os.location , i.weight, o.distance, o.order_date AS date, cri.name AS cancel_reason, os.city AS Origin, os.district_city AS Kecamatan
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN order_senders os ON o.order_sender_id = os.id
LEFT JOIN item_specifications i ON o.item_specification_id = i.id
LEFT JOIN item_types x ON i.item_type_id = x.id
LEFT JOIN delivery_types d ON o.delivery_type_id = d.id
LEFT JOIN payment_methods pm ON o.payment_method_id = pm.id
LEFT JOIN order_statuses ou ON o.status_id = ou.id
LEFT JOIN order_receivers ors ON o.order_receiver_id = ors.id
LEFT JOIN cancel_reasons cri ON o.cancel_reason_id = cri.id
LEFT JOIN item_types it ON i.item_type_id = it.id
where o.status_id NOT IN (5,89,21) and o.delivery_type_id IN (22,23,51) and o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2022-04-01 00:00:00' and '2022-04-30 23:59:59'


Untuk mencari data B2B

SELECT o.po_no, o.order_date, o.total_amount, p.partner_name, os.name as status
FROM "order_partners" o
LEFT JOIN partners p ON o.partner_id = p.id
LEFT JOIN order_statuses os ON o.status_id = os.id
WHERE TO_CHAR (o.order_date, 'YYYYMMDD') between '20220401' and '20220430'

Atau untuk lengkapnya menggunakan Query ini
SELECT o.po_no, o.order_date, o.total_amount, p.partner_name, dt.name as Delivery_type, os.name as status
FROM "order_partners" o
LEFT JOIN partners p ON o.partner_id = p.id
LEFT JOIN order_statuses os ON o.status_id = os.id
LEFT JOIN delivery_types dt ON o.delivery_type_id = dt.id

WHERE TO_CHAR (o.order_date, 'YYYYMMDD') between '20220401' and '20220430'


Cara mengetahui New User by Registered Account

select o.fullname, o.phone_number
FROM users o

where o.created_at at time zone 'asia/jakarta' at time zone 'utc' between '2022-04-25 00:00:00' and '2022-04-25 23:59:59'

Cara mengetahui voucher yang sukses digunakan 
Db_voucher


SELECT *
FROM "voucher_logs"
WHERE "voucher_id" = '500' AND "redeem_date" IS NOT NULL AND "created_at" at time zone 'asia/jakarta' at time zone 'utc' between '2022-05-01 00:00:00' and '2022-05-08 23:59:59'


