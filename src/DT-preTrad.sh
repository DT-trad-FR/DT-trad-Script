#!/bin/bash
# Script Name: DT-preTrad.sh
# Description: Initilalisation des variables git paramétrables
# Version: 1.0
# Author: Manuel PINTOR 
# Date: 2026-10-30
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# localBaseFolder : racine locale du clone, créé si inexistant. 
# 		    Ce n'est PAS le répertoire du clone lui-même, mais le niveau au dessus, le dossier du clone darktable étant créé par git clone
# gitUser    	  : username sur github
# gitEmail        : mail sur github
# gitBranch	  : nom de la branche perso de la forme "Br_<pseudo>"

localBaseFolder="path"		# chemin d'accès au dossier de base du clone, SANS le dossier nommé darktable. C'est dans ce dossier qu'est cloné darktable
                          # la syntaxe de ce chemin ne doit pas comprendre la ~ et doit rester encadrée de ".
gitUser="GitHub username"	# tel que défini dans GitHub
gitEmail="GitHub email"		# tel que défini dans GitHub
gitBranch="BR_pseudo" 		# remplacer "pseudo" par un pseudo perso et laisser le préfixe BR_
