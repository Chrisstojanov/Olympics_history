create table if not exists OLYMPICS_HISTORY
(
	id	INT,
	name varchar,
	sex varchar,
	age varchar,
	height varchar,
	weight varchar,
	team varchar,
	noc varchar,
	games varchar,
	year int,
	season varchar,
	city varchar,
	sport varchar,
	event varchar,
	medal varchar);
	
create table if not exists noc_regions
( 
	noc	varchar,
	region varchar,
	notes varchar);
	
--1.How many olympics games have been held?

select count (distinct games) as total_olympic_games from olympics_history
 
 
--2.List all Olympics games held so far.

select distinct year, season, city from olympics_history
order by year

--3.Mention the total # of nations who participated in each olympics game?

select games, count (distinct noc) as total_countries from olympics_history
group by games

--4.Which year saw the highest and lowest no of countries participating in olympics?

select games, count (distinct noc) from olympics_history
group by games
order by count desc limit 5

select games, count (distinct noc) from olympics_history
group by games
order by count asc limit 5

--5.Which nation has participated in all of the olympic games?

with t1 as
(select count (distinct games) as total_olympic_games from olympics_history),
t2 as 
(select distinct noc, games from olympics_history
	order by games),
t3 as 
(select noc, count(games) as no_of_games_played from t2
	group by noc)
select * from t3
order by no_of_games_played desc


--6.Identify the sport which was played in all summer olympics.

with t1 as 
	(select count( distinct games) as total_summer_games from olympics_history
	where season = 'Summer'),
t2 as 
	(select distinct sport, games from olympics_history
	where season = 'Summer' order by games),	
t3 as 
	(select sport, count(games) as no_of_games from t2
	group by sport)
select * from t3
join t1 on t1.total_summer_games = t3.no_of_games;

--7.Which Sports were played only once in the olympics?

with t1 as
          	(select distinct games, sport
          	from olympics_history),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport
	  
--8.Fetch the total no of sports played in each olympic games.

select games, count(distinct sport) as no_of_sports from olympics_history
group by games
order by no_of_sports desc

--9.Fetch details of the oldest athletes to win a gold medal.

SELECT name, sex, age, team, games, city, sport, event, medal 
FROM olympics_history
WHERE medal = 'Gold' and age != 'NA'
ORDER BY age DESC
limit 5



--11.Fetch the top 5 athletes who have won the most gold medals.

select name, noc, count(medal) as total_gold_medals from olympics_history
where medal = 'Gold'
group by name, noc
order by total_gold_medals desc
limit 5

--12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select name, team, count(medal) as total_medals from olympics_history
where medal in('Gold','Silver', 'Bronze')
group by name, team
order by total_medals desc
limit 5

--13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with t1 as
	(select region, count(1) as total_medals from olympics_history 
	join noc_regions
	on olympics_history.noc = noc_regions.noc 
	where medal in ('Gold', 'Silver', 'Bronze')
	group by region
	order by total_medals desc),
t2 as 
	(select *, dense_rank() over(order by total_medals desc) as rnk
	from t1)
select * from t2
where rnk <= 5;

