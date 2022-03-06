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
function Mysql.server.installed()
{
    debug "Mysql.server.installed ()"
    getent passwd mysql > /dev/null && return 0
    return 1
}


###
# Test si MySQL est en execution
# @return bool
##
function Mysql.server.running()
{
    debug "Mysql.server.running ()"
    netstat -ntpul | grep mysql > /dev/null 2>&1
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
function Mysql.server.connection()
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
# Test une connexion au serveur de base de données
# @return bool
##
function Mysql.server.check()
{
    local CONNEXION=$(Mysql.server.connection $1 $2 $3 $4)
    debug "Mysql.server.check (${CONNEXION})"

    mysql $CONNEXION --execute="SHOW DATABASES;" > /dev/null 2>&1
    [[ $? -ne 0 ]] && return 1

    return 0
}


###
# Retroune la liste des bases de données
# @return : Liste
##
function Mysql.server.databases()
{
    local CONNEXION=$(Mysql.server.connection $1 $2 $3 $4)
    debug "Mysql.server.databases (${CONNEXION})"

    local DATABASES
    DATABASES=$(mysql $CONNEXION --execute='SHOW DATABASES' 2>/dev/null | grep -vE "(Database|information_schema|performance_schema|mysql|lost\+found)")
    [[ $? -ne 0 ]] && return 1
    echo -n $DATABASES
    return 0
}
