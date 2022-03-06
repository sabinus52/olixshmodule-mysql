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
if [[ -z ${OLIX_MODULE_MYSQL_DOCK} ]]; then

    # Mode serveur
    echo -e "Test de connexion avec ${Ccyan}${OLIX_MODULE_MYSQL_USER}@${OLIX_MODULE_MYSQL_HOST}:${OLIX_MODULE_MYSQL_PORT}${CVOID}"

    Mysql.server.check
    [[ $? -ne 0 ]] && critical "Echec de connexion au serveur MySQL"

    mysql --version

else

    # Mode docker
    echo -e "Test de connexion avec le containeur ${Ccyan}${OLIX_MODULE_MYSQL_DOCK}${CVOID}"

    Mysql.docker.check "${OLIX_MODULE_MYSQL_DOCK}"
    [[ $? -ne 0 ]] && critical "Echec de connexion au serveur MySQL"

    docker exec -i ${OLIX_MODULE_MYSQL_DOCK} mysql --version

fi


###
# FIN
##
echo -e "${CVERT}Connexion au serveur MySQL réussi${CVOID}"
