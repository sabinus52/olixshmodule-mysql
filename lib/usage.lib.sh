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
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} check   ${CVOID}  : Test de la connexion au serveur MySQL"
    echo -e "${Cjaune} dump    ${CVOID}  : Fait un dump d'une base de données"
    echo -e "${Cjaune} restore ${CVOID}  : Restauration d'une base de données"
    echo -e "${Cjaune} create  ${CVOID}  : Création d'une base de données"
    echo -e "${Cjaune} drop    ${CVOID}  : Suppréssion d'une base de données"
    echo -e "${Cjaune} copy    ${CVOID}  : Copy d'une base de données vers une autre"
    echo -e "${Cjaune} sync    ${CVOID}  : Synchronisation d'une base à partir d'un serveur distant"
    echo -e "${Cjaune} backup  ${CVOID}  : Réalisation d'une sauvegarde des bases MySQL avec rapport pour tâches planifiées"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action CHECK
##
function module_mysql_usage_check()
{
    logger_debug "module_mysql_usage_check ()"
    stdout_printVersion
    echo
    echo -e "Test de la connexion au serveur MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}check${CVOID} ${CBLANC} [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=${OLIX_MODULE_MYSQL_HOST} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_HOST}" 13 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=${OLIX_MODULE_MYSQL_PORT} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_PORT}" 13 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=${OLIX_MODULE_MYSQL_USER} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_USER}" 13 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; stdout_strpad "" 13 " "; echo " : Password du serveur MYSQL"
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
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}dump${CVOID} ${CBLANC}base dumpfile [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=${OLIX_MODULE_MYSQL_HOST} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_HOST}" 13 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=${OLIX_MODULE_MYSQL_PORT} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_PORT}" 13 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=${OLIX_MODULE_MYSQL_USER} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_USER}" 13 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; stdout_strpad "" 13 " "; echo " : Password du serveur MYSQL"
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
    echo -e "Restauration d'une base de données MySQL à partir d'un fichier de dump"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}restore${CVOID} ${CBLANC}dumpfile base [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=${OLIX_MODULE_MYSQL_HOST} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_HOST}" 13 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=${OLIX_MODULE_MYSQL_PORT} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_PORT}" 13 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=${OLIX_MODULE_MYSQL_USER} ${CVOID}"; stdout_strpad "${OLIX_MODULE_MYSQL_USER}" 13 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; stdout_strpad "" 13 " "; echo " : Password du serveur MYSQL"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Usage de l'action CREATE
##
function module_mysql_usage_create()
{
    logger_debug "module_mysql_usage_create ()"
    stdout_printVersion
    echo
    echo -e "Création d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}create${CVOID} ${CBLANC}base${CVOID}"
}


