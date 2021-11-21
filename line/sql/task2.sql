/*
средняя сумма чека в месяц, среднее количество операций в месяц, среднее количество клиентов, которые совершали операции
долю от общего количества операций за год и долю в месяц от общей суммы операций; 
*/
SELECT   month_
	, avg(cnt_client)   OVER (ORDER BY month_ ASC)::int AS avg_client
	, avg(cnt_transact) OVER (ORDER BY month_ ASC)::int AS avg_transact
	, (sum_payment / cnt_pay)                           AS average_spend
	, sum_payment AS sum_p
	--, avg(cnt_transact) OVER (ORDER BY month_ ASC) / (SELECT COUNT(id_check) from transactions_info) * 100  as df
	, ROUND(100 * (cnt_transact::numeric / 
				   (SELECT COUNT(id_check) from transactions_info)::numeric), 3)   || '%' AS  pct_total_count
	, ROUND(100 * (sum_payment::numeric / 
				   (SELECT SUM(sum_payment) from transactions_info)::numeric), 3)  || '%' AS pct_total_sum  
FROM     (SELECT   TO_CHAR(date_new, 'YYYY-MM') AS month_ 
			  , COUNT(DISTINCT id_client) AS cnt_client
			  , COUNT(id_check) AS cnt_transact
			  , SUM(sum_payment) AS sum_payment
			  , COUNT(sum_payment) as cnt_pay
          FROM     transactions_info
		  --LEFT JOIN customer_info ci USING (id_client)
          GROUP BY TO_CHAR(date_new, 'YYYY-MM')) t
ORDER BY month_ ASC;


/*
вывести % соотношение M/F/NA в каждом месяце с их долей затрат
*/	  
WITH cte AS (
SELECT TO_CHAR(date_new, 'YYYY-MM') AS month_
	, gender
	, COUNT(*) as count_gender
	, SUM(sum_payment) as sum_month_p_on_gender
FROM customer_info 
	INNER JOIN transactions_info USING (id_client)
GROUP BY TO_CHAR(date_new, 'YYYY-MM'), gender
ORDER BY month_, gender	  
)
SELECT month_
	, gender
	, sum_month_p_on_gender
	, ROUND(100 * sum_month_p_on_gender::numeric 
	   / SUM(sum_month_p_on_gender::numeric) OVER (PARTITION BY month_), 2)::numeric || '%' as pct_sum_payment_on_month
	, ROUND(100 * count_gender / SUM(count_gender) OVER (PARTITION BY month_), 3)::numeric || '%' as pct_gender
FROM cte 








/*
среднее количество операций
*/
SELECT   month_, avg(cnt) OVER (ORDER BY month_ ASC)::int avg_client
FROM     (SELECT   TO_CHAR(date_new, 'YYYY-MM') AS month_
		  		, COUNT(id_check) AS cnt
          FROM     transactions_info
          GROUP BY TO_CHAR(date_new, 'YYYY-MM')) t
ORDER BY month_ ASC;
