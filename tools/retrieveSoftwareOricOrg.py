# http://api.oric.org/0.2/softwares/

import json
import pycurl
import zipfile
import os, sys
from io import BytesIO 
import pathlib


from shutil import copyfile

def DecimalToBinary(num):
    #print("XXXXXXXXXXXXXXXXXXXXXX:"+num)
    #print("%d",int(num).to_bytes(1, byteorder='little'))
    return int(num).to_bytes(1, byteorder='little')

def KeyboardMatrix(num):
    #keyboardMatrixTab = [1.56, u"tabouret", 3j]
    #keyboardMatrixTab[10]=180 #Down
    #keyboardMatrixTab[32]=132 #Space
    keyboardMatrixTab=[
           #                                        LeftRight
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,172 ,188 , #0..9
           #          RET 
            180 ,156 ,175 ,0   ,0   ,0   ,0   ,0   ,0   ,0   , #10..19
           #                                   ESC 
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,169 ,0   ,0   , #20..29
           #          ESP
            0   ,0   ,132 ,0   ,0   ,0   ,0   ,0   ,0   ,0   , #30..39
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , #40..49
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   , #50..59
           #                         A    B    C    D    E
            0   ,0   ,0   ,0   ,0   ,174 ,146 ,186 ,185 ,158  , #60..69
           #F    G    H    I    J    K    L    M    N    O
            153 ,150 ,142 ,141 ,129 ,131 ,143 ,130 ,136 ,149  , #70..79
           #P    Q    R    S     T    U    V    W    X    Y 
            157 ,177 ,145 ,182  ,137 ,133 ,152 ,180 ,176 ,134 , #80..89
           #Z 
            170 ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0    , #90..99

            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #100..109
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #110..119
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #120..129
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #130..139
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #140..149
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #150..159


            ] #Space
    key=keyboardMatrixTab[int(num)]
    return DecimalToBinary(key)

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
            f.write(KeyboardMatrix(down_joy))
            f.write(KeyboardMatrix(right_joy))
            f.write(KeyboardMatrix(left_joy))
            f.write(KeyboardMatrix(fire1_joy))
            f.write(KeyboardMatrix(up_joy))
            f.write(KeyboardMatrix(fire2_joy))
            f.close() 

        exit
