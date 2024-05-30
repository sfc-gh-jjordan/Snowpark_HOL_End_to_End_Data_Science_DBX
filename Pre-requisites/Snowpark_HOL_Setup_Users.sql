USE ROLE ACCOUNTADMIN;

-- create utility DB
create database utility;

-- create a SP to loop queries for N users
-- it replaces the placeholder XXX with N in the supplied query
create or replace procedure utility.public.loopquery (QRY STRING, N FLOAT)
  returns float
  language javascript
  strict
as
$$
  for (i = 0; i <= N; i++) {
    snowflake.execute({sqlText: QRY.replace(/XXX/g, i)});
  }


  return i-1;
$$;

----------------------------------------------------------------------------------
-- Set up the HOL environment for the first time
----------------------------------------------------------------------------------
set num_users = 20; --> adjust number of attendees here
set lab_pwd = '$nowpark@_Walgreens!'; --> enter an attendee password here

-- set up the roles
create or replace role hol_parent comment = "HOL parent role";

grant role hol_parent to role accountadmin;

call utility.public.loopquery('create or replace role roleXXX comment = "HOLXXX User Role";', $num_users);

-- Create Cortex role
CREATE or replace ROLE cortex_user_role;

GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_user_role;

-- set up the users
call utility.public.loopquery('create or replace user userXXX default_role=roleXXX password="' || $lab_pwd || '";', $num_users);
call utility.public.loopquery('grant role roleXXX to user userXXX;', $num_users);
call utility.public.loopquery('grant role roleXXX to role hol_parent;', $num_users);
call utility.public.loopquery('grant role roleXXX to role accountadmin;', $num_users);

-- grant account permissions
grant create warehouse on account to role hol_parent;
grant usage on warehouse hol_setup_wh to role hol_parent;

-- set up the warehouses and grant permissions
call utility.public.loopquery('create or replace warehouse whXXX warehouse_size = \'xsmall\' AUTO_SUSPEND = 300;', $num_users);
call utility.public.loopquery('grant all on warehouse whXXX to role roleXXX;', $num_users);

-- set up the schemas and grant permissions
call utility.public.loopquery('create or replace schema HOL.schemaXXX clone HOL.PUBLIC;', $num_users);
call utility.public.loopquery('grant usage, modify on database HOL to role roleXXX;', $num_users);
call utility.public.loopquery('grant usage on schema HOL.PUBLIC to role roleXXX;', $num_users);
call utility.public.loopquery('grant ownership on schema HOL.schemaXXX to role roleXXX;', $num_users);
call utility.public.loopquery('grant usage, modify on future schemas in database HOL to role roleXXX;', $num_users);
call utility.public.loopquery('grant all on all tables in schema HOL.schemaXXX to role roleXXX;', $num_users);
call utility.public.loopquery('grant all on all views in schema hol.schemaXXX to role roleXXX;', $num_users);
call utility.public.loopquery('grant all on future views in schema hol.schemaXXX to role roleXXX;', $num_users);
call utility.public.loopquery('GRANT SELECT ON VIEW hol.schemaXXX.sales_forecast_input TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT usage ON schema hol.schemaXXX TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT create stage ON schema hol.schemaXXX TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT usage ON warehouse whXXX TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT ROLE cortex_user_role TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT CREATE STREAMLIT ON SCHEMA hol.schemaXXX TO ROLE roleXXX', $num_users);
call utility.public.loopquery('GRANT CREATE STAGE ON SCHEMA hol.schemaXXX TO ROLE roleXXX', $num_users);
call utility.public.loopquery('grant create model on schema HOL.SCHEMAXXX to role roleXXX;', $num_users);





