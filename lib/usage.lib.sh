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
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}dump${CVOID} ${CBLANC}[BASE] [dumpfile]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}