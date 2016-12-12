###
# Restauration d'un dump d'une base de données MySQL
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
if [[ -z $OLIX_MODULE_MYSQL_DUMP ]]; then
    Module.execute.usage "restore"
    critical "Nom du fichier dump manquant"
fi
if [[ -z $OLIX_MODULE_MYSQL_BASE ]]; then
    Module.execute.usage "restore"
    critical "Nom de la base à restaurer manquante"
fi

# Si le dump existe
File.exists $OLIX_MODULE_MYSQL_DUMP
[[ $? -ne 0 ]] && critical "Le dump '${OLIX_MODULE_MYSQL_DUMP}' est absent ou inaccessible"

# Si la base existe
Mysql.base.exists $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_MYSQL_BASE}' n'existe pas"


###
# Avertissement
##
echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base '${OLIX_MODULE_MYSQL_BASE}' et son contenu${CVOID}"
Read.confirm "Confirmer" false
[[ $OLIX_FUNCTION_RETURN == false ]] && return


###
# Traitement
##
info "Restauration du dump '${OLIX_MODULE_MYSQL_DUMP}' vers la base '${OLIX_MODULE_MYSQL_BASE}'"

Mysql.base.restore $OLIX_MODULE_MYSQL_BASE $OLIX_MODULE_MYSQL_DUMP
[[ $? -ne 0 ]] && critical "Echec de la restauration du dump '${OLIX_MODULE_MYSQL_DUMP}' vers la base '${OLIX_MODULE_MYSQL_BASE}'"



###
# FIN
##
echo -e "${Cvert}La base ${Ccyan}${OLIX_MODULE_MYSQL_BASE}${Cvert} a été restaurée avec succès depuis ${Ccyan}${OLIX_MODULE_MYSQL_DUMP}${CVOID}"
