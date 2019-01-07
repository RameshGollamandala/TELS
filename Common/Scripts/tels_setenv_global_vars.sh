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
PCA=$basedir/pca
PCA_sources_basedir=$PCA/informatica/sources
PCA_sources_archive=$PCA_sources_basedir/archive
PCA_sources_badfiles=$PCA_sources_basedir/badfiles
PCA_targets_basedir=$PCA/informatica/targets
PCA_targets_archive=$PCA_targets_basedir/archive
PCA_targets_badfiles=$PCA_targets_basedir/badfiles

################################################################################
# Anything else
################################################################################

# # Import Environment Variables

# . /home/callidus/.bash_profile

# # Set Tenant ID

# tenantid="tels"
# tenantid_uc="TELS"

# custinst="dev"
# custinst_uc="DEV"

# #
# # Set Environment Variables
# #

# # Data Files Folders

# basedir=/apps/Callidus

# tntdir=$basedir/$tenantid

# backupfolder=$tntdir/backup
# datafile=$tntdir/datafiles
# logfolder=$tntdir/logs
# workdir=$tntdir/workarea

# archivefolder=$datafile/archive
# badfilesfolder=$datafile/badfiles
# inboundfolder=$datafile/inbound
# lndoutboundfolder=$datafile/outbound
# tempdir=$datafile/temp
# outboundfolder=$datafile/toapp

# stagefolder=$datafile/staging

# # Tenant Script Directories

# tntscriptsdir=$tntdir/integrator

# # typemap -> typemap_conf
# typemap_conf="${tenantid}_typemap.conf"
# # email -> email_conf
# email_conf="${tenantid}_email.conf"

# # Telstra File Folder Archive for all Sources

# PCA=$basedir/pca

# PCA_sources_basedir=$PCA/informatica/sources

# PCA_sources_archive=$PCA_sources_basedir/archive
# PCA_sources_badfiles=$PCA_sources_basedir/badfiles

# PCA_targets_basedir=$PCA/informatica/targets

# PCA_targets_archive=$PCA_targets_basedir/archive
# PCA_targets_badfiles=$PCA_targets_basedir/badfiles

# # File Processing

# timestamp=`date +%Y%m%d_%H%M%S`

# # Informatica Details

# service="IS_lnd${tenantid}${custinst}"

# domain="Domain_lnd${tenantid}${custinst}"

# # username --> infa_username
# infa_username="Administrator"
# # password --> infa_password
# infa_password="hl0lqiMVSe"

# # Landing Pad Database Details

# # dbusername --> lpdb_username
# lpdb_username="telsadmin"
# # dbpwd --> lpdb_password
# lpdb_password="telsadmin"

# repositoryname="TCAnalytics${custinst_uc}"

# infatgtdir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles"
# infasrcdir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/SrcFiles"
# infabadfiledir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/BadFiles"
# infacachedir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/Cache"
# infasessiondir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/SessLogs"
# infaworkflowdir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/WorkflowLogs"
# infatgtoutbound="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/outbound"
# infatgtinbound="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/inbound"
# infatgtinboundplain="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/inbound-plain"

# dependencycheck="${datafile}/dependencycheck"

# #####
# #####
# ##### Not confirmed required for TELS below here #####
# #####
# #####

# ## set this to 1 to allow PEX trigger files for each BU to be created and processed
# ## otherwise set to 0 to only load PEX data into LND table.
# env_tlst_pex_create_trigger_files="1"

# # delay in the time for file processing
# delaytimer="300"

# # gpg Encoder Code Map
# # ADD YOUR KEY HERE AFTER ARRANGING WITH SUPPORT
# gpgcodemap="AAAAAAA"

# # Database Details
# #"LND-tlst-PRD" Connection string
# dbconnstring="tlstprd"
# #dbusername="tlstprd"
# #dbpwd=""

# truecomp_username="Administrator"
# truecomp_password="XXXXX"

# dbtrnusername="cortana_transform"
# dbtrnpassword="XXXXX"
# dbtmpusername="cortana_template"
# dbtmppassword="XXXXX"


# infaarchive="/apps/Callidus/tlst/archive"
# backupdir="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/Backup"
# org_inbound="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/org_inbound"
# CSD_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/CSD_PEX"
# TW_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/TW_PEX"
# GCC_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/GCC_PEX"
# GESA_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/GESA_PEX"
# GESI_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/GESI_PEX"
# TCW_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/TCW_PEX"
# DATA_EXTRACT="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/DATA_EXTRACT"
# BTS_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/BTS_PEX"
# T007_PEX="/apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/T007_PEX"

# #BusinessUnit Targets
# twtargetdir=$infatgtdir/TW
# csdtargetdir=$infatgtdir/CSD
# gcctargetdir=$infatgtdir/GCC
# gesatargetdir=$infatgtdir/GESA
# tcwtargetdir=$infatgtdir/TCW
# t007targetdir=$infatgtdir/T007
# gesitargetdir=$infatgtdir/GESI
# DATA_EXTRACTtargetdir=$infatgtdir/DATA_EXTRACT
# btstargetdir=$infatgtdir/BTS

