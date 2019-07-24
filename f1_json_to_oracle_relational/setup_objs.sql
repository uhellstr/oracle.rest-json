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

--exec dbms_scheduler.drop_schedule('SCH_F1_LOAD_DATA');
--exec dbms_scheduler.drop_job('JOB_RUN_F1_INIT_PKG', false);
--exec dbms_scheduler.drop_chain('CHAIN_1', false);
--exec dbms_scheduler.drop_program('F1_INIT_DATA', false);
  
BEGIN

  --exec dbms_scheduler.drop_schedule('SCH_F1_LOAD_DATA');
  --exec dbms_scheduler.drop_job('JOB_RUN_F1_INIT_PKG', false);
  --exec dbms_scheduler.drop_chain('CHAIN_1', false);
  --exec dbms_scheduler.drop_program('F1_INIT_DATA', false);
  
  dbms_scheduler.create_schedule('SCH_F1_LOAD_DATA', systimestamp, 
    repeat_interval=>'FREQ=HOURLY; INTERVAL=1');


  DBMS_SCHEDULER.set_attribute( name => '"F1_DATA"."SCH_F1_LOAD_DATA"', attribute => 'repeat_interval', value => 'FREQ=DAILY;BYTIME=220000;BYDAY=MON,TUE,WED,THU,FRI');

  DBMS_SCHEDULER.set_attribute( name => '"F1_DATA"."SCH_F1_LOAD_DATA"', attribute => 'comments', value => 'Load ergast once per day');


  dbms_scheduler.create_program(program_name=>'F1_INIT_DATA',program_type=>'PLSQL_BLOCK', 
    program_action=>'BEGIN
      F1_INIT_PKG.load_json();
    END;', 
    number_of_arguments=>0,enabled=>TRUE,comments=>'Loads data into F1_DATA tables regular');

  -- create chain
  dbms_scheduler.create_chain(chain_name=>'CHAIN_1',comments=>'Schedule chain for f1_data');
  -- define chain steps
  dbms_scheduler.define_chain_step(chain_name=>'CHAIN_1',step_name=>'STEP_RUN_F1_INIT',program_name=>'F1_INIT_DATA');
  -- define chain rules
  dbms_scheduler.define_chain_rule(chain_name=>'CHAIN_1',condition=>'TRUE',action=>'START "STEP_RUN_F1_INIT"',rule_name=>'CHAIN_R01',comments=>'Run main pgm');
  dbms_scheduler.define_chain_rule(chain_name=>'CHAIN_1',condition=>'STEP_RUN_F1_INIT succeeded',action=>'END',rule_name=>'CHAIN_R02',comments=>'End of chain');
 -- enable chain
  dbms_scheduler.ENABLE ('CHAIN_1');
  -- create job
  dbms_scheduler.create_job(job_name=>'JOB_RUN_F1_INIT_PKG',job_type=>'CHAIN',job_action=>'CHAIN_1',schedule_name=>'SCH_F1_LOAD_DATA',enabled=>TRUE,auto_drop=>FALSE,comments=>'Job to load f1 data from ergast.com');
END;
/