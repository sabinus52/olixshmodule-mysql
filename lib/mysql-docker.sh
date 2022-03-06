###
# Gestion du containeur Docker de base de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##


###
# Recupère la chaine de connexion au containeur
# @param $1 : Utilisateur mysql
# @param $2 : Mot de passe
# @return string
##
function Mysql.docker.connection()
{
    if [[ $# -eq 0 ]]; then
        echo -n "--user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASS}"
    else
        if [[ -z $4 ]]; then
            echo "--user=$1 -p"
        else
            echo "--user=$1 --password=$2"
        fi
    fi
}


###
# Test une connexion au containeur Docker
# @param $1 : Nom du containeur
# @return bool
##
function Mysql.docker.check()
{
    local CONNEXION=$(Mysql.docker.connection $2 $3)
    debug "Mysql.docker.check ($1, ${CONNEXION})"

    docker exec -i $1 mysql $CONNEXION --execute="SHOW DATABASES;" > /dev/null
    [[ $? -ne 0 ]] && return 1

    return 0
}
