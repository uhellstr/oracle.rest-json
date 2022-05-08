@F1_DATA_TBS.sql
@F1_LOGIK_GRANTS.sql
@./role/F1_DATA_FORVALT_ROLE.sql
grant F1_DATA_FORVALT_ROLE to F1_ACCESS ;
grant F1_DATA_FORVALT_ROLE to F1_LOGIK ;
ALTER USER "F1_ACCESS" DEFAULT ROLE CONNECT,F1_DATA_FORVALT_ROLE;
ALTER USER "F1_LOGIK" DEFAULT ROLE "CONNECT","F1_DATA_FORVALT_ROLE";
@F1_INIT_PKG.sql
@F1_INIT_PKG_BODY.sql
@F1_ACCESS_OBJS.sql

REM
REM Helper functions
REM 

create or replace function f1_logik.to_millis 
(
    p_in_laptime in varchar2
) return number 
is
  v_hour number;
  v_minutes number;
  v_seconds number;
  v_millis  number;
  lv_retval number;
  lv_laptime varchar2(15); 

begin

    if length(p_in_laptime) = 15 then
      lv_laptime := regexp_replace(replace(p_in_laptime,'0{2,}',''),'^:','');
    else
      lv_laptime := p_in_laptime;
    end if;
    
    if regexp_count(lv_laptime, ':') = 2 then -- We have hours in the string too 
      v_hour := to_number(substr(lv_laptime,1,instr(lv_laptime,':',1)-1));
      v_minutes := to_number(substr(lv_laptime,instr(lv_laptime,':',1)+1,instr(lv_laptime,':',2)));
      v_seconds := to_number(substr(lv_laptime,instr(lv_laptime,':',1,2)+1,(length(lv_laptime) - instr(lv_laptime,'.',1)-1)));
      v_millis := to_number(substr(lv_laptime,instr(lv_laptime,'.',-1)+1));
      lv_retval := ((v_hour * 60) * 60000) + (v_minutes * 60000) + (v_seconds * 1000) + v_millis;
    else -- mi.ss.mi
      v_minutes := to_number(substr(lv_laptime,1,instr(lv_laptime,':',1)-1));
      v_seconds := to_number(substr(lv_laptime,instr(lv_laptime,':',1)+1,(length(lv_laptime) - instr(lv_laptime,'.',1)-1)));
      v_millis  := to_number(substr(lv_laptime,instr(lv_laptime,'.',-1)+1));
      lv_retval := (v_minutes * 60000) + (v_seconds * 1000) + v_millis;
    end if;
    return  lv_retval;

end to_millis;
/

create or replace function f1_logik.get_cur_f1_season 
(
  p_in_cur_year in varchar2 default to_char(current_date,'RRRR') 
) 
return varchar2 result_cache
as 

 lv_season varchar2(4);
 
begin

    with future_races as -- We need to handle between seasons where there are no races
    (
      select /*+ MATERIALIZE */ count(vfu.season) as any_races
      from f1_data.v_f1_upcoming_races vfu
      where vfu.season = substr(to_char(trunc(sysdate,'YEAR')),1,4)  --Fix to YEAR and substr(1,4) to garantee that we only get the YEAR part
    )
    select season into lv_season -- Is current season finished yet?
    from
    (
     select to_date(r.race_date,'RRRR-MM-DD') as race_date
            ,case
               when (r.race_date < trunc(sysdate) and x.any_races < 1) then to_char(to_number(to_char(current_date,'RRRR') - 1))
               when r.race_date < trunc(sysdate) then to_char(current_date,'RRRR')
               when (r.race_date > trunc(sysdate) and x.any_races > 0) then to_char(current_date,'RRRR')
               else '1900'
             end as season
     from f1_data.v_f1_seasons_race_dates r
          ,future_races x
     where r.season = p_in_cur_year
       and to_number(r.round) in (select max(to_number(rd.round)) from f1_data.v_f1_seasons_race_dates rd
                                  where rd.season  = r.season)
    );
    
    return lv_season;
    
end get_cur_f1_season;
/

grant execute on f1_logik.get_cur_f1_season to f1_access;

create or replace function get_check_season 
(
  p_in_cur_year in varchar2 default to_char(current_date,'rrrr') 
) 
return varchar2 result_cache
as

 lv_retval varchar2(4);
 
begin

    select season into lv_retval -- Is current season finished yet?
    from
    (
     select to_date(r.race_date,'RRRR-MM-DD') as race_date
            ,case 
               when r.race_date < trunc(sysdate) then to_char(current_date,'RRRR')
               when r.race_date > trunc(sysdate) then to_char(to_number(to_char(current_date,'RRRR') - 1))
               else '1900'
             end as season
     from f1_data.v_f1_seasons_race_dates r
     where r.season = p_in_cur_year
       and to_number(r.round) in (select max(to_number(rd.round)) from f1_data.v_f1_seasons_race_dates rd
                                  where rd.season  = r.season)
    );
  return lv_retval;
  
end get_check_season;
/

grant execute on f1_logik.get_check_season to f1_access;

create or replace function get_last_race 
(
  p_in_cur_year in varchar2 default to_char(current_date,'rrrr') 
) return number result_cache 
as 

  lv_retval number;
  
begin

    with last_race as -- we need to check if any upcoming races or if the last race for the season is done.
    (
    select /*+ MATERIALIZE */  nvl(min(to_number(x.round)-1),-1) as race -- check if any upcoming races this seaseon -1 and season is done
    from f1_data.v_f1_upcoming_races x
    where x.season = p_in_cur_year
    )
    select case when race = -1 then (select max(to_number(y.round))
                                   from  f1_data.v_f1_races y
                                   where y.season = to_char(to_number(p_in_cur_year)-1))
          else race
          end race
          into lv_retval
          from last_race;
          
   return lv_retval;

end get_last_race;
/

grant execute on f1_logik.get_last_race to f1_access;

@F1_DATA_SCHEDULER.sql
