/*
Вывести возрастные группы клиентов с шагом 10 лет  - вариант 1 
*/
SELECT id_client, 
 CASE 
	 WHEN age IS NULL THEN 'Null'
	 WHEN age < 10 AND NOT NULL THEN '0-10'
	 WHEN age < 20 THEN '10-20'
	 WHEN age < 30 THEN '20-30'
	 WHEN age < 40 THEN '40-50'
	 WHEN age < 50 THEN '40-60'
	 WHEN age < 60 THEN '60-70'
	 WHEN age < 70 THEN '70-80'
	 WHEN age < 80 THEN '80-90'
	 WHEN age < 90 THEN '90-100'
 	ELSE '<100'
 END AS groups_age
FROM customer_info
ORDER BY id_client

/*
Вывести возрастные группы клиентов с шагом 10 лет  - вариант 2 
*/
WITH age_groups AS (
    SELECT  (i*10)::text||'-'||(i*10+9)::text AS age_group
			, i*10   AS r_min
			, i*10+9 AS r_max
    FROM generate_series(0,9) AS t(i)
)
SELECT ag.age_group, ci.id_client
FROM age_groups ag
LEFT JOIN customer_info ci ON ci.age BETWEEN ag.r_min AND ag.r_max
WHERE age IS NOT NULL
GROUP BY ag.age_group, ci.id_client
ORDER BY ag.age_group;

/*
отдельно клиентов, 
у которых нет данной информации с параметрами сумма и количество операций за весь период, 
и поквартально, средние показатели и %.
Под фразой "нет данной информации" я понял так, что это те клиенты у которых отсутствует возраст.
Поэтому в отборе указал: WHERE age IS NULL 
*/
SELECT DISTINCT id_client
		, quarter
		, SUM(sum_payment)          OVER w_year    as total_sum
		, AVG(sum_payment::numeric) OVER w_year    as avg_sum
		, SUM(sum_payment)          OVER w_quarter as quarter_sum
		, AVG(sum_payment::numeric) OVER w_quarter as avg_sum_quarter
		, ROUND(100 * quarter_count_operat / total_count_operat , 3)::numeric as pct_count_of_total
		, ROUND(100 * 
				(SUM(sum_payment::numeric) OVER w_quarter / 
				 SUM(sum_payment::numeric) OVER w_year ), 3)::numeric as pct_sum_of_total
FROM customer_info 
LEFT JOIN (SELECT *
	  		, (EXTRACT(year    FROM date_new)::text || '.Q' || 
		 	   EXTRACT(quarter FROM date_new)::text) AS quarter
		   /*
		   Пришлось эту часть (расчет количества) вынести в подзапрос, 
		   т.к в основном запросе процент считался доля считалось с округлением до целого числа.
		   Хотя приведение типов к numeric или float делал.
		   */
		   ,   COUNT(*) OVER (PARTITION BY id_client)::numeric as total_count_operat
		   ,   COUNT(*) OVER (PARTITION BY id_client, (EXTRACT(year    FROM date_new)::text || '.Q' || 
		 	   										   EXTRACT(quarter FROM date_new)::text))::numeric as quarter_count_operat
		   FROM transactions_info) as t1 
	USING (id_client)
WHERE age IS NULL
WINDOW w_year    AS (PARTITION BY id_client),  
       w_quarter AS (PARTITION BY id_client, quarter)
ORDER BY id_client, quarter

