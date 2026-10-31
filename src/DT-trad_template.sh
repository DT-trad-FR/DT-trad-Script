#!/bin/bash
# Script Name: DT-preTrad.sh
# Description: Opérations GIT précédent une traduction locale
# Version: 1.0
# Author: Manuel PINTOR
# Date: 2026-10-26
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

# localFolder 	: stores the local clone, created if not existing. Note that it is NOT the repo directory but the upper level since darktable directory is created by clone
# gitUser	: username on github
# gitEmail	: mail on github
# currDate 	: the current date in YYMMDDHHMM
# currBranch 	: the name of the user's current branch based on $USER and $currDate
originRepo="https://github.com/darktable-org/darktable.git"
upstreamRepo="https://github.com/DT-trad-FR"
darktable="darktable"
dtTradFolder="DT-trad-FR"
gitUser="foo"
gitEmail="contact@foo.home"
currDate=`date +"%y%m%d%H%M"`
currBranch="$USER-$currDate"

# test git command exists on system
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1


# Clone darktable and rename it in $dtTtradFolder and change directory to it
if [ ! -e "$localFolder/darktable" ]; 
then 
	echo "Initialisation du repo local..."
	git clone "$originRepo"
	mv "$darktable" "$dtTradFolder" && cd "$dtTradFolder"
	git config user.name $gitUser
	git config user.email $gitEmail
	git remote add upstream "$upstreamRepo"
else
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
[ ! -x "$(command -v poedit)" ] && echo "poedit n'est pas installé sur cette machine !" && exit 1

poedit po/fr.po > /dev/null 2>&1

read -p "OK pour envoyer la branche sur github ? " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[YyOo]$ ]]
then
	git push upstream "$currBranch"

else
	echo "Il reste à passer la commande suivante pour envoyer sur le repo DT-trad-FR :"
	echo "git push upstream $currBranch"
fi
exit 0
