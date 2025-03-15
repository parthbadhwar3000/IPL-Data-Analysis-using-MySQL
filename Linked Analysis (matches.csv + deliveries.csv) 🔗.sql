-- Which batsmen perform best in IPL finals?
with Matches as
(	
	select row_number() over(partition by season order by id desc) as rn,
    id,season,city,date,team1,team2
    from IPL_MATCHES 


)
select batsman, sum(batsman_runs) as highest_runs from Matches as m
join IPL_DELIVERIES as d
on m.id=d.match_id
where rn=1
group by batsman
order by highest_runs desc;

-- How do powerplay scores affect match outcomes?

with powerplay_effect as (select match_id, inning,batting_team, sum(total_runs) as Powerplay_runs,
sum(case when dismissal_kind in('bowled','caught','lbw', 'stumped', 'caught and bowled','hit wicket','run out') then 1 
else 0 end) as wickets_fallen
from IPL_DELIVERIES
where overs between 1 and 6
group by match_id,inning, batting_team
order by match_id,inning)
select p.*,m.winner
from powerplay_effect as p
left join IPL_MATCHES as m
on p.match_id=m.id;

--- answer: therefore in most cases teams who have better powerplay end up winning matches

-- What is the impact of winning the toss on the first 6 overs?
with powerplay_effect as (select match_id, inning,batting_team, sum(total_runs) as Powerplay_runs,
sum(case when dismissal_kind in('bowled','caught','lbw', 'stumped', 'caught and bowled','hit wicket','run out') then 1 
else 0 end) as wickets_fallen
from IPL_DELIVERIES
where overs between 1 and 6
group by match_id,inning, batting_team
order by match_id,inning)
select m.toss_winner,p.*
from powerplay_effect as p
left join IPL_MATCHES as m
on p.match_id=m.id
where inning=1;

-- How do different venues affect batting strike rates?
with runrate as 
(
	select match_id,inning,batting_team,sum(total_runs)/20 as run_rate
    from IPL_DELIVERIES
    group by match_id,inning,batting_team
)
select venue, inning,round(avg(run_rate)*20,2) as avg_score
from
(select r.*, m.venue from runrate as r left join IPL_MATCHES as m
on r.match_id=m.id
) as p
group by venue,inning
order by venue;

--  Which bowlers perform the best in death overs (16-20)?

select bowler, 
sum(case when dismissal_kind in ('bowled','caught','stumped','caught and bowled', 'lbw', 'hit wicket') then 1
else 0 end) as wickets,
sum(total_runs) as runs_conceded
from IPL_DELIVERIES
where overs between 16 and 20
group by bowler
having count(ball)>=500
order by wickets desc,runs_conceded asc;

-- Which teams perform better in home vs. away matches?
select
sum(case when winner= team1 and venue=city then 1 else 0 end) as home_wins,
sum(case when winner= team2 and venue!=city  then 1 else 0 end) as away_wins,
count(case when team1=winner or team2=winner then 1 end) as total_wins
from IPL_MATCHES
group by team1;

-- What is the probability of a match going to a Super Over?
with super_over as(
select *,
row_number() over(partition by match_id) as rn
 from IPL_DELIVERIES
where is_super_over=1 )

select (select count(*) as super_over_matches from super_over as s
join IPL_MATCHES as m
on s.match_id=m.id
where rn=1)/(select count(*) as total_matches from 
IPL_MATCHES) as probability
from (select count(*) as super_over_matches from super_over as s
join IPL_MATCHES as m
on s.match_id=m.id
where rn=1) as p join (select count(*) as total_matches from 
IPL_MATCHES) as q;




