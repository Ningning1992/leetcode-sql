/* level: easy */

--lt 176
/* Need to consider about the case that only one record： 
不用temporary table的话，不会return null， 会return为空 */
SELECT (
    SELECT salary
    FROM(
        SELECT DISTINCT Salary, RANK() OVER (ORDER BY Salary DESC) as row_index
        FROM Employee
    ) tmp
    WHERE row_index = 2
) AS SecondHighestSalary;

--mysql only
SELECT(
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1 
) AS SecondHighestSalary;






--lt 196
DELETE FROM Person
WHERE(
    Id in (
        SELECT a.Id 
        FROM (
            SELECT Id, Email, RANK() OVER (PARTITION BY Email ORDER BY Id) AS MyRank
            FROM Person
        ) a
        WHERE MyRank != 1 
    )
);

DELETE FROM Person
WHERE (
    Id NOT IN (
        SELECT * FROM (
            SELECT MIN(Id) 
            FROM Person
            GROUP BY Email
        ) tmp
    )
);









--lt 197 (we can leverage lag(Temperature, 1) with window function to get previous temperature as well)
SELECT Id
FROM (
    SELECT b.Id, b.Temperature AS Tb, a.Temperature AS Ta
    FROM Weather a
    LEFT JOIN Weather b
    ON a.RecordDate = DATEADD(day, -1, b.RecordDate)
) tmp
WHERE Tb > Ta










--lt 596

SELECT class
FROM courses
GROUP BY class
HAVING COUNT(DISTINCT student) > 4

--deal the duplicates from the data source level instead of after using group by 
SELECT class
FROM (SELECT DISTINCT student, class FROM courses) as tbl
GROUP BY class
HAVING COUNT(class) >= 5






--lt 619
SELECT MAX(num)
FROM(
    SELECT num, COUNT(*) AS appear_time
    FROM num_table
    GROUP BY num
    HAVING COUNT(*)=1
) tmp






--lt 597
SELECT
ROUND(
    IFNULL(
    (SELECT COUNT(*) FROM (SELECT DISTINCT requester_id, accepter_id FROM request_accepted) AS A)
    /
    (SELECT COUNT(*) FROM (SELECT DISTINCT sender_id, send_to_id FROM friend_request) AS B),
    0)
, 2) AS accept_rate;

--Can you write a query to return the accept rate but for every month? (MySQL)
WITH monthly_accept AS (
    SELECT m, COUNT(*) AS accpt_count
    FROM(
        SELECT DISTINCT requester_id, accepter_id, EXTRACT(YEAR_MONTH FROM accept_date) AS m
        FROM request_accepted
    ) tmp1
    GROUP BY m 
), monthly_request AS(
    SELECT m, COUNT(*) AS request_count
    FROM(
        SELECT DISTINCT sender_id, send_to_id, EXTRACT(YEAR_MONTH FROM request_date) AS m
        FROM friend_request
    ) tmp2
    GROUP BY m
)

SELECT (CASE WHEN monthly_request IS NOT NULL THEN monthly_request.m ELSE monthly_accept.m END) AS m,
       (CASE WHEN request_count IS NULL THEN 0
             WHEN request_count = 0 THEN 0
             ELSE ROUND(accpt_count/request_count, 2)
        END) AS accept_rate
FROM monthly_request
FULL OUTER JOIN monthly_accept
ON monthly_request.m=monthly_accept.m

--How about the cumulative accept rate for every day?
--Without null check (cumsum: counld try sum + window function)
SELECT ROUND(COUNT(DISTINCT requester_id, accepter_id) / COUNT(DISTINCT sender_id, send_to_id), 2) AS rate, 
       date_table.dates
FROM request_accepted acp, friend_request req, 
(SELECT request_date AS dates FROM friend_request
UNION
SELECT accept_date FROM request_accepted
ORDER BY dates) AS date_table
WHERE acp.accept_date <= date_table.dates
AND req.request_date <= date_table.dates
GROUP BY date_table.dates




