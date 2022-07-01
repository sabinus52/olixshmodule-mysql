###
# Réalisation d'un dump d'une base de données MySQL
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
if [[ -z $OLIX_MODULE_MYSQL_BASE ]]; then
    Module.execute.usage "dump"
    critical "Nom de la base à dumper manquante"
fi
if [[ -z $OLIX_MODULE_MYSQL_DUMP ]]; then
    Module.execute.usage "dump"
    critical "Nom du fichier dump manquant"
fi

# Si la base existe
if [[ -z ${OLIX_MODULE_MYSQL_DOCK} ]]; then
    Mysql.base.exists $OLIX_MODULE_MYSQL_BASE
else
    Mysql.docker.base.exists "${OLIX_MODULE_MYSQL_DOCK}" "$OLIX_MODULE_MYSQL_BASE"
fi
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_MYSQL_BASE}' n'existe pas"

# Si le dump peut être créé
File.created $OLIX_MODULE_MYSQL_DUMP
[[ $? -ne 0 ]] && critical "Impossible de créer le fichier '${OLIX_MODULE_MYSQL_DUMP}'"


###
# Traitement
##
info "Dump de la base '${OLIX_MODULE_MYSQL_BASE}' vers le fichier '${OLIX_MODULE_MYSQL_DUMP}'"

if [[ -z ${OLIX_MODULE_MYSQL_DOCK} ]]; then

    # Mode server
    Mysql.base.dump $OLIX_MODULE_MYSQL_BASE $OLIX_MODULE_MYSQL_DUMP "$OLIX_MODULE_MYSQL_EXTRAOPTS"
    [[ $? -ne 0 ]] && critical "Echec du dump de la base '${OLIX_MODULE_MYSQL_BASE}' vers le fichier '${OLIX_MODULE_MYSQL_DUMP}'"

else

    # Mode docker
    Mysql.docker.base.dump ${OLIX_MODULE_MYSQL_DOCK} ${OLIX_MODULE_MYSQL_BASE} ${OLIX_MODULE_MYSQL_DUMP} "$OLIX_MODULE_MYSQL_EXTRAOPTS"
    [[ $? -ne 0 ]] && critical "Echec du dump de la base ${OLIX_MODULE_MYSQL_DOCK}:'${OLIX_MODULE_MYSQL_BASE}' vers le fichier '${OLIX_MODULE_MYSQL_DUMP}'"

fi


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CVERT} a été sauvegardée avec succès dans ${CCYAN}${OLIX_MODULE_MYSQL_DUMP}${CVOID}"
