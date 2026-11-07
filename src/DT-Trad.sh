#!/bin/bash
# Script Name: DT-Trad.sh
# Description: Opérations GIT pour une traduction locale
# Version: 3.0
# Author: Manuel PINTOR / Jean-Pierre Verrue
# Date: 2026-11-07
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
currDate=`date +"%y%m%d%H%M"`

# Initialisation des variables paramétrables
source $scriptDir/DT-preTrad.sh

gitBranchPrefix="${gitBranch}"

# test si la commande git existe sur le système
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1

# Check si le dossier darktable existe déjà dans le dossier de base
# et le renomme si c'est c'est déjà un clone local de darktable.org
if [ -e "$localBaseFolder/$darktable" ]; 
then
    echo "Un dossier $darktable existe déjà dans $localBaseFolder."
    echo "Si ce dossier est un clone local de darktable.org, il sera utilisé et renommé."
    read -p "Est-ce un clone local de darktable.org ? [o/N] " -n 1 -r repoExisting ; echo
    if [[ $repoExisting =~ ^[YyOo]$ ]]
    then
        echo "Ce dépôt est renommé $dtTradFolder..."
        mv "$localBaseFolder/$darktable" "$localBaseFolder/$dtTradFolder"
    fi
fi

# Si 1ère exécution, clone darktable et renomme le dossier en $dtTtradFolder et s'y déplace
# puis initialise la config git 
if [ ! -e "$localBaseFolder/$dtTradFolder" ]; 
then 
    echo "Initialisation du dépôt local à partir de darktable.org..."
    cd "$localBaseFolder"
    git clone "$originRepo"
    mv "$darktable" "$dtTradFolder" && cd "$dtTradFolder"
    git config user.name $gitUser
    git config user.email $gitEmail
    git remote add upstream "$upstreamRepo"
    gitBranch="${gitBranchPrefix}_$currDate"
else

#   sinon direction le dossier du dépôt local
    cd "$localBaseFolder/$dtTradFolder"

    # Verification si une branche personnelle existe déjà :
    # Si tel est le cas, demander s'il faut l'utiliser ou non
    # S'il ne faut pas l'utiliser, demande s'il faut la supprimer ou non
    # Sinon détermine le nom de la nouvelle branche

    currBranch="`git branch --merged | grep "* $gitBranchPrefix" | awk -F"* " '{ print $2 }' | xargs`"
    if [ ! -z $currBranch ]; 
    then
	echo "Une branche nommé $currBranch existe."
        read -p "Doit-elle être utilisée ? [o/N] " -n 1 -r useExistingBranch ; echo
    	if [[ $useExistingBranch =~ ^[YyOo]$ ]]
    	then
            gitBranch="$currBranch" 
	else
            gitBranch="${gitBranchPrefix}_$currDate"

            read -p "Doit-elle être supprimée ? [o/N] " -n 1 -r delExistingBranch ; echo
    	    if [[ $delExistingBranch =~ ^[YyOo]$ ]]
            then
		git switch master
                git branch -D "$currBranch"
	    else
	    	echo "OK, il faudra penser à la gérer ultérieurement..."
    	    fi
    	fi
    else
        gitBranch="${gitBranchPrefix}_$currDate"
    fi

    if [ "$gitBranch" != "$currBranch" ]; then git branch "$gitBranch"; fi

    echo "Récupération du dépôt darktable.org..." 
    git switch master
    git pull origin master
fi

git switch "$gitBranch"

# prêt à traduire 
# si poedit est installé sur la machine  
# * force poedit po/fr.po  (si poedit est sur la machine)
# * et propose de pusher la banche en quittant poedit
if [ ! -x "$(command -v poedit)" ];
then
    echo "poedit n'est pas installé sur cette machine !"
    echo
    echo "Ne pas oublier de passer la commande suivante pour envoyer sur le dépôt $dtTradFolder :" 
    echo "./DT-PosTrad.sh"
    exit 2
fi

poedit "$localBaseFolder/$dtTradFolder/po/fr.po" > /dev/null 2>&1

# Suite du processus de traduction 
source $scriptDir/DT-posTrad.sh

exit 0
