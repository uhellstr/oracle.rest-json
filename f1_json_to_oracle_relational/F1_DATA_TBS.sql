REM
REM Cleanup
REM
declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_seasons_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_seasons_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_drivers_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_drivers_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_tracks_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_tracks_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_race_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_race_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_raceresults_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_raceresults_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_constructors_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_constructors_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_driverstandings_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_driverstandings_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_constructorstandings_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_constructorstandings_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_constructorstandings_json';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_constructorstandings_json purge';
    end if;
end;
/

declare
  lv_count number;
begin

   select count(*) into lv_count
   from dba_tables
   where owner = 'F1_DATA'
     and lower(table_name) = 'f1_seasons_race_dates';

    if lv_count > 0 then
      execute immediate 'drop table f1_data.f1_seasons_race_dates purge';
    end if;
end;
/

REM
REM create tables and views
REM

create table f1_data.f1_seasons_json(
    seasonid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    season    clob,
    constraint season_isjson check (season is json)
);

create or replace view f1_data.v_f1_season as
select f1.season,f1.info
from f1_seasons_json ftab,
     json_table(ftab.season,'$.MRData.SeasonTable.Seasons[*]'
                COLUMNS ( season PATH '$.season',
                          info PATH '$.url')
               ) f1;
               
create table f1_data.f1_drivers_json(
    driverid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    drivers     clob,
    constraint drivers_isjson check (drivers is json)
); 

create or replace view f1_data.v_f1_drivers as
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
               
create table f1_data.f1_tracks_json(
    trackid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    tracks     clob,
    constraint trackid_isjson check (tracks is json)
);

create or replace view f1_data.v_f1_tracks as
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
               
create table f1_data.f1_race_json(
    racid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    race     clob,
    constraint race_isjson check (race is json)
);

create or replace view f1_data.v_f1_races as
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
               
create table f1_data.f1_raceresults_json(
    resultid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    round number(4),
    result     clob,
    constraint result_isjson check (result is json)
);

create or replace view f1_data.v_f1_results as
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

create table f1_data.f1_constructors_json(
    constructortid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    constructor     clob,
    constraint constructor_isjson check (constructor is json)
);

create or replace view f1_data.v_f1_constructors as
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
               
create table f1_data.f1_driverstandings_json(
    standingid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    driverstanding     clob,
    constraint driverstanding_isjson check (driverstanding is json)
);

create or replace view f1_data.v_f1_driverstandings as
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

create table f1_data.f1_constructorstandings_json(
    constructorid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    constructorstandings clob,
    constraint constructorstanding_isjson check (constructorstandings is json)
);

create or replace view f1_data.v_f1_constructorstandings as
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

create table f1_data.f1_seasons_race_dates(
    seasonid    number    generated always as identity,
    fetched_at  timestamp default systimestamp,
    year number(4),
    race_date    clob,
    constraint racedate_isjson check (race_date is json)
);

create or replace view f1_data.v_f1_seasons_race_dates as
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

create or replace view f1_data.v_f1_upcoming_races as
select a.season,
       a.round,
       a.race_date
from v_f1_seasons_race_dates a
where a.round not in ( select b.race
                     from v_f1_results b
                     where a.season = b.season
                       and a.round = b.race)
  and a.season = to_char(trunc(sysdate),'RRRR');
  
create or replace view f1_data.v_f1_last_race_results as
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
