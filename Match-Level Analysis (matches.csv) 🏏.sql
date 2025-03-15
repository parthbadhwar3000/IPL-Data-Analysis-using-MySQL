select * from IPL_MATCHES
where city='Chennai';
-- How many matches were played in each IPL season?
select season,count(*)
from IPL_MATCHES
group by season
order by season;

-- Which team has won the most matches across all seasons?

select winner, count(winner) as count
from IPL_MATCHES
group by winner
order by count desc
limit 1;

-- How often does the toss winner also win the match?
select (sum(case when toss_winner=winner then 1 else 0 end)*100/count(*)) as win_percent_aftertosswin
from IPL_MATCHES
where winner is not null;

-- What are the top 10 venues in terms of matches hosted?
select venue, count(*) as matches_hosted
from IPL_MATCHES
group by venue
order by matches_hosted desc
limit 10;

-- Which city has hosted the most IPL finals?
select city, count(*) as count
from 
(select season,city,max(id)
from IPL_MATCHES
group by season
order by season) as q
group by city
order by count desc
limit 1;

-- Which teams have performed the best while defending a target?
select winner,count(*) as 'Most Wins while defending'
from IPL_MATCHES
where result='normal'
and win_by_runs>0
and win_by_wickets=0
group by winner
order by count(*) desc
limit 4;
;

-- Which teams have been the most successful while chasing?
select winner,count(*) as 'Most Wins while chasing'
from IPL_MATCHES
where result='normal'
and win_by_runs=0
and win_by_wickets>0
group by winner
order by count(*) desc
limit 4;

-- What is the highest margin of victory (by runs and wickets) in IPL history?
select max(win_by_runs) as win_by_runs, max(win_by_wickets) 
from IPL_MATCHES;

-- Which team has won the most tosses?
select toss_winner,count(*) as 'most toss wins'
from IPL_MATCHES
group by toss_winner
order by count(*) desc
limit 1;

-- Which players have won the most “Player of the Match” awards?
select player_of_match,count(*) as 'most motm'
from IPL_MATCHES
group by player_of_match
order by count(*) desc
limit 1;






