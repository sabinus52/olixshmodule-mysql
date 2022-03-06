# olixshmodule-mysql
Module for oliXsh : Management of MyQSL server


**INFO** : La plupart des paramètres peuvent être configurés dans le fichier */etc/olixsh/mysql.conf* ou via la commande *setcfg*


Pour réaliser une sauvegarde ou une restauration d'une base de données depuis un containeur Docker MySQL ou MariaDB, il suffit d'utiliser la paramètre `dock`

### Test de connexion au serveur MySQL

Command : `olixsh mysql check [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>] [--dock=<container>]`

- `--host=<host>` : Host du serveur MySQL
- `--port=3306` : Port du serveur MySQL
- `--user=<user>` : Utilisateur de connexion au serveur MySQL
- `--pass=<password>` : Mot de passe du serveur MySQL
- `--dock=<container>` : Nom du containeur Docker MySQL ou MariaDB

Ces paramètres surchargent celles saisies lors de la commande **init** situées dans */etc/olixsh/mysql.conf*



### Dump d'une base de données MySQL

Command : `olixsh mysql dump <base> <dump_file> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>] [--dock=<container>]`

- `base` : Nom de la base à sauvegarder
- `dump_file` : Emplacement et nom du fichier du dump de la base

Exemple :
~~~ bash
# Sauvegarde en utilisant les paramètres de connexion définis dans le fichier /etc/olixsh/mysql.conf
olixsh mysql dump toto /tmp/toto.sql
# Sauvegarde en utilisant l'utilisateur titi et le mot de passe 12345
olixsh mysql dump toto /tmp/toto.sql --user=titi --password=12345
# Sauvegarde de la base toto à travers le containeur casimir
olixsh mysql dump toto /tmp/toto.sql --dock=casimir 
~~~


### Restauration d'une base de données MySQL

Command : `olixsh mysql restore <dump_file> <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>] [--dock=<container>]`

- `dump_file` : Emplacement et nom du fichier à restaurer
- `base` : Nom de la base à restaurer

Exemple :
~~~ bash
# Restauration en utilisant les paramètres de connexion définis dans le fichier /etc/olixsh/mysql.conf
olixsh mysql restore /tmp/toto.sql toto
# Restauration en utilisant l'utilisateur titi et le mot de passe 12345
olixsh mysql restore /tmp/toto.sql toto --user=titi --password=12345
# Restauration de la base toto à travers le containeur casimir
olixsh mysql restore /tmp/toto.sql toto --dock=casimir 
~~~


### Création d'une base de données MySQL

Command : `olixsh mysql create <base> <owner> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à créer
- `owner` : Nom du propriétaire de la base (s'il n'existe pas, il sera créé)



### Suppression d'une base de données MySQL

Command : `olixsh mysql drop <base> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base` : Nom de la base à supprimer


### Copie d'une base de données MySQL

Fait une copie d'une base de données vers une autre base sur le même serveur MySQL

Command : `olixsh mysql copy <base_source> <base_destination> [--host=<host>] [--port=3306] [--user=<user>] [--pass=<password>]`

- `base_source` : Nom de la base à copier
- `base_destination` : Nom de la base à coller



### Synchronisation d'une base de données MySQL

Fait une copie d'une base de données d'un serveur distant
vers une base sur le serveur MySQL local défini dans */etc/olixsh/mysql.conf*

Command : `olixsh mysql sync <user@host[:port]> <base_source> <base_destination>`

- `user@host[:port]` : Info de connexion au serveur MySQL distant
- `base_source` : Nom de la base de source du serveur distant
- `base_destination` : Nom de la base de destination à coller
