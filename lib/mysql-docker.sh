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
# @param $2-3 : Infos de connexion au serveur
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


###
# Retroune la liste des bases de données
# @param $1 : Nom du containeur
# @param $2-3 : Infos de connexion au serveur
# @return : Liste
##
function Mysql.docker.databases()
{
    local CONNEXION=$(Mysql.docker.connection $2 $3)
    debug "Mysql.docker.databases ($1, ${CONNEXION})"

    local DATABASES
    DATABASES=$(docker exec -i $1 mysql $CONNEXION --execute='SHOW DATABASES' 2>/dev/null | grep -vE "(Database|information_schema|performance_schema|mysql|lost\+found)")
    [[ $? -ne 0 ]] && return 1
    echo -n $DATABASES
    return 0
}


###
# Vérifie si une base existe
# @param $1 : Nom du containeur
# @param $2 : Nom de la base à vérifier
# @param $3-4 : Infos de connexion au serveur
# @return bool
##
function Mysql.docker.base.exists()
{
    debug "Mysql.docker.base.exists ($1, $2)"

    local BASES=$(Mysql.docker.databases $1 $3 $4)
    String.list.contains "$BASES" "$2" && return 0
    return 1
}


###
# Fait un dump d'une base
# @param $1 : Nom du containeur
# @param $2 : Nom de la base
# @param $3 : Fichier de dump
# @param $4 : Options en extra
# @param $5-6 : Infos de connexion au serveur
# @return bool
##
function Mysql.docker.base.dump()
{
    local CONNECTION=$(Mysql.docker.connection $5 $6)
    debug "Mysql.docker.base.dump ($1, $2, $3, $4, ${CONNECTION})"

    debug "docker exec -i $1 mysqldump --opt $4 $CONNECTION $2 > $3"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        docker exec -i $1 mysqldump --verbose --opt $4 $CONNECTION $2 > $3
    else
        docker exec -i $1 mysqldump --opt $4 $CONNECTION $2 > $3 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure une restauration d'une base
# @param $1 : Nom du containeur
# @param $2 : Nom de la base
# @param $3 : Fichier de dump
# @param $4-5 : Infos de connexion au serveur
# @return bool
##
function Mysql.docker.base.restore()
{
    local CONNECTION=$(Mysql.docker.connection $4 $5)
    debug "Mysql.docker.base.restore ($1, $2, $3, ${CONNECTION})"

    docker exec -i $1 mysql $CONNECTION $2 < $3 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}
