# SQL zoo
Created: 2021-12-14 13:45
Tags: #sql #databases #relational-model 
***

# Basic SELECT
```sql
SELECT attribute-list
   FROM table-name
   WHERE condition
```
-   `attribute-list`
-   -   This is usually a comma separated list of attributes (field names)
    -   Expressions involving these attributes may be used. The normal mathematical operators `+, -, *, /` may be used on numeric values. String values may be concatenated using `||`
    -   To select all attributes use *
    -   The attributes in this case are: `name`, `region`, `area`, `population` and `gdp`
-   `table-name`
    -   In these examples the table is always `bbc`.
-   `condition`
-   -   This is a boolean expression which each row must satisfy.
    -   Operators which may be used include `AND`, `OR`, `NOT` 
		-   Numeric: >, >=, =, <, <=, `!=` 
		-   `<>` for non numeric
    -   The `LIKE` operator permits strings to be compared using 'wild cards'. The symbols '\_' and '%' are used to represent a single character or a sequence of characters. 
		-   `MS Access SQL` uses `?` and `*` instead of an underscore `_` and `%` .
    -   The `IN` operator allows an item to be tested against a list of values.
    -   There is a `BETWEEN` operator for checking ranges.
-   nested `SELECT` loops function like nested for loops

```sql
# countries with a less than a third of the population of the countries around it
SELECT name, region FROM bbc x
WHERE population < ALL(
	SELECT population/3 FROM bbc y 
	WHERE 
		y.region = x.region 
		AND y.name != x.name
)
```

# Aggregation functions
- aggregators: 
	- Numeric: `MIN`, `MAX,` `COUNT`, `SUM`, `AVG`
	- `DISTINCT`
	- `LENGTH` (strings)
	- note that `COUNT` requires a `GROUP BY`
- concatenate
	- `CONCAT(a, b)`
	- `a || b`
	- `a + b`
- `HAVING` filters rows **after** aggregation, whereas `WHERE` applies filter criteria **before**
	- `WHERE` precedes `GROUP BY`
	```sql
	SELECT continent, COUNT(name)
		FROM world
		WHERE population>200000000
	GROUP BY continent
	```
	- `HAVING` after `GROUP BY`
	```sql
	SELECT continent, SUM(population)
		FROM world
		GROUP BY continent
	HAVING SUM(population)>500000000
	```

```sql
ORDER BY [col1] ASC/DESC, [col2] ASC/DESC, ...
```
- orders `col1`, then for rows with identical `col1` values, sorts them by `col2`, etc.

## `GROUP BY` to remove duplicate rows
[Self join - SQLZOO](https://sqlzoo.net/wiki/Self_join) (no. 7)
Without the last `GROUP BY [...]`, the results are duplicated between `a` and `b`. 
```sql
SELECT a.company, a.num
FROM route a JOIN route b ON 
(a.company=b.company AND a.num=b.num)
WHERE a.stop=115 AND b.stop=137
GROUP BY a.company, a.num
```


# Joining
![[SQL joins.png]]
#sql-joins

Join two tables (default is inner join) 
```sql
SELECT yr,COUNT(title) FROM
  movie JOIN casting ON movie.id=movieid
        JOIN actor   ON actorid=actor.id
WHERE name='Rock Hudson'
GROUP BY yr
HAVING COUNT(title) > 2
```
 
Duplicating tables so that a 'source' table (a) can be referenced differently from a 'destination' table (b)
 ```sql
SELECT a.company, a.num, stopa.name, stopb.name
FROM route a JOIN route b 
	ON (a.company=b.company AND a.num=b.num)
	JOIN stops stopa ON (a.stop=stopa.id)
	JOIN stops stopb ON (b.stop=stopb.id)
WHERE stopa.name='Craiglockhart' AND stopb.name='London Road'
 ```
 
 Repeated self-joins (I found this **very** difficult)
 ^repeated-self-joins
 ```sql
SELECT DISTINCT a.num, a.company, stopb.name, c.num, c.company
FROM route a 
	JOIN route b ON(a.num=b.num AND a.company=b.company)
	JOIN (route c 
		JOIN route d ON(c.num=d.num AND c.company=d.company)
	)
	JOIN stops stopa ON(stopa.id=a.stop)
	JOIN stops stopb ON(stopb.id=b.stop)
	JOIN stops stopc ON(stopc.id=c.stop)
	JOIN stops stopd ON(stopd.id=d.stop)
WHERE 
	stopa.name='Craiglockhart' AND
	stopb.name=stopc.name AND
	stopd.name='Lochend'
GROUP BY a.num, a.company, stopb.name, c.num, c.company
```
 
## References
1. [SQLZOO](https://sqlzoo.net/wiki/SQL_Tutorial)