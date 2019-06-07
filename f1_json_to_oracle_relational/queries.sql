--- Some queries --
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

-- Get the median position for ME9 Ericsson during his F1 career

select r.driverid,
       median(to_number(r.position)) as median_position
from v_f1_results r
where r.driverid = 'ericsson'
group by r.driverid;

-- Get median position for all drivers in the modern era

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




-- Get the number of races that ME9 partisipated in F1.
select count(*) 
from v_f1_results
where driverid = 'ericsson';

-- Get data from wikipedia for further parsing

select apex_web_service.make_rest_request(
    p_url         => 'https://en.wikipedia.org/wiki/Marcus_Ericsson', 
    p_http_method => 'GET',
    p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
) as result from dual;


-- <meta property="og:image" content="https://upload.wikimedia.org/wikipedia/commons/f/ff/Marcus_Ericsson_at_the_2018_British_Grand_Prix_%28cropped%29.jpg"/>



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


-- Try to parse  and Get race date from wikipedia for a race not yet in the database

select c.round,
       c.info,
       (select to_date(regexp_substr(substr(apex_web_service.make_rest_request
       (
         p_url         => c.info, 
         p_http_method => 'GET',
         p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
       ),instr(apex_web_service.make_rest_request
                (
                  p_url         => c.info, 
                  p_http_method => 'GET',
                  p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
                 ),'mw-formatted-date',1,1),100),'\d{4}-\d{2}-\d{2}', 1, 1, 'im'),'RRRR-MM-DD') 
                 from dual) as race_date
from v_f1_races c
where c.season = to_char(trunc(sysdate),'RRRR')
  and c.round in (select a.round
                  from v_f1_races a
                  where round not in ( select b.race
                                       from v_f1_results b
                                       where a.season = b.season
                                         and a.round = b.race)
                    and a.season = to_char(trunc(sysdate),'RRRR'));
  