###
# Usage du module MYSQL
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale du module
##
function olixmodule_mysql_usage_main()
{
    debug "olixmodule_mysql_usage_main ()"
    echo
    echo -e "Gestion des bases de données MySQL (sauvegarde, restauration, ...)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
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
function olixmodule_mysql_usage_check()
{
    debug "olixmodule_mysql_usage_check ()"
    echo
    echo -e "Test de la connexion au serveur MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}check${CVOID} ${CBLANC}[OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
}


###
# Usage de l'action DUMP
##
function olixmodule_mysql_usage_dump()
{
    debug "olixmodule_mysql_usage_dump ()"
    echo
    echo -e "Faire un dump d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}dump${CVOID} ${CBLANC}<base> <dumpfile> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
    echo
    olixmodule_mysql_usage_listbases
}


###
# Usage de l'action RESTORE
##
function olixmodule_mysql_usage_restore()
{
    debug "olixmodule_mysql_usage_restore ()"
    echo
    echo -e "Restauration d'une base de données MySQL à partir d'un fichier de dump"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}restore${CVOID} ${CBLANC}<dumpfile> <base> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
    echo
    olixmodule_mysql_usage_listbases
}


###
# Usage de l'action CREATE
##
function olixmodule_mysql_usage_create()
{
    debug "olixmodule_mysql_usage_create ()"
    echo
    echo -e "Création d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}create${CVOID} ${CBLANC}<base> <owner> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
}


###
# Usage de l'action DROP
##
function olixmodule_mysql_usage_drop()
{
    debug "olixmodule_mysql_usage_drop ()"
    echo
    echo -e "Suppréssion d'une base de données MySQL"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}drop${CVOID} ${CBLANC}base [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
    echo
    olixmodule_mysql_usage_listbases
}


###
# Usage de l'action COPY
##
function olixmodule_mysql_usage_copy()
{
    debug "olixmodule_mysql_usage_copy ()"
    echo
    echo -e "Copie d'une base de données MySQL vers une autre"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}copy${CVOID} ${CBLANC}<base_source> <base_destination> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
    echo
    olixmodule_mysql_usage_listbases
}


###
# Usage de l'action SYNC
##
function olixmodule_mysql_usage_sync()
{
    debug "olixmodule_mysql_usage_sync ()"
    echo
    echo -e "Synchronisation d'une base à partir d'un serveur MySQL distant"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}sync${CVOID} ${CBLANC}<user@host[:port]> <base_source> <base_destination>${CVOID}"
    echo
    olixmodule_mysql_usage_listbases
}


###
# Usage de l'action BACKUP
##
function olixmodule_mysql_usage_backup()
{
    debug "olixmodule_mysql_usage_backup ()"
    echo
    echo -e "Réalisation d'une sauvegarde des bases MySQL avec rapport pour tâches planifiées"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}mysql ${CJAUNE}backup${CVOID} ${CBLANC}[bases...] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    olixmodule_mysql_usage_paramserver
    echo -en "${CBLANC} --dir=$OLIX_MODULE_MYSQL_BACKUP_DIR ${CVOID}"; String.pad "--dir=$OLIX_MODULE_MYSQL_BACKUP_DIR" 30 " "; echo " : Chemin de stockage des backups"
    echo -en "${CBLANC} --purge=$OLIX_MODULE_MYSQL_BACKUP_PURGE ${CVOID}"; String.pad "--purge=$OLIX_MODULE_MYSQL_BACKUP_PURGE" 30 " "; echo " : Nombre de jours avant la purge des anciens backups"
    echo -en "${CBLANC} --gz|--bz2 ${CVOID}"; String.pad "--gz|--bz2" 30 " "; echo " : Compression du dump au format gzip ou bzip2"
    echo -en "${CBLANC} --html ${CVOID}"; String.pad "--html" 30 " "; echo " : Rapport au format HTML sinon au format TEXT par défaut"
    echo -en "${CBLANC} --email=name@domain.ltd ${CVOID}"; String.pad "--email=name@domain.ltd" 30 " "; echo " : Envoi du rapport à cette adresse"
    echo
    olixmodule_mysql_usage_listbases
}


###
# Affiche les options des paramètres de connexion au serveur
##
function olixmodule_mysql_usage_paramserver()
{
    echo -en "${CBLANC} --host=$OLIX_MODULE_MYSQL_HOST ${CVOID}"; String.pad "--host=$OLIX_MODULE_MYSQL_HOST" 30 " "; echo " : Host du serveur MYSQL"
    echo -en "${CBLANC} --port=$OLIX_MODULE_MYSQL_PORT ${CVOID}"; String.pad "--port=$OLIX_MODULE_MYSQL_PORT" 30 " "; echo " : Port du serveur MYSQL"
    echo -en "${CBLANC} --user=$OLIX_MODULE_MYSQL_USER ${CVOID}"; String.pad "--user=$OLIX_MODULE_MYSQL_USER" 30 " "; echo " : User du serveur MYSQL"
    echo -en "${CBLANC} --pass= ${CVOID}"; String.pad "--pass=" 30 " "; echo " : Password du serveur MYSQL"
}


###
# Affiche la liste des bases disponibles
##
function olixmodule_mysql_usage_listbases()
{
    echo -e "${CJAUNE}Liste des BASES disponibles${CVOID} :"
    for I in $(Mysql.server.databases); do
        Print.usage.item "$I" "Base de de données $I" 15
    done
}
