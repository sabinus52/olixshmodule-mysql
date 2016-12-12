###
# Fichier obligatoire contenant la configuration et l'initialisation du module
# ==============================================================================
# @package olixsh
# @module mysql
# @label Utilitaires pour les bases MySQL
# @author Olivier <sabinus52@gmail.com>
##



###
# Paramètres du modules
##



###
# Chargement des librairies requis
##
olixmodule_mysql_require_libraries()
{
    load "modules/mysql/conf/params.sh"
    load "modules/mysql/lib/*"
}


###
# Retourne la liste des modules requis
##
olixmodule_mysql_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_mysql_require_binary()
{
    echo -e "mysql mysqldump"
}


###
# Traitement à effectuer au début d'un traitement
##
olixmodule_mysql_include_begin()
{
    olixmodule_mysql_params_parse $@
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_mysql_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
olixmodule_mysql_list()
{
    Mysql.server.check || return
    Mysql.server.databases
}
