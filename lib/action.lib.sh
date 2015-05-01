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
    logger_debug "OLIX_MODULE_MYSQL_PASS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_PASS=${OLIX_STDIN_RETURN}

    # Emplacement des dumps lors de la sauvegarde
    [[ -z ${OLIX_MODULE_MYSQL_BACKUP_DIR} ]] && OLIX_MODULE_MYSQL_BACKUP_DIR="/tmp"
    stdin_readDirectory "Chemin complet des dumps de sauvegarde" "${OLIX_MODULE_MYSQL_BACKUP_DIR}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_DIR=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_BACKUP_DIR=${OLIX_STDIN_RETURN}

    # Format de compression
    [[ -z ${OLIX_MODULE_MYSQL_BACKUP_COMPRESS} ]] && OLIX_MODULE_MYSQL_BACKUP_COMPRESS="GZ"
    stdin_readSelect "Format de compression des dumps (NULL pour sans compression)" "NULL null GZ gz BZ2 bz2" "${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${OLIX_STDIN_RETURN}

    # Nombre de jours de retention de la sauvegarde
    [[ -z ${OLIX_MODULE_MYSQL_BACKUP_PURGE} ]] && OLIX_MODULE_MYSQL_BACKUP_PURGE="5"
    stdin_readSelect "Retention des dumps de sauvegarde" "LOG log 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31" "${OLIX_MODULE_MYSQL_BACKUP_PURGE}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_PURGE=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_BACKUP_PURGE=${OLIX_STDIN_RETURN}

    # Format du rapport
    [[ -z ${OLIX_MODULE_MYSQL_BACKUP_REPORT} ]] && OLIX_MODULE_MYSQL_BACKUP_REPORT="TEXT"
    stdin_readSelect "Format des rapports de sauvegarde" "TEXT text HTML html" "${OLIX_MODULE_MYSQL_BACKUP_REPORT}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_REPORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_BACKUP_REPORT=${OLIX_STDIN_RETURN}

    # Email d'envoi de rapport
    stdin_read "Email d'envoi du rapport" "${OLIX_MODULE_MYSQL_BACKUP_EMAIL}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_EMAIL=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_MYSQL_BACKUP_EMAIL=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${FILECONF}"
    echo "# Fichier de configuration du module MYSQL" > ${FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_BACKUP_DIR=${OLIX_MODULE_MYSQL_BACKUP_DIR}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_BACKUP_PURGE=${OLIX_MODULE_MYSQL_BACKUP_PURGE}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_BACKUP_REPORT=${OLIX_MODULE_MYSQL_BACKUP_REPORT}" >> ${FILECONF}
    echo "OLIX_MODULE_MYSQL_BACKUP_EMAIL=${OLIX_MODULE_MYSQL_BACKUP_EMAIL}" >> ${FILECONF}

    # Création du rôle
    logger_info "Création du rôle '${OLIX_MODULE_MYSQL_USER}'"
    module_mysql_createRoleOliX "${OLIX_MODULE_MYSQL_HOST}" "${OLIX_MODULE_MYSQL_PORT}" "${OLIX_MODULE_MYSQL_USER}" "${OLIX_MODULE_MYSQL_PASS}"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le rôle '${OLIX_MODULE_MYSQL_USER}' dans le serveur MySQL"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
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
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"
    
    logger_info "Dump de la base '${OLIX_MODULE_MYSQL_PARAM1}' vers le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"
    module_mysql_dumpDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec du dump de la base '${OLIX_MODULE_MYSQL_PARAM1}' vers le fichier '${OLIX_MODULE_MYSQL_PARAM2}'"

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
    [[ ! -r ${OLIX_MODULE_MYSQL_PARAM1} ]] && logger_error "Le fichier '${OLIX_MODULE_MYSQL_PARAM1}' est absent ou inaccessible"
    
    logger_info "Restauration du dump '${OLIX_MODULE_MYSQL_PARAM1}' vers la base '${OLIX_MODULE_MYSQL_PARAM2}'"
    module_mysql_restoreDatabase ${OLIX_MODULE_MYSQL_PARAM1} ${OLIX_MODULE_MYSQL_PARAM2}
    [[ $? -ne 0 ]] && logger_error "Echec de la restauration du dump '${OLIX_MODULE_MYSQL_PARAM1}' vers la base '${OLIX_MODULE_MYSQL_PARAM2}'"

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
    [[ $? -ne 0 ]] && logger_error "Echec de la création de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

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
        [[ $? -ne 0 ]] && logger_error "Echec de la suppression de la base '${OLIX_MODULE_MYSQL_PARAM1}'"

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
    [[ $? -ne 0 ]] && logger_error "Echec de la copie de '${OLIX_MODULE_MYSQL_PARAM1}' vers '${OLIX_MODULE_MYSQL_PARAM2}'"

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
    [[ $? -ne 0 ]] && logger_error "La base '${OLIX_MODULE_MYSQL_PARAM1}' n'existe pas"

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
        [[ $? -ne 0 ]] && logger_error "Echec de la synchronisation de '${OLIX_STDIN_RETURN_HOST}:${OLIX_MODULE_MYSQL_PARAM2}' vers '${OLIX_MODULE_MYSQL_PARAM1}'"
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
        mkdir ${OLIX_MODULE_MYSQL_BACKUP_DIR} || logger_error "Impossible de créer OLIX_MODULE_MYSQL_BACKUP_DIR: \"${OLIX_MODULE_MYSQL_BACKUP_DIR}\""
    elif [[ ! -w ${OLIX_MODULE_MYSQL_BACKUP_DIR} ]]; then
        logger_error "Le dossier '${OLIX_MODULE_MYSQL_BACKUP_DIR}' n'a pas les droits en écriture"
    fi

    source lib/backup.lib.sh
    source lib/report.lib.sh

    # Mise en place du rapport
    report_initialize "${OLIX_MODULE_MYSQL_BACKUP_REPORT}" \
                      "${OLIX_MODULE_MYSQL_BACKUP_DIR}/rapport-dump-mysql-${OLIX_SYSTEM_DATE}" \
                      "${OLIX_MODULE_MYSQL_BACKUP_EMAIL}"
    stdout_printHead1 "Sauvegarde des bases MySQL %s le %s à %s" "${HOSTNAME}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"
    report_printHead1 "Sauvegarde des bases MySQL %s le %s à %s" "${HOSTNAME}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"

    local I
    for I in ${OLIX_MODULE_MYSQL_BACKUP_BASES}; do
        logger_info "Sauvegarde de la base '${I}'"
        module_mysql_backupDatabase ${I}
        [[ $? -ne 0 ]] && IS_ERROR=true
    done

    stdout_print; stdout_printLine; stdout_print "${Cvert}Sauvegarde terminée en $(core_getTimeExec) secondes${CVOID}"
    report_print; report_printLine; report_print "Sauvegarde terminée en $(core_getTimeExec) secondes"

    if [[ ${IS_ERROR} == true ]]; then
        report_terminate "ERREUR - Rapport de backups des bases du serveur ${HOSTNAME}"
    else
        report_terminate "Rapport de backups des bases du serveur ${HOSTNAME}"
    fi
}
