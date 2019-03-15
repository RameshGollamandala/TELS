###############################################################################
# Global Variables
###############################################################################

# File Processing
timestamp=`date +%Y%m%d_%H%M%S`
starttime=`date +%m/%d/%Y-%H:%M:%S`
timestp=`date +%Y%m%d`
filetimestamp=`date +%Y%m%d_%H%M%S`
filedate=`date +%m%d%Y_%H%M`

# Informatica Details
service="IS_lnd${tenantid}${custinst}"
domain="Domain_lnd${tenantid}${custinst}"
repositoryname="TCAnalytics${custinst_uc}"

################################################################################
# Common directories and scripts
################################################################################

#Tenant folders
basedir=/apps/Callidus
tntdir=$basedir/$tenantid
backupfolder=$tntdir/backup
logfolder=$tntdir/logs
workdir=$tntdir/workarea
tntscriptsdir=$tntdir/integrator
datafile=$tntdir/datafiles
archivefolder=$datafile/archive
badfilesfolder=$datafile/badfiles
inboundfolder=$datafile/inbound
lndoutboundfolder=$datafile/outbound
tempdir=$datafile/temp
outboundfolder=$datafile/toapp
stagefolder=$datafile/staging
dependencycheck="${datafile}/dependencycheck"

#Informatica folders
infabase="/apps/Informatica/PowerCenter10.1.1/server/infa_shared"
infasrcdir=$infabase"/SrcFiles"
infabadfiledir=$infabase"/BadFiles"
infacachedir=$infabase"/Cache"
infasessiondir=$infabase"/SessLogs"
infaworkflowdir=$infabase"/WorkflowLogs"
infatgtdir=$infabase"/TgtFiles"
infatgtoutbound=$infatgtdir"/outbound"
infatgtinbound=$infatgtdir"/inbound"
infatgtinboundplain=$infatgtdir"/inbound-plain"

#Scripts
tntsetenvname="${tenantid}_setenv_variable.sh"
inboundfilerun_start="${tenantid}_inboundfilerun_start.sh"   
inboundfilerun_end="${tenantid}_inboundfilerun_end.sh"
datafilesummary_start="${tenantid}_datafilesummary_start.sh"
datafilesummary_end="${tenantid}_datafilesummary_end.sh"
codemap="${tenantid}_codemap.conf"
typemap_conf="${tenantid}_typemap.conf"
email_conf="${tenantid}_email.conf"
datasummary="${tenantid}_datasummary.sh"

################################################################################
# BU Specific directories
################################################################################

# Telstra File Folder Archive for all Sources
indirect_bu_archive=$datafile/Indirect_AU

# Unknown badfiles archive folders
Unknown_archive=$indirect_bu_archive/unknown
Unknown_sources_badfiles=$Unknown_archive/sources/badfiles

# PIMS User archive folders
PIMS_User_archive=$indirect_bu_archive/pims_user
PIMS_User_sources_archive=$PIMS_User_archive/sources/archive
PIMS_User_sources_badfiles=$PIMS_User_archive/sources/badfiles
PIMS_User_targets_archive=$PIMS_User_archive/targets/archive
PIMS_User_targets_badfiles=$PIMS_User_archive/targets/badfiles

# Audit Log archive folders
Audit_Log_archive=$indirect_bu_archive/audit_log
Audit_Log_sources_archive=$Audit_Log_archive/sources/archive
Audit_Log_sources_badfiles=$Audit_Log_archive/sources/badfiles
Audit_Log_targets_archive=$Audit_Log_archive/targets/archive
Audit_Log_targets_badfiles=$Audit_Log_archive/targets/badfiles

# CCG Tools archive folders
CCG_Tools_archive=$indirect_bu_archive/ccg_tools
CCG_Tools_sources_archive=$CCG_Tools_archive/sources/archive
CCG_Tools_sources_badfiles=$CCG_Tools_archive/sources/badfiles
CCG_Tools_targets_archive=$CCG_Tools_archive/targets/archive
CCG_Tools_targets_badfiles=$CCG_Tools_archive/targets/badfiles

# Repository Export archive folders
Rep_Export_archive=$indirect_bu_archive/rep_export
Rep_Export_sources_archive=$Rep_Export_archive/sources/archive
Rep_Export_sources_badfiles=$Rep_Export_archive/sources/badfiles
Rep_Export_targets_archive=$Rep_Export_archive/targets/archive
Rep_Export_targets_badfiles=$Rep_Export_archive/targets/badfiles

# Bulk Dealer archive folders
Bulk_Dealer_archive=$indirect_bu_archive/bulk_dealer
Bulk_Dealer_sources_archive=$Bulk_Dealer_archive/sources/archive
Bulk_Dealer_sources_badfiles=$Bulk_Dealer_archive/sources/badfiles
Bulk_Dealer_targets_archive=$Bulk_Dealer_archive/targets/archive
Bulk_Dealer_targets_badfiles=$Bulk_Dealer_archive/targets/badfiles

# Bulk Dealer archive folders
OrderExpress_archive=$indirect_bu_archive/order_express
OrderExpress_sources_archive=$OrderExpress_archive/sources/archive
OrderExpress_sources_badfiles=$OrderExpress_archive/sources/badfiles
OrderExpress_targets_archive=$OrderExpress_archive/targets/archive
OrderExpress_targets_badfiles=$OrderExpress_archive/targets/badfiles

# PCA archive folders
PCA=$indirect_bu_archive/pca
PCA_sources_archive=$PCA/sources/archive
PCA_sources_badfiles=$PCA/sources/badfiles
PCA_targets_archive=$PCA/targets/archive
PCA_targets_badfiles=$PCA/targets/badfiles
