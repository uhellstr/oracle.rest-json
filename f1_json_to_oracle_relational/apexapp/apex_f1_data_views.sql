CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_CONSTRUCTORS AS SELECT * FROM APEX_F1_DATA.S_F1_CONSTRUCTORS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_CONSTRUCTORSTANDINGS AS SELECT * FROM  APEX_F1_DATA.S_F1_CONSTRUCTORSTANDINGS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_DRIVERS AS SELECT * FROM APEX_F1_DATA.S_F1_DRIVERS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_DRIVERSTANDINGS AS SELECT * FROM APEX_F1_DATA.S_F1_DRIVERSTANDINGS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_LAPTIMES AS SELECT * FROM APEX_F1_DATA.S_F1_LAPTIMES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_LAST_RACE_RESULTS AS SELECT * FROM APEX_F1_DATA.S_F1_LAST_RACE_RESULTS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_RACES AS SELECT * FROM APEX_F1_DATA.S_F1_RACES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_RESULTS AS SELECT * FROM APEX_F1_DATA.S_F1_RESULTS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_SEASON AS SELECT * FROM APEX_F1_DATA.S_F1_SEASON;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_SEASONS_RACE_DATES AS SELECT * FROM APEX_F1_DATA.S_F1_SEASONS_RACE_DATES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_TRACKS AS SELECT * FROM APEX_F1_DATA.S_F1_TRACKS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_UPCOMING_RACES AS SELECT * FROM APEX_F1_DATA.S_F1_UPCOMING_RACES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_QUALIFICATIONTIMES AS SELECT * FROM APEX_F1_DATA.S_F1_QUALIFICATIONTIMES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_MV_F1_LAP_TIMES AS SELECT * FROM APEX_F1_DATA.S_MV_F1_LAP_TIMES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_MV_F1_QUALIFICATION_TIMES AS SELECT * FROM APEX_F1_DATA.S_MV_F1_QUALIFICATION_TIMES;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_MV_F1_RESULTS AS SELECT * FROM APEX_F1_DATA.S_MV_F1_RESULTS;
CREATE OR REPLACE VIEW APEX_F1_DATA.R_F1_DRIVER_IMAGES AS SELECT * FROM APEX_F1_DATA.S_F1_DRIVER_IMAGES;

-- Additional views created 

-- Handle tracks used during a season
create or replace view apex_f1_data.r_f1_seasons_and_tracks as
select vt.circuitid
       ,vt.info
       ,vt.circuitname
       ,vr.season
       ,vr.round
       ,vr.lat
       ,vr.longitude
       ,vr.locality
       ,vr.country
from r_f1_tracks vt
inner join r_f1_races vr
on vt.circuitid = vr.circuitid
order by to_number(vr.season) desc, to_number(vr.round) asc;
