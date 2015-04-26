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
    stdout_printVersion
    echo
    echo -e "Gestion des bases de données MySQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}[ACTION]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} dump    ${CVOID}  : Fait un dump d'une base de données"
    echo -e "${Cjaune} restore ${CVOID}  : Restauration d'une base de données"
    echo -e "${Cjaune} sync    ${CVOID}  : Synchronisation d'une base à partir d'un serveur distant"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_mysql__olixmod_list ($@)"
    echo
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
    source modules/mysql/lib/mysql.lib.sh

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
