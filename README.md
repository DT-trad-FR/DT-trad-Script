# DT-trad-Script
Faciliter l'utilisation des dépôt Git darktable.org et  DT-trad-FR à l'aide d'un script
## <ins title="Author: Auteur inconnu" datetime="2026-10-27T16:31:59">Pourquoi ?

</ins>Après pas mal d’essais infructueux, nous avons modifié le workflow. Au lieu d’une liaison bipartite entre le dépôt local et le dépôt DT-trad-FR, nous établissons une liaison tripartite en ajoutant le dépôt principal de darktable. Ainsi, il n’est plus nécessaire de maintenir à jour très strictement le dépôt DT-trad-FR. Voici le diagramme de fonctionnement.

Le principe est d’aller chercher les modifications sources directement à partir du dépôt principal de Darktable, de faire les modifications que l’on souhaite, puis de pousser ces modifs vers le dépôt DT-trad-FR. Une fois ces modifs disponibles sur ce dépôt, elles seront regroupées (rebase) pour pouvoir créer une PR à l’attention de Pascal.

![Schéma](./schéma.png)


Il faut maintenant modifier la configuration du dépôt DT-trad-FR dans le fichier de configuration de git (emplacement : \<dossier du clone\>/.git/config). Toutes ces modifs sont faites dans le script d’utilisation. Elles ne sont données ici qu’à titre d’information.


Il faut ajouter le user et le mail :

```schell
git config user.name $gitUser

git config user.email $gitEmail

Puis l’accès au dépôt Dt-trad-FR :

git remote add upstream git@github.com:DT-trad-FR/darktable.git
```

Voici ce fichier tel qu’il est après les modifications.

```shell
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true

[remote "origin"]
	url = https://github.com/darktable-org/darktable.git
	fetch = +refs/heads/\*:refs/remotes/origin/\*

[branch "master"]
	remote = origin
	merge = refs/heads/master

[user]
	name = foo
	email = [contact@foo.home](mailto:contact@foo.home)

[remote "upstream"]
	url = git@github.com:DT-trad-FR/darktable.git

fetch = +refs/heads/\*:refs/remotes/upstream/\*
```

## Clé ssh

Il est également nécessaire de définir la clé SSH qui sera utilisée pour le push :

1. sur sa machine créer une clé SSH **si pas déjà fait** : 
   `ssh-keygen -t ed25519 -C \<contact@foo.home\>`

2. récupérer la ligne contenue dans le fichier `~/.ssh/id\_ed25519.pub`

3. Sur GitHub, compte DT-trad-FR → Settings → SSH and GPG keys : créer une **New SSH key** 

   1. Title : foo

   2. Key type : Authentication key (valeur par défaut).

   3. Key : la ligne récupérée au point 2 ci-dessus.


## Poedit

À partir de là, il est possible de traduire fr.po avec poedit (activé automatiquement par le script). Puis, de pousser ses modifications vers le dépôt DT-trad-FR.


## Le script

LE script est disponible dans ce dépôt dans le dossier src


Avant de l’utiliser, vous devrez le personnaliser.

Il y a trois variables à modifier aux lignes 25,26 et 27.

localBaseFolder="chemin"	\# to be modified

gitUser="GitHub-user"		\# to be modified

gitEmail="GitHub-user-mail"	\# to be modified


Il enchaîne pour vous les opérations suivantes :

1. Vérification de la présence du logiciel Git.

2. Vérification de la présence du logiciel Poedit.

3. Vérification de la présence d’un dossier darktable, là où vous voulez cloner le dépôt principal de darktable.

4. Si le dépôt DT-trad.FR n’existe pas :

   1. Clonage du dépôt principal de darktable et renommage en  DT-trad-FR.

   2. Modification du fichier config dans le dépôt DT-trad-FR.

5. Si le dépôt existe déjà :

   1. Positionnement sur la branche master

   2. pull du dépôt principal de darktable

6. Création d’une branche de travail

7. lancement de poedit

8. push de la branche de travail vers le dépôt DT-trad-FR

Vous pouvez donc vous appuyer systématiquement sur ce script pour effectuer vos traductions de l’UI.

Ne pas oublier de prévenir le mainteneur du dépôt DT-trad-FR que de nouvelles traductions ont été poussées.


## Maintenance du dépôt DT-trad-FR

### Synchronisation du fork

Comme expliqué, le fork ne doit plus être synchronisé systématiquement puisque la branche master n’est plus utilisée. Néanmoins une mise à jour.
