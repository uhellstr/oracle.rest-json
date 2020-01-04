create role F1_DATA_FORVALT_ROLE ;
grant select on F1_DATA.F1_DATA_DRIVER_IMAGES to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_CONSTRUCTORS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_CONSTRUCTORSTANDINGS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_DRIVERS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_DRIVERSTANDINGS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_LAPTIMES_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_QUALIFICATION_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_RACE_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_RACERESULTS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_SEASONS_JSON to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.F1_SEASONS_RACE_DATES to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.F1_TRACKS_JSON to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.V_F1_CONSTRUCTORS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_CONSTRUCTORSTANDINGS to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.V_F1_DRIVERS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_DRIVERSTANDINGS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_LAPTIMES to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.V_F1_QUALIFICATIONTIMES to F1_DATA_FORVALT_ROLE   ;
grant select on F1_DATA.V_F1_RACES to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_RESULTS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_LAST_RACE_RESULTS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_SEASON to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_SEASONS_RACE_DATES to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_TRACKS to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.V_F1_UPCOMING_RACES to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.MV_F1_LAP_TIMES to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.MV_F1_QUALIFICATION_TIMES to F1_DATA_FORVALT_ROLE  ;
grant select on F1_DATA.MV_F1_RESULTS to F1_DATA_FORVALT_ROLE  ;

-- Direct grants to be able to create view in F1_ACCESS
grant select on F1_DATA.F1_DATA_DRIVER_IMAGES to F1_ACCESS   ;
grant select on F1_DATA.V_F1_CONSTRUCTORS to F1_ACCESS  ;
grant select on F1_DATA.V_F1_CONSTRUCTORSTANDINGS to F1_ACCESS    ;
grant select on F1_DATA.V_F1_DRIVERS to F1_ACCESS   ;
grant select on F1_DATA.V_F1_DRIVERSTANDINGS to F1_ACCESS   ;
grant select on F1_DATA.V_F1_LAPTIMES to F1_ACCESS    ;
grant select on F1_DATA.V_F1_QUALIFICATIONTIMES to F1_ACCESS    ;
grant select on F1_DATA.V_F1_RACES to F1_ACCESS   ;
grant select on F1_DATA.V_F1_RESULTS to F1_ACCESS   ;
grant select on F1_DATA.V_F1_LAST_RACE_RESULTS to F1_ACCESS   ;
grant select on F1_DATA.V_F1_SEASON to F1_ACCESS   ;
grant select on F1_DATA.V_F1_SEASONS_RACE_DATES to F1_ACCESS  ;
grant select on F1_DATA.V_F1_TRACKS to F1_ACCESS  ;
grant select on F1_DATA.V_F1_UPCOMING_RACES to F1_ACCESS   ;
grant select on F1_DATA.MV_F1_LAP_TIMES to F1_ACCESS   ;
grant select on F1_DATA.MV_F1_QUALIFICATION_TIMES to F1_ACCESS   ;
grant select on F1_DATA.MV_F1_RESULTS to F1_ACCESS   ;