
DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM DBA_USERS
  WHERE USERNAME = 'F1_DATA';

  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'DROP USER F1_DATA CASCADE';
  END IF;

END;
/

-- USER SQL
CREATE USER "F1_DATA" IDENTIFIED BY "oracle"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS
ALTER USER "F1_DATA" QUOTA UNLIMITED ON "USERS";

-- ROLES
GRANT "CONNECT" TO "F1_DATA" ;
ALTER USER "F1_DATA" DEFAULT ROLE "CONNECT";

-- SYSTEM PRIVILEGES
GRANT CREATE TRIGGER TO "F1_DATA" ;
GRANT CREATE VIEW TO "F1_DATA" ;
GRANT CREATE SESSION TO "F1_DATA" ;
GRANT CREATE TABLE TO "F1_DATA" ;
GRANT CREATE TYPE TO "F1_DATA" ;
GRANT EXECUTE ANY PROGRAM TO "F1_DATA" ;
GRANT CREATE SEQUENCE TO "F1_DATA" ;
GRANT CREATE PROCEDURE TO "F1_DATA" ;
GRANT CREATE MATERIALIZED VIEW TO "F1_DATA";
GRANT SELECT ON DBA_TABLES TO "F1_DATA";
GRANT CREATE JOB TO "F1_DATA";
GRANT CREATE RULE TO "F1_DATA";
GRANT CREATE RULE SET TO "F1_DATA";
GRANT CREATE EVALUATION CONTEXT TO "F1_DATA";

-- USERSCHEMA F1_DATA

-- ACL must run as SYS -
BEGIN
DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
acl => 'f1_data.xml',
description => 'Permissions to access internet',
principal => 'APEX_190100',
is_grant => TRUE,
privilege => 'connect',
start_date => SYSTIMESTAMP,
end_date => NULL);
COMMIT;
END;
/


begin
 DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
 acl => 'f1_data.xml',
 principal => 'APEX_190100',
 is_grant => true,
 privilege => 'resolve',
 start_date => SYSTIMESTAMP,
 end_date => NULL
 );
 COMMIT;
 END;
/
 
 
begin
 DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
 acl => 'f1_data.xml',
 principal => 'F1_DATA',
 is_grant => true,
 privilege => 'connect',
 start_date => SYSTIMESTAMP,
 end_date => NULL
 );
 COMMIT;
 END;
/ 

begin
 DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
 acl => 'f1_data.xml',
 principal => 'F1_DATA',
 is_grant => true,
 privilege => 'resolve',
 start_date => SYSTIMESTAMP,
 end_date => NULL
 );
 COMMIT;
 END;
/

BEGIN
DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
acl => 'f1_data.xml',
host => 'localhost');
COMMIT;
END;
/

DECLARE
  --l_principal VARCHAR2(20) := 'APEX_040200';
  --l_principal VARCHAR2(20) := 'APEX_050000';
  --l_principal VARCHAR2(20) := 'APEX_050100';
  l_principal VARCHAR2(20) := 'APEX_190100';
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => '*', 
    lower_port => 80,
    upper_port => 8888,
    ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                              principal_name => l_principal,
                              principal_type => xs_acl.ptype_db)); 
 COMMIT;                             
END;
/

select * from dba_network_acls;
--
SELECT *
FROM dba_network_acl_privileges
where principal in('APEX_190100','F1_DATA');
--
---- END ACL --

--select apex_web_service.make_rest_request(
--    p_url         => 'http://ergast.com/api/f1/seasons.json?limit=1000', 
--    p_http_method => 'GET'
--    --p_wallet_path => 'file:///home/oracle/https_wallet' 
--) as result from dual;
