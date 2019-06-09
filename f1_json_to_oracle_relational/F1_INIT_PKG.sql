CREATE OR REPLACE package f1_data.f1_init_pkg as 

  procedure load_json;

end f1_init_pkg;
/


CREATE OR REPLACE package body f1_data.f1_init_pkg 
as

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure load_f1_seasons
  is
  begin

    delete from f1_seasons_json;

    insert into f1_seasons_json( 
      season 
    ) values 
    ( apex_web_service.make_rest_request
      (
        p_url => 'http://ergast.com/api/f1/seasons.json?limit=1000', 
        p_http_method => 'GET' 
      )
    );
    commit;
    
  end load_f1_seasons;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_drivers
  is
  begin
  
    delete from f1_drivers_json;
    
    insert into f1_drivers_json( 
      drivers 
    ) values 
    ( apex_web_service.make_rest_request
      (
        p_url => 'http://ergast.com/api/f1/drivers.json?limit=2000', 
        p_http_method => 'GET' 
      )
    );
    commit;
    
  end load_f1_drivers;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_tracks
  is
  begin
  
    delete from f1_tracks_json;
    insert into f1_tracks_json( 
      tracks
    ) values 
    ( apex_web_service.make_rest_request
      (
        p_url => 'http://ergast.com/api/f1/circuits.json?limit=1000', 
        p_http_method => 'GET'
      )
    );
    commit;
    
  end load_f1_tracks;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_races
  is
  
    url clob := 'http://ergast.com/api/f1/{YEAR}.json?limit=1000';
    calling_url clob;
    
    cursor cur_get_season_year is
    select f1.season
    from f1_seasons_json ftab,
         json_table(ftab.season,'$.MRData.SeasonTable.Seasons[*]'
                   COLUMNS ( season PATH '$.season',
                             info PATH '$.url')
                   ) f1;                   
    --inline
    procedure get_races(
      p_in_year in number,
      p_in_url in clob
    ) 
    is
    
      lv_count number;
      
    begin
   
      -- check if year is already loaded, if then skip
      select count(year) into lv_count
      from f1_race_json
      where year = p_in_year;
      
      if lv_count = 0 then
        insert into f1_race_json(
          year
          ,race
        ) values 
        ( p_in_year
         ,apex_web_service.make_rest_request
           (
              p_url => p_in_url, 
              p_http_method => 'GET'
 
           )
         );   
        commit;
      end if;  
    end get_races;
    
  begin
  
    for rec in cur_get_season_year loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      get_races(rec.season,calling_url);
    end loop;
    
  end load_f1_races;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_raceresults
  is
  
    url clob := 'http://ergast.com/api/f1/{YEAR}/{ROUND}/results.json';
    tmp clob;
    calling_url clob;
    
    cursor cur_get_f1_races is
    select season
           ,round
    from v_f1_races;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_round in number
         ,p_in_url in clob
        )
    is
      lv_count number;
    begin
    
    -- check if race is already loaded , if then skip the call and insert.
     select count(year) into lv_count
     from f1_raceresults_json
     where year = p_in_year
       and round = p_in_round;
     
     if lv_count = 0 then
       insert into f1_raceresults_json(
          year
          ,round
          ,result
        ) values 
        ( p_in_year
          ,p_in_round
          ,apex_web_service.make_rest_request
           (
              p_url => p_in_url, 
              p_http_method => 'GET'
 
           )
         );
       commit;  
     end if;
    end insert_results;
    
  begin
    for rec in cur_get_f1_races loop
      tmp := replace(url,'{YEAR}',rec.season);
      calling_url := replace(tmp,'{ROUND}',rec.round);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,rec.round,calling_url);
    end loop;
  end load_f1_raceresults;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_constructors
  is
  begin
    delete from f1_constructors_json;
    insert into f1_constructors_json( 
      constructor
    ) values 
    ( apex_web_service.make_rest_request
      (
        p_url => 'http://ergast.com/api/f1/constructors.json?limit=1000', 
        p_http_method => 'GET'
        --p_wallet_path => 'file:///home/oracle/https_wallet' 
      )
    );
    commit;
  end load_f1_constructors;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_driverstandings
  is
    url clob := 'http://ergast.com/api/f1/{YEAR}/driverStandings.json';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
     lv_count number;
    begin
    
     -- Reload current years driverstandings since the update until end of season.
     if p_in_year = to_number(to_char(trunc(sysdate),'RRRR')) then
       lv_count := 0;
       delete from f1_driverstandings_json where year = to_number(to_char(trunc(sysdate),'RRRR'));
     else  
       -- check if results for year already loaded. if then skip to load it.
       select count(year) into lv_count
       from f1_driverstandings_json
       where year = p_in_year;
     end if;
     
     if lv_count = 0 then
       insert into f1_driverstandings_json(
          year
          ,driverstanding
        ) values 
        ( p_in_year
          ,apex_web_service.make_rest_request
           (
              p_url => p_in_url, 
              p_http_method => 'GET'
 
           )
        );
       commit;
     end if;
    end insert_results;
    
  begin
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;  
  end load_f1_driverstandings;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_constructorstandings
  is
    url clob := 'http://ergast.com/api/f1/{YEAR}/constructorStandings.json?limit=100';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
      lv_count number;
    begin
    
     -- Reload current years constructortandings since the update until end of season.
     if p_in_year = to_number(to_char(trunc(sysdate),'RRRR')) then
       lv_count := 0;
       delete from f1_constructorstandings_json where year = to_number(to_char(trunc(sysdate),'RRRR'));
     else  
       -- check if results for year already loaded. if then skip to load it.
       select count(year) into lv_count
       from f1_constructorstandings_json
       where year = p_in_year;
     end if;
     
     if lv_count = 0 then
       insert into f1_constructorstandings_json(
          year
          ,constructorstandings
        ) values 
        ( p_in_year
         ,apex_web_service.make_rest_request
           (
              p_url => p_in_url, 
              p_http_method => 'GET'
 
           )
         );
       commit;
     end if;
    end insert_results;
    
  begin
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;   
  end load_f1_constructorstandings;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure load_f1_seasons_racedates
  is
  
    url clob := 'http://ergast.com/api/f1/{YEAR}.json?limit=1000';
    calling_url clob;
    
    cursor cur_get_f1_seasons is
    select season
    from v_f1_season;
 
    -- inline
    procedure insert_results
       (
         p_in_year in number
         ,p_in_url in clob
        )
    is
      lv_count number;
    begin
    
    -- check if racedates already loaded , if then skip
     select count(year) into lv_count
     from f1_seasons_race_dates
     where year = p_in_year;
     
     if lv_count = 0 then
       insert into f1_seasons_race_dates(
          year
          ,race_date
        ) values 
        ( p_in_year
         ,apex_web_service.make_rest_request
           (
              p_url => p_in_url, 
              p_http_method => 'GET'
 
           )
         );
       commit;
     end if;
    end insert_results;
    
  begin
  
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;
    
  end load_f1_seasons_racedates;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_f1_laptimes is
  url clob := 'http://ergast.com/api/f1/{YEAR}/{ROUND}/laps/{LAP}.json?limit=1000';
  calling_url clob;
  tmp_url clob;
  tmp1_url clob;
  lv_number_of_races number;
  lv_number_of_laps number;
    
  cursor cur_get_season_year is
  select season
  from v_f1_season
  where to_number(season) > 1995;
                        
  --inline
  procedure get_laps(
      p_in_year in number,
      p_in_round in number,
      p_in_lap in number,
      p_in_url clob
  ) 
  is
  
    lv_count number;
    
  begin
  
    select count(lap) into lv_count
    from f1_laptimes_json
    where year = p_in_year
      and round = p_in_round
      and lap = p_in_lap;
    
    if lv_count = 0 then   
      insert into f1_laptimes_json(
        year
        ,round
        ,lap
        ,laptimes 
      ) values 
      ( p_in_year,
        p_in_round,
        p_in_lap,
        apex_web_service.make_rest_request
          (
            p_url => p_in_url, 
            p_http_method => 'GET'  
          )
      );   
      commit;
    end if;
   end get_laps;
    
  begin
      
    for rec in cur_get_season_year loop
    
      select count(round) 
        into lv_number_of_races
      from v_f1_races
      where to_number(season) = to_number(rec.season);
            
      for i in 1..lv_number_of_races loop
      
        select to_number(laps) 
          into lv_number_of_laps
        from v_f1_results
        where to_number(position) = 1
          and to_number(season) = rec.season
          and to_number(race) = i; 
        
        for j in 1..lv_number_of_laps loop
          tmp_url := replace(url,'{YEAR}',rec.season);
          tmp1_url := replace(tmp_url,'{ROUND}',i);      
          calling_url := replace(tmp1_url,'{LAP}',j);
          get_laps(rec.season,i,j,calling_url);
        end loop;
        
      end loop;  
    end loop;
    
  end load_f1_laptimes;
  
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure load_json as
  begin
    load_f1_seasons;
    load_f1_drivers;
    load_f1_tracks;
    load_f1_races;
    load_f1_raceresults;
    load_f1_constructors;
    load_f1_driverstandings;
    load_f1_constructorstandings;
    load_f1_seasons_racedates;
  end load_json;

end f1_init_pkg;
/
