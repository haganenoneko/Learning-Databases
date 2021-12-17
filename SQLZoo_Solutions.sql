
--My solutions to SQLZoo. Though I completed all the tutorials and quizzes, I've only included the solutions to tutorial problems that I found interesting and/or challenging.


-- SELECT WITHIN SELECT: https://sqlzoo.net/wiki/SELECT_within_SELECT_Tutorial
--4:
SELECT name, population FROM world 
WHERE population > (
	SELECT population FROM world 
	WHERE name = 'Canada') 
	AND population < (
		SELECT population FROM world 
		WHERE name = 'Poland'
	)
)

--5:
SELECT name, 
CONCAT(
	ROUND( 100*population / (
		SELECT population FROM world 
		WHERE name = 'Germany'
	),0), 
'%')
FROM world
WHERE continent = 'Europe'

--6:
SELECT name FROM world
WHERE gdp > ALL(
	SELECT gdp FROM world 
	WHERE 
		(continent = 'Europe') 
		AND (gdp > 0)
)

--7:
SELECT continent, name, area FROM world x
WHERE area >= ALL(
	SELECT area from world y
	WHERE 
		y.continent = x.continent 
		AND y.area > 0
)

--8:
SELECT continent, name FROM world 
WHERE name IN(
	SELECT name FROM world x
	WHERE name = (
		SELECT name FROM world y
		WHERE y.continent = x.continent 
		LIMIT 1
	)
)

--9:
SELECT name, continent, population 
FROM world x 
WHERE continent IN(
	SELECT continent FROM world y
	WHERE 
		x.continent = y.continent 
		AND 25000000 > ALL(
			SELECT population FROM world
			 WHERE continent = y.continent 
	)
)

--10:
SELECT name, continent 
FROM world x 
WHERE name IN(
	SELECT name FROM world y
	WHERE population > ALL(
		SELECT 3*population FROM world 
		WHERE 
			continent = x.continent 
			AND NOT (name = y.name)
	)
) 
ORDER BY name

-- JOIN: https://sqlzoo.net/wiki/The_JOIN_operation
--8:
SELECT DISTINCT(player)
FROM game 
	JOIN goal ON matchid = id 
WHERE 
	(team1='GER' OR team2='GER') 
	AND teamid != 'GER'


--9:
SELECT teamname, COUNT(player)
FROM goal JOIN eteam ON teamid=id
GROUP BY teamname

--10:
SELECT stadium, COUNT(matchid)
FROM game JOIN goal ON id=matchid
GROUP BY stadium

--11:
SELECT matchid, mdate, COUNT(id) 
FROM game JOIN goal ON matchid=id
WHERE (team1 = 'POL' OR team2 = 'POL')
GROUP BY id, mdate, matchid

--12:
SELECT matchid, mdate, COUNT(matchid)
FROM game JOIN goal ON (matchid=id)
WHERE goal.teamid = 'GER'
GROUP BY matchid, mdate

--13:
SELECT 
	mdate, 
	team1,
	SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END) AS score1,
	team2,
	SUM(CASE WHEN teamid=team2 THEN 1 ELSE 0 END) AS score2
FROM game 
	LEFT JOIN goal ON matchid = id
GROUP BY mdate, matchid, team1, team2

-- More JOIN: https://sqlzoo.net/wiki/More_JOIN_operations
--7:
SELECT actor.name
FROM casting 
	JOIN actor ON casting.actorid=actor.id
	JOIN movie ON casting.movieid=movie.id
WHERE movie.title = 'Alien'

--8:
SELECT movie.title
FROM casting
	JOIN actor ON casting.actorid=actor.id
	JOIN movie ON casting.movieid=movie.id
WHERE actor.name = 'Harrison Ford'

--9:
SELECT movie.title
FROM casting
	JOIN actor ON casting.actorid=actor.id
	JOIN movie ON casting.movieid=movie.id
WHERE 
	actor.name = 'Harrison Ford' 
	AND casting.ord > 1

--10:
SELECT movie.title, actor.name 
FROM casting 
	JOIN movie ON casting.movieid = movie.id
	JOIN actor ON casting.actorid = actor.id
WHERE (movie.yr = 1962) AND (casting.ord=1)

--12:
SELECT movie.title, actor.name
FROM movie
	JOIN casting ON (movie.id = casting.movieid AND ord=1)
	JOIN actor ON (actor.id = casting.actorid)

WHERE movie.id IN (
	SELECT movieid FROM casting
	WHERE actorid = (
		SELECT id FROM actor 
		WHERE name = 'Julie Andrews'
	)
)

--13:
SELECT actor.name
FROM actor 
	JOIN casting ON actorid=id
WHERE casting.ord=1

GROUP BY actor.name
HAVING COUNT(actor.name) >= 15
ORDER BY actor.name

--14:
SELECT title, COUNT(actorid)
FROM movie 
	JOIN casting ON id=movieid
WHERE yr=1978
GROUP BY title
ORDER BY COUNT(actorid) DESC, title ASC

--15:
SELECT actor.name 
FROM actor 
WHERE id IN(
	SELECT actorid FROM casting
	WHERE NOT actorid=(
		SELECT id FROM actor 
		WHERE name='Art Garfunkel'
	) AND movieid IN(
		SELECT movieid FROM casting 
		WHERE actorid=(
			SELECT id FROM actor WHERE name='Art Garfunkel'
		)
	)
)

-- Using NULL: https://sqlzoo.net/wiki/Using_Null
--3:
SELECT teacher.name, dept.name
FROM 
	teacher LEFT JOIN dept
	ON (teacher.dept=dept.id)

--4: 
SELECT teacher.name, dept.name
FROM 
	dept LEFT JOIN teacher 
	ON teacher.dept=dept.id

--5:
SELECT 
	teacher.name, 
	COALESCE(mobile, '07986 444 2266')
FROM teacher

--6:
SELECT teacher.name, COALESCE(dept.name, 'None')
FROM teacher
	LEFT JOIN dept 
	ON teacher.dept=dept.id

--7:
SELECT 
	SUM(CASE WHEN name IS NULL THEN 0 ELSE 1 END),
	SUM(CASE WHEN mobile IS NULL THEN 0 ELSE 1 END)
FROM teacher

--8:
SELECT dept.name, COUNT(teacher.id)
FROM dept
	LEFT JOIN teacher ON teacher.dept=dept.id
GROUP BY dept.name

--9:
SELECT name,
	CASE 
		WHEN dept >= 1 
		THEN 'Sci' 
		ELSE 'Art' 
	END
FROM teacher 

--10:
SELECT name, 
	CASE 
		WHEN dept<3 THEN 'Sci'
		WHEN dept=3 THEN 'Art'
		ELSE 'None' 
	END
FROM teacher


-- SELF JOIN: https://sqlzoo.net/wiki/Self_join
--7:
SELECT a.company, a.num
	FROM route a JOIN route b ON 
	(a.company=b.company AND a.num=b.num)
	WHERE a.stop=115 AND b.stop=137
GROUP BY a.company, a.num

--9:
SELECT stopb.name, a.company, a.num
FROM 
	route a JOIN route b ON
	(a.company=b.company AND a.num=b.num)
	JOIN stops stopa ON (a.stop=stopa.id)
	JOIN stops stopb ON (b.stop=stopb.id)
WHERE 
	stopa.name='Craiglockhart' AND
	a.company = 'LRT'

--10: Two bus routes that connect destinations A and B
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