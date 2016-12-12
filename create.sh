###
# Création d'une base de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Affichage de l'aide
##
if [[ -z $OLIX_MODULE_MYSQL_BASE ]]; then
    Module.execute.usage "create"
    critical "Nom de la base à créer manquante"
fi

# Si la base existe
Mysql.base.exists $OLIX_MODULE_MYSQL_BASE
[[ $? -eq 0 ]] && critical "La base '${OLIX_MODULE_MYSQL_BASE}' existe déjà"



###
# Traitement
##
info "Création de la base '${OLIX_MODULE_MYSQL_BASE}'"

Mysql.base.create $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "Echec de la création de la base '${OLIX_MODULE_MYSQL_BASE}'"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CVERT} a été créée avec succès${CVOID}"
