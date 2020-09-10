# http://api.oric.org/0.2/softwares/

import json
import pycurl
import zipfile
import os, sys
from io import BytesIO 
import pathlib

from shutil import copyfile

def DecimalToBinary(num):
    print("XXXXXXXXXXXXXXXXXXXXXX:"+num)
    print("%d",int(num).to_bytes(1, byteorder='little'))
    return int(num).to_bytes(1, byteorder='little')


dest="../orix/usr/share/basic11"
destetc="../orix/var/cache/basic11/"
tmpfolderRetrieveSoftware="build/"
exist_ok=True
if not os.path.exists(dest):
    pathlib.Path(dest).mkdir(parents=True)
if not os.path.exists(destetc):
    pathlib.Path(destetc).mkdir(parents=True)    
if not os.path.exists(tmpfolderRetrieveSoftware):
    pathlib.Path(tmpfolderRetrieveSoftware).mkdir(parents=True)    




print("Retrieve json file from oric.org ...")
b_obj = BytesIO() 
crl = pycurl.Curl() 

# Set URL value
crl.setopt(crl.URL, 'http://api.oric.org/0.2/softwares/')

# Write bytes that are utf-8 encoded
crl.setopt(crl.WRITEDATA, b_obj)

# Perform a file transfer 
crl.perform() 

# End curl session
crl.close()

# Get the content stored in the BytesIO object (in byte characters) 
get_body = b_obj.getvalue()

# Decode the bytes stored in get_body to HTML and print the result 
#print('Output of GET request:\n%s' % get_body.decode('utf8')) 

datastore = json.loads(get_body.decode('utf8'))

for i in range(len(datastore)):
    print(i)
    #Use the new datastore datastructure
    tapefile=datastore[i]["download_software"]
    rombasic11=datastore[i]["basic11_ROM_TWILIGHTE"]
    up_joy=datastore[i]["up_joy"]
    down_joy=datastore[i]["down_joy"]
    right_joy=datastore[i]["right_joy"]
    left_joy=datastore[i]["up_joy"]
    fire1_joy=datastore[i]["fire1_joy"]
    fire2_joy=datastore[i]["fire2_joy"]    
    print(datastore[i])
    print(tapefile)
    if tapefile!="":
        b_obj_tape = BytesIO() 
        crl_tape = pycurl.Curl() 

        # Set URL value
        crl_tape.setopt(crl_tape.URL, 'https://cdn.oric.org//games/software/'+tapefile)
        crl_tape.setopt(crl_tape.SSL_VERIFYHOST, 0)
        crl_tape.setopt(crl_tape.SSL_VERIFYPEER, 0)
        # Write bytes that are utf-8 encoded
        crl_tape.setopt(crl_tape.WRITEDATA, b_obj_tape)

        # Perform a file transfer 
        crl_tape.perform() 

        # End curl session
        crl_tape.close()

        # Get the content stored in the BytesIO object (in byte characters) 
        get_body_tape = b_obj_tape.getvalue()

        # Decode the bytes stored in get_body to HTML and print the result 
        #print('Output of GET request:\n%s' % get_body.decode('utf8')) 

        extension=tapefile[-3:]


        head, tail = os.path.split(tapefile)

        f = open(tmpfolderRetrieveSoftware+"/"+tail, "wb")
        f.write(get_body_tape)
        f.close()
        #tail=tail.lower()
        letter=tail[0:1].lower()
        folder=dest+'/'+letter
        folderdb=destetc+'/'+letter
        print(folder)
        directory = os.path.dirname(folder)
        if not os.path.exists(folder):
            os.mkdir(folder)
            print("######################## Create "+folder)
        if not os.path.exists(folderdb):
            os.mkdir(folderdb)
            print("######################## Create "+folderdb)

        if extension=="zip":
            print("zip")
            #with zipfile.ZipFile(tmpfolderRetrieveSoftware+tail, 'r') as zip_ref:
            #    zip_ref.extractall(dest+"/"+rombasic11+"/"+letter+"")
        if extension=="tap":
            print("tap")
            filenametap=tail.lower().replace(" ", "")
            print(tmpfolderRetrieveSoftware+tail,dest+"/"+letter+"/"+filenametap)
            copyfile(tmpfolderRetrieveSoftware+tail,dest+"/"+letter+"/"+filenametap )
            if not os.path.exists(destetc+"/"+letter):
                os.mkdir(destetc+"/"+letter)
            tcnf=filenametap.split('.')
            cnf=tcnf[0]+".db"

            f = open(destetc+"/"+letter+"/"+cnf, "wb")
            f.write(DecimalToBinary(rombasic11))
            f.write(DecimalToBinary(down_joy))
            f.write(DecimalToBinary(right_joy))
            f.write(DecimalToBinary(left_joy))
            f.write(DecimalToBinary(fire1_joy))
            f.write(DecimalToBinary(up_joy))
            f.write(DecimalToBinary(fire2_joy))
            f.close() 

        exit