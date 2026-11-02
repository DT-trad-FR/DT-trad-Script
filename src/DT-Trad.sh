#!/bin/bash
# Script Name: DT-Trad.sh
# Description: Opérations GIT pour une traduction locale
# Version: 3.0
# Author: Manuel PINTOR / Jean-Pierre Verrue
# Date: 2026-10-27
# Licence: GNU GPL v3.0
# Environment: Bash 5.2+

set -e

confFile="$HOME/.config/DT-trad.cfg"

function createConfFile { # Création du fichier de configuration

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

answer="N"
while [ "$answer" != "o" ]
do
    printf "\n%s : Création du fichier de configuration\n" $0
    printf "Chemin d'accès au dossier de base du clone, SANS le dossier nommé darktable.\n"
    printf "C'est dans ce dossier qu'est cloné darktable\n"
    printf "Ce chemin ne doit pas comprendre le caractère '~', utilisez \$HOME si besoin"
    read -p " : " -r localBaseFolder

    printf "Le nom d'utilisateur (pseudo) que vous souhaitez avoir dans Git"
    read -p " : " -r gitUser

    printf "L'adresse mail que vous souhaitez utiliser dans Git"
    read -p " : " -r gitEmail

    printf "Le nom de la branche que vous souhaitez utiliser dans Git.\n"
    printf "Ce nom sera préfixé par \"BR_\""
    read -p " : " -r gitBranch
    gitBranch="BR_$gitBranch"

    printf "\nVous avez saisi :
    Dossier de base   : $localBaseFolder
    Nom d'utilisateur : $gitUser
    Adressz mail      : $gitEmail
    Nom de la branche : $gitBranch\n\n"

    read  -p "Confirmez vous votre saisie ? [o/N] " -n 1 -r answer
done

cat << END-OF-FILE > $confFile
# Fichier de configuration du Script DT-Trad.sh

scriptDir=$scriptDir # dossier dans lequel est ce script (et DT-posTrad.sh)
originRepo="https://github.com/darktable-org/darktable.git" # dépôt darktable.org sur github (source)
upstreamRepo="git@github.com:DT-trad-FR/darktable.git" # dépôt DT-trad-FR sur github (upstream)
darktable="darktable" # nom d'origine du dépôt 
dtTradFolder="DT-trad-FR"  # nom du répertoire de la traduction de darktable

localBaseFolder="$localBaseFolder"	# racine locale du clone, créé si inexistant.
gitUser="$gitUser" # username sur github
gitEmail="$gitEmail" # mail sur github
gitBranch="$gitBranch" # Nom de la branche perso de la forme "Br_<pseudo>"
END-OF-FILE
}

if [ ! -e $confFile ] ; # Il n'y a pas de fichier de configuration, le créer.
then
    createConfFile
fi

source $confFile # Lecture du fichier de configuration

# test si la commande git existe sur le système
[ ! -x "$(command -v git)" ] && echo "git doit être installé sur cette machine !" && exit 1

# Check si le dossier darktable existe déjà dans le dossier de base
# et le renomme si c'est déjà un clone local de darktable.org
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
else

#   sinon récupèrer darktable de darktable.org pour être à jour
    cd "$localBaseFolder/$dtTradFolder"

    # switch sur la branche master et pull l'origin(e) pour ramener les nouveaux fichiers
    git switch master
    git pull origin master
fi

# Crée la branche locale et switche sur celle-ci
if ! git branch --list | grep --silent "$gitBranch" ;
then
    git branch "$gitBranch"
fi
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
