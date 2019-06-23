REM
REM Cleanup
REM
declare

  lv_stmt clob;
  
  cursor cur_get_f1_tables is
  select table_name
  from dba_tables
  where owner = 'F1_DATA'
  order by table_name;
begin
  for rec in cur_get_f1_tables loop
    lv_stmt := 'DROP TABLE F1_DATA.'||rec.table_name||' PURGE';
    execute immediate lv_stmt;
  end loop;
end;
/


--------------------------------------------------------
--  DDL for Table F1_CONSTRUCTORS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_CONSTRUCTORS_JSON" 
   (	"CONSTRUCTORTID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"CONSTRUCTOR" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_CONSTRUCTORSTANDINGS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" 
   (	"CONSTRUCTORID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"CONSTRUCTORSTANDINGS" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_DRIVERS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_DRIVERS_JSON" 
   (	"DRIVERID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"DRIVERS" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_DRIVERSTANDINGS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_DRIVERSTANDINGS_JSON" 
   (	"STANDINGID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"DRIVERSTANDING" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_LAPTIMES_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_LAPTIMES_JSON" 
   (	"RESULTID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"ROUND" NUMBER(4,0), 
	"LAP" NUMBER(4,0), 
	"LAPTIMES" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_QUALIFICATION_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_QUALIFICATION_JSON" 
   (	"SEASONID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER, 
	"ROUND" NUMBER, 
	"QUALIFICATION" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_RACE_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_RACE_JSON" 
   (	"RACID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"RACE" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_RACERESULTS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_RACERESULTS_JSON" 
   (	"RESULTID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"ROUND" NUMBER(4,0), 
	"RESULT" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_SEASONS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_SEASONS_JSON" 
   (	"SEASONID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"SEASON" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_SEASONS_RACE_DATES
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_SEASONS_RACE_DATES" 
   (	"SEASONID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"YEAR" NUMBER(4,0), 
	"RACE_DATE" CLOB
   ) ;
--------------------------------------------------------
--  DDL for Table F1_TRACKS_JSON
--------------------------------------------------------

  CREATE TABLE "F1_DATA"."F1_TRACKS_JSON" 
   (	"TRACKID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE , 
	"FETCHED_AT" TIMESTAMP (6) DEFAULT systimestamp, 
	"TRACKS" CLOB
   ) ;
--------------------------------------------------------
--  DDL for View V_F1_CONSTRUCTORS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_CONSTRUCTORS" ("CONSTRUCTORID", "INFO", "NAME", "NATIONALITY") AS 
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
               ) f1
;
--------------------------------------------------------
--  DDL for Index F1_RACERESULTS_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_RACERESULTS_JSON_PK" ON "F1_DATA"."F1_RACERESULTS_JSON" ("RESULTID", "YEAR", "ROUND") 
  ;
--------------------------------------------------------
--  DDL for Index F1_DRIVERSTANDINGS_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_DRIVERSTANDINGS_JSON_PK" ON "F1_DATA"."F1_DRIVERSTANDINGS_JSON" ("STANDINGID", "YEAR") 
  ;
--------------------------------------------------------
--  DDL for Index F1_QUALIFICATION_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_QUALIFICATION_JSON_PK" ON "F1_DATA"."F1_QUALIFICATION_JSON" ("YEAR", "ROUND", "SEASONID") 
  ;
--------------------------------------------------------
--  DDL for Index F1_RACE_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_RACE_JSON_PK" ON "F1_DATA"."F1_RACE_JSON" ("RACID", "YEAR") 
  ;
--------------------------------------------------------
--  DDL for Index F1_CONSTRUCTORSTANDINGS_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON_PK" ON "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" ("CONSTRUCTORID", "YEAR") 
  ;
--------------------------------------------------------
--  DDL for Index F1_LAPTIMES_JSON_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_LAPTIMES_JSON_PK" ON "F1_DATA"."F1_LAPTIMES_JSON" ("RESULTID", "YEAR", "ROUND", "LAP") 
  ;
--------------------------------------------------------
--  Constraints for Table F1_DRIVERSTANDINGS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_DRIVERSTANDINGS_JSON" MODIFY ("STANDINGID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_DRIVERSTANDINGS_JSON" ADD CONSTRAINT "DRIVERSTANDING_ISJSON" CHECK (driverstanding is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_DRIVERSTANDINGS_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_DRIVERSTANDINGS_JSON" ADD CONSTRAINT "F1_DRIVERSTANDINGS_JSON_PK" PRIMARY KEY ("STANDINGID", "YEAR")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_RACERESULTS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_RACERESULTS_JSON" MODIFY ("RESULTID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_RACERESULTS_JSON" ADD CONSTRAINT "RESULT_ISJSON" CHECK (result is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_RACERESULTS_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_RACERESULTS_JSON" MODIFY ("ROUND" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_RACERESULTS_JSON" ADD CONSTRAINT "F1_RACERESULTS_JSON_PK" PRIMARY KEY ("RESULTID", "YEAR", "ROUND")
  USING INDEX  ENABLE;
  
--------------------------------------------------------
--  DDL for Index F1_SEASONS_RACE_DATES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "F1_DATA"."F1_SEASONS_RACE_DATES_PK" ON "F1_DATA"."F1_SEASONS_RACE_DATES" ("SEASONID", "YEAR") 
  ;  
--------------------------------------------------------
--  Constraints for Table F1_CONSTRUCTORSTANDINGS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" MODIFY ("CONSTRUCTORID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" ADD CONSTRAINT "CONSTRUCTORSTANDING_ISJSON" CHECK (constructorstandings is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORSTANDINGS_JSON" ADD CONSTRAINT "F1_CONSTRUCTORSTANDINGS_JSON_PK" PRIMARY KEY ("CONSTRUCTORID", "YEAR")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_DRIVERS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_DRIVERS_JSON" MODIFY ("DRIVERID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_DRIVERS_JSON" ADD CONSTRAINT "DRIVERS_ISJSON" CHECK (drivers is json) ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_SEASONS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_SEASONS_JSON" MODIFY ("SEASONID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_SEASONS_JSON" ADD CONSTRAINT "SEASON_ISJSON" CHECK (season is json) ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_RACE_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_RACE_JSON" MODIFY ("RACID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_RACE_JSON" ADD CONSTRAINT "RACE_ISJSON" CHECK (race is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_RACE_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_RACE_JSON" ADD CONSTRAINT "F1_RACE_JSON_PK" PRIMARY KEY ("RACID", "YEAR")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_SEASONS_RACE_DATES
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_SEASONS_RACE_DATES" MODIFY ("SEASONID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_SEASONS_RACE_DATES" ADD CONSTRAINT "RACEDATE_ISJSON" CHECK (race_date is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_SEASONS_RACE_DATES" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_SEASONS_RACE_DATES" ADD CONSTRAINT "F1_SEASONS_RACE_DATES_PK" PRIMARY KEY ("SEASONID", "YEAR")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_LAPTIMES_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" MODIFY ("RESULTID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" ADD CONSTRAINT "LAPTIME_ISJSON" CHECK (laptimes is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" MODIFY ("ROUND" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" MODIFY ("LAP" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_LAPTIMES_JSON" ADD CONSTRAINT "F1_LAPTIMES_JSON_PK" PRIMARY KEY ("RESULTID", "YEAR", "ROUND", "LAP")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_CONSTRUCTORS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORS_JSON" MODIFY ("CONSTRUCTORTID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_CONSTRUCTORS_JSON" ADD CONSTRAINT "CONSTRUCTOR_ISJSON" CHECK (constructor is json) ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_TRACKS_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_TRACKS_JSON" MODIFY ("TRACKID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_TRACKS_JSON" ADD CONSTRAINT "TRACKID_ISJSON" CHECK (tracks is json) ENABLE;
--------------------------------------------------------
--  Constraints for Table F1_QUALIFICATION_JSON
--------------------------------------------------------

  ALTER TABLE "F1_DATA"."F1_QUALIFICATION_JSON" MODIFY ("SEASONID" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_QUALIFICATION_JSON" ADD CONSTRAINT "QUALIFICATION_ISJSON" CHECK (qualification is json) ENABLE;
  ALTER TABLE "F1_DATA"."F1_QUALIFICATION_JSON" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_QUALIFICATION_JSON" MODIFY ("ROUND" NOT NULL ENABLE);
  ALTER TABLE "F1_DATA"."F1_QUALIFICATION_JSON" ADD CONSTRAINT "F1_QUALIFICATION_JSON_PK" PRIMARY KEY ("YEAR", "ROUND", "SEASONID")
  USING INDEX  ENABLE;
  
--------------------------------------------------------
--  DDL for View V_F1_CONSTRUCTORSTANDINGS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_CONSTRUCTORSTANDINGS" ("SEASON", "RACE", "POSITION", "POSITIONTEXT", "POINTS", "WINS", "CONSTRUCTORID", "CONSTRUCTORINFO", "CONSTRUCTORNAME", "CONSTRUCTORNATIONALITY") AS 
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
order by to_number(f1.season),to_number(f1.race)
;
--------------------------------------------------------
--  DDL for View V_F1_DRIVERS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_DRIVERS" ("DRIVERID", "PERMANENTNUMBER", "CODE", "INFO", "GIVENNAME", "FAMILYNAME", "DATEOFBIRTH", "NATIONALITY") AS 
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
               ) f1
;
--------------------------------------------------------
--  DDL for View V_F1_DRIVERSTANDINGS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_DRIVERSTANDINGS" ("SEASON", "RACE", "POSITION", "POSITIONTEXT", "POINTS", "WINS", "DRIVERID", "PERMANENTNUMBER", "CODE", "INFO", "GIVENNAME", "FAMILYNAME", "DATEOFBIRTH", "NATIONALITY", "CONSTRUCTORID", "CONSTRUCTORINFO", "CONSTRUCTORNAME", "CONSTRUCTORNATIONALITY") AS 
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
order by to_number(f1.season),to_number(f1.race),to_number(f1.position)
;
--------------------------------------------------------
--  DDL for View V_F1_LAPTIMES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_LAPTIMES" ("SEASON", "ROUND", "INFO", "RACENAME", "CIRCUITID", "URL", "CIRCUITNAME", "RACE_DATE", "RACE_TIME", "LAP_NUMBER", "DRIVERID", "POSITION", "LAPTIME") AS 
  select f1.season,
       f1.round,
       f1.info,
       f1.racename,
       f1.circuitid,
       f1.url,
       f1.circuitname,
       f1.race_date,
       f1.race_time,
       f1.lap_number,
       f1.driverid,
       f1.position,
       f1.laptime
from f1_laptimes_json ftab,
     json_table(ftab.laptimes,'$.MRData.RaceTable.Races[*]'
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
                         race_date PATH '$.date',
                         race_time PATH '$.time',
                         nested path '$.Laps[*]'
                         COLUMNS
                          (
                            lap_number PATH '$.number',
                            nested PATH '$.Timings[*]'
                            COLUMNS
                             (
                               driverId PATH '$.driverId',
                               position PATH '$.position',
                               laptime PATH '$.time'
                             )
                          )
                       )   
               ) f1 
order by to_number(f1.season),to_number(f1.round),to_number(f1.lap_number),to_number(f1.position)
;
--------------------------------------------------------
--  DDL for View V_F1_LAST_RACE_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_LAST_RACE_RESULTS" ("SEASON", "RACE", "RACENAME", "POSITION", "POINTS", "GIVENNAME", "FAMILYNAME") AS 
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
order by to_number(r.position) asc
;
--------------------------------------------------------
--  DDL for View V_F1_RACES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_RACES" ("SEASON", "ROUND", "INFO", "RACENAME", "CIRCUITID", "URL", "CIRCUITNAME", "LAT", "LONGITUDE", "LOCALITY", "COUNTRY") AS 
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
               ) f1
;
--------------------------------------------------------
--  DDL for View V_F1_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_RESULTS" ("SEASON", "RACE", "INFO", "RACENAME", "CIRCUITID", "URL", "CIRCUITNAME", "LAT", "LON", "LOCALITY", "COUNTRY", "RACEDATE", "PILOTNR", "POSITION", "POSITIONTEXT", "POINTS", "DRIVERID", "DRIVURL", "GIVENNAME", "FAMILYNAME", "DATEOFBIRTH", "NATIONALITY", "CONSTRUCTORID", "CONSTRUCTORINFO", "CONSTRUCTORNAME", "CONSTRUCTORNATIONALITY", "GRID", "LAPS", "STATUS", "RANKING", "FASTESTLAP", "UNITS", "SPEED", "MILLIS", "RACETIME") AS 
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
order by f1.season,f1.race
;
--------------------------------------------------------
--  DDL for View V_F1_SEASON
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_SEASON" ("SEASON", "INFO") AS 
  select f1.season,f1.info
from f1_seasons_json ftab,
     json_table(ftab.season,'$.MRData.SeasonTable.Seasons[*]'
                COLUMNS ( season PATH '$.season',
                          info PATH '$.url')
               ) f1
;
--------------------------------------------------------
--  DDL for View V_F1_SEASONS_RACE_DATES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_SEASONS_RACE_DATES" ("SEASON", "ROUND", "INFO", "RACENAME", "CIRCUITID", "URL", "CIRCUITNAME", "RACE_DATE") AS 
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
order by to_number(f1.season),to_number(f1.round)
;
--------------------------------------------------------
--  DDL for View V_F1_TRACKS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_TRACKS" ("CIRCUITID", "INFO", "CIRCUITNAME", "LAT", "LONGITUD", "LOCALITY", "COUNTRY") AS 
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
               ) f1
;
--------------------------------------------------------
--  DDL for View V_F1_UPCOMING_RACES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "F1_DATA"."V_F1_UPCOMING_RACES" ("SEASON", "ROUND", "RACE_DATE") AS 
  select a.season,
       a.round,
       a.race_date
from v_f1_seasons_race_dates a
where a.round not in ( select b.race
                     from v_f1_results b
                     where a.season = b.season
                       and a.round = b.race)
  and a.season = to_char(trunc(sysdate),'RRRR')
;


