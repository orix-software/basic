# http://api.oric.org/0.2/softwares/

import json
import pycurl
import zipfile
import os, sys
from io import BytesIO 
import pathlib
import re


from shutil import copyfile

version_bin="0"
dest="../orix/usr/share/basic11/"
destetc="../orix/var/cache/basic11/"
tmpfolderRetrieveSoftware="build/"
list_file_for_md2hlp=""


def removeFrenchChars(mystr):

    
    mystr=mystr.replace("é", "e")
    mystr=mystr.replace("è", "e")
    mystr=mystr.replace("ê", "e")
    mystr=mystr.replace("ë", "e")
    mystr=mystr.replace("ç", "c")
    mystr=mystr.replace("°", " ")

    mystr=mystr.replace("à", "a")
    mystr=mystr.replace("â", "a")

    mystr=mystr.replace("ô", "o")
    mystr=mystr.replace("ï", "i")
    mystr=mystr.replace("î", "i")
    mystr=mystr.replace("©", "")
    return mystr


def DecimalToBinary(num):
    return int(num).to_bytes(1, byteorder='little')

def KeyboardMatrix(num):
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
            140 ,0   ,148   ,0   ,0   ,174 ,146 ,186 ,185 ,158  , #60..69
           #F    G    H    I    J    K    L    M    N    O
            153 ,150 ,142 ,141 ,129 ,131 ,143 ,130 ,136 ,149  , #70..79
           #P    Q    R    S     T    U    V    W    X    Y 
            157 ,177 ,145 ,182 ,137 ,133 ,152 ,180 ,176 ,134 , #80..89
           #Z 
            170 ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0   ,0    , #90..99

            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #100..109
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #110..119
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #120..129
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #130..139
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #140..149
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #150..159
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #160..169
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #170..179
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #180..189
            0   ,0   ,0   ,0   ,0   ,0   ,0   ,0  ,0  , 0  , #190..199


            ] 
    key=keyboardMatrixTab[int(num)]
    return DecimalToBinary(key)


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
crl.setopt(crl.URL, 'http://api.oric.org/0.2/softwares/?sorts=name_software')

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

basic_main_db="basic11.db"
basic_main_db_indexed="basic11i.db"
basic_main_db_str=""
count=0
#                       low, high
main_db_table_software=[1,0]
lenAddSoftware=0

