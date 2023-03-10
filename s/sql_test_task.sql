/*
SQL 1.
*/

SELECT 
	t1.groups,
	round(avg(t1.avg_minutes_on_issue), 2) as average_minutes
from
	(
	select 
		substr(h.issue_key, 1, 1) as groups, 
		h.issue_key , 
		AVG(h.minutes_in_status)/60 as avg_minutes_on_issue
	from history h 
	where h.status = 'Open'
	group by substr(h.issue_key, 1, 1), h.issue_key
	) t1
GROUP BY t1.groups


--SELECT  
--		substr(issue_key, 1, 1) as groups, 
--		ROUND(AVG(minutes_in_status)/60, 2) as average_minutes
--from history h 
--where status = 'Open'
--group by substr(issue_key, 1, 1)




/*
SQL 2.
*/

SELECT 
	t1.issue_key,
	t1.last_status,
	t1.created_at
FROM 
	(
	SELECT 
	    history.issue_key, 
	    CASE WHEN 
	    	history.started_at = max(history.started_at) 
	    	THEN history.status 
	    END AS last_status,
	    strftime('%Y-%m-%d %H:%M:%S', history.started_at / 1000, 'unixepoch') as created_at
	FROM 
	    history 
	WHERE 
		history.started_at <= strftime('%s', '2021-08-31') * 1000 --DATETIME меняем на дату в прошлом
	GROUP BY 
	    history.issue_key
	) t1
WHERE t1.last_status NOT IN ('Closed', 'Resolved');