-- Give us all world champions in Formula 1!!

select
    d.season,
    d.race,
    d.position,
    d.positiontext,
    d.points,
    d.wins,
    d.driverid,
    d.permanentnumber,
    d.code,
    d.info,
    d.givenname,
    d.familyname,
    d.dateofbirth,
    d.nationality,
    d.constructorid,
    d.constructorinfo,
    d.constructorname,
    d.constructornationality
from
    f1_data.v_f1_driverstandings d
    where d.race = (select max(e.race)
                    from f1_data.v_f1_driverstandings e
                    where e.season = d.season)
      and d.position = 1
      and d.season < to_char(trunc(sysdate),'RRRR');

-- Give us the number of championships a champ has got! E.g who is the ultimate champ!

select driverid,
       givenname,
       familyname,
       nationality,
       championships_won
from
(
select driverid,
       givenname,
       familyname,
       nationality,
       count(driverid) as championships_won
from 
(
select
    d.season,
    d.race,
    d.position,
    d.positiontext,
    d.points,
    d.wins,
    d.driverid,
    d.permanentnumber,
    d.code,
    d.info,
    d.givenname,
    d.familyname,
    d.dateofbirth,
    d.nationality,
    d.constructorid,
    d.constructorinfo,
    d.constructorname,
    d.constructornationality
from
    f1_data.v_f1_driverstandings d
    where d.race = (select max(e.race)
                    from f1_data.v_f1_driverstandings e
                    where e.season = d.season)
      and d.position = 1
      and d.season < to_char(trunc(sysdate),'RRRR')
) group by driverid,givenname,familyname,nationality
) order by championships_won desc;

--- Show all ME9 Ericssons F1 races during his career --
select *
from f1_data.v_f1_results
where pilotnr = 9
  and season >= 2014
order by to_number(season),to_number(race) asc;


-- List all times Alonso has driven at Monza

select season,
       race,
       locality,
       country,
       position,
       points,
       givenname,
       familyname,
       constructorname,
       constructornationality,
       grid,
       laps,
       status,
       ranking,
       fastestlap       
from f1_data.v_f1_results
where locality = 'Monza'
  and driverid = 'alonso'
order by to_number(season),to_number(race);

-- What is the fastest laptime set on Monza on the current layout on the track from 2000 and forward ?
-- Here we query the json data directly (e.g we parse the json data and do the join) quite timeconsuming.

select 
    l.season,
    l.round,
    l.info,
    l.racename,
    r.circuitid,
    l.url,
    r.circuitname,
    l.race_date,
    l.race_time,
    l.lap_number,
    l.driverid,
    l.position,
    l.laptime,
    to_millis(l.laptime) as millis
from
    f1_data.v_f1_laptimes l
inner join f1_data.v_f1_races r
on (r.season = l.season and  r.round = l.round)
where r.season > '1999'
  and r.circuitid = 'monza'
  and to_millis(l.laptime) = (select min(f1_data.to_millis(x.laptime))
                              from f1_data.v_f1_laptimes x
                              inner join f1_data.v_f1_races y
                              on (y.season = x.season and  y.round = x.round)
                              where y.season > '1999'
                               and y.circuitid = 'monza');
                              
-- The same query but now we use the MV view instead !!
select 
    l.season,
    l.round,
    l.info,
    l.racename,
    l.circuitid,
    l.url,
    l.circuitname,
    l.race_date,
    l.race_time,
    l.lap,
    l.driverid,
    l.position,
    l.laptime,
    l.laptimes_millis
from
    f1_data.mv_f1_lap_times l
where l.season > 1999
  and l.circuitid = 'monza'
  and l.laptimes_millis = (select min(x.laptimes_millis)
                              from f1_data.mv_f1_lap_times x
                              where x.season > 1999
                               and x.circuitid = 'monza');
                               
-- List info about swedish drivers in F1 history!
select * 
from f1_data.v_f1_drivers
where upper(nationality) = 'SWEDISH'
order by to_date(dateofbirth,'YYYY-MM-DD') desc;

-- List all races ME9 Ericsson scored points during his F1 time.
select eri.season,
       eri.race,
       eri.locality,
       eri.country,
       eri.position,
       eri.points,
       eri.givenname,
       eri.familyname,
       eri.constructorname,
       eri.constructornationality,
       eri.grid,
       eri.laps,
       eri.status,
       eri.ranking,
       eri.fastestlap