for i in range(len(datastore)):
    print(i)
    #Use the new datastore datastructure
    tapefile=datastore[i]["download_software"]
    name_software=datastore[i]["name_software"]
    programmer_software=datastore[i]["programmer_software"]
    download_platform_software=datastore[i]["platform_software"]
    junk_software=datastore[i]["junk_software"]
    date_software=datastore[i]["date_software"]
    name_software=name_software.replace("é", "e")
    name_software=name_software.replace("è", "e")
    name_software=name_software.replace("ç", "c")
    name_software=name_software.replace("°", " ")
    name_software=name_software.replace("à", "a")
    name_software=name_software.replace("â", "o")
    joystick_management_state=datastore[i]["joystick_management_state"]
    junk_software=removeFrenchChars(junk_software)

    

    programmer_software=programmer_software.replace("é", "e")
    programmer_software=programmer_software.replace("è", "e")
    programmer_software=programmer_software.replace("ç", "c")
    programmer_software=programmer_software.replace("°", " ")
    programmer_software=programmer_software.replace("à", "a")
    programmer_software=programmer_software.replace("ô", "o")


    rombasic11=datastore[i]["basic11_ROM_TWILIGHTE"]
    up_joy=datastore[i]["up_joy"]
    down_joy=datastore[i]["down_joy"]
    right_joy=datastore[i]["right_joy"]
    left_joy=datastore[i]["left_joy"]
    fire1_joy=datastore[i]["fire1_joy"]
    fire2_joy=datastore[i]["fire2_joy"]
    fire3_joy=0
    #print(datastore[i])
    #print(tapefile)
    if tapefile!="":
        b_obj_tape = BytesIO() 
        crl_tape = pycurl.Curl() 

        # Set URL value
        crl_tape.setopt(crl_tape.URL, 'https://cdn.oric.org/games/software/'+tapefile)
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

        extension=tapefile[-3:].lower()


        head, tail = os.path.split(tapefile)

        f = open(tmpfolderRetrieveSoftware+"/"+tail, "wb")
        f.write(get_body_tape)
        f.close()
        #tail=tail.lower()
        letter=tail[0:1].lower()
        folder=dest+'/'+letter
        folderdb=destetc+'/'+letter
        #print(folder)
        directory = os.path.dirname(folder)
        if not os.path.exists(folder):
            os.mkdir(folder)
            print("######################## Create "+folder)
        if not os.path.exists(folderdb):
            os.mkdir(folderdb)
            print("######################## Create "+folderdb)

        if extension=="zip":
            print("zip")
            print(tail)
            #with zipfile.ZipFile(tmpfolderRetrieveSoftware+tail, 'r') as zip_ref:
            #    zip_ref.extractall(dest+"/"+rombasic11+"/"+letter+"")
        if extension=="tap":
            #print("tap")
            filenametap=tail.lower().replace(" ", "").replace("-", "").replace("_", "")
            
            tcnf=filenametap.split('.')
            filenametapext=tcnf[1]
            cnf=tcnf[0]+".db"
            filenametapbase=tcnf[0]
            filenametap8bytesLength=filenametapbase[0:8]
            #print("Copy : "+tmpfolderRetrieveSoftware+tail,dest+"/"+letter+"/"+filenametap8bytesLength+"."+filenametapext)
            copyfile(tmpfolderRetrieveSoftware+tail,dest+"/"+letter+"/"+filenametap8bytesLength+"."+filenametapext )
            if not os.path.exists(destetc+"/"+letter):
                os.mkdir(destetc+"/"+letter)
            md_software="# "+name_software+"\n"
            #md_software=md_software+"Type : "+download_platform_software+"\n"
            tdate_software=date_software.split('-')
            year=tdate_software[0]
            md_software=md_software+"Release Date : "+year+"\n"
            md_software=md_software+"Platform : "
            match = re.search('A', download_platform_software)
            doslash="no"
            if match:
                md_software=md_software+"Atmos"
                doslash="yes"
            match = re.search('O', download_platform_software)
            if match:
                if doslash=="yes":
                    md_software=md_software+"/"
                md_software=md_software+"Oric-1"
                doslash="yes"                

            md_software=md_software+"\n"
            
            md_software=md_software+"Programmer : "+programmer_software+"\n"
            #md_software=md_software+"Origin : "+programmer_software+"\n"
            md_software=md_software+"Informations : "+junk_software+"\n"
            
            #print(md_software)
            
            md=filenametap8bytesLength+".md"
            file_md_path=dest+"/"+letter+"/"+md
            f = open(file_md_path, "wb")
            md_bin=bytearray(md_software,'ascii')
            f.write(md_bin)
            f.close()



            f = open(destetc+"/"+letter+"/"+filenametap8bytesLength+".db", "wb")
            f.write(DecimalToBinary(version_bin))
            f.write(DecimalToBinary(rombasic11))
            f.write(KeyboardMatrix(fire2_joy))
            f.write(KeyboardMatrix(fire3_joy))            
            f.write(KeyboardMatrix(down_joy))
            f.write(KeyboardMatrix(right_joy))
            f.write(KeyboardMatrix(left_joy))
            f.write(KeyboardMatrix(fire1_joy))
            f.write(KeyboardMatrix(up_joy))

            f.write(DecimalToBinary(len(name_software)))
            name_software_bin=bytearray(name_software,'ascii')
            name_software_bin.append(0x00)
            f.write(name_software_bin)
#            
            f.close()
            count=count+1

            # main db
            print(name_software)
            addSoftware=filenametap8bytesLength+';'+name_software+'\0'
            basic_main_db_str=basic_main_db_str+addSoftware
            lenAddSoftware+=len(addSoftware)
            
            #listeconcat.append(3j)
            main_db_table_software.append(lenAddSoftware.to_bytes(2, 'little'))

        #exit
f = open(destetc+"/"+basic_main_db, "wb")
f.write(DecimalToBinary(version_bin))
f.write(bytearray(basic_main_db_str,'ascii'))
EOF=0xFF
f.write(DecimalToBinary(EOF))
f.close()
EOF=0xFF
print(main_db_table_software)
# indexed
f = open(destetc+"/"+basic_main_db_indexed, "wb")
f.write(DecimalToBinary(version_bin))
f.write(bytearray(basic_main_db_str,'ascii'))

#f.write(DecimalToBinary(EOF))
##for item in main_db_table_software:
    #f.write(item)

f.write(DecimalToBinary(EOF))

#print("Number of software : "+count)

#endof file : $FF


