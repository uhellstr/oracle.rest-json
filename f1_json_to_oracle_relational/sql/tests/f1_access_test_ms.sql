with t as
(
  --select '00:01:30.423000' as laptime from dual
  select '1:30.423' as laptime from dual
) 
select f1_logik.to_millis(laptime) from t; --90423

-- 2:25.430

select regexp_count('00:01:30.423000', ':') from dual;

with t as
(
  select '2:25.430' as laptime from dual
) 
select f1_logik.to_millis(laptime) from t;

set serveroutput on
declare

  --lv_timestamp varchar2(15) := '00:01:30.423000';
  lv_timestamp varchar2(15) := '00:01:01.000000';
  lv_laptime varchar2(15);
  lv_retval number;
  v_hour number;
  v_minutes number;
  v_seconds number;
  v_millis  number;  
  
begin

  if length(lv_timestamp) = 15 then
    lv_laptime := regexp_replace(lv_timestamp,'0{2,}','');
    lv_laptime := regexp_replace(lv_laptime,'^:','');
    lv_laptime := regexp_replace(lv_laptime,'^0','');
    lv_laptime := regexp_replace(lv_laptime,'$.','.0'); -- end of string still not working...
  else
    lv_laptime := lv_timestamp;
  end if;
  
  dbms_output.put_line(lv_timestamp);
  dbms_output.put_line(lv_laptime);
  
  v_minutes := to_number(substr(lv_laptime,1,instr(lv_laptime,':',1)-1));
  v_seconds := to_number(substr(lv_laptime,instr(lv_laptime,':',1)+1,(length(lv_laptime) - instr(lv_laptime,'.',1)-1)));
  v_millis  := to_number(substr(lv_laptime,instr(lv_laptime,'.',-1)+1));
  lv_retval := (v_minutes * 60000) + (v_seconds * 1000) + v_millis;
  
  dbms_output.put_line('Minutes: '||v_minutes);
  dbms_output.put_line('Seconds: '||v_seconds);
  dbms_output.put_line('Millisec: '||v_millis);
  dbms_output.put_line(to_char(lv_retval));    
      
end;
/




