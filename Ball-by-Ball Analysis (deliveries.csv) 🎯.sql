-- Which bowler has taken the most wickets in IPL history?
select bowler,count(*) as wickets
from IPL_DELIVERIES
where dismissal_kind in('bowled','caught','lbw', 'stumped', 'caught and bowled','hit wicket')
group by bowler
order by wickets desc
limit 1;

-- Which batsman has scored the most runs?
select batsman, sum(batsman_runs) as runs
from IPL_DELIVERIES
group by batsman
order by runs desc
limit 1;

-- Which batsman has hit the most sixes?
select batsman, sum(case when batsman_runs=6 then 1 else 0 end) as sixes
from IPL_DELIVERIES
group by batsman
order by sixes desc
limit 1;

-- Which over (1-20) is the most economical for bowlers?
select overs,sum(total_runs) as runs_conceded
from IPL_DELIVERIES
group by overs
order by runs_conceded
limit 1;

-- Which over sees the most wickets fall on average?
select overs,count(*) as wickets
from IPL_DELIVERIES
where dismissal_kind in('bowled','caught','lbw', 'stumped', 'caught and bowled','hit wicket','run out')
group by overs
order by wickets desc
limit 1;

-- Which team has the best economy rate in powerplays (overs 1-6)?
select bowling_team, sum(total_runs)/count(distinct match_id,overs) as run_rate
from IPL_DELIVERIES
where overs<7
group by bowling_team
order by run_rate asc
limit 1;

-- Which bowler has bowled the most dot balls in IPL history?
select bowler, count(*) as dot_balls from
IPL_DELIVERIES 
where total_runs=0
group by bowler
order by dot_balls desc
limit 1;

-- What is the highest individual score in an IPL match?
select match_id,batsman, sum(batsman_runs) as runs
from IPL_DELIVERIES
group by match_id,batsman
order by runs desc
limit 1;

-- Which batsman has the best strike rate (minimum 500 balls faced)
select batsman, sum(batsman_runs)*100/count(ball) as strike_rate
from IPL_DELIVERIES
group by batsman
having count(ball)>=500
order by strike_rate desc
limit 1;
 
 -- Which bowler has the best average against specific teams?
with Bowling_avg as(
select batting_team,bowler,
(sum(is_super_over)+sum(wide_runs)+sum(noball_runs)+sum(penalty_runs)+sum(batsman_runs))
/nullif(sum(case when dismissal_kind in('bowled','caught','lbw', 'stumped', 'caught and bowled','hit wicket') then 1
else 0 end),0) as average
from IPL_DELIVERIES
group by batting_team,bowler)

select *,rank() over(partition by batting_team order by average asc ) as rnk
from Bowling_avg;