from f1_data.v_f1_results eri
where eri.driverid = 'ericsson'
  and eri.points > 0 
order by to_number(eri.season),to_number(eri.race);

-- How many points in total did ME9 Ericsson get during his F1 career.

select sum(eri.points) as totalcareerpoints
from f1_data.v_f1_results eri
where eri.driverid = 'ericsson'
  and eri.points > 0;
  

-- How man points did Alonso score during his F1 career
select sum(alo.points) as totalcareerpoints
from f1_data.v_f1_results alo
where alo.driverid = 'alonso'
  and alo.points > 0;
  
-- Get the median position for ME9 Ericsson during his F1 career

select r.driverid,
       median(to_number(r.position)) as median_position
from f1_data.v_f1_results r
where r.driverid = 'ericsson'
group by r.driverid;

-- Get median posititon for all drivers in the modern era 2010-2019

select driverid,
       givenname,
       familyname,
       median_position,
       number_of_races
from
(
select r.driverid,
       r.givenname,
       r.familyname,
       median(to_number(r.position)) as median_position,
       (select count(b.driverid) from v_f1_results b
        where b.driverid = r.driverid) as number_of_races
from f1_data.v_f1_results r
where to_number(r.season) between 2010 and 2019              
group by r.driverid,r.givenname,r.familyname
) where number_of_races > 10
order by median_position asc,number_of_races desc;

-- Get the median score for drivers between 2000-2010
select driverid,
       givenname,
       familyname,
       median_position,
       number_of_races
from
(
select r.driverid,
       r.givenname,
       r.familyname,
       median(to_number(r.position)) as median_position,
       (select count(b.driverid) from v_f1_results b
        where b.driverid = r.driverid) as number_of_races
from f1_data.v_f1_results r
where to_number(r.season) between 2000 and 2010              
group by r.driverid,r.givenname,r.familyname
) where number_of_races > 10
order by median_position asc,number_of_races desc;

-- Get the median score for drivers late 90's

select driverid,
       givenname,
       familyname,
       median_position,
       number_of_races
from
(
select r.driverid,
       r.givenname,
       r.familyname,
       median(to_number(r.position)) as median_position,
       (select count(b.driverid) from v_f1_results b
        where b.driverid = r.driverid) as number_of_races
from f1_data.v_f1_results r
where to_number(r.season) between 1990 and 2000              
group by r.driverid,r.givenname,r.familyname
) where number_of_races > 10
order by median_position asc,number_of_races desc;

--And the median score of drivers during the 80's era..
select driverid,
       givenname,
       familyname,
       median_position,
       number_of_races
from
(
select r.driverid,
       r.givenname,
       r.familyname,
       median(to_number(r.position)) as median_position,
       (select count(b.driverid) from v_f1_results b
        where b.driverid = r.driverid) as number_of_races
from f1_data.v_f1_results r
where to_number(r.season) between 1980 and 1990              
group by r.driverid,r.givenname,r.familyname
) where number_of_races > 10
order by median_position asc,number_of_races desc;

-- Get the number of races that ME9 partisipated in F1.
select count(*) 
from f1_data.v_f1_results
where driverid = 'ericsson';

-- How many races did the swedish drivers partisipate in total ?
select *
from
(
select r.givenname
       ,r.familyname
       ,count(r.race) as total_races
from f1_data.v_f1_results r
where r.nationality = 'Swedish'
group by r.givenname
         ,r.familyname
) order by total_races desc;

-- Get races for current year not yet done.  
select a.season,
       a.round,
       a.race_date
from f1_data.v_f1_seasons_race_dates a
where a.round not in ( select b.race
                     from f1_data.v_f1_results b
                     where a.season = b.season
                       and a.round = b.race)
  and a.season = to_char(trunc(sysdate),'RRRR');
  
-- Get the score points for the last race

select r.season,
       r.race,
       r.racename,
       r.position,
       r.points,
       r.givenname,
       r.familyname
from f1_data.v_f1_results r
where r.season = to_char(trunc(sysdate),'RRRR')
  and r.race = (select max(race)
                from f1_data.v_f1_results
                where season = to_char(trunc(sysdate),'RRRR'))
  and r.position < 11
order by to_number(r.position) asc;

-- Give us the qualification times from 1994 and forward (Full data from 2002 ca)

