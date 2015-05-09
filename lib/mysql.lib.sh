###
# Gestion du serveur de base de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si MySQL est installé
# @return bool
##
function module_mysql_isInstalled()
{
    logger_debug "module_mysql_isInstalled ()"
    [[ ! -f /etc/mysql/my.cnf ]] && return 1
    return 0
}


###
# Test si MySQL est en execution
# @return bool
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
# @return bool
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
# Crée un rôle
# @param $1 : Nom de la base du rôle
# @param $2 : Nom du rôle
# @param $3 : Mot de passe du rôle
# @param $4 : Host du serveur MySQL
# @param $5 : Port du serveur
# @param $6 : Utilisateur mysql
# @param $7 : Mot de passe
##
function module_mysql_createRole()
{
    local URL=$(module_mysql_getDbUrl $4 $5 $6 $7)
    logger_debug "module_mysql_createRole ($1, $2, $3, ${URL})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysql --verbose ${URL}  --execute="GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$2';"
    else
        mysql ${URL} --execute="GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$2';" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
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

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysqldump --verbose --opt ${URL} $1 > $2
    else
        mysqldump --opt ${URL} $1 > $2 2> ${OLIX_LOGGER_FILE_ERR}
    fi
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

    mysql ${PARAM} ${URL} $2 < $1 2> ${OLIX_LOGGER_FILE_ERR}
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

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysql --verbose ${URL}  --execute="CREATE DATABASE $1;"
    else
        mysql ${URL} --execute="CREATE DATABASE $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
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

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysql --verbose ${URL}  --execute="DROP DATABASE $1;"
    else
        mysql ${URL} --execute="DROP DATABASE $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données même si elle n'existe pas
# @param $1 : Nom de la base à créer
# @param $2 : Host du serveur MySQL
# @param $3 : Port du serveur
# @param $4 : Utilisateur mysql
# @param $5 : Mot de passe
# @return bool
##
function module_mysql_dropDatabaseIfExists()
{
    local URL=$(module_mysql_getDbUrl $2 $3 $4 $5)
    logger_debug "module_mysql_dropDatabaseIfExists ($1, ${URL})"

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysql --verbose ${URL}  --execute="DROP DATABASE IF EXISTS $1;"
    else
        mysql ${URL} --execute="DROP DATABASE IF EXISTS $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
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

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysqldump --verbose ${URL} --opt ${URL} $1 | mysql ${URL} $2
    else
        mysqldump --opt ${URL} $1 | mysql ${URL} $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
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

    if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
        mysqldump --verbose ${URL} --opt $1 $2 | mysql $3 $4
    else
        mysqldump --opt ${URL} $1 $2 | mysql $3 $4 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
    [[ $? -eq 0 && ${PIPESTATUS} -eq 0 ]] && return 0
    return 1
}


###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
# @param $2 : Emplacement du backup
# @param $3 : Compression
# @param $4 : Rétention pour la purge
# @param $5 : FTP type utilisé (false|lftp|ncftp)
# @param $6 : Host du FTP
# @param $7 : Utilisateur du FTP
# @param $8 : Password du FTP
# @param $9 : Chemin du FTP
# @return bool
##
function module_mysql_backupDatabase()
{
    logger_debug "module_mysql_backupDatabase ($1)"
    local BASE=$1
    local DIRBCK=$2
    local COMPRESS=$3
    local PURGE=$4
    local FTP=$5
    local FTP_HOST=$6
    local FTP_USER=$7
    local FTP_PASS=$8
    local FTP_PATH=$9

    stdout_printHead2 "Dump de la base MySQL %s" "${BASE}"
    report_printHead2 "Dump de la base MySQL %s" "${BASE}"

    if ! module_mysql_isBaseExists "${BASE}"; then
        report_warning "La base '${BASE}' n'existe pas"
        logger_warning "La base '${BASE}' n'existe pas"
        return 1
    fi

    local DUMP="${DIRBCK}/dump-${BASE}-${OLIX_SYSTEM_DATE}.sql"
    logger_info "Sauvegarde baseMySQL (${BASE}) -> ${DUMP}"

    local START=${SECONDS}

    module_mysql_dumpDatabase "${BASE}" "${DUMP}"
    stdout_printMessageReturn $? "Sauvegarde de la base" "$(filesystem_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    report_printMessageReturn $? "Sauvegarde de la base" "$(filesystem_getSizeFileHuman ${DUMP})" "$((SECONDS-START))"
    [[ $? -ne 0 ]] && report_warning && logger_warning2 && return 1

    backup_finalize "${DUMP}" "${DIRBCK}" "${COMPRESS}" "${PURGE}" "dump-${BASE}-*" \
        "${FTP}" "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_PATH}"

    return $?
}
