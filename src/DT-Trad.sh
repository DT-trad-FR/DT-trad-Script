#!/bin/bash
# Script Name: DT-Trad.sh
# Description: Opérations GIT pour une traduction locale
# Version: 2.0
# Author: Manuel PINTOR / Jean-Pierre Verrue
# Date: 2026-10-27
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# scriptDir	  : dossier dans lequel est ce script (et DT-posTrad.sh)
# originRepo   	  : dépôt darktable.org sur github (source)
# upstreamRepo    : dépôt DT-trad-FR sur github (upstream)
# darktable	  : nom d'origine du dépôt 
# dtTradFolder	  : nom du répertoire de la traduction de darktable
# currDate        : date courante au format YYMMDD

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
originRepo="https://github.com/darktable-org/darktable.git"
upstreamRepo="git@github.com:DT-trad-FR/darktable.git"
darktable="darktable"
dtTradFolder="DT-trad-FR"
currDate=`date +"%y%m%d"`

# Initialisation des variables paramétrables
source $scriptDir/DT-preTrad.sh

# test si la commande git existe sur le système
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1

# Check si le dossier darktable existe déjà dans le dossier de base
# et le renomme si c'est c'est déjà un clone local de darktable.org
if [ -e "$localBaseFolder/$darktable" ]; 
then
    echo "Un dossier $darktable existe déjà dans $localBaseFolder."
    echo "Si ce dossier est un clone local de darktable.org, il sera utilisé et renommé."
    read -p "Est-ce un clone local de darktable.org ? [o/N] " -n 1 -r repoExisting
    echo    # nouvelle ligne
    if [[ $repoXisting =~ ^[YyOo]$ ]]
    then
        echo "Ce dépôt est renommé $dtTradFolder..."
        mv "$localBaseFolder/$darktable" "$localBaseFolder/$dtTradFolder"
    fi
fi

# Si 1ère exécution, clone darktable et renomme le dossier en $dtTtradFolder puis s'y déplace
# puis initialise la config git
if [ ! -e "$localBaseFolder/$dtTradFolder" ]; 
then 
    echo "Initialisation du dépôt local..."
    cd "$localBaseFolder"
    git clone "$originRepo"
    mv "$darktable" "$dtTradFolder" && cd "$dtTradFolder"
    git config user.name $gitUser
    git config user.email $gitEmail
    git remote add upstream "$upstreamRepo"
    git branch "$gitBranch"
else

#   sinon récupèrer darktable de darktable.org pour être à jour
    cd "$localBaseFolder/$dtTradFolder"

    # switch sur la branche master et pull l'origin(e) pour ramener les nouveaux fichiers
    git switch master
    git pull origin master
fi

# Switch sur la branche locale courante
git switch "$gitBranch"

# prêt à traduire 
# si poedit est installé sur la machine  
# * force poedit po/fr.po  (si poedit est sur la machine)
# * et propose de pusher la banche en quittant poedit
if [ ! -x "$(command -v poedit)" ];
then
    echo "poedit n'est pas installé sur cette machine !"
    echo "Ne pas oublier de passer la commande suivante pour envoyer sur le dépôt $dtTradFolder :" 
    echo "./DT-PosTrad.sh"
    exit 1
fi

poedit po/fr.po > /dev/null 2>&1

# Suite du processus de traduction 
source $scriptDir/DT-posTrad.sh

exit 0
