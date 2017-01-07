###
# Test de la connexion au serveur MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Traitement
##
echo -e "Test de connexion avec ${Ccyan}${OLIX_MODULE_MYSQL_USER}@${OLIX_MODULE_MYSQL_HOST}:${OLIX_MODULE_MYSQL_PORT}${CVOID}"


Mysql.server.check
[[ $? -ne 0 ]] && critical "Echec de connexion au serveur MySQL"

mysql --version


###
# FIN
##
echo -e "${CVERT}Connexion au serveur MySQL réussi${CVOID}"
