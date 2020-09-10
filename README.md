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
    1: Jeux:
        Joysticks
        Signature de la banque: KO
        Jeu de caractères interne détruit
        Chargement d'un fichier DEFAULT.CHS à la place du jeu de caractères de la ROM
    2: Normale:
        Joystick
        Signature de la banque: OK
        Jeu de caractère interne détruit
        Chargement d'un fichier DEFAULT.CHS à la place du jeu de caractères de la ROM
        Bug IF/THEN/ELSE corrigé