select
  q.season,
  q.round,
  r.info,
  r.racename,
  r.circuitid,
  r.url,
  r.circuitname,
  r.locality,
  r.country,
  q.racedate,
  q.racetime,
  q.drivernumber,
  q.position,
  q.driverid,
  q.permanentnumber,
  q.code,
  q.driverinfo,
  q.givenname,
  q.familyname,
  q.dateofbirth,
  q.nationality,
  q.constructor,
  q.constructorinfo,
  q.constructorname,
  q.constructornationality,
  q.q1,
  q.q2,
  q.q3
from
  f1_data.v_f1_qualificationtimes q
inner join f1_data.v_f1_races r
on q.season = r.season and q.round = r.round;

-- Give us the number of poles different drivers has achived broken down per season
select *
from
(
select q.season
       ,q.driverid
       ,q.drivernumber
       ,q.givenname
       ,q.familyname
       ,q.constructorname
       ,count(position) as number_of_poles
from f1_data.mv_f1_qualification_times q
where q.position = 1
group by q.season
       ,q.driverid
       ,q.drivernumber
       ,q.givenname
       ,q.familyname
       ,q.constructorname
) order by season desc,
           number_of_poles desc;
           
-- Give us all polesitters and number of polepositions thru the history since about 2000 and forward
-- Note: Ergast dont give us all data so we only see absolute correct data from 2003 and forward
-- Means that data for Senna as an example is completly messed up and only shows 3 polepositions

select *
from
(
select
 count(f1q.position) as number_of_poles,
  f1q.driverid,
  f1q.givenname,
  f1q.familyname,
  f1q.dateofbirth,
  f1q.nationality,
  f1q.constructor,
  f1q.constructorname,
  f1q.constructornationality
from f1_data.mv_f1_qualification_times f1q
where to_number(f1q.position) = 1
group by f1q.driverid,
         f1q.givenname,
         f1q.familyname,
         f1q.dateofbirth,
         f1q.nationality,
         f1q.constructor,
         f1q.constructorname,
         f1q.constructornationality
) order by number_of_poles desc, driverid asc;
  
           
-- Who outqualifed who in the 2018 season ?
select *
from
(
select season
       ,drivernumber
       ,givenname
       ,familyname
       ,constructorname
       ,count(internal_position) as outqualify_teammate
from
(
select q.season
       ,q.round
       ,q.driverid
       ,q.drivernumber
       ,q.givenname
       ,q.familyname
       ,q.constructorname
       ,q.position
       ,rank() over (partition by q.season,q.round,q.constructorname order by to_number(position)) as internal_position
from f1_data.mv_f1_qualification_times q
where q.constructor = (select distinct(q1.constructor)
                       from f1_data.mv_f1_qualification_times q1
                       where q1.season = 2018
                         and q1.constructor = q.constructor)
  and q.season = 2018
) where internal_position = 1
group by season
       ,drivernumber
       ,givenname
       ,familyname
       ,constructorname
) order by season,constructorname,outqualify_teammate;

-- Get the starting grid for the latest race in current season

select
  season,
  round,
  circuitname,
  locality,
  country,
  racedate,
  drivernumber,
  permanentnumber,
  code,
  givenname,
  familyname, 
  nationality,
  constructor,
  constructornationality,
  case 
  when q3 is not null and q2 is not null and q1 is not null then
    'Q3'
  when q3 is null and q2 is not null and q1 is not null then 
    'Q2'
  when q3 is null and q2 is null and q1 is not null then
    'Q1'
  else
    null
  end as qualification,  
  case 
  when q3 is not null and q2 is not null and q1 is not null then
    q3
  when q3 is null and q2 is not null and q1 is not null then 
    q2
  when q3 is null and q2 is null and q1 is not null then
    q1
  else
    null
  end as qualification_time,
  to_number(position) as starting_grid
from
  f1_data.mv_f1_qualification_times
where to_number(season) = to_number(to_char(trunc(sysdate),'RRRR'))
  and position is not null
  and to_number(round) = (select min(to_number(round))-1
                          from f1_data.v_f1_upcoming_races
                          where to_number(season) = to_number(to_char(trunc(sysdate),'RRRR'))
                            and to_date(race_date,'RRRR-MM-DD') >= trunc(sysdate))
order by to_number(position) asc;

-- Give us the fastest qualification lap on a track