# # Telstra File Folder Archive  For all Sources 
# basedir=/apps/Callidus
# cortana=$basedir/CORTANA
# PEXbasedir=$cortana/PEX/INFORMATICA/SOURCES
# GCCbasedir=$cortana/GCC/INFORMATICA/SOURCES
# CSDbasedir=$cortana/CSD/INFORMATICA/SOURCES
# TWbasedir=$cortana/TW/INFORMATICA/SOURCES
# GESAbasedir=$cortana/GESA/INFORMATICA/SOURCES
# GESIbasedir=$cortana/GESI/INFORMATICA/SOURCES
# TCWbasedir=$cortana/TCW/INFORMATICA/SOURCES
# T007basedir=$cortana/T007/INFORMATICA/SOURCES
# DATA_EXTRACTbasedir=$cortana/DATA_EXTRACT/INFORMATICA/SOURCES
# BTSbasedir=$cortana/BTS/INFORMATICA/SOURCES

# PEXbadfiles=$PEXbasedir/badfiles
# CSDbadfiles=$CSDbasedir/badfiles
# GCCbadfiles=$GCCbasedir/badfiles
# TWbadfiles=$TWbasedir/badfiles
# GESAbadfiles=$GESAbasedir/badfiles
# GESIbadfiles=$GESIbasedir/badfiles
# TCWbadfiles=$TCWbasedir/badfiles
# T007badfiles=$T007basedir/badfiles
# DATA_EXTRACTbadfiles=$DATA_EXTRACTbasedir/badfiles
# BTSbadfiles=$BTSbasedir/badfiles

# PEXarchive=$PEXbasedir/archive
# CSDarchive=$CSDbasedir/archive
# GCCarchive=$GCCbasedir/archive
# TWarchive=$TWbasedir/archive
# GESAarchive=$GESAbasedir/archive
# GESIarchive=$GESIbasedir/archive
# TCWarchive=$TCWbasedir/archive
# T007archive=$T007basedir/archive
# DATA_EXTRACTarchive=$DATA_EXTRACTbasedir/archive
# BTSarchive=$BTSbasedir/archive

# # Telstra File Folder Archive  For all Targets
# basedir=/apps/Callidus
# cortana=$basedir/CORTANA
# PEXTGTbasedir=$cortana/PEX/INFORMATICA/TARGETS
# GCCTGTbasedir=$cortana/GCC/INFORMATICA/TARGETS
# CSDTGTbasedir=$cortana/CSD/INFORMATICA/TARGETS
# TWTGTbasedir=$cortana/TW/INFORMATICA/TARGETS
# TCWTGTbasedir=$cortana/TCW/INFORMATICA/TARGETS
# GESATGTbasedir=$cortana/GESA/INFORMATICA/TARGETS
# GESITGTbasedir=$cortana/GESI/INFORMATICA/TARGETS
# T007TGTbasedir=$cortana/T007/INFORMATICA/TARGETS
# DATA_EXTRACTTGTbasedir=$cortana/DATA_EXTRACT/INFORMATICA/TARGETS
# BTSTGTbasedir=$cortana/BTS/INFORMATICA/TARGETS

# PEXTGTbadfiles=$PEXTGTbasedir/badfiles
# CSDTGTbadfiles=$CSDTGTbasedir/badfiles
# GCCTGTbadfiles=$GCCTGTbasedir/badfiles
# TWTGTbadfiles=$TWTGTbasedir/badfiles
# GESATGTbadfiles=$GESATGTbasedir/badfiles
# GESITGTbadfiles=$GESITGTbasedir/badfiles
# TCWTGTbadfiles=$TCWTGTbasedir/badfiles
# T007TGTbadfiles=$T007TGTbasedir/badfiles
# DATA_EXTRACTTGTbadfiles=$DATA_EXTRACTTGTbasedir/badfiles
# BTSTGTbadfiles=$BTSTGTbasedir/badfiles

# PEXTGTarchive=$PEXTGTbasedir/archive
# CSDTGTarchive=$CSDTGTbasedir/archive
# TWTGTarchive=$TWTGTbasedir/archive
# GCCTGTarchive=$GCCTGTbasedir/archive
# GESATGTarchive=$GESATGTbasedir/archive
# TCWTGTarchive=$TCWTGTbasedir/archive
# T007TGTarchive=$T007TGTbasedir/archive
# GESITGTarchive=$GESITGTbasedir/archive
# DATA_EXTRACTTGTarchive=$DATA_EXTRACTTGTbasedir/archive
# BTSTGTarchive=$BTSTGTbasedir/archive
# #ODI Script Directories
# odiscriptsdir="/apps/Callidus/ondemand/integrator"

# #Tenant Script Directories
# tntsetenvname="${tenantid}_setenv_variable.sh"
# executeworkflow="${tenantid}_executeworkflow.sh"
# inboundfilerun_start="${tenantid}_inboundfilerun_start.sh"   
# inboundfilerun_end="${tenantid}_inboundfilerun_end.sh"
# datafilesummary_start="${tenantid}_datafilesummary_start.sh"
# datafilesummary_end="${tenantid}_datafilesummary_end.sh"
# datasummary="${tenantid}_datasummary.sh"
# concatenate="${tenantid}_concatenate_all.sh"
# statusmail="${tenantid}_statusmail.sh"
# codemap="${tenantid}_codemap.conf"


# # File Processing
# starttime=`date +%m/%d/%Y-%H:%M:%S`
# timestp=`date +%Y%m%d`
# filetimestamp=`date +%Y%m%d_%H%M%S`
# filedate=`date +%m%d%Y_%H%M`
