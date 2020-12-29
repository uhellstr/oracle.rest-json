# oracle.rest-json
This is a demo of Oracle's functionality of using and creating Rest Based services and how to parse JSON documents.

- How to publish REST based services direct from the Oracle database and example app written in Node to consume them.
- How to consume REST based F1 service from ergast.com and how to parse json to relation data to be able to query all stats thru SQL.

# Publish Oracle data as REST service thru PL/SQL

Requirements:

* Linux environment supported like Centos7. The demo is not tested or has any scripts for Windows.
* Oracle 11g or higher. (For a non licensed environment I strongly recommend to use Oracle 18c Express Edition or higher)
* Java 8 or Java 11 LTS or higher where you install Oracle Rest Data Services. 
* Oracle Application Express version 20 or higher
* Latest version of Oracle Rest Data services (ORDS)

All the installation kits can be downloaded from https://www.oracle.com/technical-resources/

You must have APEX v5 (Recommend the latest version of APEX) or newer installed due to PL/SQL packaged code is used in the demo code to publish data as a REST enabled service in JSON format. I like to hide logic in code and even if you can publish tables or views in a Oracle schema directly i suggest you hide all logic in code to minimize and control exactly what you want to publish to your audience.

You also need ORDS installed and configured (see example below) to be able to call the service. In this example we make i easy and use normal http calls. In a production environemnt you would never do that. There you always should use https calls to secure your environment as much as possible. I recommend to look at Tim Hall's excelent introduction to Oracle Rest Data Services (ORDS) for more indepth information about setting up and configuring ORDS.

Tim Hall's excelent site:
https://oracle-base.com

You can use a browser like Chromium, Safari, Firefox to call the published services but the demo also includes som examples made with the nodejs engine to show that you can call Oracle Rest enabled services from any language supporting JSON and REST calls. You could easy create a client in any language like python, ruby or even in C. See your platform for how to install node. (It's easy) if you intend to try out the node part of the code

Configuring ORDS:

a) Install Oracle Application Express (APEX) if not installed in the datbase you intend to run this demo against.

Installing APEX normally done as SYS by running the following scripts from the catalog where you unzipped the downloaded apex zip file. Use sqlplus or sqlcl against either a pluggable database if you run this demo against 12c or higher or a normal database if below 12c. (Recommend atleast 11g as a minimum) If you don't have a database you will need to setup that first. 

1. SQL>@apexins SYSAUX SYSAUX TEMP /i/
2. SQL>@apex_rest_config (To setup APEX_LISTENER, APEX_REST_PUBLIC_USER that is a MUST for ORDS to work correctly)
3. SQL>@apxchpwd (Setup the password for the internal workspace admin user)

In this example we have installed Oracle 18c Express Edition as a demonstration environment. Since Oracle 18c uses multitenant by default
we have a containerdatabase XE and atleast one pluggable database XEPDB1 by default setup after installation. All configuration
and installation is done against the pluggable database XEPDB1

Even if there is no intent to use APEX i recommend you setup ORDS for APEX that will also make sure you have a working ORDS environment and minimize any problem solving:

After the installation of APEX the i highly recommend you try to connect to the following schemas to make sure you can connect to them

4. APEX_LISTENER
5. APEX_REST_PUBLIC_USER

You also need to enable APEX_PUBLIC_USER as:

6. SQL> alter user APEX_PUBLIC_USER identified by "your secret password" account unlock;

Also verify you can connect to the APEX_PUBLIC_USER.

