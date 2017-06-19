###
# Gestion des rôles du serveur de bases de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Test si un rôle existe
# @param $1 : Nom du rôle
# @param $2-5 : Infos de connexion au serveur
##
function Mysql.role.exists()
{
    local CONNECTION=$(Mysql.server.connection $2 $3 $4 $5)
    debug "Mysql.role.exists ($1, $CONNECTION)"
    local USER=$(String.explode "$1" 1 '@' | tr -d "'")
    local HOST=$(String.explode "$1" 2 '@' | tr -d "'")

    mysql $CONNECTION --execute="SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$USER' AND host = '$HOST')" | tail -1 | grep -q 1
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Crée un rôle
# @param $1 : Nom du rôle
# @param $2 : Mot de passe du rôle
# @param $3 : Ecoute réseau du rôle 
# @param $4-7 : Infos de connexion au serveur
##
function Mysql.role.create()
{
    local CONNECTION=$(Mysql.server.connection $4 $5 $6)
    debug "Mysql.role.create ($1, $2, $3, $CONNECTION)"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysql --verbose $CONNECTION --execute="CREATE USER $1 IDENTIFIED BY '$2';"
    else
        mysql $CONNECTION --execute="CREATE USER $1 IDENTIFIED BY '$2';" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime un rôle
# @param $1 : Nom du rôle
##
function Mysql.role.drop()
{
    local CONNECTION=$(Mysql.server.connection $2 $3 $4)
    debug "Mysql.role.drop ($1, $CONNECTION)"

    [[ "$1" == "root" ]] && warning "Impossible de supprimer le rôle 'root'" && return 1

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysql --verbose $CONNECTION --execute="DROP USER $1;"
    else
        mysql $CONNECTION --execute="DROP USER $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}
