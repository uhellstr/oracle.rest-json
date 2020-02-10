#!/usr/bin/env python

r"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# _____ _   ____    _  _____  _    
#|  ___/ | |  _ \  / \|_   _|/ \   
#| |_  | | | | | |/ _ \ | | / _ \  Additional wiki url of images of F1 tracjs
#|  _| | | | |_| / ___ \| |/ ___ \ 
#|_|   |_| |____/_/   \_\_/_/   \_\
#
# The "r" on row 4 is there to make this comment
# in raw format so that pylint not complains 
# about strange characters within this comment :-)
# Do not remove the leading "r"!!
#
#               Generate csv file with url for image of f1 drivers
#               * Requires Oracle 12c instant client or higher
#               * Python 3.x or higher with cx_Oracle module installed
#               By Ulf Hellstrom,oraminute@gmail.com , EpicoTech 2019
#
#
#               Requires cx_Oracle installed
#               Requires pip install bs4
#               Requires pip install requests
#            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""

from bs4 import BeautifulSoup
from datetime import datetime
import requests
import subprocess
import sys
import getpass
import getopt
import base64
import os
import shutil

# Import oraclepackage module
workingdir = os.getcwd()
orapackdir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '')) +"/"
sys.path.append(orapackdir)
from oraclepackage import oramodule

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Logger()
    Logfunction that logs all output to screen to logfile.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
class Logger(object):
    def __init__(self):
        logfile = datetime.now().strftime('wikif1tracks_%Y_%m_%d_%H_%M.log')
        self.terminal = sys.stdout
        self.log = open(logfile, "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)  

    def flush(self):
        #this flush method is needed for python 3 compatibility.
        #this handles the flush command by doing nothing.
        #you might want to specify some extra behavior here.
        pass


"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_object_exists()
    Check if object exists or not
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def check_if_object_exists(connection):

    retval = False

    sql_stmt = """
select count(*) as antal
from dba_objects
where owner  = 'F1_DATA'
  and  object_name = 'V_F1_RESULTS'
  and object_type = 'VIEW'
"""
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    # convert tuple to integer
    value = int(c1.fetchone()[0])
    if value > 0:
        retval = True
    c1.close()

    return retval

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_f1_tracks(connection):

    track_list = []
    sql_stmt =  """
select distinct season,circuitid,race,info
from f1_data.v_f1_results
where info is not null
order by season,race
"""
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    res = c1.fetchall()
    for row in res:
        season = row[0]
        circuitid = row[1]
        race = row[2]
        info = row[3]
        val = str(season)+","+str(circuitid)+","+str(race)+","+str(info)
        track_list.append(val)

    return track_list

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_image_from_f1_wiki(circuitid,year,imageurl):

    if imageurl is not "null":
        imagename = workingdir+"/images/"+circuitid+"_"+year+".jpg"
        resp = requests.get(imageurl, stream=True)
        local_file = open(imagename, 'wb')
        resp.raw.decode_content = True
        shutil.copyfileobj(resp.raw, local_file)
        del resp

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_image_urls(track_list):

    image_list = []
    for val in track_list:
        imageurl="null"
        season = oramodule.split_list(val,',',0)
        circuitid = oramodule.split_list(val,',',1)
        print("Fetching wiki data for: "+circuitid)
        wikiurl  = oramodule.split_list(val,',',3)
        print(wikiurl)
        race = oramodule.split_list(val,',',2)
        r = requests.get(wikiurl)
        soup = BeautifulSoup(r.content,'html.parser')
        covers = soup.select('table.infobox a.image img[src]')
        for cover in covers:
            imageurl = "https:"+ cover['src']
        val = str(season)+"|"+str(circuitid)+"|"+str(race)+"|"+str(wikiurl)+"|"+str(imageurl)    
        image_list.append(val)
        get_image_from_f1_wiki(circuitid,season,imageurl)

    return image_list  

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def insert_image_data(connection,imageinfo):

    imagename = workingdir+"/images/"
    season = oramodule.split_list(imageinfo,'|',0)
    circuitid = oramodule.split_list(imageinfo,'|',1)
    race = oramodule.split_list(imageinfo,'|',2)
    checkimage = oramodule.split_list(imageinfo,'|',3)
    print("checkimage is: "+checkimage)
    if checkimage is not "null":
        imagename = workingdir+"/images/"+circuitid+"_"+season+".jpg"
        print(imagename)
        if checkimage.startswith("http"):
            print("Insert into F1_DATA: "+circuitid+","+imagename)
            try:
                with open(imagename, 'rb') as f:
                    imgdata = f.read()
            except Exception:
                imgdata = None
                pass
            cursor = connection.cursor()
            cursor.execute("""
            insert into f1_data.F1_DATA_TRACK_IMAGES (circuitid,year,race,image)
            values (:circuitid,:year,:race,:blobdata)""",
            circuitid=circuitid,year=season,race=race,blobdata=imgdata)
            connection.commit()    
            cursor.close()
    else:
        print("Missing image data for: "+season+","+race+","+circuitid)        

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Main starts here. Eg this is where we run the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def main():
    outputfile = workingdir+"/wikidata.csv"
    # Give the hostname or scan-listener
    tns = input("Pleas give hostname or scan-listener name: ")
    # Get the TNS name
    dbname = input("Give the TNS-string for DB to connect to: ")
    # Get oracle user name 
    username = input("Oracle Username: ")
    # Get password and encrypt it
    pwd = getpass.getpass(prompt="Please give "+username +" password: ")
    pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["DB_INFO"] = pwd
    tnsport = input("Give Listener port default (1521): ")
    # Enable logging output to log file
    sys.stdout = Logger()
    if username.lower() == "sys":
        print("Trying to connect to "+username+"/xxxxx@"+dbname+" as sysdba")
    else:     
        print("Trying to connect to "+username+"/xxxxx@"+dbname)
    connection = oramodule.get_oracle_connection(dbname,tns,tnsport,username,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    print("Connection successfull")
    print("Checking for F1_DATA.V_F1_TRACKS")
    if check_if_object_exists(connection) is True:
        print("F1_DATA.V_F1_TRACKS exists")
    else:
        print("Missing F1_DATA.V_F1_TRACKS please install schema...")
    tracks = get_f1_tracks(connection)
    wikilist = get_image_urls(tracks)
    csvfile = open(outputfile,'w')
    for val in wikilist:
        insert_image_data(connection,val)
        csvfile.write(val)
        csvfile.write('\n')
    csvfile.close()
    connection.close()

if __name__ == "__main__":
    main()