--lt 183
SELECT Name AS Customers
FROM Customers c
LEFT JOIN Orders o
ON c.Id=o.CustomerId
WHERE o.Id IS NULL;

--not using join
SELECT customers.Name as 'Customers'
FROM customers
WHERE customers.Id NOT IN (
    SELECT CustomerId FROM Orders
)







--lt 181
--sol1
SELECT t1.Name AS 'Employee'
FROM Employee t1
JOIN Employee t2 
ON t1.ManagerId = t2.Id
WHERE t1.Salary > t2.Salary

--sol2
SELECT a.Name as Employee
FROM Employee a, Employee b
WHERE a.ManagerId = b.Id AND a.Salary > b.Salary;






--lt 175
SELECT FirstName, LastName, City, State 
FROM Person
LEFT JOIN Address
ON Person.PersonId = Address.PersonId;








--lt 182 (Another way to optimize this is using Having Count(*) > 1, so that we do not need subquery)
SELECT Email
FROM(
    SELECT Email, COUNT(*) AS freq
    FROM Person
    GROUP BY Email
)tmp
WHERE freq > 1;







--lt607
SELECT name 
FROM salesperson
WHERE salesperson.sales_id NOT IN (
    SELECT DISTINCT orders.sales_id
    FROM orders
    LEFT JOIN company
    ON orders.com_id = company.com_id
    WHERE company.name = 'RED'
);









--lt603
--sol1
SELECT DISTINCT (c1.seat_id)
FROM cinema c1
JOIN cinema c2
ON c1.seat_id + 1 = c2.seat_id
WHERE c1.free+c2.free = 2

--sol2
select
case
when (lag(free) over (order by seat_id) = 1 and free = 1) then seat
when (lead(free) over (order by seat_id) = 1 and free = 1) then seat
else NULL
end as Consecutive_Seats
from cinema;





--lt 577
SELECT name, bonus
FROM Employee
LEFT JOIN Bonus
ON Employee.empId = Bonus.empId
WHERE COALESCE(Bonus.bonus, 0) < 1000







--lt 610
SELECT x, y, z,
       (CASE WHEN (x+y>z) AND (x+z>y) AND (z+y>x) THEN "Yes"
       ELSE "No"
       END) AS triangle
FROM triangle






--lt 620
SELECT *
FROM cinema
WHERE id%2 != 0 AND description != "boring"
ORDER BY rating DESC;






--lt 586
SELECT customer_number
FROM orders
GROUP BY customer_number
ORDER BY COUNT(*) DESC
LIMIT 1;






--lt 584
SELECT name 
FROM customer 
WHERE referee_id <> 2 OR referee_id IS NULL;





--lt 627 (update the table)
UPDATE salary
SET
    sex = CASE sex
        WHEN 'm' THEN 'f'
        ELSE 'm'
    END;








--lt 613
SELECT MIN(ABS(p1.x - p2.x)) AS shortest
FROM point p1
JOIN point p2 
ON p1.x != p2.x;






--lt595
SELECT name, population, area
FROM World
WHERE area>3000000 OR population>25000000;










/* level: Medium */

