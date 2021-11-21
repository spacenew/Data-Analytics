/*
вывести список клиентов с непрерывной историей за год.
Здесь можно было взять клиентов, которые совершали непрерывно покупки с момента первой покупки или с момента
начала истории транзакций.
Решил, что здесь требуется взять клиентов, которые заказывали каждый месяц с начала истории транзакции.
Т.о получается, что у такого клиента должно быть > 12 записей - по 1 на каждый месяц, включая последний месяц.
Брал уникальные записи, т.к нам не важно сколько транзакции в течении месяца сделал коиент. Достаточно 1.
Далее использовал этот код в отборе
*/			
SELECT id_client
FROM transactions_info
GROUP BY id_client
HAVING COUNT(DISTINCT  date_trunc('month', date_new))> 12								
		
/*
средний чек за период. количество всех операций по клиенту за период.
Взял средний чек только по тем пользователя, которые совершали транзакции в каждом месяце года
*/
SELECT  
	id_client
	, ROUND(AVG(sum_payment::numeric), 3) as avg_year_spend
	, COUNT(*) as count_year_transact
FROM transactions_info 
WHERE id_client IN (SELECT ID_client
					FROM transactions_info
					GROUP BY ID_client
					HAVING COUNT(DISTINCT  date_trunc('month', date_new))> 12)
GROUP BY id_client

/*
Cредняя сумма покупок за месяц. 
*/
SELECT   month_
	, sum_payment AS average_month_sum
FROM     (SELECT   TO_CHAR(date_new, 'YYYY-MM') AS month_ 
		  , SUM(sum_payment) AS sum_payment
          FROM     transactions_info
		  WHERE id_client IN (SELECT ID_client
					FROM transactions_info
					GROUP BY ID_client
					HAVING COUNT(DISTINCT  date_trunc('month', date_new))> 12)
          GROUP BY TO_CHAR(date_new, 'YYYY-MM') ) t 
GROUP BY month_, sum_payment
ORDER BY month_ ASC;