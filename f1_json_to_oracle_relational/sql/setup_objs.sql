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

begin

    if regexp_count(p_in_laptime, ':') = 2 then -- We have hours in the string too 
      v_hour := to_number(substr(p_in_laptime,1,instr(p_in_laptime,':',1)-1));
      v_minutes := to_number(substr(p_in_laptime,instr(p_in_laptime,':',1)+1,instr(p_in_laptime,':',2)));
      v_seconds := to_number(substr(p_in_laptime,instr(p_in_laptime,':',1,2)+1,(length(p_in_laptime) - instr(p_in_laptime,'.',1)-1)));
      v_millis := to_number(substr(p_in_laptime,instr(p_in_laptime,'.',-1)+1));
      lv_retval := ((v_hour * 60) * 60000) + (v_minutes * 60000) + (v_seconds * 1000) + v_millis;
    else -- mi.ss.mi
      v_minutes := to_number(substr(p_in_laptime,1,instr(p_in_laptime,':',1)-1));
      v_seconds := to_number(substr(p_in_laptime,instr(p_in_laptime,':',1)+1,(length(p_in_laptime) - instr(p_in_laptime,'.',1)-1)));
      v_millis  := to_number(substr(p_in_laptime,instr(p_in_laptime,'.',-1)+1));
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

@F1_DATA_SCHEDULER.sql
