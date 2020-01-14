REM
REM Run this script as F1_ACCESS after setup and installing ORDS (use 19.4 or higher)
REM
REM This allows for using SQL*Developer Web and SQL Enabled REST
REM

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'F1_ACCESS',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'f1_access',
      p_auto_rest_auth      => FALSE);   
      COMMIT;
END;
/

REM
REM Auto rest the view V_F1_CONSTRUCTOR
REM
REM To access use:
REM
REM http://localhost:8080/ords/pdbutv1/f1_access/f1_constructors/
REM 

BEGIN
  ORDS.enable_object (
    p_enabled      => TRUE, -- Default  { TRUE | FALSE }
    p_schema       => 'F1_ACCESS',
    p_object       => 'V_F1_CONSTRUCTORS',
    p_object_type  => 'VIEW', -- Default  { TABLE | VIEW }
    p_object_alias => 'f1_constructors'
  );   
  COMMIT;
END;
/