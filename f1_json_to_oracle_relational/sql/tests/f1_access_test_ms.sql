with t as
(
  select '00:01:30.423000' as laptime from dual
) 
select f1_logik.to_millis(laptime) from t; --90423


with t as
(
  select '00:01:24' as laptime from dual
) 
select f1_logik.to_millis(laptime) from t; -- 84000

with t as
(
  select '1:30.423' as laptime from dual
) 
select f1_logik.to_millis(laptime) from t; -- bug out right now

