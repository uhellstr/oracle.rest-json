prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.03.31'
,p_default_workspace_id=>1310767003467378
);
end;
/
prompt  WORKSPACE 1310767003467378
--
-- Workspace, User Group, User, and Team Development Export:
--   Date and Time:   11:47 Friday August 2, 2019
--   Exported By:     UHELLSTR
--   Export Type:     Workspace Export
--   Version:         19.1.0.00.15
--   Instance ID:     250137868799741
--
-- Import:
--   Using Instance Administration / Manage Workspaces
--   or
--   Using SQL*Plus as the Oracle user APEX_190100
 
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>1310767003467378);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace F1_DATA...
begin
wwv_flow_fnd_user_api.create_company (
  p_id => 1310955633467518
 ,p_provisioning_company_id => 1310767003467378
 ,p_short_name => 'F1_DATA'
 ,p_display_name => 'F1_DATA'
 ,p_first_schema_provisioned => 'APEX_F1_DATA'
 ,p_company_schemas => 'APEX_F1_DATA'
 ,p_account_status => 'ASSIGNED'
 ,p_allow_plsql_editing => 'Y'
 ,p_allow_app_building_yn => 'Y'
 ,p_allow_packaged_app_ins_yn => 'Y'
 ,p_allow_sql_workshop_yn => 'Y'
 ,p_allow_websheet_dev_yn => 'Y'
 ,p_allow_team_development_yn => 'Y'
 ,p_allow_to_be_purged_yn => 'Y'
 ,p_allow_restful_services_yn => 'Y'
 ,p_source_identifier => 'F1_DATA'
 ,p_webservice_logging_yn => 'Y'
 ,p_path_prefix => 'F1_DATA'
 ,p_files_version => 1
);
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1280382648851520,
  p_GROUP_NAME => 'OAuth2 Client Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to register OAuth2 Client Applications');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1280246519851520,
  p_GROUP_NAME => 'RESTful Services',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use RESTful Services with this workspace');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1280123779851517,
  p_GROUP_NAME => 'SQL Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use SQL Developer with this workspace');
end;
/
prompt  Creating group grants...
----------------
-- U S E R S
-- User repository for use with APEX cookie-based authentication.
--
prompt  Creating Users...
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1310668015467378',
  p_user_name                    => 'F1-ADMIN',
  p_first_name                   => 'Ulf',
  p_last_name                    => 'Hellstrom',
  p_description                  => '',
  p_email_address                => 'oraminute@gmail.com',
  p_web_password                 => 'AC53C7CE1AD8E0E388C7C0B9D5212E1DF4FF81AB334EAF44C45C110FE68EC7703703F4C21B8296499EAAF20A42BBF280FDF0311126C7A987568039479E3E4F04',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'APEX_F1_DATA',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201906292220','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1311743888474144',
  p_user_name                    => 'UHELLSTR',
  p_first_name                   => 'Ulf',
  p_last_name                    => 'Hellstrom',
  p_description                  => 'Developer of F1 APP',
  p_email_address                => 'oraminute@gmail.com',
  p_web_password                 => 'E668858DE1AC7E6D4A3581DB5497D3BC5B685EF9BC18DA53E55188C3078DBA853D56EC81694BF9EF6CDB1C9FD7063101FEBA1F3B12DB9280774220982AE14D7D',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'APEX_F1_DATA',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201906292221','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_default_date_format          => 'RRRR-MM-DD HH24:MM:SS',
  p_allow_access_to_schemas      => '');
end;
/
prompt Check Compatibility...
begin
-- This date identifies the minimum version required to import this file.
wwv_flow_team_api.check_version(p_version_yyyy_mm_dd=>'2010.05.13');
end;
/
 
begin wwv_flow.g_import_in_progress := true; wwv_flow.g_user := USER; end; 
/
 
--
prompt ...news
--
begin
null;
end;
/
--
prompt ...links
--
begin
null;
end;
/
--
prompt ...bugs
--
begin
null;
end;
/
--
prompt ...events
--
begin
null;
end;
/
--
prompt ...feature types
--
begin
null;
end;
/
--
prompt ...features
--
begin
null;
end;
/
--
prompt ...feature map
--
begin
null;
end;
/
--
prompt ...tasks
--
begin
null;
end;
/
--
prompt ...feedback
--
begin
null;
end;
/
--
prompt ...task defaults
--
begin
null;
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
