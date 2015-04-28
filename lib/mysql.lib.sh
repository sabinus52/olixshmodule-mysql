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
        echo -n "--host=${OLIX_MODULE_MYSQL_HOST} --port=${OLIX_MODULE_MYSQL_PORT} --user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASSWORD}"
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