b) Create a catalog (you don't need to be the Oracle O/S user as long as you can run java) called ords and the following subcatalogs. In this example we have downloaded ORDS version 19. In this example we use the O/S user test that has it's home catalog in /home/test

1. $ mkdir ords
2. $ cd ords
3. $ mkdir ords191
4. $ mkdir scripts
5. $ mkdir logs
6. $ mkdir configdir

Also copy over the subcatalog images from your APEX installation. This is done by

Wherever you have APEX unziped

1. $ cd /../apex
2. $ zip -r images.zip ./images/*

Move the images.zip file to /home/test/ords and 
3. $ unzip images.zip

You should now have a images catalog also in /home/test/ords 

Put the downloaded zip file with the latest ORDS version in the ords191 catalong and unzip it.
1. $ cd ords191
2. $ unzip ords-18.10.0.092.1545.zip (Your file might have another name depending on version)

c) Then we need to setup where ORDS is storing it's configuration files

1. $ cd /ords/ords181
2. $ java -jar ords.war configdir /home/test/ords/configdir (You need to alter the path to where the configdir is created)

Then we setup a path for our database. In our example we use 18c Express Edition and the pluggable database xepdb1.
You will understand how the path is used when calling the service below

3. $ java -jar ords.war map-url --type base-path /xepdb1 xepdb1

Then we run the configuration to enable ORDS in the xepdb1 database. You must configure all steps and the script will ask you for
the administrator user or SYS for the installation to complete. For more details in depth please see references on how to setup
ORDS on Tim Hall's site as stated above.

4. $ java -jar ords.war setup --database xepdb1

Don't skip any steps more then the last that asks if you want to start ORDS in standalone mode. We do it manually below.

When you are finished with the ORDS configuration you can startup the ORDS listener in a standalone mode from your terminal to
check that things works as intended. (Remember the step with "base-path" setup "/xepdb1". This will now uniqly identify what
resource we call

5. $ java -jar ords.war standalone

Running this will ask about using http or https. For demo purpose use HTTP , default port (Normally 8080) and where to find APEX images catalog in the example /home/test/ords/images

The issue with starting ORDS in the way above is that we have to let the terminal window to be open. If we close it or
press Ctrl+C we will force quit ORDS. If you want you can put the following shellscripts as executables in the 
scripts subfolder and then add the path to that folder to your environemnt to allow stop/start ORDS in the background.
You ofcause needs to edit the paths below if you have another user then test setup in your environment.

startords:

#!/bin/bash
export PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:$PATH
LOGFILE=/home/test/ords/logs/ords-`date +"%Y""%m""%d"`.log
cd /home/test/ords/ords191 
export JAVA_OPTIONS="-Dorg.eclipse.jetty.server.Request.maxFormContentSize=3000000"
nohup java ${JAVA_OPTIONS} -jar ords.war standalone >> $LOGFILE 2>&1 &
echo "View log file with : tail -f $LOGFILE"

stopords:

#!/bin/bash
export PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:$PATH
kill `ps -ef | grep ords.war | awk '{print $2}'` >/dev/null 2>&1stopords:

d) Now you can try out to see if APEX and ORDS works as intended by using a browser and a URL like:

http://<you host where ords is installed>:8080/ords/xepdb1/apex_admin

Example:
http://localhost:8080/ords/xepdb1/apex_admin

If everything works you should see the login page for Oracle Application Express.

e) Setup the database schema for the demonstration:

To setup the database schema see the sql scripts provided in the subdirectory node/oracle_rest_api/sql

Create the REST_DATA schema as SYS run the script (You can change the password for the schema in the script. I'ts set to "oracle" by default.

1. SQL> @SETUP_SCHEMA.sql

To setup all database objects and enable ORDS in the schema connect as REST_DATA/oracle and run

2. SQL> @SETUP_REST_DATA_OBJS.sql

From your browser try the following URL to verify that the demo works.

http://<your host where ords is installed>:8080/ords/xepdb1/rest_data/testmodule/countrynames/

Example: http://localhost:8080/ords/xepdb1/rest_data/testmodule/countrynames/

If everything works you should get a JSON document in return with all the countries in the world as countrycode and countrynames.

Another example is to check how the population growth for Sweden looked like from the 60's until around 2010. That can be
done by calling the following url:

http://localhost:8080/ords/xepdb1/rest_data/testmodule/country/Sweden

How does this work e.g how do we get our relational data out as JSON ?
----------------------------------------------------------------------

First of all look at the sql script REST_SETUP.sql
This script instructs Oracle to enable REST for the Oracle schema rest_data and is a way of granting permission
to allow data to be called from the ORDS service.

Nest study the COUNTRY_STATS_PKG.sql script. THis includes the PL/SQL package that we use to transform relational
data to JSON format. If you look at the code you can see that we use some magic underlying code from the APEX framework.
The apex_json package in APEX allow to transform data to json. If you look carefully at the package in your database
with SQL*Developer you even can see that you can do some debugging of the code to get the resulting JSON document
even within SQL*Developer itself.

But this do not explain how ORDS maps it service thru the PL/SQL code to a URL call ?
The final magic lies in the code you find in SETUP_REST_COUNTRY_CODE.sql
This is where we tell ORDS how to map the PL/SQL packaged code back to URL where we
even allow for calling the PL/SQL package with paramters like what country we want statistics for
as in the above example where we look at the population for Sweden.

Using the node example code written in node:
----------------------------

If you don't want to write your own client you could test out the provided example code written for nodejs
Installing nodejs is reallys simple. For more information on how to get started see https://nodejs.org/en/

When you have nodejs working you need to apply some modules to get the demos to work:
Use npm to install

* require
* blessed
* blessed-contrib
* terminal

That should be as easy as "npm install require" etc.

To get a graph in your terminal over popultion development in Sweden from the 60's and forward run

$ node sweden_graph.js

There is one configuration file you need to be aware of. You can change the "resturl" value for all
of the node apps in "config.json" so it matches your environment. 

How to consume a REST service and transform JSON to Relational data for SQL analysis ?
--------------------------------------------------------------------------------------

Requirements:

* Linux environment supported like Centos7. The demo is not tested or has any scripts for Windows.
* Oracle 12c or higher. (For a non licensed environment I strongly recommend to use Oracle 18c Express Edition or higher) 
* Oracle Application Express version 5 or higher. Recommend version 18.x and higher and prefered use the lastest possible version.
  Even if you do not use APEX the PL/SQL API used to fetch data from ergast uses packaged API only found in APEX so APEX *MUST* be installed.
* ORDS is used if you want to test AutoRest functionality and then i recommend 20.2 version or higher.

Note: ergast is used only for non commercial applications. You cannot use this data and build any kind of commercial applications as per there license.

I'm a huge fan of Formula 1. I've been following it since i was a kid and the "Superswede" Ronnie Peterson was my absolute
hero. I still belive the "Lotus 72D" is one of the most beatiful oneseater cars ever built. As a "datanerd". i'm more into analysing data then the database technology itself. So having a lot of F1 data for historical Formula 1 races, season, laptimes etc would be great to help me better understand how the teams differs from each others, how drivers perform during a season, what enginges seems to have
more problems then others etc.

Now, thanks to https://ergast.com/mrd/ I finally found a way to be able to get hold of data and do some analysis of my favorite
motorsport besides Indycar. This site publish allot of statistical data in form of REST services and you can download the raw
JSON document and store them in a Oracle database (Oracle supports JSON storage in tables) and the parse and query the data as if it is
a normal relational table.

If you want to setup this demo yourself be warned. You will download 10 000's of relative small JSON documents and the volume of
races are huge. The first official Formula 1 race was done in the 1950's. Not all years have the full statistics, it was not until
around 1996 the technology was there to get lot of more data that is now public for publishing. But in anycase this will take some
time to get your tables loaded before you can start to analyze. On a medium to good internet connection assume it will take around
4-5 hours to get the data in place. The data is loaded thru a scheduled job so you do not need to sit around and wait for it to be finished. 

When everything is in place you will have information about all F1 seasons, all races, qualification times , lap times , constructors and drivers.

All the code is in the subfolder "f1_son_to_oracle_relational" in this github repo.

How to install the basetables and start load the data from ergast ?
-------------------------------------------------------------------

1. First you need to run the "setup_schema.sql" script as SYS.

Now before running it look at the ACL part and change the password for the F1_DATA schema if not in a private demo environment. 
You must have APEX installed before attempting to run the script. The script will automaticly find out the latest installed version
of APEX and add it to the ACL list.


You also have to look at the DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL where you set the hostname for the server where the Oracle database is installed.

In the example it is set to 'localhost'. You need to change that to match your environment if necessary.

The ACL part (Access Control List) is where we tell the Oracle database that we allow for doing http calls from inside the database
and to a website outside our protected environment. It is quite complex configuration so I refer to the official Oracle documentation for you to read more about ACL's in Oracle.

When done with the necessary changes you can run the script as SYS.

When it is done you could try to do a call to ergast thru the SQL below to see if it works. If not you need to start to check for any errors in the setup for ACL, firewall issues etc that could cause the callout to fail.

select apex_web_service.make_rest_request(
    p_url         => 'http://ergast.com/api/f1/seasons.json?limit=1000', 
    p_http_method => 'GET' 
) as result from dual;

2. When, and only when the query above works it is time to setup the schema and initiate the job to start download data from ergast.com
This is done by running the "setup_objs.sql" scipt to initiate all tables and views and the scheduler job.
The script should only be run as the "F1_DATA" schema user.

a) SQL> conn F1_DATA/oracle

b) SQL> @setup_objs.sql

Check for any errors. I recommend to use SQL*Developer to check for any invalid objects and re-compile them and also look at the
scheduler job to make sure it runs as intended. The job is defaulted to start 20:00 everyday. if everyting works so it might take some
time before you see any data starting to be loaded into the base tables.

How to use the data for analysis ?
---------------------------------

I have provided a SQL script called "queries.sql" you can use for start analysing the data. I also provided a number of materialized views that speeds up some queries due to minimize parsing time when joining different tables with each others.

There is also som additional script for handling ORDS AutoRest (E.g publish back the relational data as REST services). Scripts for allowing other users then F1_ACCESS to access data thru views and som python scripts for loading images of drivers,tracks etc. See the included README_FIRST.txt for more information.

I'm currently building a APEX application ontop of the data but it's not yet ready but the query part might be interesting nevertheless.
