REM
REM Must run this script after setup.sql has been runned loged in as F1_DATA
REM

--1. Download global certificate for example wikipedia
--
--[oracle@centos oracle_wallet]$ ls -ltrh
--totalt 4,0K
---rwxrwx--- 1 oracle oinstall 1,1K  6 jun 13.51 GlobalSign Organization Validation CA - SHA256 - G2.cer
--drwx------ 2 oracle oinstall   90  6 jun 13.56 https_wallet
--[oracle@centos oracle_wallet]$
--
--
--2. Create wallwt callet https_wallet
--
--[oracle@centos oracle_wallet]$ pwd
--/home/oracle/oracle_wallet
--[oracle@centos oracle_wallet]$ orapki wallet add -wallet https_wallet -cert GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2.cer -trusted_cert -pwd vOJ1m04e
--
--3. add the certificate from step 1
--
--[oracle@centos oracle_wallet]$ ls -ltrh
--totalt 4,0K
---rwxrwx--- 1 oracle oinstall 1,1K  6 jun 13.51 GlobalSign Organization Validation CA - SHA256 - G2.cer
--drwx------ 2 oracle oinstall   90  6 jun 13.56 https_wallet
--[oracle@centos oracle_wallet]$ orapki wallet add -wallet https_wallet -cert GlobalSign\ Organization\ Validation\ CA\ -\ SHA256\ -\ G2.cer -trusted_cert -pwd vOJ1m04e
--
--4. Test with SQL that you can get the page with APEX api.
--
--select apex_web_service.make_rest_request(
--    p_url         => 'https://en.wikipedia.org/wiki/Marcus_Ericsson', 
--    p_http_method => 'GET',
--    p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
--) as result from dual;


drop table f1_seasons_json;

create table f1_seasons_json(
    seasonid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    season    clob,
    constraint season_isjson check (season is json)
);

-- Get all seasons from 1950 and forward

delete from f1_seasons_json;

insert into f1_seasons_json( 
    season 
) values 
( apex_web_service.make_rest_request
    (
      p_url => 'http://ergast.com/api/f1/seasons.json?limit=1000', 
      p_http_method => 'GET'
      --p_wallet_path => 'file:///home/oracle/https_wallet' 
    )
);
commit;

--select id, fetched_at, dbms_lob.getlength(document) from f1_seasons_json;

-- Convert JSON data back to relational data

create or replace view v_f1_season as
select f1.season,f1.info
from f1_seasons_json ftab,
     json_table(ftab.season,'$.MRData.SeasonTable.Seasons[*]'
                COLUMNS ( season PATH '$.season',
                          info PATH '$.url')
               ) f1;
               

-- Setup table for all F1 drivers 
drop table f1_drivers_json;

create table f1_drivers_json(
    driverid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    drivers     clob,
    constraint drivers_isjson check (drivers is json)
);

insert into f1_drivers_json( 
    drivers 
) values 
( apex_web_service.make_rest_request
    (
      p_url => 'http://ergast.com/api/f1/drivers.json?limit=2000', 
      p_http_method => 'GET'
      --p_wallet_path => 'file:///home/oracle/https_wallet' 
    )
);
commit;    

create or replace view v_f1_drivers as
select f1.driverid
       ,f1.permanentNumber
       ,f1.code
       ,f1.info
       ,f1.givenname
       ,f1.familyname
       ,f1.dateofbirth
       ,f1.nationality
from f1_drivers_json ftab,
     json_table(ftab.drivers,'$.MRData.DriverTable.Drivers[*]'
                COLUMNS ( driverid PATH '$.driverId',
                          permanentNumber PATH '$.permanentNumber',
                          code PATH '$.code',
                          info PATH '$.url',
                          givenName PATH '$.givenName',
                          familyName PATH '$.familyName',
                          dateOfBirth PATH '$.dateOfBirth',
                          nationality PATH '$.nationality')
               ) f1;
               
-- Get all tracks F1 raced on
drop table f1_tracks_json;

create table f1_tracks_json(
    trackid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    tracks     clob,
    constraint trackid_isjson check (tracks is json)
);

insert into f1_tracks_json( 
    tracks
) values 
( apex_web_service.make_rest_request
    (
      p_url => 'http://ergast.com/api/f1/circuits.json?limit=1000', 
      p_http_method => 'GET'
      --p_wallet_path => 'file:///home/oracle/https_wallet' 
    )
);
commit;

create or replace view v_f1_tracks as
select f1.circuitid
       ,f1.info
       ,f1.circuitname
       ,f1.lat
       ,f1.lon as longitud
       ,f1.locality
       ,f1.country
