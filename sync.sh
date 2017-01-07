###
# Synchronisation d'une base de données depuis un serveur MySQL distant
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Vérification des paramètres
##
if [[ -z $OLIX_MODULE_MYSQL_SOURCE_HOST ]]; then
    Module.execute.usage "sync"
    critical "Nom du serveur distant manquant"
fi
if [[ -z $OLIX_MODULE_MYSQL_SOURCE_BASE ]]; then
    Module.execute.usage "sync"
    critical "Nom de la base source manquante"
fi
if [[ -z $OLIX_MODULE_MYSQL_BASE ]]; then
    Module.execute.usage "sync"
    critical "Nom de la base destination manquante"
fi


###
# Récupération des infos de connexion de la source
##
OLIX_MODULE_MYSQL_SOURCE_USER=$(String.connection.user $OLIX_MODULE_MYSQL_SOURCE_HOST)
[[ -z $OLIX_MODULE_MYSQL_SOURCE_USER ]] && OLIX_MODULE_MYSQL_SOURCE_USER="root"
OLIX_MODULE_MYSQL_SOURCE_PORT=$(String.connection.port $OLIX_MODULE_MYSQL_SOURCE_HOST)
[[ -z $OLIX_MODULE_MYSQL_SOURCE_PORT ]] && OLIX_MODULE_MYSQL_SOURCE_PORT="3306"
OLIX_MODULE_MYSQL_SOURCE_HOST=$(String.connection.host $OLIX_MODULE_MYSQL_SOURCE_HOST)
Read.password "Mot de passe de connexion au serveur MySQL (${OLIX_MODULE_MYSQL_SOURCE_HOST}) en tant que ${OLIX_MODULE_MYSQL_SOURCE_USER}"
OLIX_MODULE_MYSQL_SOURCE_PASS=$OLIX_FUNCTION_RETURN


###
# Vérification du serveur source
## 
Mysql.server.check "$OLIX_MODULE_MYSQL_SOURCE_HOST" "$OLIX_MODULE_MYSQL_SOURCE_PORT" "$OLIX_MODULE_MYSQL_SOURCE_USER" "$OLIX_MODULE_MYSQL_SOURCE_PASS"
[[ $? -ne 0 ]] && critical "Echec de connexion au serveur MySQL source ${OLIX_MODULE_MYSQL_SOURCE_USER}@${OLIX_MODULE_MYSQL_SOURCE_HOST}:${OLIX_MODULE_MYSQL_SOURCE_PORT}"
Mysql.base.exists $OLIX_MODULE_MYSQL_SOURCE_BASE $OLIX_MODULE_MYSQL_SOURCE_HOST $OLIX_MODULE_MYSQL_SOURCE_PORT $OLIX_MODULE_MYSQL_SOURCE_USER $OLIX_MODULE_MYSQL_SOURCE_PASS
[[ $? -ne 0 ]] && critical "La base source '${OLIX_MODULE_MYSQL_SOURCE_BASE}' n'existe pas"


###
# Si la base destination existe -> suppression
##
if Mysql.base.exists $OLIX_MODULE_MYSQL_BASE; then
    # Avertissement
    echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CJAUNE} et son contenu${CVOID}"
    Read.confirm "Confirmer" false
    [[ $OLIX_FUNCTION_RETURN == false ]] && return
    Mysql.base.drop $OLIX_MODULE_MYSQL_BASE
    [[ $? -ne 0 ]] && critical "Echec de la suppression de la base '${OLIX_MODULE_MYSQL_BASE}'"
fi


###
# Traitement
##
info "Synchronisation de la base '${OLIX_MODULE_MYSQL_SOURCE_BASE}' (${OLIX_MODULE_MYSQL_SOURCE_USER}@${OLIX_MODULE_MYSQL_SOURCE_HOST}:${OLIX_MODULE_MYSQL_SOURCE_PORT}) vers la base '${OLIX_MODULE_MYSQL_BASE}'"

# Création de la nouvelle base
Mysql.base.create $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "Echec de la création de la base '${OLIX_MODULE_MYSQL_BASE}'"

# Synchronisation
Mysql.action.synchronize \
    "--host=$OLIX_MODULE_MYSQL_SOURCE_HOST --port=$OLIX_MODULE_MYSQL_SOURCE_PORT --user=$OLIX_MODULE_MYSQL_SOURCE_USER --password=$OLIX_MODULE_MYSQL_SOURCE_PASS" \
    "$OLIX_MODULE_MYSQL_SOURCE_BASE" \
    "--host=$OLIX_MODULE_MYSQL_HOST --port=$OLIX_MODULE_MYSQL_PORT --user=$OLIX_MODULE_MYSQL_USER --password=$OLIX_MODULE_MYSQL_PASS" \
    "$OLIX_MODULE_MYSQL_BASE"
[[ $? -ne 0 ]] && critical "Echec de la synchronisation de '${OLIX_MODULE_MYSQL_BASE}' depuis '${OLIX_MODULE_MYSQL_SOURCE_BASE}' (${OLIX_MODULE_MYSQL_SOURCE_USER}@${OLIX_MODULE_MYSQL_SOURCE_HOST}:${OLIX_MODULE_MYSQL_SOURCE_PORT})"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CVERT} a été synchronisée avec succès depuis la base ${CCYAN}${OLIX_MODULE_MYSQL_SOURCE_BASE} (${OLIX_MODULE_MYSQL_SOURCE_USER}@${OLIX_MODULE_MYSQL_SOURCE_HOST}:${OLIX_MODULE_MYSQL_SOURCE_PORT})${CVOID}"
