###
# Librairies des actions du module MYSQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##




###
# Copie une base de données vers une autre une base
# @param $1  : Nom de la base source
# @param $2  : Nom de la base destination
# @param $3-6 : Infos de connexion au serveur
# @return bool
##
function Mysql.action.copy()
{
    local CONNECTION=$(Mysql.server.connection $3 $4 $5 $6)
    debug "Mysql.action.copy ($1, $2, $CONNECTION)"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysqldump --verbose --opt $CONNECTION $1 | mysql $CONNECTION $2
    else
        mysqldump --opt $CONNECTION $1 | mysql $CONNECTION $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
    [[ $? -eq 0 && $PIPESTATUS -eq 0 ]] && return 0
    return 1
}


###
# Copie une base de données depuis un serveur distant vers une base locale
# @param $1  : Chaine de connexion de la source
# @param $2  : Base source
# @param $3  : chaine de connexion locale
# @param $4  : Base de destination
# @return bool
##
function Mysql.action.synchronize()
{
    debug "Mysql.action.synchronize ($1, $2, $3, $4)"

    if [[ $OLIX_OPTION_VERBOSE == true ]]; then
        mysqldump --verbose --opt $1 $2 | mysql $3 $4
    else
        mysqldump --opt $1 $2 | mysql $3 $4 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    fi
    [[ $? -eq 0 && $PIPESTATUS -eq 0 ]] && return 0
    return 1
}


###
# Choix d'une base de donées
##
function Mysql.action.read()
{
    local CONNECTION=$(Mysql.server.connection $1 $2 $3 $4)
    debug "Mysql.action.read ($CONNECTION)"

    local BASE LIST_BASE
    LIST_BASE=$(Mysql.server.databases $1 $2 $3 $4)
    [[ $? -ne 0 ]] && error "Impossible de se connecter au serveur '$1'"

    while true; do
        for I in $LIST_BASE; do
            echo -e "${Cjaune} $I${CVOID} : Base $I"
        done
        echo -en "Choix de la base de données [${CBLANC}$BASE${CVOID}] : "
        read BASE
        String.list.contains "$LIST_BASE" "$BASE" && break
    done
    OLIX_FUNCTION_RETURN=$BASE
}
