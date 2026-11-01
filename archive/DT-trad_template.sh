#!/bin/bash
# Script Name: DT-preTrad.sh
# Description: Opérations GIT précédent une traduction locale
# Version: 1.0
# Author: Manuel PINTOR / Jean-Pierre Verrue
# Date: 2026-10-27
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# originRepo   	  : darktable.org repo on github (source)
# upstreamRepo    : DT-trad-FR repo on github (upstream)
# darktable	  : origin repo name
# dtTradFolder	  : darktable translation folder name
# localBaseFolder : stores the local clone, created if not existing. Note that it is NOT the repo directory but the upper level since darktable directory is created by clone
# gitUser    : username on github
# gitEmail    : mail on github
# currDate     : the current date in YYMMDDHHMM
# currBranch     : the name of the user's current branch based on $USER and $currDate
originRepo="https://github.com/darktable-org/darktable.git"
upstreamRepo="git@github.com:DT-trad-FR/darktable.git"
darktable="darktable"
dtTradFolder="DT-trad-FR"
localBaseFolder="chemin"	# to be modified
gitUser="GitHub-user"		# to be modified
gitEmail="GitHub-user-mail"	# to be modified
currDate=`date +"%y%m%d%H%M"`
currBranch="$USER-$currDate"

# test git command exists on system
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1
# test poedit command exists on system
[ ! -x "$(command -v poedit)" ] && echo "poedit n'est pas installé sur cette machine !" && exit 1


# Check if a darktable directory already exists in the local base folder
# and rename it in case it's already a local darktable.org clone
if [ -e "$localBaseFolder/$darktable" ]; 
then
    echo "Un dossier $darktable existe déjà dans $localBaseFolder"
    read -p "Est-ce un dépôt local clone de darktable.org ? [o/N] " -n 1 -r repoExisting
    echo    # move to a new line
    if [[ $repoXisting =~ ^[YyOo]$ ]]
    then
        echo "Ce dépôt va être renommé DT-trad-FR..."
        mv "$localBaseFolder/$darktable" "$localBaseFolder/$dtTradFolder"
    fi
fi


# Clone darktable and rename it in $dtTtradFolder and change directory to it
if [ ! -e "$localBaseFolder/$dtTradFolder" ]; 
then 
    echo "Initialisation du repo local..."
    cd "$localBaseFolder"
    git clone "$originRepo"
    mv "$darktable" "$dtTradFolder" && cd "$dtTradFolder"
    git config user.name $gitUser
    git config user.email $gitEmail
    git remote add upstream "$upstreamRepo"
else
    cd "$localBaseFolder/$dtTradFolder"
    # switch to master branch and pull from origin to get new files
    git switch master
    git pull origin master
fi

# create and switch to current local branch
git branch "$currBranch" && git switch "$currBranch"

# ready to edit 
# at this stage we could 
# * force poedit po/fr.po 
# * and propose to push the current branch after exiting poedit

poedit po/fr.po > /dev/null 2>&1

read -p "OK pour envoyer la branche $currBranch sur github ? [o/N] " -n 1 -r sendBranch
echo    # move to a new line
if [[ $sendBranch =~ ^[YyOo]$ ]]
then
    git push upstream "$currBranch"

else
    echo "Il reste à passer la commande suivante pour envoyer sur le repo DT-trad-FR :"
    echo "git push upstream $currBranch"
fi
exit 0
