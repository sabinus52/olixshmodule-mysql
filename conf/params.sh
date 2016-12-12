###
# Parse les paramètres de la commande en fonction des options
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Parsing des paramètres
##
function olixmodule_mysql_params_parse()
{
    debug "olixmodule_mysql_params_parse ($@)"
    local ACTION=$1
    local PARAM

    shift
    while [[ $# -ge 1 ]]; do
        case $1 in
            --host=*)
                OLIX_MODULE_MYSQL_HOST=$(String.explode.value $1)
                ;;
            --port=*)
                OLIX_MODULE_MYSQL_PORT=$(String.explode.value $1)
                ;;
            --user=*)
                OLIX_MODULE_MYSQL_USER=$(String.explode.value $1)
                ;;
            --pass=*)
                OLIX_MODULE_MYSQL_PASS=$(String.explode.value $1)
                ;;
            --dir=*)
                OLIX_MODULE_MYSQL_BACKUP_DIR=$(String.explode.value $1)
                ;;
            --purge=*)
                OLIX_MODULE_MYSQL_BACKUP_PURGE=$(String.explode.value $1)
                ;;
            --gz|--bz2)
                OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${1/--/}
                ;;
            --html)
                OLIX_MODULE_MYSQL_BACKUP_REPORT="HTML"
                ;;
            --email=*)
                OLIX_MODULE_MYSQL_BACKUP_EMAIL=$(String.explode.value $1)
                ;;
            *)
                olixmodule_mysql_params_get "$ACTION" "$1"
                ;;
        esac
        shift
    done

    olixmodule_mysql_params_debug $ACTION
}


###
# Fonction de récupération des paramètres
# @param $1 : Nom de l'action
# @param $2 : Nom du paramètre
##
function olixmodule_mysql_params_get()
{
    case $1 in
        create|drop)
            [[ -z $OLIX_MODULE_MYSQL_BASE ]] && OLIX_MODULE_MYSQL_BASE=$2
            ;;
        dump)
            [[ -z $OLIX_MODULE_MYSQL_BASE ]] && OLIX_MODULE_MYSQL_BASE=$2 && return
            [[ -z $OLIX_MODULE_MYSQL_DUMP ]] && OLIX_MODULE_MYSQL_DUMP=$2 && return
            ;;
        restore)
            [[ -z $OLIX_MODULE_MYSQL_DUMP ]] && OLIX_MODULE_MYSQL_DUMP=$2 && return
            [[ -z $OLIX_MODULE_MYSQL_BASE ]] && OLIX_MODULE_MYSQL_BASE=$2 && return
            ;;
        copy)
            [[ -z $OLIX_MODULE_MYSQL_SOURCE_BASE ]] && OLIX_MODULE_MYSQL_SOURCE_BASE=$2 && return
            [[ -z $OLIX_MODULE_MYSQL_BASE ]] && OLIX_MODULE_MYSQL_BASE=$2 && return
            ;;
        sync)
            [[ -z $OLIX_MODULE_MYSQL_SOURCE_HOST ]] && OLIX_MODULE_MYSQL_SOURCE_HOST=$2 && return
            [[ -z $OLIX_MODULE_MYSQL_SOURCE_BASE ]] && OLIX_MODULE_MYSQL_SOURCE_BASE=$2 && return
            [[ -z $OLIX_MODULE_MYSQL_BASE ]] && OLIX_MODULE_MYSQL_BASE=$2 && return
            ;;
        backup)
            OLIX_MODULE_MYSQL_BACKUP_BASES="$OLIX_MODULE_MYSQL_BACKUP_BASES $2"
            ;;
    esac
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_mysql_params_debug ()
{
    debug "OLIX_MODULE_MYSQL_HOST=${OLIX_MODULE_MYSQL_HOST}"
    debug "OLIX_MODULE_MYSQL_PORT=${OLIX_MODULE_MYSQL_PORT}"
    debug "OLIX_MODULE_MYSQL_USER=${OLIX_MODULE_MYSQL_USER}"
    debug "OLIX_MODULE_MYSQL_PASS=${OLIX_MODULE_MYSQL_PASS}"
    case $1 in
        create|drop)
            debug "OLIX_MODULE_MYSQL_BASE=${OLIX_MODULE_MYSQL_BASE}"
            ;;
        dump)
            debug "OLIX_MODULE_MYSQL_BASE=${OLIX_MODULE_MYSQL_BASE}"
            debug "OLIX_MODULE_MYSQL_DUMP=${OLIX_MODULE_MYSQL_DUMP}"
            ;;
        restore)
            debug "OLIX_MODULE_MYSQL_DUMP=${OLIX_MODULE_MYSQL_DUMP}"
            debug "OLIX_MODULE_MYSQL_BASE=${OLIX_MODULE_MYSQL_BASE}"
            ;;
        copy)
            debug "OLIX_MODULE_MYSQL_SOURCE_BASE=${OLIX_MODULE_MYSQL_SOURCE_BASE}"
            debug "OLIX_MODULE_MYSQL_BASE=${OLIX_MODULE_MYSQL_BASE}"
            ;;
        sync)
            debug "OLIX_MODULE_MYSQL_SOURCE_HOST=${OLIX_MODULE_MYSQL_SOURCE_HOST}"
            debug "OLIX_MODULE_MYSQL_SOURCE_BASE=${OLIX_MODULE_MYSQL_SOURCE_BASE}"
            debug "OLIX_MODULE_MYSQL_BASE=${OLIX_MODULE_MYSQL_BASE}"
            ;;
        backup)
            debug "OLIX_MODULE_MYSQL_BACKUP_BASES=${OLIX_MODULE_MYSQL_BACKUP_BASES}"
            debug "OLIX_MODULE_MYSQL_BACKUP_DIR=${OLIX_MODULE_MYSQL_BACKUP_DIR}"
            debug "OLIX_MODULE_MYSQL_BACKUP_PURGE=${OLIX_MODULE_MYSQL_BACKUP_PURGE}"
            debug "OLIX_MODULE_MYSQL_BACKUP_COMPRESS=${OLIX_MODULE_MYSQL_BACKUP_COMPRESS}"
            debug "OLIX_MODULE_MYSQL_BACKUP_REPORT=${OLIX_MODULE_MYSQL_BACKUP_REPORT}"
            debug "OLIX_MODULE_MYSQL_BACKUP_EMAIL=${OLIX_MODULE_MYSQL_BACKUP_EMAIL}"
            ;;
    esac
}
