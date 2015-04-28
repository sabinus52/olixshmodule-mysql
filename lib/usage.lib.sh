###
# Usage du module MYSQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function module_mysql_usage_main()
{
    logger_debug "module_mysql_usage_main ()"
    stdout_printVersion
    echo
    echo -e "Gestion des bases de données MySQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}[ACTION]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} dump    ${CVOID}  : Fait un dump d'une base de données"
    echo -e "${Cjaune} restore ${CVOID}  : Restauration d'une base de données"
    echo -e "${Cjaune} sync    ${CVOID}  : Synchronisation d'une base à partir d'un serveur distant"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action DUMP
##
function module_mysql_usage_dump()
{
    logger_debug "module_mysql_usage_dump ()"
    stdout_printVersion
    echo
    echo -e "Faire un dump d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}dump${CVOID} ${CBLANC}[BASE] [dumpfile] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=[${OLIX_MODULE_MYSQL_HOST}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_HOST}" 11 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=[${OLIX_MODULE_MYSQL_PORT}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_PORT}" 11 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=[${OLIX_MODULE_MYSQL_USER}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_USER}" 11 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass=   ${CVOID}"; stdout_strpad "" 11 " "; echo " : Password du serveur MYSQL"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -e "${CBLANC} --host=[localhost]   ${CVOID} : Host du serveur MYSQL"
    echo -e "${CBLANC} --port=[3306]        ${CVOID} : Port du serveur MYSQL"
    echo -e "${CBLANC} --user=[root]        ${CVOID} : User du serveur MYSQL"
    echo -e "${CBLANC} --pass=              ${CVOID} : Password du serveur MYSQL"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Usage de l'action RESTORE
##
function module_mysql_usage_restore()
{
    logger_debug "module_mysql_usage_restore ()"
    stdout_printVersion
    echo
    echo -e "Faire un dump d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}restore${CVOID} ${CBLANC}[dumpfile] [BASE]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=[${OLIX_MODULE_MYSQL_HOST}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_HOST}" 11 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=[${OLIX_MODULE_MYSQL_PORT}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_PORT}" 11 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=[${OLIX_MODULE_MYSQL_USER}] ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_USER}" 11 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass=   ${CVOID}"; stdout_strpad "" 11 " "; echo " : Password du serveur MYSQL"
    echo
    echo -e "${CJAUNE}Restauration d'une base de données à partir d'un dump${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Retourne les paramètres de la commandes en fonction des options
# @param $@ : Liste des paramètres
##
function module_mysql_usage_getParams()
{
    logger_debug module_mysql_usage_getParams
    local PARAM

    while [[ $# -ge 1 ]]; do
        case $1 in
            --host=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_HOST=${PARAM[1]}
                ;;
            --port=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_PORT=${PARAM[1]}
                ;;
            --user=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_USER=${PARAM[1]}
                ;;
            --pass=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_PASS=${PARAM[1]}
                ;;
            *)
                [[ -n ${OLIX_MODULE_MYSQL_PARAM1} ]] && OLIX_MODULE_MYSQL_PARAM2=$1
                [[ -z ${OLIX_MODULE_MYSQL_PARAM1} ]] && OLIX_MODULE_MYSQL_PARAM1=$1
                ;;
        esac
        shift
    done
    logger_debug "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}"
    logger_debug "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}"
    logger_debug "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}"
    logger_debug "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}"
    logger_debug "OLIX_MODULE_MYSQL_PARAM1=${OLIX_MODULE_MYSQL_PARAM1}"
    logger_debug "OLIX_MODULE_MYSQL_PARAM2=${OLIX_MODULE_MYSQL_PARAM2}"
}