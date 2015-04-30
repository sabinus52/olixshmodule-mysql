###
# Gestion du serveur de base de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si MySQL est installé
##
function module_mysql_isInstalled()
{
    logger_debug "module_mysql_isInstalled ()"
    [[ ! -f /etc/mysql/my.cnf ]] && return 1
    return 0
}


###
# Test si MySQL est en execution
##
function module_mysql_isRunning()
{
    logger_debug "module_mysql_isRunning ()"
    netstat -ntpul | grep mysql > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée le rôle olix qui permettra à olixsh de se connecter directement
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Nom du rôle
# @param $4 : Mot de passe du rôle
##
function module_mysql_createRoleOliX()
{
    logger_debug "module_mysql_createRoleOliX ($1, $2, $3, $4)"
    echo -e "Mot de passe d'accès au serveur MySQL avec l'utilisateur ${CCYAN}root${CVOID} "
    mysql --host=$1 --port=$2 --user=root -p \
        --execute="GRANT ALL PRIVILEGES ON *.* TO '$3'@'localhost' IDENTIFIED BY '$4';" \
        > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Recupère la chaine de connexion au serveur
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @return string
##
function module_mysql_getDbUrl()
{
    if [[ $# -eq 0 ]]; then
        echo -n "--host=${OLIX_MODULE_MYSQL_HOST} --port=${OLIX_MODULE_MYSQL_PORT} --user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASS}"
    else
        if [[ -z $4 ]]; then
            echo "--host=$1 --port=$2 --user=$3 -p"
        else
            echo "--host=$1 --port=$2 --user=$3 --password=$4"
        fi
    fi
}


###
# Vérifie si une base existe
# @param $1 : Nom de la base à vérifier
# @param $2 : Host du serveur MySQL
# @param $3 : Port du serveur
# @param $4 : Utilisateur mysql
# @param $5 : Mot de passe
# @return bool
##
function module_mysql_isBaseExists()
{
    logger_debug "module_mysql_isBaseExists ($1, $2, $3, $4, $5)"

    local BASES=$(module_mysql_getListDatabases $2 $3 $4 $5)
    core_contains "$1" "${BASES}" && return 0
    return 1
}


###
# Retroune la liste des bases de données
# @param $1 : Host du serveur MySQL
# @param $2 : Port du serveur
# @param $3 : Utilisateur mysql
# @param $4 : Mot de passe
# @return : Liste
##
function module_mysql_getListDatabases()
{
    local URL=$(module_mysql_getDbUrl $1 $2 $3 $4)
    logger_debug "module_mysql_getListDatabases (${URL})"

    local DATABASES
    DATABASES=$(mysql ${URL} --execute='SHOW DATABASES' | grep -vE "(Database|information_schema|performance_schema|mysql|lost\+found)")
    [[ $? -ne 0 ]] && return 1
    echo -n ${DATABASES}
    return 0
}


###
# Fait un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3  : Host du serveur MySQL
# @param $4  : Port du serveur
# @param $5  : Utilisateur mysql
# @param $6  : Mot de passe
# @return bool
##
function module_mysql_dumpDatabase()
{
    local URL=$(module_mysql_getDbUrl $3 $4 $5 $6)
    logger_debug "module_mysql_dumpDatabase ($1, $2, ${URL})"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysqldump ${PARAM} --opt ${URL} $1 > $2
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure un dump d'une base
# @param $1  : Fichier de dump
# @param $2  : Nom de la base
# @param $3  : Host du serveur MySQL
# @param $4  : Port du serveur
# @param $5  : Utilisateur mysql
# @param $6  : Mot de passe
# @return bool
##
function module_mysql_restoreDatabase()
{
    local URL=$(module_mysql_getDbUrl $3 $4 $5 $6)
    logger_debug "module_mysql_restoreDatabase ($1, $2, ${URL})"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysql ${PARAM} ${URL} $2 < $1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée une nouvelle base de données
# @param $1 : Nom de la base à créer
# @param $2 : Host du serveur MySQL
# @param $3 : Port du serveur
# @param $4 : Utilisateur mysql
# @param $5 : Mot de passe
# @return bool
##
function module_mysql_createDatabase()
{
    local URL=$(module_mysql_getDbUrl $2 $3 $4 $5)
    logger_debug "module_mysql_createDatabase ($1, ${URL})"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysql ${PARAM} ${URL} --execute="CREATE DATABASE $1;"
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données
# @param $1 : Nom de la base à créer
# @param $2 : Host du serveur MySQL
# @param $3 : Port du serveur
# @param $4 : Utilisateur mysql
# @param $5 : Mot de passe
# @return bool
##
function module_mysql_dropDatabase()
{
    local URL=$(module_mysql_getDbUrl $2 $3 $4 $5)
    logger_debug "module_mysql_dropDatabase ($1, ${URL})"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysql ${PARAM} ${URL} --execute="DROP DATABASE IF EXISTS $1;"
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Copie une base de données vers une autre une base
# @param $1  : Nom de la base source
# @param $2  : Nom de la base destination
# @param $3  : Host du serveur MySQL
# @param $4  : Port du serveur
# @param $5  : Utilisateur mysql
# @param $6  : Mot de passe
# @return bool
##
function module_mysql_copyDatabase()
{
    local URL=$(module_mysql_getDbUrl $3 $4 $5 $6)
    logger_debug "module_mysql_copyDatabase ($1, $2, ${URL})"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysqldump ${PARAM} --opt ${URL} $1 | mysql ${URL} $2
    [[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
    return 1
}


###
# Copie une base de données depuis un serveur distant vers une base locale
# @param $1  : Paramètre de connexion de la source
# @param $2  : Base source
# @param $3  : Paramètre de connexion locale
# @param $4  : Base de destination
# @return bool
##
function module_mysql_synchronizeDatabase()
{
    logger_debug "module_mysql_synchronizeDatabase ($1, $2, $3, $4)"

    local PARAM
    [[ ${OLIX_OPTION_VERBOSE} == true ]] && PARAM="--verbose"
    mysqldump ${PARAM} --opt $1 $2 | mysql $3 $4
    [[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
    return 1
}


###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
##
function module_mysql_backupDatabase()
{
    logger_debug "module_mysql_backupDatabase ($1)"

    if ! module_mysql_isBaseExists "${I}"; then
        logger_warning "La base '${I}' n'existe pas"
        return 1
    fi

    local DUMP="${OLIX_MODULE_MYSQL_BACKUP_DIR}/dump-$1-${OLIX_SYSTEM_DATE}.sql"
    logger_info "Sauvegarde baseMySQL ($1) -> ${DUMP}"

    local START=${SECONDS}

    module_mysql_dumpDatabase $1 ${DUMP}
    stdout_printMessageReturn $? "Sauvegarde de la base" "$(filesystem_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    report_printMessageReturn $? "Sauvegarde de la base" "$(filesystem_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning && return 1

    if [[ -n ${OLIX_MODULE_MYSQL_BACKUP_COMPRESS} ]]; then
        backup_compress "${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}" "${DUMP}"
        [[ $? -ne 0 ]] && return 1
        DUMP=${OLIX_FUNCTION_RESULT}
    fi

    backup_purge "${OLIX_MODULE_MYSQL_BACKUP_DIR}" "dump-$I-*" "${OLIX_MODULE_MYSQL_BACKUP_PURGE}"
    [[ $? -ne 0 ]] && return 1

    return 0
    [[ $? -ne 0 ]] && logger_warning "Echec du dump de la base '${I}' vers '${DUMP}'" && return 1
    
    if [[ -n ${OLIX_MODULE_MYSQL_BACKUP_COMPRESS} ]]; then
            file_compressBZ2 ${DUMP}
            [[ $? -ne 0 ]] && "Echec de la compression du dump '${DUMP}'" && continue
        fi


    

    return 0
}