from f1_tracks_json ftab,
     json_table(ftab.tracks,'$.MRData.CircuitTable.Circuits[*]'
                COLUMNS ( circuitId PATH '$.circuitId',
                          info PATH '$.url',
                          circuitName PATH '$.circuitName',
                          lat PATH '$.Location.lat',
                          lon PATH '$.Location.long',
                          locality PATH '$.Location.locality',
                          country PATH '$.Location.country'
                          )
               ) f1;
               
-- Get all races for all seasons

drop table f1_race_json;

create table f1_race_json(
    racid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    race     clob,
    constraint race_isjson check (race is json)
);

set serveroutput on
declare 
  
    url clob := 'http://ergast.com/api/f1/{YEAR}.json?limit=1000';
    calling_url clob;
    
    cursor cur_get_season_year is
    select f1.season
    from f1_seasons_json ftab,
         json_table(ftab.season,'$.MRData.SeasonTable.Seasons[*]'
                   COLUMNS ( season PATH '$.season',
                             info PATH '$.url')
                   ) f1;
                   
   --inline
   procedure get_races(
      p_in_year in number,
      p_in_url in clob
   ) 
   is
   begin
   
      insert into f1_race_json(
        year
        ,race
      ) values 
      ( p_in_year
       ,apex_web_service.make_rest_request
         (
            p_url => p_in_url, 
            p_http_method => 'GET'
 
         )
       );   
       
   end get_races;
                   
begin
   for rec in cur_get_season_year loop
     calling_url := replace(url,'{YEAR}',rec.season);
     dbms_output.put_line(calling_url);
     get_races(rec.season,calling_url);
   end loop;
   commit;
end;
/


create or replace view v_f1_races as
select f1.season
       ,f1.round
       ,f1.info
       ,f1.racename
       ,f1.circuitid
       ,f1.url
       ,f1.circuitname
       ,f1.lat
       ,f1.lon as longitude
       ,f1.locality
       ,f1.country
from f1_race_json ftab,
     json_table(ftab.race,'$.MRData.RaceTable.Races[*]'
                COLUMNS ( season PATH '$.season',
                          round PATH '$.round',
                          info PATH '$.url',
                          raceName PATH '$.raceName',
                          circuitId PATH '$.Circuit.circuitId',
                          url PATH '$.Circuit.url',
                          circuitName PATH '$.Circuit.circuitName',
                          lat PATH '$.Circuit.Location.lat',
                          lon PATH '$.Circuit.Location.long',
                          locality PATH '$.Circuit.Location.locality',
                          country PATH '$.Circuit.Location.country'
                        )
               ) f1 ;
               
-- Get the results for all races

drop table f1_raceresults_json;

create table f1_raceresults_json(
    resultid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    round number(4),
    result     clob,
    constraint result_isjson check (result is json)
);


set serveroutput on
declare

    url clob := 'http://ergast.com/api/f1/{YEAR}/{ROUND}/results.json';
    tmp clob;
    calling_url clob;
    
    cursor cur_get_f1_races is
    select season
           ,round
    from v_f1_races;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_round in number
         ,p_in_url in clob
        )
    is
    begin
     insert into f1_raceresults_json(
        year
        ,round
        ,result
      ) values 
      ( p_in_year
        ,p_in_round
       ,apex_web_service.make_rest_request
         (
            p_url => p_in_url, 
            p_http_method => 'GET'
 
         )
       );
    end insert_results;
begin
  for rec in cur_get_f1_races loop
    tmp := replace(url,'{YEAR}',rec.season);
    calling_url := replace(tmp,'{ROUND}',rec.round);
    dbms_output.put_line(calling_url);
    insert_results(rec.season,rec.round,calling_url);
  end loop;
  commit;
end;
/

create or replace view v_f1_results as
select f1.season
       ,f1.race
       ,f1.info
       ,f1.raceName
       ,f1.circuitId
       ,f1.url
       ,f1.circuitName
       ,f1.lat
       ,f1.lon
       ,f1.locality
       ,f1.country
       ,f1.racedate
       ,f1.pilotnr
       ,f1.position
       ,f1.positionText
       ,f1.points
       ,f1.driverId
       ,f1.drivurl
       ,f1.givenName
       ,f1.familyName
       ,f1.dateOfBirth
       ,f1.nationality
       ,f1.constructorId
       ,f1.constructorinfo
       ,f1.constructorname
       ,f1.constructornationality
       ,f1.grid
       ,f1.laps
       ,f1.status
       ,f1.ranking
       ,fastestlap
       ,units
       ,speed
       ,f1.millis
       ,f1.racetime
