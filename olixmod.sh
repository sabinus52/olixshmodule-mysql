###
# Module de la gestion des bases MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="mysql"

# Valeur par defaut de la configuration principale
OLIX_MODULE_MYSQL_HOST="localhost"
OLIX_MODULE_MYSQL_PORT="3306"
OLIX_MODULE_MYSQL_USER="olix"
OLIX_MODULE_MYSQL_PASS=
# Valeur par defaut de la configuration optionnelle
OLIX_MODULE_MYSQL_BACKUP_DIR="/tmp"
OLIX_MODULE_MYSQL_BACKUP_COMPRESS="GZ"
OLIX_MODULE_MYSQL_BACKUP_PURGE="5"
OLIX_MODULE_MYSQL_BACKUP_REPORT="TEXT"
OLIX_MODULE_MYSQL_BACKUP_EMAIL=


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
    if [[ -z ${OLIX_MODULE_MYSQL_PASS} ]]; then
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
    source modules/mysql/lib/mysql.lib.sh
    source modules/mysql/lib/action.lib.sh
    module_mysql_action_init $@
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

    # Librairies necessaires
    source lib/stdin.lib.sh
    source lib/filesystem.lib.sh
    source lib/file.lib.sh
    source modules/mysql/lib/mysql.lib.sh
    source modules/mysql/lib/usage.lib.sh
    source modules/mysql/lib/action.lib.sh

    if ! type "module_mysql_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    
    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_mysql_usage_$ACTION && core_exit 0

    shift
    module_mysql_usage_getParams $@
    module_mysql_action_$ACTION $@
}
