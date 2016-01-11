###
# Librairies des actions du module MYSQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Initialisation du module en créant le fichier de configuration
# @var OLIX_MODULE_MYSQL_*
##
function module_mysql_action_init()
{
    logger_debug "module_mysql_action_init ($@)"
    local FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})

    # Host
    stdin_read "Host du serveur MySQL" "${OLIX_MODULE_MYSQL_HOST}"
    logger_debug "OLIX_MODULE_MYSQL_HOST=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_HOST=${OLIX_STDIN_RETURN}
    
    # Port
    stdin_read "Host du serveur MySQL" "${OLIX_MODULE_MYSQL_PORT}"
    logger_debug "OLIX_MODULE_MYSQL_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_PORT=${OLIX_STDIN_RETURN}
    
    # Utilisateur
    while true; do
        stdin_read "Utilisateur de la base MySQL autre que root" "${OLIX_MODULE_MYSQL_USER}"
        [[ ${OLIX_STDIN_RETURN} != "root" ]] && break;
    done
    logger_debug "OLIX_MODULE_MYSQL_USER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_USER=${OLIX_STDIN_RETURN}

    # Mot de passe
    stdin_readDoublePassword "Mot de passe du serveur MySQL"
    logger_debug "OLIX_MODULE_MYSQL_PASS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_PASS=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${FILECONF}"
    echo "# Fichier de configuration du module MYSQL" > ${FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_critical
    echo "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}" >> ${FILECONF}

    # Création du rôle
    logger_info "Création du rôle '${OLIX_MODULE_MYSQL_USER}'"
    module_mysql_createRoleOliX "${OLIX_MODULE_MYSQL_HOST}" "${OLIX_MODULE_MYSQL_PORT}" "${OLIX_MODULE_MYSQL_USER}" "${OLIX_MODULE_MYSQL_PASS}"
    [[ $? -ne 0 ]] && logger_critical "Impossible de créer le rôle '${OLIX_MODULE_MYSQL_USER}' dans le serveur MySQL"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Test de la connexion au serveur MySQL
##
function module_mysql_action_check()
{
    logger_debug "module_mysql_action_check ($@)"

    echo -e "Test de connexion avec ${Ccyan}${OLIX_MODULE_MYSQL_USER}@${OLIX_MODULE_MYSQL_HOST}:${OLIX_MODULE_MYSQL_PORT}${CVOID}"
    module_mysql_checkConnect
    [[ $? -ne 0 ]] && logger_critical "Echec de connexion au serveur MySQL"
    mysql --version

    echo -e "${Cvert}Connexion au serveur MySQL réussi${CVOID}"
}


###
# Fait un dump d'une base de données
# @param $1 : Nom de la base
# @param $2 : Nom du dump
##
function module_mysql_action_dump()
{
    logger_debug "module_mysql_action_dump ($@)"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_dump && core_exit 1

    # Vérifie les paramètres
    filesystem_isCreateFile "${OLIX_MODULE_MYSQL_PARAM2}"
    [[ $? -ne 0 ]] && logger_critical "Impossible de créer le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"
    
    logger_info "Dump de la base '${OLIX_MODULE_MYSQL_PARAM1}' vers le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"
    module_mysql_dumpDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_critical "Echec du dump de la base '${OLIX_MODULE_MYSQL_PARAM1}' vers le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}



###
# Fait une restauration d'un dump
##
function module_mysql_action_restore()
{
    logger_debug "module_mysql_action_restore ($@)"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_restore && core_exit 1

    # Vérifie les paramètres
    [[ ! -r ${OLIX_MODULE_MYSQL_PARAM1} ]] && logger_critical "Le fichier '${OLIX_MODULE_MYSQL_PARAM1}' est absent ou inaccessible"
    
    logger_info "Restauration du dump '${OLIX_MODULE_MYSQL_PARAM1}' vers la base '${OLIX_MODULE_MYSQL_PARAM2}'"
    module_mysql_restoreDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_critical "Echec de la restauration du dump '${OLIX_MODULE_MYSQL_PARAM1}' vers la base '${OLIX_MODULE_MYSQL_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}



###
# Crée une base de données
# @param $1 : Nom de la base
##
function module_mysql_action_create()
{
    logger_debug "module_mysql_action_create ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_create && core_exit 1

    logger_info "Création de la base '${OLIX_MODULE_MYSQL_PARAM1}'"
    module_mysql_createDatabase ${OLIX_MODULE_MYSQL_PARAM1}
    [[ $? -ne 0 ]] && logger_critical "Echec de la création de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}



###
# Supprime une base de données
# @param $1 : Nom de la base
##
function module_mysql_action_drop()
{
    logger_debug "module_mysql_action_drop ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_drop && core_exit 1

    echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer la base et son contenu${CVOID}"
    stdin_readYesOrNo "Confirmer" false
    if [[ ${OLIX_STDIN_RETURN} == true ]]; then

        logger_info "Suppression de la base '${OLIX_MODULE_MYSQL_PARAM1}'"
        module_mysql_dropDatabase ${OLIX_MODULE_MYSQL_PARAM1}
        [[ $? -ne 0 ]] && logger_critical "Echec de la suppression de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

        echo -e "${Cvert}Action terminée avec succès${CVOID}"
    fi
}



###
# Copie une base de données vers une autre
# @param $1 : Nom de la base source
# @param $2 : Nom de la base destination
##
function module_mysql_action_copy()
{
    logger_debug "module_mysql_action_copy ($@)"

    # Affichage de l'aide
    [ $# -lt 2 ] && module_mysql_usage_copy && core_exit 1

    logger_info "Copie de la base '${OLIX_MODULE_MYSQL_PARAM1}' vers '${OLIX_MODULE_MYSQL_PARAM2}'"
    module_mysql_copyDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_critical "Echec de la copie de '${OLIX_MODULE_MYSQL_PARAM1}' vers '${OLIX_MODULE_MYSQL_PARAM2}'"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}



###
# Synchronise une base de données depuis un serveur distant
##
function module_mysql_action_sync()
{
    logger_debug "module_mysql_action_sync ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_mysql_usage_sync && core_exit 1

    module_mysql_isBaseExists "${OLIX_MODULE_MYSQL_PARAM1}"
    [[ $? -ne 0 ]] && logger_critical "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"

    # Demande des infos de connexion à la base distante
    stdin_readConnexionServer "" "3306" "root"
    stdin_readPassword "Mot de passe de connexion au serveur MySQL (${OLIX_STDIN_RETURN_HOST}) en tant que ${OLIX_STDIN_RETURN_USER}"
    OLIX_STDIN_RETURN_PASS=${OLIX_STDIN_RETURN}

    echo "Choix de la base de données source"
    module_mysql_usage_readDatabase "${OLIX_STDIN_RETURN_HOST}" "${OLIX_STDIN_RETURN_PORT}" "${OLIX_STDIN_RETURN_USER}" "${OLIX_STDIN_RETURN_PASS}"
    OLIX_MODULE_MYSQL_PARAM2=${OLIX_STDIN_RETURN}

    if [[ -n ${OLIX_MODULE_MYSQL_PARAM2} ]]; then
        logger_info "Synchronisation de la base '${OLIX_STDIN_RETURN_HOST}:${OLIX_MODULE_MYSQL_PARAM2}' vers '${OLIX_MODULE_MYSQL_PARAM1}'"
        module_mysql_synchronizeDatabase \
            "--host=${OLIX_STDIN_RETURN_HOST} --port=${OLIX_STDIN_RETURN_PORT} --user=${OLIX_STDIN_RETURN_USER} --password=${OLIX_STDIN_RETURN_PASS}" \
            "${OLIX_MODULE_MYSQL_PARAM2}" \
            "--host=${OLIX_MODULE_MYSQL_HOST} --port=${OLIX_MODULE_MYSQL_PORT} --user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASS}" \
            "${OLIX_MODULE_MYSQL_PARAM1}"
        [[ $? -ne 0 ]] && logger_critical "Echec de la synchronisation de '${OLIX_STDIN_RETURN_HOST}:${OLIX_MODULE_MYSQL_PARAM2}' vers '${OLIX_MODULE_MYSQL_PARAM1}'"
        echo -e "${Cvert}Action terminée avec succès${CVOID}"
    fi
}



###
# Fait un backup complet des bases MySQL
# @param $@ : Liste des bases à sauvegarder
##
function module_mysql_action_backup()
{
    logger_debug "module_mysql_action_backup ($@)"
    local IS_ERROR=false

    # Si aucune base définie, on récupère toutes les bases
    if [[ -z ${OLIX_MODULE_MYSQL_BACKUP_BASES} ]]; then
        OLIX_MODULE_MYSQL_BACKUP_BASES=$(module_mysql_getListDatabases)
    fi
    if [[ ! -d ${OLIX_MODULE_MYSQL_BACKUP_DIR} ]]; then
        logger_warning "Création du dossier inexistant OLIX_MODULE_MYSQL_BACKUP_DIR: \"${OLIX_MODULE_MYSQL_BACKUP_DIR}\""
        mkdir ${OLIX_MODULE_MYSQL_BACKUP_DIR} || logger_critical "Impossible de créer OLIX_MODULE_MYSQL_BACKUP_DIR: \"${OLIX_MODULE_MYSQL_BACKUP_DIR}\""
    elif [[ ! -w ${OLIX_MODULE_MYSQL_BACKUP_DIR} ]]; then
        logger_critical "Le dossier '${OLIX_MODULE_MYSQL_BACKUP_DIR}' n'a pas les droits en écriture"
    fi

    source lib/backup.lib.sh
    source lib/report.lib.sh

    # Mise en place du rapport
    report_initialize "${OLIX_MODULE_MYSQL_BACKUP_REPORT}" \
                      "${OLIX_MODULE_MYSQL_BACKUP_DIR}" "rapport-dump-mysql-${OLIX_SYSTEM_DATE}" \
                      "${OLIX_MODULE_MYSQL_BACKUP_EMAIL}"
    stdout_printHead1 "Sauvegarde des bases MySQL %s le %s à %s" "${HOSTNAME}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"

    local I
    for I in ${OLIX_MODULE_MYSQL_BACKUP_BASES}; do
        logger_info "Sauvegarde de la base '${I}'"
        module_mysql_backupDatabase "${I}" "${OLIX_MODULE_MYSQL_BACKUP_DIR}" "${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}" "${OLIX_MODULE_MYSQL_BACKUP_PURGE}" false
        [[ $? -ne 0 ]] && IS_ERROR=true
    done

    stdout_print; stdout_printLine; stdout_print "Sauvegarde terminée en $(core_getTimeExec) secondes" "${Cvert}"

    if [[ ${IS_ERROR} == true ]]; then
        report_terminate "ERREUR - Rapport de backups des bases du serveur ${HOSTNAME}"
    else
        report_terminate "Rapport de backups des bases du serveur ${HOSTNAME}"
    fi

    # Purge des logs
    logger_info "Purge des logs de rapport"
    file_purgeStandard "${OLIX_MODULE_MYSQL_BACKUP_DIR}" "rapport-dump-mysql-" "10"
}
