#!/bin/bash
# Script Name: DT-posTrad.sh
# Description: Opérations GIT suivant une traduction locale
# Version: 2.0
# Author: Manuel PINTOR
# Date: 2026-11-07
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# test git command exists on system
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1

# scriptDir       : dossier dans lequel est ce script (et DT-posTrad.sh)
# dtTradFolder	  : nom du dossier local de traduction de darktable
# localBaseFolder : racine du dossier local de traduction de sarktable
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dtTradFolder="DT-trad-FR"

# Initialisation des variables paramétrables
source $scriptDir/DT-preTrad.sh

gitBranchPrefix="${gitBranch}"

# On se positionne sur le dépôt local
cd "$localBaseFolder/$dtTradFolder"

# Récupération de la banche git actuelle
currBranch="`git branch --merged | grep "* $gitBranchPrefix" | awk -F"* " '{ print $2 }' | xargs`"

# Si elle n'existe pas, il n'y a rien à pusher
# Sinon, on demande s'il faut l'envoyer
if [ -z $currBranch ];
then
    echo "Aucune branche locale n'est identifiée !"
    echo "Il n'y a rien à envoyer sur $dtTradFolder."
else
    echo
    read -p "OK pour envoyer la branche $currBranch sur github $dtTradFolder ? [o/N] " -n 1 -r sendBranch ; echo    
    if [[ $sendBranch =~ ^[YyOo]$ ]]
    then
        git add .

#       Saisie du message de commit 
        read -p "Message de commit ? " -r messageCommit ; echo 
    	git commit -m "$messageCommit"

        git push upstream "$currBranch"

	echo
        read -p "La branche locale $currBranch doit-elle à présent être supprimée ? [o/N] " -n 1 -r delCurrBranch ; echo    
        if [[ $delCurrBranch =~ ^[YyOo]$ ]]
	then
		git switch master
		git branch -D "$currBranch"
	fi

        echo
        echo "! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !"
	echo 
        echo "À présent, merci de prévenir de ce push les autres traducteurs sur le groupe Signal !"
	echo 
        echo "Cela leur permettra de ne pas perdre leurs éventuelles traductions des mêmes parties..."
        echo "par une PR un peu trop précoce."
    else
	echo 
        echo "La branche peut être pushée à tout moment en éxécutant le script $scriptDir/DT-posTrad.sh"
    fi
fi    

exit 0