select season,
       round,
       racedate,
       drivernumber,
       position,
       driverid,
       constructor,
       qualification_time
from
(
select
  qu.season,
  qu.round,
  qu.racedate,
  qu.drivernumber,
  qu.position,
  qu.driverid,
  qu.permanentnumber,
  qu.code,
  qu.constructor,
  case
    when q3 is not null and q2 is not null and q1 is not null then
      q3
    when q3 is null and q2 is not null and q1 is not null then 
      q2
    when q3 is null and q2 is null and q1 is not null then
      q1
    else
      null
  end as qualification_time,  
  case 
    when q3 is not null and q2 is not null and q1 is not null then
      to_number(qu.q3_millis)
    when q3 is null and q2 is not null and q1 is not null then 
      to_number(qu.q2_millis)
    when q3 is null and q2 is null and q1 is not null then
      to_number(qu.q1_millis)
    else null
  end as millis 
from
  f1_data.mv_f1_qualification_times qu
where to_number(qu.position) = 1
  and qu.circuitid = 'red_bull_ring'
) where millis = (select min(
                             case 
                               when q3 is not null and q2 is not null and q1 is not null then
                                 to_number(qa.q3_millis)
                               when q3 is null and q2 is not null and q1 is not null then 
                                 to_number(qa.q2_millis)
                               when q3 is null and q2 is null and q1 is not null then
                                 to_number(qa.q1_millis)
                               else 9999999
                              end
                              )
                  from f1_data.mv_f1_qualification_times qa
                  where qa.circuitid = 'red_bull_ring'
                    and to_number(qa.position) = 1);
                    
-- Get the fastest lap time for a specific race
select lp.season
       ,lp.round
       ,lp.circuitid
       ,lp.circuitname
       ,lp.race_date
       ,lp.lap
       ,lp.driverid
       ,lp.position
       ,lp.laptime
from f1_data.mv_f1_lap_times lp
where lp.season = 2019
  and lp.round = 9
  and lp.laptimes_millis = (select min(lp1.laptimes_millis)
                            from f1_data.mv_f1_lap_times lp1
                            where lp1.season = 2019
                              and lp1.round = 9);

-- How many times has Hamilton won his homerace at Silverstone ?

select
  f1r.season,
  f1r.race,
  f1r.racename,
  f1r.circuitname,
  f1r.locality,
  f1r.country,
  f1r.racedate,
  f1r.pilotnr,
  f1r.givenname,
  f1r.familyname,
  f1r.dateofbirth,
  f1r.nationality,
  f1r.constructorname,
  f1r.constructornationality
from
  f1_data.mv_f1_results f1r
  where f1r.circuitid = 'silverstone'
    and to_number(position) = 1
    and driverid = 'hamilton'
order  by season desc;

-- Give us the winners at Silverstonde thru history and the total number of wins.

select circuitname,
       locality,
       country,
       number_of_wins,
       driverid,
       givenname,
       familyname,
       dateofbirth,
       nationality
from
(
select
  f1r.circuitname,
  f1r.locality,
  f1r.country,
  count(f1r.position) as number_of_wins,
  f1r.driverid,
  f1r.givenname,
  f1r.familyname,
  f1r.dateofbirth,
  f1r.nationality
from
  f1_data.mv_f1_results f1r
where f1r.circuitid = 'silverstone'
  and to_number(f1r.position) = 1
group by f1r.circuitname,
         f1r.locality,
         f1r.country,
         f1r.driverid,
         f1r.givenname,
         f1r.familyname,
         f1r.dateofbirth,
         f1r.nationality
) order by number_of_wins desc;

-- Get ditinct statuses
select distinct(status)
from f1_data.v_f1_results
order by status;

-- How many times has there been accidents in Formula 1 in race situations?
select count(*) as number_of_accidents
from f1_data.v_f1_results
where lower(status) = 'accident';


-- Drivers involved in accidents in races
select *
from
(
select r.driverid,count(*) as number_of_accidents
from f1_data.v_f1_results r
where lower(r.status) = 'accident'
group by r.driverid
) order by number_of_accidents desc;

-- Fatal accident during races according to status...
select r.*
from f1_data.v_f1_results r
where lower(r.status) = 'fatal accident';

-- Give us the accidents that Ericsson was involved in race situation.

select r.*
from f1_data.v_f1_results r
where lower(r.status) = 'accident'
  and lower(r.driverid) = 'ericsson';

