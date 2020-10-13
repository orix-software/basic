[![Build Status](https://travis-ci.org/orix-software/basic.svg?branch=master)](https://travis-ci.org/orix-software/basic)

# Description
BASIC cartridge for Orix with ch376 support

- Based on BASIC v1.1 (Atmos version)
- Patch CSAVE/CLOAD/STORE/RECALL to use ch376 instead of tapes

## Directories
- docs: Documentation
- src : Source files
- original: Original ROM image

## Informations (french)

    0: Hobbit:
        Pas de joysticks
        Signature de la banque: Ok
        Jeu de caractères interne partiellement conservé
        Pas de chargement d'un fichier de xxx.CHS
        doit être à la racine du device (sdcard ou clé usb)
    1: Jeux:
        Joysticks
        Signature de la banque: KO
        Jeu de caractères interne détruit
        Chargement d'un fichier DEFAULT.CHS à la place du jeu de caractères de la ROM
        pas d'initialisation de RND ni de la conf du joystick (doit être éventuellement fait par basic11)
    2: Normale:
        Joystick
        Signature de la banque: OK
        Jeu de caractère interne détruit
        Chargement d'un fichier DEFAULT.CHS à la place du jeu de caractères de la ROM
        Bug IF/THEN/ELSE corrigé
         initialisation d'une configuration par défaut du joystick (et de RND)

    Fire 2 (bit 7) => [Enter]
    Fire 3 (bit 5) => [Esc]
    Down   => [Down_arrow]
    Right  => [Right_arrow]
    Left   => [Left_arrow]
    Fire   => [Space]
    Up     => [Up_arrow]

Joystick:

    Boutons 2 & 3 pris en compte
    Boutons 2 & 3 peuvent être affecté à une touche "normale" ou à une touche "spéciale"
        [SHIFT_L] => $A4
        [SHIFT_R] => $A7
        [CTRL_L] => $A2
        [CTRL_R] => $A0    /!\ Spécifique Oricutron
        [FUNCT]  => $A5

## Joysticks offsets
    $f3: button 2
    $f4: button 3
    $f5: Down
    $f6: Right
    $f7: Left
    $f8: Fire
    $f9: Up

## Db Struct of a software (VERSION 1)
    version of db : 1 byte
    id of the rom : 1 byte
    fire2_joy : 1 byte
    fire3_joy : 1 byte            
    down_joy : 1 byte
    right_joy : 1 byte
    left_joy : 1 byte
    fire1_joy : 1 byte
    up_joy : 1 byte
    length of name_software = 1 byte length 
    name_software_bin = X bytes X equals to previous byte
    end of string : 1 bytes (value : 0)

## DB Struct of main db
    First byte : version of the binary
    KEY (8 byte length max: name of the tape file)
    Name of the tape file (max 255 bytes)
    EOF 0xff

