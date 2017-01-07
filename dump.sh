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
Mysql.base.exists $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_MYSQL_BASE}' n'existe pas"

# Si le dump peut être créé
File.created $OLIX_MODULE_MYSQL_DUMP
[[ $? -ne 0 ]] && critical "Impossible de créer le fichier '${OLIX_MODULE_MYSQL_DUMP}'"


###
# Traitement
##
info "Dump de la base '${OLIX_MODULE_MYSQL_BASE}' vers le fichier '${OLIX_MODULE_MYSQL_DUMP}'"

Mysql.base.dump $OLIX_MODULE_MYSQL_BASE $OLIX_MODULE_MYSQL_DUMP
[[ $? -ne 0 ]] && critical "Echec du dump de la base '${OLIX_MODULE_MYSQL_BASE}' vers le fichier '${OLIX_MODULE_MYSQL_DUMP}'"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CVERT} a été sauvegardée avec succès dans ${CCYAN}${OLIX_MODULE_MYSQL_DUMP}${CVOID}"
