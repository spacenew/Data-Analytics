CREATE TABLE Trip (
    id INT NOT NULL,
    company INT NOT NULL,
    plane VARCHAR(255) NOT NULL,
    town_from VARCHAR(255) NOT NULL,
    town_to VARCHAR(255) NOT NULL,
    time_out timestamp NOT NULL,
    time_in timestamp NOT NULL,
    PRIMARY KEY (id)
);
 
CREATE TABLE Pass_in_trip (
    id INT NOT NULL,
    trip INT NOT NULL,
    passenger INT NOT NULL,
    place VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

 CREATE TABLE Passenger(
    id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id) 
);
  
CREATE TABLE Company (
    id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);
 
ALTER TABLE
    Trip ADD CONSTRAINT trip_company_fk FOREIGN KEY(company) REFERENCES Company (id);
   
ALTER TABLE
    Pass_in_trip ADD CONSTRAINT pass_in_trip_trip_fk FOREIGN KEY(trip) REFERENCES Trip (id);
   
ALTER TABLE
    Pass_in_trip ADD CONSTRAINT pass_in_trip_passenger_fk FOREIGN KEY(passenger) REFERENCES Passenger(id);

   
INSERT INTO Company (id, name) VALUES
    (1, 'aeroflot'),
    (2, 'S7'),
    (3, 'pobeda'),
    (4, 'redwings'), 
    (5, 'etihad'),
    (6, 'flydubai'),
    (7, 'airfrance'),
    (8, 'lufthansa');   
   
INSERT INTO passenger (id, name) VALUES
    (1, 'Ivanov A.A'),
    (2, 'Davidov S.A'),
    (3, 'Kutuzov M.I'),
    (4, 'Brail A.V'), 
    (5, 'Dugin Y.A'),
    (6, 'Novikov B.B'),
    (7, 'Chollet F.A'),
    (8, 'Noris C.R'),
    (9, 'Guberman I.N'),
    (10, 'Panarin A.A');

INSERT INTO Trip (id, company, plane, town_from, town_to, time_out, time_in) VALUES
    (2244, 2, 'Boeing', 'Moscow', 'Omsk', '2021-08-12 14:30:00', '2021-08-12 19:00:00'),
    (8888, 1, 'Airbus', 'Moscow', 'Berlin', '2021-05-10 11:50:00', '2021-05-10 14:20:00'),
    (3333, 3, 'SSJ-100', 'Moscow', 'Sochi', '2021-03-12 19:10:00', '2021-03-12 21:20:00'),
    (3423, 7, 'Boeing', 'London', 'Paris', '2021-04-04 13:30:00', '2021-04-04 15:15:00'),
    (7566, 6, 'Airbus', 'Dubai', 'Amsterdam', '2021-04-04 19:30:00', '2021-04-04 21:50:00'),
    (1111, 8, 'Boeing', 'Ankara', 'Berlin', '2021-04-04 19:30:00', '2021-04-04 21:50:00'),
    (3452, 4, 'IL-86', 'Vladivostok', 'Novosibirsk', '2021-06-06 07:00:00', '22021-06-06 12:40:00'); 
   
INSERT INTO pass_in_trip (id, trip, passenger, place) VALUES
    (1, 2244, 1, '1c'),
    (2, 1111, 3, '17a'),
    (3, 3452, 4, '2b'),
    (4, 2244, 5, '1c'), 
    (5, 3452, 2, '5f'),
	(6, 3452, 3, '5f'),
    (7, 3423, 7, '4a'),
    (8, 3423, 8, '26c'),
    (9, 8888, 1, '32c'),
    (10, 8888, 5, '21c'),
    (11, 3333, 1, '3c'),
    (12, 3333, 5, '5a'),
    (13, 7566, 1, '3c'),
    (14, 7566, 5, '5a'),
	(15, 1111, 7, '5a'),
	(16, 1111, 8, '5a');


SELECT * FROM company;
SELECT * FROM pass_in_trip;
SELECT * FROM passenger;
SELECT * FROM trip;


/*
Выведите имена всех пар пассажиров, летевших вместе на одном рейсе два или более раз, и количество таких совместных рейсов. 
В passengerName1 разместите имя пассажира с наименьшим идентификатором.
--Поля в результирующей таблице:
--1.	passengerName1
--2.	passengerName2
--3.	count
*/

SELECT passengerName1
	, passengerName2
	, COUNT(trip1) AS count_trip
FROM 
	/*
	Определяем ид. пользователя, имя пользователя, номер поездки
	*/
	(SELECT p2.id as pid1
	 	, p2.name as passengerName1
	 	, pit.trip as trip1
	FROM passenger p2 
	INNER JOIN pass_in_trip pit 
		ON p2.id = pit.passenger 
	GROUP BY pid1, passengerName1, trip1) as t1
	/*
	Внутренним соединение прицепляем туже таблицу по наименованию поездки
	Т.о получаем множество различных сооответсвий поездок.
	*/
INNER JOIN (
	SELECT p3.id as pid2
		, p3.name as passengerName2
		, pit2.trip as trip2
	FROM passenger p3
	INNER JOIN pass_in_trip pit2 
		ON p3.id = pit2.passenger
	GROUP BY pid2, passengerName2, trip2) as t2
ON t1.trip1 = t2.trip2
/*
Отбираем только те ид.пользователя, которые не совпадают. 
Иначе получим как связи одного и тоже пользователя, так и повторные связи разных пользователей
*/
WHERE pid1>pid2	
GROUP BY  passengerName1, passengerName2
/*
Отбираем только техпользователей, которые летали вместе более 1 раза
*/
HAVING COUNT(trip1)>1;





