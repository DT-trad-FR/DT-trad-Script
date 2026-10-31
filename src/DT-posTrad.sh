#!/bin/bash
# Script Name: DT-posTrad.sh
# Description: Opérations GIT suivant une traduction locale
# Version: 1.0
# Author: Manuel PINTOR
# Date: 2026-10-29
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# scriptDir       : dossier dans lequel est ce script (et DT-posTrad.sh)
# dtTradFolder	  : nom du dossier local de traduction de darktable
# localBaseFolder : racine du dossier local de traduction de sarktable
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dtTradFolder="DT-trad-FR"
localBaseFolder="/media/shared/Photos"
cd "$localBaseFolder/$dtTradFolder"

# Initialisation des variables paramétrables
source $scriptDir/DT-preTrad.sh

# test git command exists on system
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1

echo
read -p "OK pour envoyer la branche $gitBranch sur github $dtTradFolder ? [o/N] " -n 1 -r sendBranch
echo    # nouvelle ligne
if [[ $sendBranch =~ ^[YyOo]$ ]]
then
    git add .

#   Saisie du message de commit 
    read -p "Message de commit ? " -r messageCommit
    echo 
    git commit -m "$messageCommit"

    git push upstream "$gitBranch"

else
    echo "La branche peut être pushée à tout moment en éxécutant le script $scriptDir/DT-posTrad.sh"
fi
    
exit 0



