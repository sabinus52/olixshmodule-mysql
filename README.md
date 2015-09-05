# olixshmodule-mysql
Module for oliXsh : Management of MyQSL server



### Initialisation du module

Initialiser le module

Command : `olixsh mysql init [--force]`

Entrer les informations suivantes :
- Host du serveur MySQL local
- Port du serveur MySQL
- Choix d'un utilisateur pour une connexion automatique au serveur
- Choix du mot de passe pour cet utilisateur



### Test de connexion au serveur MySQL

Command : `olixsh mysql check [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `--host=<host>` : Host du serveur MySQL
- `--port=3306` : Port du serveur MySQL
- `--user=<user>` : Utilisateur de connexion au serveur MySQL
- `--pass=<password>` : Mot de passe du serveur MySQL

Ces paramètres surchargent celles saisies lors de la commande **init** situées dans */etc/olixsh/mysql.conf*



### Dump d'une base de données MySQL

Command : `olixsh mysql dump <base> <dump_file> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à sauvegarder
- `dump_file` : Emplacement et nom du fichier du dump de la base



### Restauration d'une base de données MySQL

Command : `olixsh mysql restore <dump_file> <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `dump_file` : Emplacement et nom du fichier à restaurer
- `base` : Nom de la base à restaurer



### Création d'une base de données MySQL

Command : `olixsh mysql create <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à créer



### Suppression d'une base de données MySQL

Command : `olixsh mysql drop <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à supprimer


### Copie d'une base de données MySQL

Fait une copie d'une base de données vers une autre base sur le même serveur MySQL

Command : `olixsh mysql copy <base_source> <base_destination> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base_source` : Nom de la base à copier
- `base_destination` : Nom de la base à coller



### Synchronisation d'une base de données MySQL

Fait une copie d'une base de données d'un serveur distant (saisie en mode interactif)
vers une base sur le serveur MySQL local défini dans */etc/olixsh/mysql.conf*

Command : `olixsh mysql sync <base_destination>`

- `base_destination` : Nom de la base de destination à coller



### Backup des bases d'un serveur MySQL

Réalisation d'une sauvegarde des bases MySQL avec rapport pour des tâches planifiées.

Command : `olixsh mysql backup [bases...] [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>] [--dir=/tmp] [--purge=5] [--gz|--bz2] [--html] [--email=<name@domain.ltd>]

- `base` : Liste des bases à sauvegarder. Si omis, *toutes les bases*
- `--dir=/tmp` : Chemin de stockage des backups. Par defaut */tmp*
- `--purge=5` : Nombre de jours avant la purge des anciens backups. Par défaut *5*
- `--gz` : Compression du dump au format gzip
- `--bz2` : Compression du dump au format bzip2
- `--html` : Rapport au format HTML sinon au format TEXT par défaut
- `--email=name@domain.ltd` : Envoi du rapport à l'adresse *name@domain.ltd*

Ces derniers paramètres peuvent être insérés dans le fichier de configuration */etc/olixsh/mysql.conf* pour éviter de les mettre en paramètres dans la commande :
- `OLIX_MODULE_MYSQL_BACKUP_DIR` : Emplacement des dumps lors de la sauvegarde
- `OLIX_MODULE_MYSQL_BACKUP_COMPRESS` : Format de compression (`GZ`|`BZ2`)
- `OLIX_MODULE_MYSQL_BACKUP_PURGE` : Nombre de jours de retention de la sauvegarde
- `OLIX_MODULE_MYSQL_BACKUP_REPORT` : Format des rapports (`TEXT`|`HTML`)
- `OLIX_MODULE_MYSQL_BACKUP_EMAIL` : Email d'envoi du rapport

