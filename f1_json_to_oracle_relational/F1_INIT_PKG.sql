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
        --p_wallet_path => 'file:///home/oracle/https_wallet' 
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
        --p_wallet_path => 'file:///home/oracle/https_wallet' 
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
    begin
   
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
       
    end get_races;
    
  begin
    delete from f1_race_json;
    for rec in cur_get_season_year loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      get_races(rec.season,calling_url);
    end loop;
    commit;

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
    begin
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
    end insert_results;
    
  begin
    delete from f1_raceresults_json;
    for rec in cur_get_f1_races loop
      tmp := replace(url,'{YEAR}',rec.season);
      calling_url := replace(tmp,'{ROUND}',rec.round);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,rec.round,calling_url);
    end loop;
    commit;
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
    begin
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
    end insert_results;
    
  begin
    delete from f1_driverstandings_json;
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;
    commit;  
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
    begin
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
    end insert_results;
    
  begin
    delete from f1_constructorstandings_json;
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;
    commit;    
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
    begin
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
    end insert_results;
    
  begin
    delete from f1_seasons_race_dates;
    for rec in cur_get_f1_seasons loop
      calling_url := replace(url,'{YEAR}',rec.season);
      --dbms_output.put_line(calling_url);
      insert_results(rec.season,calling_url);
    end loop;
    commit;  
  end load_f1_seasons_racedates;

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