--lt614 (count follower's follower)
SELECT f1.follower,
       COUNT(DISTINCT f2.follower) AS num 
FROM follow AS f1
JOIN follow AS f2
ON f1.follower = f2.followee
GROUP BY f1.follower
ORDER BY f1.follower



--lt177
SELECT (CASE WHEN Salary IS NOT NULL THEN Salary ELSE NULL END) AS Salary
FROM (
    SELECT Salary, ROW_NUMBER() OVER (ORDER BY Salary DESC) AS row_index
    FROM Employee
)t1
WHERE row_index = N

set N=N-1
select DISTINCT Salary from Employee
order by Salary desc 
limit 1 offset N




--lt184
WITH t1 AS (
    SELECT Name,
           Salary,
           DepartmentId,
           DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
    FROM Employee 
)
SELECT Department.Name AS Department, t1.Name AS Employee, Salary
FROM t1
LEFT JOIN Department
ON Department.Id=t1.DepartmentId
WHERE Rank = 1 AND Department.Name IS NOT NULL;



--lt180
--sol1: faster
SELECT DISTINCT ConsecutiveNums
FROM (
    SELECT (CASE WHEN LAG(Num, 1) OVER (ORDER BY Id) = Num AND LAG(Num, 2) OVER (ORDER BY Id) = Num THEN Num ELSE NULL END) AS ConsecutiveNums FROM Logs
) t1
WHERE ConsecutiveNums IS NOT NULL

--sol2: slower
SELECT DISTINCT(t1.Num) AS ConsecutiveNums
FROM Logs t1
JOIN Logs t2
ON t1.Id = t2.Id+1
JOIN logs t3
ON t1.Id = t3.Id+2
WHERE t1.Num = t2.Num AND t1.Num=t3.Num



--lt578
--sol1
WITH answer_count AS(
    SELECT question_id, COUNT(*) AS answer_num
    FROM survey_log
    GROUP BY 1
    HAVING action = 'answer'
),
show_count AS (
    SELECT question_id, COUNT(*) AS show_num
    FROM survey_log
    GROUP BY 1
    HAVING action = 'show'
)

SELECT question_id AS survey_log
FROM answer_count
JOIN show_count
ON answer_count.question_id = show_count.question_id
ORDER BY answer_num/show_num DESC
LIMIT 1;

--sol2
SELECT question_id as survey_log
FROM
(
    SELECT question_id,
         SUM(case when action="answer" THEN 1 ELSE 0 END) as num_answer,
        SUM(case when action="show" THEN 1 ELSE 0 END) as num_show,    
    FROM survey_log
    GROUP BY question_id
) as tbl
ORDER BY (num_answer / num_show) DESC
LIMIT 1;


--sol3
SELECT 
    question_id AS 'survey_log'
FROM
    survey_log
GROUP BY question_id
ORDER BY COUNT(answer_id) / COUNT(IF(action = 'show', 1, 0)) DESC
LIMIT 1;







--lt178
SELECT Score,
       DENSE_RANK() OVER (ORDER BY Score DESC) as Rank
FROM Scores
ORDER BY Score DESC;







--lt574

SELECT Name 
FROM (
    SELECT Name, COUNT(*) as vote_num
    FROM Vote
    LEFT JOIN Candidate
    On Vote.CandidateId=Candidate.id 
    GROUP BY Name 
) t1
ORDER BY vote_num DESC
LIMIT 1;








--lt580
SELECT
    dept_name, COUNT(student_id) AS student_number
FROM
    department
        LEFT OUTER JOIN
    student ON department.dept_id = student.dept_id
GROUP BY department.dept_name
ORDER BY student_number DESC , department.dept_name;






--lt602
SELECT ids AS id, cnt as num 
FROM (
    SELECT ids, COUNT(*) AS cnt 
    FROM (
        SELECT requester_id AS ids FROM request_accepted
        UNION ALL
        SELECT accepter_id FROM request_accepted
    ) AS t1
    GROUP BY ids
) AS t2
ORDER BY num DESC
LIMIT 1;









--lt585 (using subquery in the where statement)
SELECT ROUND(SUM(TIV_2016), 2) AS TIV_2016
FROM insurance
WHERE TIV_2015 IN (
    SELECT TIV_2015
    FROM insurance
    GROUP BY TIV_2015
    HAVING COUNT(*) > 1
) AND CONCAT(LAT, LON) IN (
    SELECT CONCAT(LAT, LON)
    FROM insurance
    GROUP BY LAT, LON 
    HAVING COUNT(*) = 1
);






--lt612
--sol1
SELECT
    p1.x,
    p1.y,
    p2.x,
    p2.y,
    SQRT((POW(p1.x - p2.x, 2) + POW(p1.y - p2.y, 2))) AS distance
FROM
    point_2d p1
        JOIN
    point_2d p2 ON p1.x != p2.x OR p1.y != p2.y;

--sol2
SELECT
    t1.x,
    t1.y,
    t2.x,
    t2.y,
    SQRT((POW(t1.x - t2.x, 2) + POW(t1.y - t2.y, 2))) AS distance
FROM
    point_2d t1
        JOIN
    point_2d t2 ON (t1.x <= t2.x AND t1.y < t2.y)
        OR (t1.x <= t2.x AND t1.y > t2.y)
        OR (t1.x < t2.x AND t1.y = t2.y);







--lt626
SELECT (CASE WHEN id%2 != 0 AND counts != id THEN id+1
             WHEN id%2 != 0 AND counts = id THEN id
             ELSE id-1
       END) AS id, 
       student
FROM seat,
     (SELECT COUNT(*) AS counts FROM seat) AS seat_counts
ORDER BY id;





--lt608
SELECT id,
       (CASE WHEN p_id IS NULL THEN "Root"
             WHEN id NOT IN (SELECT DISTINCT p_id FROM tree WHERE p_id IS NOT NULL) THEN "Leaf"
             ELSE "Inner"
       END) AS Type 
FROM tree
ORDER BY id;




--lt570

--sol1
SELECT Name 
FROM
(
    SELECT t1.ManagerId, t2.Name, COUNT(*) AS direct_num
    FROM Employee t1
    LEFT JOIN Employee t2
    ON t1.ManagerId = t2.Id
    GROUP BY t1.ManagerId, t2.Name
) t3
WHERE direct_num >= 5;

--sol2
SELECT
    Name
FROM
    Employee AS t1 JOIN
    (SELECT
        ManagerId
    FROM
        Employee
    GROUP BY ManagerId
    HAVING COUNT(ManagerId) >= 5) AS t2
    ON t1.Id = t2.ManagerId
;





/* hard */
--lt262
select t.Request_at Day,
       ROUND((count(IF(t.status!='completed',TRUE,null))/count(*)),2) as 'Cancellation Rate'
from Trips t where 
t.Client_Id in (Select Users_Id from Users where Banned='No') 
and t.Driver_Id in (Select Users_Id from Users where Banned='No')
and t.Request_at between '2013-10-01' and '2013-10-03'
group by t.Request_at;

select Request_at as Day, round(sum(case when status != 'completed' then 1 else 0 end) * 1.0 / count(status),2) as 'Cancellation Rate'
from Trips
where Client_Id in (select Users_Id from Users where Banned = 'No') and Driver_Id in (select Users_Id from Users where Banned = 'No') and Request_at between '2013-10-01' and '2013-10-03'
group by 1




--lt185
SELECT Department, Employee, Salary
FROM
(
    SELECT t2.Name AS Department, t1.Name AS Employee, Salary,
           DENSE_RANK() OVER (PARTITION BY t1.DepartmentId Order BY Salary DESC) AS rank
    FROM Employee AS t1
    JOIN Department AS t2
    ON t1.DepartmentId=t2.Id
) AS t3 
WHERE rank <= 3 




--lt579
--sol1
SELECT
    E1.id,
    E1.month,
    (IFNULL(E1.salary, 0) + IFNULL(E2.salary, 0) + IFNULL(E3.salary, 0)) AS Salary
FROM
    (SELECT
        id, MAX(month) AS month
    FROM
        Employee
    GROUP BY id
    HAVING COUNT(*) > 1) AS maxmonth
        LEFT JOIN
    Employee E1 ON (maxmonth.id = E1.id
        AND maxmonth.month > E1.month)
        LEFT JOIN
    Employee E2 ON (E2.id = E1.id
        AND E2.month = E1.month - 1)
        LEFT JOIN
    Employee E3 ON (E3.id = E1.id
        AND E3.month = E1.month - 2)
ORDER BY id ASC , month DESC;

--sol2
WITH s AS
(SELECT Id,Month,Salary,
Sum(Salary) OVER (PARTITION BY Id ORDER BY Month) as SumSal,
ROW_NUMBER() OVER (PARTITION BY id ORDER BY id ASC, month DESC) rn
FROM emp1)

SELECT Id,Month,SumSal as Salary
FROM s
WHERE rn > 1





--lt601
SELECT id, visit_date, people
FROM
(
    SELECT id, visit_date, people, lead(people) OVER (ORDER BY id ASC) as next1,
    lead(people,2) OVER (ORDER BY id ASC ) as next2,
    lag(people) OVER (ORDER BY id ASC) as prev1,
    lag(people,2) OVER (ORDER BY id ASC ) as prev2
    FROM stadium
) AS cons_sal	
WHERE (people>=100 and next1>=100 and next2>=100) 
      or (people>=100 and prev1>=100 and prev2>=100) 
      or (people >= 100 and next1>=100 and prev1>=100);







--lt615
--sol1: date_format(pay_date, '%Y-%m') as pay_month to truncate the date can be better
SELECT tmp1.pay_month, 
       department_id,
       (CASE WHEN department_avg > company_avg THEN 'higher'
             WHEN department_avg < company_avg THEN 'lower'
             ELSE 'same'
        END) AS comparison
FROM(
    SELECT  SUBSTRING(Pay_date, 1, 7) AS pay_month,
            department_id,
            AVG(amount) AS department_avg
    FROM salary
    JOIN employee
    ON salary.employee_id = employee.employee_id
    GROUP BY 1, 2      
) tmp1
JOIN (
    SELECT  SUBSTRING(Pay_date, 1, 7) AS pay_month,
            AVG(amount) AS company_avg
    FROM salary
    GROUP BY 1
) tmp2
ON tmp1.pay_month = tmp2.pay_month
ORDER BY 1, 2


--sol2
with dataset as (
select
avg(amount) over (partition by trunc(pay_date,'mm') ) - avg(amount) over (partition by trunc(pay_date,'mm'),department_id ) as salary_ind,
department_id, trunc(pay_date,'mm') as pay_month
from salary a
join employee e on a.employee_id =e.employee_id
)
select distinct pay_month,department_id,
case when salary_ind > 0 then 'lower'
else (
case when salary_ind < 0 then 'higher '
else ('same') end
) end as comparison
from dataset










--lt618
SELECT
  America,
  Asia,
  Europe
FROM
  (SELECT
     row_number() OVER (PARTITION BY continent) AS asid,
     name AS Asia
   FROM
     student
   WHERE
     continent = 'Asia'
   ORDER BY Asia) AS t1
  RIGHT JOIN
  (SELECT
     row_number() OVER (PARTITION BY continent) AS amid,
     name AS America
   FROM
     student
   WHERE
     continent = 'America'
   ORDER BY America) AS t2 ON asid = amid
  LEFT JOIN
  (SELECT
     row_number()
     OVER (PARTITION BY continent) AS euid,
     name AS Europe
   FROM
     student
   WHERE
     continent = 'Europe'
   ORDER BY Europe) AS t3 ON amid = euid;











--lt569
select  id,
        company,
        salary
from (
    select id,
    company,
    salary,
    row_number() over(partition by company order by salary) as aesc_row,
    row_number() over(partition by company order by salary DESC) as desc_row
    from employee
) as subq
where subq.aesc_row in (desc_row, desc_row - 1, desc_row + 1)
order by company, salary




 





--lt571
select avg(t3.Number) as median
from Numbers as t3 
inner join 
    (select t1.Number, 
        abs(sum(case when t1.Number>t2.Number then t2.Frequency else 0 end) -
            sum(case when t1.Number<t2.Number then t2.Frequency else 0 end)) as count_diff
    from numbers as t1, numbers as t2
    group by t1.Number) as t4
on t3.Number = t4.Number
where t3.Frequency>=t4.count_diff









































