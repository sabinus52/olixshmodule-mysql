###
# Module de la gestion des bases MySQL
# ==============================================================================
# OLIX_MODULE_MYSQL_USER     : Nom de l'utilisateur MySQL
# OLIX_MODULE_MYSQL_PASS : Mot de passe de l'utilisateur
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

    module_mysql_usage_getParams $@

    # Vérifie les paramètres
    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM1}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"
    filesystem_isCreateFile "${OLIX_MODULE_MYSQL_PARAM2}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"
    
    module_mysql_dumpDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec du dump"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
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

    module_mysql_usage_getParams $@

    # Vérifie les paramètres
    [[ ! -r ${OLIX_MODULE_MYSQL_PARAM1} ]] && logger_error "Le fichier '${OLIX_MODULE_MYSQL_PARAM1}' est absent ou inaccessible"
    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM2}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM2}' n'existe pas"
    
    module_mysql_restoreDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec de la restauration"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Crée une base de données
##
function mysql_action__create()
{
    logger_debug "mysql_action__create ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_create && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_create && core_exit 0

    module_mysql_usage_getParams $@
    
    module_mysql_createDatabase ${OLIX_MODULE_MYSQL_PARAM1}
    [[ $? -ne 0 ]] && logger_error "Echec de la création de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Supprime une base de données
##
function mysql_action__drop()
{
    logger_debug "mysql_action__drop ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_drop && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_drop && core_exit 0

    module_mysql_usage_getParams $@

    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM1}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"

    echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base et son contenu${CVOID}"
    stdin_readYesOrNo "Confirmer" false
    if [[ ${OLIX_STDIN_RETURN} == true ]]; then

        module_mysql_dropDatabase ${OLIX_MODULE_MYSQL_PARAM1}
        [[ $? -ne 0 ]] && logger_error "Echec de la suppréssion de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

        echo -e "${Cvert}Action terminée avec succès${CVOID}"
    fi
}


###
# Copie une base de données vers une autre
##
function mysql_action__copy()
{
    logger_debug "mysql_action__copy ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_copy && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_copy && core_exit 0

    module_mysql_usage_getParams $@

    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM1}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"
    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM2}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM2}' n'existe pas"

    module_mysql_copyDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec de la copie de '${OLIX_MODULE_MYSQL_PARAM1}' vers '${OLIX_MODULE_MYSQL_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Synchronise une base de données depuis un serveur distant
##
function mysql_action__sync()
{
    logger_debug "mysql_action__sync ($@)"

    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_copy && core_exit 1
    [[ "$1" == "help" ]] && module_mysql_usage_copy && core_exit 0

    module_mysql_usage_getParams $@

    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM1}"
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"

    stdin_readConnexionServer "" "3306" "root"
    stdin_readPassword "Mot de passe de connexion au serveur MySQL (${OLIX_STDIN_RETURN_HOST}) en tant que ${OLIX_STDIN_RETURN_USER}"
    OLIX_STDIN_RETURN_PASS=${OLIX_STDIN_RETURN}

    echo "OLIX_STDIN_RETURN_HOST=${OLIX_STDIN_RETURN_HOST}"
    echo "OLIX_STDIN_RETURN_PORT=${OLIX_STDIN_RETURN_PORT}"
    echo "OLIX_STDIN_RETURN_USER=${OLIX_STDIN_RETURN_USER}"
    echo "OLIX_STDIN_RETURN_PASS=${OLIX_STDIN_RETURN_PASS}"
    module_mysql_usage_readDatabase "${OLIX_STDIN_RETURN_HOST}" "${OLIX_STDIN_RETURN_PORT}" "${OLIX_STDIN_RETURN_USER}" "${OLIX_STDIN_RETURN_PASS}"
    OLIX_MODULE_MYSQL_PARAM2=${OLIX_STDIN_RETURN}

    if [[ -n ${OLIX_MODULE_MYSQL_PARAM2} ]]; then

        module_mysql_synchronizeDatabase \
            "--host=${OLIX_STDIN_RETURN_HOST} --port=${OLIX_STDIN_RETURN_PORT} --user=${OLIX_STDIN_RETURN_USER} --password=${OLIX_STDIN_RETURN_PASS}" \
            "${OLIX_MODULE_MYSQL_PARAM2}" \
            "--host=${OLIX_MODULE_MYSQL_HOST} --port=${OLIX_MODULE_MYSQL_PORT} --user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASS}" \
            "${OLIX_MODULE_MYSQL_PARAM1}"
        [[ $? -ne 0 ]] && logger_error "Echec de la synchronisation de '${OLIX_MODULE_MYSQL_PARAM2}' vers '${OLIX_MODULE_MYSQL_PARAM1}'"
        echo -e "${Cvert}Action terminée avec succès${CVOID}"
    fi
}
