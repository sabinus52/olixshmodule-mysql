# olixshmodule-mysql
Module for oliXsh : Management of MyQSL server


### Paramètres obligatoires de configuration du module
OLIX_MODULE_MYSQL_HOST            : Nom du serveur MySQL
OLIX_MODULE_MYSQL_PORT            : Numéro du port MySQL
OLIX_MODULE_MYSQL_USER            : Nom de l'utilisateur MySQL
OLIX_MODULE_MYSQL_PASS            : Mot de passe de l'utilisateur

### Paramètres optionnels de configuration du module
OLIX_MODULE_MYSQL_BACKUP_DIR      : Emplacement des dumps lors de la sauvegarde
OLIX_MODULE_MYSQL_BACKUP_COMPRESS : Format de compression
OLIX_MODULE_MYSQL_BACKUP_PURGE    : Nombre de jours de retention de la sauvegarde
OLIX_MODULE_MYSQL_BACKUP_REPORT   : Format des rapports
OLIX_MODULE_MYSQL_BACKUP_EMAIL    : Email d'envoi de rapport

Ces paramètres peuvent être ajoutés dans le fichier `conf/mysql.conf`