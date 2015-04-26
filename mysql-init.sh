###
# Initialisation du module pour indiquer ou se trouve le fichier de config
# ==============================================================================
# @package olixsh
# @module ubuntu
# @action mysql
# @author Olivier <sabinus52@gmail.com>
##

function mysql_init__main()
{
    logger_debug "mysql_init__main ($@)"

    local FORCE=false
    while [[ $# -ge 1 ]]; do
        case $1 in
            --force|-f) FORCE=true;;
        esac
        shift
    done

    local FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})

    # Test si la configuration existe
    logger_info "Test si la configuration est déjà effectuée"
    if config_isModuleExist ${OLIX_MODULE_NAME} && [[ ${FORCE} == false ]] ; then
        logger_warning "Le fichier de configuration existe déjà"
        if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
            echo "----------"
            cat ${FILECONF}
            echo "----------"
        fi
        logger_warning "Pour reinitialiser la configuration, utiliser : ${OLIX_CORE_SHELL_NAME} mysql init -f|--force"    
        core_exit 0
    fi

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    if config_isModuleExist ${OLIX_MODULE_NAME}; then
        logger_info "Chargement du fichier de configuration ${FILECONF}"
        source ${FILECONF}
    fi

   

    # Host
    [[ -z ${OLIX_MODULE_MYSQL_HOST} ]] && OLIX_MODULE_MYSQL_HOST="localhost"
    stdin_read "Host du serveur MySQL" "${OLIX_MODULE_MYSQL_HOST}"
    logger_debug "OLIX_MODULE_MYSQL_HOST=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_HOST=${OLIX_STDIN_RETURN}
    
    # Port
    [[ -z ${OLIX_MODULE_MYSQL_PORT} ]] && OLIX_MODULE_MYSQL_PORT="3306"
    stdin_read "Host du serveur MySQL" "${OLIX_MODULE_MYSQL_PORT}"
    logger_debug "OLIX_MODULE_MYSQL_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_PORT=${OLIX_STDIN_RETURN}
    
    # Utilisateur
    [[ -z ${OLIX_MODULE_MYSQL_USER} ]] && OLIX_MODULE_MYSQL_USER=olix
    while true; do
        stdin_read "Utilisateur de la base MySQL autre que root" "${OLIX_MODULE_MYSQL_USER}"
        [[ ${OLIX_STDIN_RETURN} != "root" ]] && break;
    done
    logger_debug "OLIX_MODULE_MYSQL_USER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_USER=${OLIX_STDIN_RETURN}

    # Mot de passe
    stdin_readDoublePassword "Mot de passe du serveur MySQL"
    logger_debug "OLIX_MODULE_MYSQL_PASSWORD=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_PASSWORD=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${FILECONF}"
    echo "# Fichier de configuration du module MYSQL" > ${FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PASSWORD=${OLIX_MODULE_MYSQL_PASSWORD}" >> ${FILECONF}

    # Création du rôle
    module_mysql_createRoleOliX "${OLIX_MODULE_MYSQL_HOST}" "${OLIX_MODULE_MYSQL_PORT}" "${OLIX_MODULE_MYSQL_USER}" "${OLIX_MODULE_MYSQL_PASSWORD}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le rôle '${OLIX_MODULE_MYSQL_USER}' dans le serveur MySQL"
}