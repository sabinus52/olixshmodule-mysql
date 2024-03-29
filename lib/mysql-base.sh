###
# Gestion des bases de données MySQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Vérifie si une base existe
# @param $1 : Nom de la base à vérifier
# @param $2-5 : Infos de connexion au serveur
# @return bool
##
function Mysql.base.exists()
{
    debug "Mysql.base.exists ($1)"

    local BASES=$(Mysql.server.databases $2 $3 $4 $5)
    String.list.contains "$BASES" "$1" && return 0
    return 1
}


###
# Crée une nouvelle base de données
# @param $1 : Nom de la base à créer
# @param $2 : Nom de "propriétaire"
# @param $3-6 : Infos de connexion au serveur
# @return bool
##
function Mysql.base.create()
{
    local CONNECTION=$(Mysql.server.connection $3 $4 $5 $6)
    debug "Mysql.base.create ($1, ${CONNECTION})"

    local SQL="CREATE DATABASE $1;"
    [[ -n $2 ]] && SQL="$SQL GRANT ALL ON $1.* TO $2;"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysql --verbose $CONNECTION  --execute="$SQL"
    else
        mysql $CONNECTION --execute="$SQL" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Supprime une base de données
# @param $1 : Nom de la base à créer
# @param $2-5 : Infos de connexion au serveur
# @return bool
##
function Mysql.base.drop()
{
    local CONNECTION=$(Mysql.server.connection $2 $3 $4 $5)
    debug "Mysql.base.drop ($1, ${CONNECTION})"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysql --verbose $CONNECTION  --execute="DROP DATABASE IF EXISTS $1;"
    else
        mysql $CONNECTION --execute="DROP DATABASE IF EXISTS $1;" 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Fait un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3  : Options en extra
# @param $4-7 : Infos de connexion au serveur
# @return bool
##
function Mysql.base.dump()
{
    local CONNECTION=$(Mysql.server.connection $4 $5 $6 $7)
    debug "Mysql.base.dump ($1, $2, $3, ${CONNECTION})"

    debug "mysqldump --opt $3 $CONNECTION $1 > $2"
    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysqldump --verbose --opt $3 $CONNECTION $1 > $2
    else
        mysqldump --opt $3 $CONNECTION $1 > $2 2> ${OLIX_LOGGER_FILE_ERR}
    fi
    [[ $? -ne 0 ]] && return 1
    return 0
}


###
# Restaure un dump d'une base
# @param $1  : Nom de la base
# @param $2  : Fichier de dump
# @param $3-6 : Infos de connexion au serveur
# @return bool
##
function Mysql.base.restore()
{
    local CONNECTION=$(Mysql.server.connection $3 $4 $5 $6)
    debug "Mysql.base.restore ($1, $2, ${CONNECTION})"

    mysql $CONNECTION $1 < $2 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && return 1
    return 0
}



###
# Fait une sauvegarde d'une base MySQL
# @param $1 : Nom de la base
# @param $2 : Fichier de dump
# @param $3 : Compression
# @return bool
##
function Mysql.base.backup()
{
    local CONNECTION=$(Mysql.server.connection $4 $5 $6 $7)
    debug "Mysql.base.backup ($1, $2, $3, $CONNECTION)"

    local BINCOMPRESS=$(Compression.binary $3)

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        if [[ -n $BINCOMPRESS ]]; then
            mysqldump --verbose --opt $CONNECTION $1 | $BINCOMPRESS > $2
        else
            mysqldump --verbose --opt $CONNECTION $1 > $2
        fi
    else
        if [[ -n $BINCOMPRESS ]]; then
            mysqldump --opt $CONNECTION $1 | $BINCOMPRESS > $2 2> ${OLIX_LOGGER_FILE_ERR}
        else
            mysqldump --opt $CONNECTION $1 > $2 2> ${OLIX_LOGGER_FILE_ERR}
        fi
    fi
    return $?
}


###
# Retourne l'extension d'un dump en fonction du format du dump
##
function Mysql.base.dump.ext()
{
    debug "Mysql.base.dump.ext ()"
    echo "sql"
}


###
# Réinitialiase complètement une base
# @param $1 : Nom de la base
# @param $2 : Nom du rôle
# @param $3 : Mot de passe du rôle
##
function Mysql.base.initialize()
{
    debug "Mysql.base.initialize ($1, $2, $3)"

    Mysql.base.drop $1 $4 $5 $6 $7 || return 1
    if Mysql.role.exists $2 $4 $5 $6 $7; then
        Mysql.role.drop $2 $4 $5 $6 $7 || return 1
    fi
    Mysql.role.create $2 $3 $4 $5 $6 $7 || return 1
    Mysql.base.create $1 $2 $4 $5 $6 $7 || return 1
    return 0
}
