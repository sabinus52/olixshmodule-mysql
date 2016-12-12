###
# Copie d'une base de données vers une autre
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
if [[ -z $OLIX_MODULE_MYSQL_SOURCE_BASE ]]; then
    Module.execute.usage "copy"
    critical "Nom de la base source manquante"
fi
if [[ -z $OLIX_MODULE_MYSQL_BASE ]]; then
    Module.execute.usage "copy"
    critical "Nom de la base destination manquante"
fi

# Si la base source existe
Mysql.base.exists $OLIX_MODULE_MYSQL_SOURCE_BASE
[[ $? -ne 0 ]] && critical "La base '${OLIX_MODULE_MYSQL_SOURCE_BASE}' n'existe pas"

# Si la base destination existe -> suppression
if Mysql.base.exists ${OLIX_MODULE_MYSQL_BASE}; then
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
info "Copie de la base '${OLIX_MODULE_MYSQL_SOURCE_BASE}' vers la base '${OLIX_MODULE_MYSQL_BASE}'"

# Création de la nouvelle base
Mysql.base.create $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "Echec de la création de la base '${OLIX_MODULE_MYSQL_BASE}'"

# Copie
Mysql.action.copy $OLIX_MODULE_MYSQL_SOURCE_BASE $OLIX_MODULE_MYSQL_BASE
[[ $? -ne 0 ]] && critical "Echec de la copie de '${OLIX_MODULE_MYSQL_SOURCE_BASE}' vers '${OLIX_MODULE_MYSQL_BASE}'"


###
# FIN
##
echo -e "${CVERT}La base ${CCYAN}${OLIX_MODULE_MYSQL_BASE}${CVERT} a été copié depuis la base ${CCYAN}${OLIX_MODULE_MYSQL_SOURCE_BASE}${CVOID}"
