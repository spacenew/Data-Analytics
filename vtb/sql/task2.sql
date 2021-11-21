CREATE TABLE Client
(
	ClID INT NOT NULL,
	FIO CHARACTER VARYING(255) NOT NULL,
	email CHARACTER VARYING(255) NOT NULL,
	PRIMARY KEY (ClID)
);

CREATE TABLE Account
(
	tNumber BIGINT NOT NULL,
	operators CHARACTER VARYING(255) NOT NULL,
	Limit_tariff INT NOT NULL,
	ClID INT NOT NULL,
	PRIMARY KEY (tNumber)
);

CREATE TABLE Talks
(
	tNumber BIGINT NOT NULL,
	Begintime timestamp NOT NULL,
	EndTime timestamp NOT NULL
);

ALTER TABLE

Talks ADD CONSTRAINT talks_account_fk FOREIGN KEY(tNumber) REFERENCES Account (tNumber);

ALTER TABLE

Account ADD CONSTRAINT account_client_fk FOREIGN KEY(ClID) REFERENCES Client (ClID);



INSERT INTO Client (clid, fio, email) VALUES

(1, 'Иванов Иван Сергеевич', 'ad@yandex.ru'),

(2, 'Петров Егор Дмитриевич', 'petreg@mail.ru'),

(3, 'Саломатин Даниил Викторович', 'salomatin@gmail.com'),

(4, 'Гусев Никита Владимирович', 'nikgusev@yandex.ru'),

(5, 'Черепанов Алексей Андреевич', '24124@yandex.ru'),

(6, 'Биль Эдуард Степанович', 'bill999@gmail.com'),

(7, 'Кожин Андрей Андреевич', 'andrandr@mail.ru'),

(8, 'Хаапасало Вилли В', 'haap@gmail.com');


INSERT INTO account (tnumber, operators, limit_tariff, clid) VALUES

(79805556588, 'mts', 200, 1),

(79202435567, 'tele2', 200, 2),

(79705456547, 'megafon', 500, 3),

(79244556778, 'megafon', 200, 4),

(79234454657, 'mts', 700, 5),

(79802342566, 'mts', 150, 6),

(79863254657, 'mts', 250, 7),

(79555555555, 'beeline', 300, 8);


INSERT INTO talks (tnumber, begintime, endtime) VALUES

(79805556588, '2021-08-20T14:32:07', '2021-08-20T14:35:43'),

(79805556588, '2021-08-20T15:53:23', '2021-08-20T16:43:43'),

(79805556588, '2021-08-22T09:12:23', '2021-08-22T11:32:00'),

(79244556778, '2021-09-11T11:19:24', '2021-09-11T11:58:12'),

(79244556778, '2021-09-13T18:34:54', '2021-09-13T20:01:32'),

(79802342566, '2021-09-15T14:21:25', '2021-09-15T14:28:21'),

(79863254657, '2021-09-29T10:43:09', '2021-09-29T10:59:08'),

(79863254657, '2021-06-17T10:13:13', '2021-06-17T10:24:03'),

(79802342566, '2021-10-25T14:14:14', '2021-10-25T19:56:53'),

(79863254657, '2021-10-12T23:18:52', '2021-10-13T04:15:32'),

(79555555555, '2021-10-24T17:18:23', '2021-10-24T17:43:54');


/*
Найдите для заданного оператора всех клиентов, которые исчерпали свой предел по тарифу. 
Выведете подробную информацию о них.
*/ 
WITH cte AS (
SELECT t1.waste_limit, a.limit_tariff, a.operators, c.fio, c.email
FROM (
	SELECT 
		  t.tnumber,
		  /* 
			Рассчитываем количество потраченных минут для каждого пользователя
			Для этого в группировке по номеру телефона вычисляем разницу между началом и концом разговора
	      */
		  ROUND(SUM(EXTRACT(epoch FROM (endtime - begintime)))/60, 1) as waste_limit
	 FROM talks t
     GROUP BY t.tnumber
     ) as t1
INNER JOIN account a 
	ON t1.tnumber = a.tnumber
INNER JOIN client c 
	ON c.clid = a.clid
/* 
	Отбираем только тех пользователей, которые исчерпали лимит по тарифу			
*/
WHERE a.limit_tariff < t1.waste_limit 
	AND  a.operators = 'mts'
)
SELECT 
	fio, email
	, limit_tariff
	, waste_limit
	, operators
	, (limit_tariff-waste_limit) as remaining_limit
FROM cte


/*
Найдите всех клиентов, которые не пользуются услугами связи в течение заданного интервала времени. 
Выведете их в порядке возрастания неизрасходованных минут.
*/

WITH setup AS (
	/*  
	Задаем пороговое количество дней для дальнейшей подстановки в отбор.
	Если количестов дней после последнего звонка пользователя больше порога, то таких
	пользователей отбираем в результирующую выборку.
	*/
    SELECT 14::numeric as threshold  
),
cte AS (
SELECT t1.waste_minutes
	, a.limit_tariff
	, a.operators
	, c.fio
	, c.email
	, a.tnumber
	, a.clid
FROM (
	SELECT 
		  t.tnumber 
		  /*
		  Расчет потраченных минут
		  */
		  , ROUND(SUM(EXTRACT(epoch from (endtime - begintime)))/60, 1) as waste_minutes
	 FROM talks t, setup s
     GROUP BY t.tnumber, s.threshold
	/* 
	Отбираем пользователей, которые не пользовались связью 
	более 14 дней от текущей даты 
	*/
	 HAVING EXTRACT(DAY FROM CURRENT_DATE - MAX(t.endtime)) >= s.threshold 
     ) as t1
INNER JOIN account a 
	ON t1.tnumber = a.tnumber
INNER JOIN client c 
	ON c.clid = a.clid
/* Отбираем пользователей, 
  у которых не превышен лимит по тарифу 
*/
WHERE a.limit_tariff > t1.waste_minutes
         )
SELECT fio
	, waste_minutes
	, limit_tariff
	, ( limit_tariff-waste_minutes ) as remaining_time
FROM cte
ORDER BY remaining_time ASC


/* 
Выведете также самого не популярного оператора связи.
*/
SELECT operators
FROM account
GROUP BY operators
HAVING COUNT(operators) = 
	(SELECT MIN(query_in.count_amount) as min_count 
	FROM (SELECT operators, COUNT(operators) as count_amount 
		  FROM account GROUP BY operators) query_in);
		  



/* 
2-ой вариант с оконной функцией. 
*/
WITH ca AS (		  
SELECT DISTINCT tnumber
	/*
	Рассчитываем сколько дней прошло с последнего звонка от текущей даты
	*/
	, CURRENT_DATE - LAST_VALUE(endtime) OVER (PARTITION BY tnumber) as val
FROM talks
)
SELECT c.fio
	, ca.tnumber
	, a.limit_tariff
	, s.waste_minutes
	, ( a.limit_tariff-s.waste_minutes) as remaining_time
FROM ca
INNER JOIN account a
	ON ca.tnumber = a.tnumber
INNER JOIN (
SELECT 
		  t.tnumber 
		  /*
		  Расчет потраченных минут
		  */
		  , ROUND(SUM(EXTRACT(epoch from (endtime - begintime)))/60, 1) as waste_minutes
	 FROM talks t
     GROUP BY t.tnumber) as s
	ON ca.tnumber = s.tnumber
INNER JOIN client c
	ON c.clid = a.clid
/*
	Отбираем только тех пользователей, которые пользовались связью более 14 дней назад
*/
WHERE val > '14 day'::interval
ORDER BY remaining_time ASC
