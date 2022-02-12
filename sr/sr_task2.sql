SELECT month_,
	   payment_id,
	   payment_date,
       amount,
	   SUM(amount) OVER (PARTITION BY month_) as month_sum
FROM (
  SELECT payment_id, 
         amount,
		payment_date,
		 to_char(payment_date, 'YYYY-MM') as month_,
         COUNT(*) OVER (PARTITION BY DATE_TRUNC('month', payment_date)) as cnt,
         RANK() OVER (PARTITION BY DATE_TRUNC('month', payment_date) order by amount desc) as rn
  from payments
) t
where (rn::numeric / cnt::numeric) <= 0.05;