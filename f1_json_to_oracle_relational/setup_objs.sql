@F1_DATA_TBS.sql
@F1_INIT_PKG.sql

create or replace function  to_millis 
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
