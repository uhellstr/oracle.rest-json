-- USER SQL
CREATE USER "APEX_F1_DATA" IDENTIFIED BY "oracle"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS

ALTER USER "APEX_F1_DATA" QUOTA UNLIMITED ON "USERS";

-- ROLES

-- SYSTEM PRIVILEGES
GRANT CREATE JOB TO "APEX_F1_DATA" ;
GRANT CREATE TRIGGER TO "APEX_F1_DATA" ;
GRANT CREATE MATERIALIZED VIEW TO "APEX_F1_DATA" ;
GRANT CREATE DIMENSION TO "APEX_F1_DATA" ;
GRANT CREATE OPERATOR TO "APEX_F1_DATA" ;
GRANT CREATE INDEXTYPE TO "APEX_F1_DATA" ;
GRANT CREATE VIEW TO "APEX_F1_DATA" ;
GRANT CREATE SESSION TO "APEX_F1_DATA" ;
GRANT CREATE TABLE TO "APEX_F1_DATA" ;
GRANT CREATE TYPE TO "APEX_F1_DATA" ;
GRANT CREATE SYNONYM TO "APEX_F1_DATA" ;
GRANT CREATE SEQUENCE TO "APEX_F1_DATA" ;
GRANT CREATE CLUSTER TO "APEX_F1_DATA" ;
GRANT CREATE PROCEDURE TO "APEX_F1_DATA" ;