from f1_raceresults_json ftab,
     json_table(ftab.result,'$.MRData.RaceTable.Races[*]'
                COLUMNS ( season PATH '$.season',
                          race PATH '$.round',
                          info PATH '$.url',
                          raceName PATH '$.raceName',
                          circuitId PATH '$.Circuit.circuitId',
                          url PATH '$.Circuit.url',
                          circuitName PATH '$.Circuit.circuitName',
                          lat PATH '$.Circuit.Location.lat',
                          lon PATH '$.Circuit.Location.long',
                          locality PATH '$.Circuit.Location.locality',
                          country PATH '$.Circuit.Location.country',
                          racedate PATH '$.date',
                          nested path '$.Results[*]'
                          COLUMNS
                           (
                             pilotnr PATH '$.number',
                             position PATH '$.position',
                             positionText PATH '$.positionText',
                             points PATH '$.points',
                             driverId PATH '$.Driver.driverId',
                             drivurl PATH '$.Driver.url',
                             givenName PATH '$.Driver.givenName',
                             familyName PATH '$.Driver.familyName',
                             dateOfBirth PATH '$.Driver.dateOfBirth',
                             nationality PATH '$.Driver.nationality',
                             constructorId PATH '$.Constructor.constructorId',
                             constructorinfo PATH '$.Constructor.url',
                             constructorname PATH '$.Constructor.name',
                             constructornationality PATH '$.Constructor.nationality',
                             grid PATH '$.grid',
                             laps PATH '$.laps',
                             status PATH '$.status',
                             ranking PATH '$.FastestLap.rank',
                             fastestlap PATH '$.FastestLap.lap',
                             units  PATH '$.FastestLap.units',
                             speed  PATH '$.FastestLap.speed',
                             millis PATH '$.Time.millis',
                             racetime PATH '$.Time.time'
                          )
                       )   
               ) f1 
order by f1.season,f1.race;


-- Get all constructors

drop table f1_constructors_json;

create table f1_constructors_json(
    constructortid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    constructor     clob,
    constraint constructor_isjson check (constructor is json)
);

-- Fetch all constructors
insert into f1_constructors_json( 
    constructor
) values 
( apex_web_service.make_rest_request
    (
      p_url => 'http://ergast.com/api/f1/constructors.json?limit=1000', 
      p_http_method => 'GET'
      --p_wallet_path => 'file:///home/oracle/https_wallet' 
    )
);
commit;

-- view for selecting all constructors converting json to relational.
create or replace view v_f1_constructors as
select f1.constructorid
       ,f1.info
       ,f1.name
       ,f1.nationality
from f1_constructors_json ftab,
     json_table(ftab.constructor,'$.MRData.ConstructorTable.Constructors[*]'
                COLUMNS ( constructorId PATH '$.constructorId',
                          info PATH '$.url',
                          name PATH '$.name',
                          nationality PATH '$.nationality'
                          )
               ) f1;
               
-- F1 champoinships rankings for all F1 seasons

drop table f1_driverstandings_json;

create table f1_driverstandings_json(
    standingid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    driverstanding     clob,
    constraint driverstanding_isjson check (driverstanding is json)
);

set serveroutput on
declare

    url clob := 'http://ergast.com/api/f1/{YEAR}/driverStandings.json';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
    begin
     insert into f1_driverstandings_json(
        year
        ,driverstanding
      ) values 
      ( p_in_year
       ,apex_web_service.make_rest_request
         (
            p_url => p_in_url, 
            p_http_method => 'GET'
 
         )
       );
    end insert_results;

begin
  for rec in cur_get_f1_seasons loop
    calling_url := replace(url,'{YEAR}',rec.season);
    dbms_output.put_line(calling_url);
    insert_results(rec.season,calling_url);
  end loop;
  commit;
end;
/

create or replace view v_f1_driverstandings as
select f1.season
       ,f1.race
       ,f1.position
       ,f1.positionText
       ,f1.points
       ,f1.wins
       ,f1.driverId
       ,f1.permanentNumber
       ,f1.code
       ,f1.info
       ,f1.givenname
       ,f1.familyName
       ,f1.dateOfBirth
       ,f1.nationality
       ,f1.constructorId
       ,f1.constructorinfo
       ,f1.constructorname
       ,f1.constructornationality
from f1_driverstandings_json ftab,
     json_table(ftab.driverstanding,'$.MRData.StandingsTable.StandingsLists[*]'
                COLUMNS ( season PATH '$.season',
                          race PATH '$.round',
                          nested path '$.DriverStandings[*]'
                          COLUMNS
                           (
                             position PATH '$.position',
                             positionText PATH '$.positionText',
                             points PATH '$.points',
                             wins PATH '$.wins',
                             driverId PATH '$.Driver.driverId',
                             permanentNumber PATH '$.Driver.permanentNumber',
                             code PATH '$.Driver.code',
                             info PATH '$.Driver.url',
                             givenname PATH '$.Driver.givenName',
                             familyName PATH '$.Driver.familyName',
                             dateOfBirth PATH '$.Driver.dateOfBirth',
                             nationality PATH '$.Driver.nationality',
                             constructorId PATH '$.Constructors.constructorId',
                             constructorinfo PATH '$.Constructors.url',
                             constructorname PATH '$.Constructors.name',
                             constructornationality PATH '$.Constructors.nationality'
                           )
                       )   
               ) f1 
