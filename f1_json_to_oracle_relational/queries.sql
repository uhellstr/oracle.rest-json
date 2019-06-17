-- Give us all world champions

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
      and d.season < 2019;

-- Give us the number of championships a champ has got! E.g who is the ultimate champ!

select *
from
(
select driverid,
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
      and d.season < 2019
) group by driverid
) order by championships_won desc;

--- Show all ME9 Ericssons F1 races during his career --
select *
from v_f1_results
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
from v_f1_results
where locality = 'Monza'
  and driverid = 'alonso'
order by to_number(season),to_number(race);

-- What is the fastest laptime set on Monza on the current layout on the track from 2000 and forward ?

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
where r.season > 1999
  and r.circuitid = 'monza'
  and to_millis(l.laptime) = (select min(to_millis(x.laptime))
                              from f1_data.v_f1_laptimes x
                              inner join f1_data.v_f1_races y
                              on (y.season = x.season and  y.round = x.round)
                              where y.season > 1999
                               and y.circuitid = 'monza');
                               
-- List info about swedish drivers in F1 history
select * 
from v_f1_drivers
where upper(nationality) = 'SWEDISH';

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
from v_f1_results eri
where eri.driverid = 'ericsson'
  and eri.points > 0 
order by to_number(eri.season),to_number(eri.race);

-- How many points in total did ME9 Ericsson get during his F1 career.

select sum(eri.points) as totalcareerpoints
from v_f1_results eri
where eri.driverid = 'ericsson'
  and eri.points > 0;
  

-- How man points did Alonso score during his F1 career
select sum(eri.points) as totalcareerpoints
from v_f1_results eri
where eri.driverid = 'alonso'
  and eri.points > 0;
  
-- Get the median position for ME9 Ericsson during his F1 career

select r.driverid,
       median(to_number(r.position)) as median_position
from v_f1_results r
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
from v_f1_results r
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
from v_f1_results r
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
from v_f1_results r
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
from v_f1_results r
where to_number(r.season) between 1980 and 1990              
group by r.driverid,r.givenname,r.familyname
) where number_of_races > 10
order by median_position asc,number_of_races desc;

-- Get the number of races that ME9 partisipated in F1.
select count(*) 
from v_f1_results
where driverid = 'ericsson';

-- Get races for current year not yet done.  
select a.season,
       a.round,
       a.race_date
from v_f1_seasons_race_dates a
where a.round not in ( select b.race
                     from v_f1_results b
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
from v_f1_results r
where r.season = to_char(trunc(sysdate),'RRRR')
  and r.race = (select max(race)
                from v_f1_results
                where season = to_char(trunc(sysdate),'RRRR'))
  and r.position < 11
order by to_number(r.position) asc;


---- Try to parse  and Get race date from wikipedia for a race not yet in the database
--
--select c.round,
--       c.info,
--       (select to_date(regexp_substr(substr(apex_web_service.make_rest_request
--       (
--         p_url         => c.info, 
--         p_http_method => 'GET',
--         p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
--       ),instr(apex_web_service.make_rest_request
--                (
--                  p_url         => c.info, 
--                  p_http_method => 'GET',
--                  p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
--                 ),'mw-formatted-date',1,1),100),'\d{4}-\d{2}-\d{2}', 1, 1, 'im'),'RRRR-MM-DD') 
--                 from dual) as race_date
--from v_f1_races c
--where c.season = to_char(trunc(sysdate),'RRRR')
--  and c.round in (select a.round
--                  from v_f1_races a
--                  where round not in ( select b.race
--                                       from v_f1_results b
--                                       where a.season = b.season
--                                         and a.round = b.race)
--                    and a.season = to_char(trunc(sysdate),'RRRR'));
--  