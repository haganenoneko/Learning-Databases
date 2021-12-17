# Hackerrank SQL
Created: 2021-12-15 16:36
Tags: #sql #hackerrank
***

- [[#Median|Median]]
- [[#Advanced Join|Advanced Join]]
- [[#Symmetric pairs|Symmetric pairs]]
	- [[#The first block|The first block]]
	- [[#The second block|The second block]]
- [[#Multiple joins with group by|Multiple joins with group by]]
- [[#Interesting use of nested `from`s|Interesting use of nested `from`s]]
- [[#References|References]]


## Aggregation
- `ceil` = replace number with next highest integer
- `replace(a_b, a, b) = b_b` replace substring `a` with `b`
```sql
SELECT CEIL(AVG(Salary)-AVG(REPLACE(Salary,'0','')))
FROM EMPLOYEES
```

Sum of total wages (each wage = months x salary), and count the number of employees with maximum wages
```sql
select months*salary, count(employee_id) from Employee
group by months*salary
order by months*salary desc
limit 1;
```

Select `LAT_W` corresponding to maximum `LAT_N` value 
```sql
select round(LONG_W, 4) from STATION
where LAT_N = (
    select max(LAT_N) from STATION
    where LAT_N < 137.2345
	# note that no `ORDER BY ...` or `GROUP BY ...` or `LIMIT ..` 
	# is needed here, because `max(..)` automatically returns a single row
)
```

Return the LONG_W where the smallest LAT_N > 38.778
```sql
select round(LONG_W, 4) from STATION
where LAT_N = (
    select min(LAT_N) from STATION
    where LAT_N > 38.778
)
```

### Median
The way this works is by selecting the value of `LAT_N` for which the number of `LAT_N` subquery values below the parent query are equal to those above the parent query. 
```sql
# https://github.com/Thomas-George-T/HackerRank-SQL-Challenges-Solutions/blob/master/Aggregation/Weather%20Observation%20Station%2020.sql

select round(LAT_N, 4) from STATION s
where
    (select count(LAT_N)from STATION t where t.lat_n < s.lat_n)
    = (select count(LAT_N) from STATION t where t.lat_n > s.lat_n)
```

In Python
```python
# df.shape = (N, 3)
# 'LAT_N' in df.columns = True

LAT = df['LAT_N'].dropna()
for lat in LAT:
	if (LAT < lat).shape[0] == (LAT > lat).shape[0]: 
		print(lat)
		break 
```

## Advanced Join
Find names of students whose friends received higher salary than they did
- Note the `on` statements in `st_sal` and `fr_sal`: the latter are joined with the friends' IDs, whereas the former are joined with the students' IDs. 
- As a result, the salaries in `fr_sal` are ordered according to `Friend_ID`s, whereas `st_sal` is ordered with respect to `st.ID`. 
- Thus, for a given student, we have the ID/Salary of a given student, along with that of their friend, all in the same row. 

```sql
select Name
    from Students st
    join Friends fr on (fr.ID=st.ID)
    join Packages st_sal on (st_sal.ID=st.ID)
    join Packages fr_sal on (fr_sal.ID=fr.Friend_ID)
where st_sal.Salary < fr_sal.Salary
order by fr_sal.Salary
```

### Symmetric pairs 
(had a lot of problem with this one)
Note we use `union` to merge two tables which are named the same way (`X, Y from Functions F1`). This is needed for the global `order by X` statement at the end

#### The first block
- `exists` to check that multiple boolean conditions hold True between each `(X, Y)` pair in `F1` and `F2`. 
	- We don't need a `[variable] IN exists(...)`, can just use `exists()` directly
- the subquery in `exists(...)` uses `*` instead of explicitly declaring which columns of `F2` to show. 
	- i.e. only interested in checking conditions, so we only need to reference `F2.X` and `F2.Y`. 
- The subquery checks: `X1=Y2`, `X2=Y1`, `X2>X1`, and `X1 != Y1`. 
- If `X1=Y1`, we need to distinguish between identical pairs that appear only once vs. twice (we only need the latter)

#### The second block
- Searches for identical pairs `X=Y` that are present at least twice
- reuse `X, Y from Functions F1`, since we `union` will preserve column names
- To distinguish from identical pairs that appear only once, use a `select count(*)` subquery to count all pairs where `X=Y`, and then keep only the rows which are present more than once, i.e. `>1`
- `>1` is sufficient, because we use `distinct` to filter out potential pairs that are present 2+ times

```sql
-- https://github.com/BlakeBrown/HackerRank-Solutions/blob/master/SQL/5_Advanced%20Join/3_Symmetric%20Pairs/Symmetric%20Pairs.mysql

select X, Y from Functions F1
where exists(
	select * from Functions F2
	where 
		F1.X = F2.Y
		and F2.X = F1.Y
		and F2.X > F1.X
		and X != Y
)

union

select distinct X, Y from Functions F1 
where 
	X = Y
	and ((
		select count(*) from Functions 
		where X=F1.X and Y=F1.X
	) > 1)

order by X;
```

### Multiple joins with group by 
(also had a lot of difficulty here with the `join` and `AS` statements)

```sql
# https://github.com/BlakeBrown/HackerRank-Solutions/blob/master/SQL/5_Advanced%20Join/4_Interviews/Interviews.mysql

select con.contest_id, con.hacker_id, con.name,
    sum(total_subs) as total_subs,
    sum(total_acc) as total_acc,
    sum(total_vws) as total_vws,
    sum(total_uvws) as total_uvws
    
from Contests as con
left join Colleges as coll 
	on (coll.contest_id=con.contest_id)
left join Challenges as chall
	on (chall.college_id=coll.college_id)
left join (
	select challenge_id,
		sum(total_views) as total_vws,
		sum(total_unique_views) as total_uvws
	from View_Stats
	group by challenge_id
) as vws on (vws.challenge_id=chall.challenge_id)
left join (
	select challenge_id,
		sum(total_submissions) as total_subs,
		sum(total_accepted_submissions) as total_acc
	from Submission_Stats
	group by challenge_id
) as subs on (subs.challenge_id=chall.challenge_id)
		
group by con.contest_id, con.hacker_id, con.name
having (total_subs + total_acc + total_vws + total_uvws) > 0
order by con.contest_id

```

### Interesting use of nested `from`s
- the first/outer `from` is needed to filter start/end dates for the same project (and to only keep the earliest end date for any given start date)
- the inner `from` defines two tables: start dates `A` and end dates `B`
	- start dates and end dates are always continuous for a given project, i.e. a project lasting day 1-3 will have start dates [1, 2] and end dates [1, 2, 3]
	- first start and final end dates are found by using `not in` followed by another subquery for either start or end dates
	- since the start and end dates are not joined, `start < end` is needed to match them 
	- finally, `group by` aggregates multiple end dates for a given start date by taking the earliest end date
```sql
#https://github.com/BlakeBrown/HackerRank-Solutions/blob/master/SQL/5_Advanced%20Join/1_Projects/Projects.mysql
select Start_Date, X from (
    select A.Start_Date, min(B.End_Date) as X
    from
        -- start dates for each project
		(select Start_Date from Projects 
         where Start_Date not in 
         (select End_Date from Projects)) A,
        
		-- end dates for each project 
        (select End_Date from Projects
         where End_Date not in
         (select Start_Date from Projects)) B
 	
    where Start_Date < End_Date
    group by A.Start_Date
	-- after group by, min(B.End_Date) is applied
) P

-- order by increasing project duration
order by datediff(X, Start_Date), Start_Date;
```
