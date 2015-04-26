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