order by to_number(f1.season),to_number(f1.race),to_number(f1.position);

-- F1 constructors rankings for all F1 seasons

drop table f1_constructorstandings_json;

create table f1_constructorstandings_json(
    constructorid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    constructorstandings clob,
    constraint constructorstanding_isjson check (constructorstandings is json)
);

set serveroutput on
declare

    url clob := 'http://ergast.com/api/f1/{YEAR}/constructorStandings.json?limit=100';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
    begin
     insert into f1_constructorstandings_json(
        year
        ,constructorstandings
      ) values 
      ( p_in_year
       ,apex_web_service.make_rest_request
         (
            p_url => p_in_url, 
            p_http_method => 'GET'
 
         )
       );
    end insert_results;

begin
  for rec in cur_get_f1_seasons loop
    calling_url := replace(url,'{YEAR}',rec.season);
    dbms_output.put_line(calling_url);
    insert_results(rec.season,calling_url);
  end loop;
  commit;
end;
/

create or replace view v_f1_constructorstandings as
select f1.season
       ,f1.race 
       ,f1.position
       ,f1.positionText
       ,f1.points
       ,f1.wins                             
       ,f1.constructorId
       ,f1.constructorinfo
       ,f1.constructorname
       ,f1.constructornationality
from f1_constructorstandings_json ftab,
     json_table(ftab.constructorstandings,'$.MRData.StandingsTable.StandingsLists[*]'
                COLUMNS ( season PATH '$.season',
                          race PATH '$.round',
                          nested path '$.ConstructorStandings[*]'
                          COLUMNS
                           (
                             position PATH '$.position',
                             positionText PATH '$.positionText',
                             points PATH '$.points',
                             wins PATH '$.wins',                             
                             constructorId PATH '$.Constructor.constructorId',
                             constructorinfo PATH '$.Constructor.url',
                             constructorname PATH '$.Constructor.name',
                             constructornationality PATH '$.Constructor.nationality'
                           )
                       )   
               ) f1 
order by to_number(f1.season),to_number(f1.race);


drop table f1_seasons_race_dates;

create table f1_seasons_race_dates(
    seasonid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    race_date    clob,
    constraint racedate_isjson check (race_date is json)
);

declare

    url clob := 'http://ergast.com/api/f1/{YEAR}.json?limit=1000';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
    begin
     insert into f1_seasons_race_dates(
        year
        ,race_date
      ) values 
      ( p_in_year
       ,apex_web_service.make_rest_request
         (
            p_url => p_in_url, 
            p_http_method => 'GET'
 
         )
       );
    end insert_results;

begin
  for rec in cur_get_f1_seasons loop
    calling_url := replace(url,'{YEAR}',rec.season);
    dbms_output.put_line(calling_url);
    insert_results(rec.season,calling_url);
  end loop;
  commit;
end;
/

create or replace view v_f1_seasons_race_dates as
select f1.season,
       f1.round,
       f1.info,
       f1.racename,
       f1.circuitid,
       f1.url,
       f1.circuitname,
       f1.race_date
from f1_seasons_race_dates ftab,
     json_table(ftab.race_date,'$.MRData.RaceTable.Races[*]'
                COLUMNS ( season PATH '$.season',
                          round PATH '$.round',
                          info PATH '$.url',
                          raceName PATH '$.raceName',
                          nested path '$.Circuit[*]'
                          COLUMNS
                           (
                             circuitid PATH '$.circuitId',
                             url PATH '$.url',
                             circuitName PATH '$.circuitName'

                           ),
                         race_date PATH '$.date'  
                       )   
               ) f1 
order by to_number(f1.season),to_number(f1.round);

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
  
-- Get data from wikipedia for further parsing

select apex_web_service.make_rest_request(
    p_url         => 'https://en.wikipedia.org/wiki/Marcus_Ericsson', 
    p_http_method => 'GET',
    p_wallet_path => 'file:///home/oracle/oracle_wallet/https_wallet' 
) as result from dual;

-- <meta property="og:image" content="https://upload.wikimedia.org/wikipedia/commons/f/ff/Marcus_Ericsson_at_the_2018_British_Grand_Prix_%28cropped%29.jpg"/>

select a.season,
       a.round,
       a.race_date
from v_f1_seasons_race_dates a
where a.round not in ( select b.race
                     from v_f1_results b
                     where a.season = b.season
                       and a.round = b.race)
  and a.season = to_char(trunc(sysdate),'RRRR');
                       