###
# Usage de l'action DROP
##
function module_mysql_usage_drop()
{
    logger_debug "module_mysql_usage_drop ()"
    stdout_printVersion
    echo
    echo -e "Suppréssion d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}drop${CVOID} ${CBLANC}base${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Usage de l'action COPY
##
function module_mysql_usage_copy()
{
    logger_debug "module_mysql_usage_copy ()"
    stdout_printVersion
    echo
    echo -e "Copie d'une base de données MySQL vers une autre"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}copy${CVOID} ${CBLANC}base_source base_destination${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Usage de l'action SYNC
##
function module_mysql_usage_sync()
{
    logger_debug "module_mysql_usage_sync ()"
    stdout_printVersion
    echo
    echo -e "Synchronisation d'une base à partir d'un serveur MySQL distant"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}sync${CVOID} ${CBLANC}base_destination${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(module_mysql_getListDatabases); do
        echo -en "${Cjaune} ${I} ${CVOID}"
        stdout_strpad "${I}" 20 " "
        echo " : Base de de données ${I}"
    done
}


###
# Usage de l'action BACKUP
##
function module_mysql_usage_backup()
{
    logger_debug "module_mysql_usage_backup ()"
    stdout_printVersion
    echo
    echo -e "Réalisation d'une sauvegarde des bases MySQL avec rapport pour tâches planifiées"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}mysql ${CJAUNE}backup${CVOID} ${CBLANC}[base1..baseN] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --host=${OLIX_MODULE_MYSQL_HOST} ${CVOID}"; stdout_strpad "--host=${OLIX_MODULE_MYSQL_HOST}" 30 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=${OLIX_MODULE_MYSQL_PORT} ${CVOID}"; stdout_strpad "--port=${OLIX_MODULE_MYSQL_PORT}" 30 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=${OLIX_MODULE_MYSQL_USER} ${CVOID}"; stdout_strpad "--user=${OLIX_MODULE_MYSQL_USER}" 30 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; stdout_strpad "--pass=" 30 " "; echo " : Password du serveur MYSQL"
    echo -en "${CBLANC} --dir=${OLIX_MODULE_MYSQL_BACKUP_DIR} ${CVOID}"; stdout_strpad "--dir=${OLIX_MODULE_MYSQL_BACKUP_DIR}" 30 " "; echo " : Chemin de stockage des backups"
    echo -en "${CBLANC} --purge=${OLIX_MODULE_MYSQL_BACKUP_PURGE} ${CVOID}"; stdout_strpad "--purge=${OLIX_MODULE_MYSQL_BACKUP_PURGE}" 30 " "; echo " : Nombre de jours avant la purge des anciens backups"
    echo -en "${CBLANC} --gz|--bz2 ${CVOID}"; stdout_strpad "--gz|--bz2" 30 " "; echo " : Compression du dump au format gzip ou bzip2"
    echo -en "${CBLANC} --html ${CVOID}"; stdout_strpad "--html" 30 " "; echo " : Rapport au format HTML sinon au format TEXT par défaut"
    echo -en "${CBLANC} --email=name@domain.ltd ${CVOID}"; stdout_strpad "--email=name@domain.ltd" 30 " "; echo " : Envoi du rapport à cette adresse"
    echo
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
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
            --dir=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_BACKUP_DIR=${PARAM[1]}
                ;;
            --purge=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_BACKUP_PURGE=${PARAM[1]}
                ;;
            --gz|--bz2)
                OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${1/--/}
                ;;
            --html)
                OLIX_MODULE_MYSQL_BACKUP_REPORT="HTML"
                ;;
            --email=*)
                IFS='=' read -ra PARAM <<< "$1"
                OLIX_MODULE_MYSQL_BACKUP_EMAIL=${PARAM[1]}
                ;;
            *)
                OLIX_MODULE_MYSQL_BACKUP_BASES="${OLIX_MODULE_MYSQL_BACKUP_BASES} $1"
                [[ -n ${OLIX_MODULE_MYSQL_PARAM1} ]] && OLIX_MODULE_MYSQL_PARAM2=$1
                [[ -z ${OLIX_MODULE_MYSQL_PARAM1} ]] && OLIX_MODULE_MYSQL_PARAM1=$1
                ;;
        esac
        shift
    done
    config_require "OLIX_MODULE_MYSQL_BACKUP_DIR" "/tmp"
    config_require "OLIX_MODULE_MYSQL_BACKUP_PURGE" "5"
    config_require "OLIX_MODULE_MYSQL_BACKUP_REPORT" "TEXT"
    logger_debug "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}"
    logger_debug "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}"
    logger_debug "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}"
    logger_debug "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}"
    logger_debug "OLIX_MODULE_MYSQL_PARAM1=${OLIX_MODULE_MYSQL_PARAM1}"
    logger_debug "OLIX_MODULE_MYSQL_PARAM2=${OLIX_MODULE_MYSQL_PARAM2}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_DIR=${OLIX_MODULE_MYSQL_BACKUP_DIR}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_PURGE=${OLIX_MODULE_MYSQL_BACKUP_PURGE}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_REPORT=${OLIX_MODULE_MYSQL_BACKUP_REPORT}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_EMAIL=${OLIX_MODULE_MYSQL_BACKUP_EMAIL}"
    logger_debug "OLIX_MODULE_MYSQL_BACKUP_BASES=${OLIX_MODULE_MYSQL_BACKUP_BASES}"
}


###
# Lecture d'une base de donées
# @return string OLIX_STDIN_RETURN
##
function module_mysql_usage_readDatabase()
{
    logger_debug "module_mysql_usage_readDatabase ($1, $2, $3, $4)"

    local BASE LIST_BASE
    LIST_BASE=$(module_mysql_getListDatabases $1 $2 $3 $4)
    [[ $? -ne 0 ]] && logger_error "Impossible de se connecter au serveur '$1'"

    while true; do
        for I in ${LIST_BASE}; do
            echo -e "${Cjaune} $I${CVOID} : Base ${I}"
        done
        echo -en "Choix de la base de données [${CBLANC}${CVOID}] : "
        read BASE
        core_contains "${BASE}" "${LIST_BASE}" && break
    done
    OLIX_STDIN_RETURN=${BASE}
}