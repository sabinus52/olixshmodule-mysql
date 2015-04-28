###
# Module de la gestion des bases MySQL
# ==============================================================================
# OLIX_MODULE_MYSQL_USER     : Nom de l'utilisateur MySQL
# OLIX_MODULE_MYSQL_PASSWORD : Mot de passe de l'utilisateur
# ------------------------------------------------------------------------------
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="mysql"


###
# Retourne la liste des modules requis
##
olixmod_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmod_require_binary()
{
    echo -e "mysql mysqldump"
}


###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_mysql__olixmod_usage ()"

    source modules/mysql/lib/usage.lib.sh
    module_mysql_usage_main
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_mysql__olixmod_list ($@)"

    config_loadConfigQuietModule "${OLIX_MODULE_NAME}"
    if [[ $? -ne 0 ]]; then
        echo -n ""
        return 0
    fi
    if [[ -z ${OLIX_MODULE_MYSQL_PASSWORD} ]]; then
        echo -n ""
        return 0
    fi

    source modules/mysql/lib/mysql.lib.sh
    module_mysql_getListDatabases
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_mysql__olixmod_init (null)"
    ubuntu_action__init $@
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_mysql__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    if ! type "mysql_action__$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi

    # Librairies necessaires
    source lib/stdin.lib.sh
    source lib/filesystem.lib.sh
    source modules/mysql/lib/mysql.lib.sh
    source modules/mysql/lib/usage.lib.sh

    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    shift
    mysql_action__$ACTION $@
}


###
# Initialisation du module en créant le fichier de configuration
##
function mysql_action__init()
{
    logger_debug "mysql_action__init ($@)"

    source modules/mysql/mysql-init.sh
    mysql_init__main $@

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Fait un dump d'une base de données
##
function mysql_action__dump()
{
    logger_debug "mysql_action__dump ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_dump && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_dump && core_exit 0

    # Vérifie les paramètres
    module_mysql_isBaseExists "$1"
    [[ $? -ne 0 ]] && logger_error "La base '$1' n'existe pas"
    filesystem_isCreateFile "$2"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le fichier '$2'"
    
    module_mysql_dumpDatabase $1 $2
    [[ $? -ne 0 ]] && logger_error "Echec du dump"

    [[ $? -eq 0 ]] && echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Fait une restauration d'un dump
##
function mysql_action__restore()
{
    logger_debug "mysql_action__restore ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_restore && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_restore && core_exit 0

    # Vérifie les paramètres
    [[ ! -r $1 ]] && logger_error "Le fichier '$1' est absent ou inaccessible"
    module_mysql_isBaseExists "$2"
    [[ $? -ne 0 ]] && logger_error "La base '$2' n'existe pas"
    
    module_mysql_restoreDatabase $1 $2
    [[ $? -ne 0 ]] && logger_error "Echec de la restauration"

    [[ $? -eq 0 ]] && echo -e "${Cvert}Action terminée avec succès${CVOID}"
}
