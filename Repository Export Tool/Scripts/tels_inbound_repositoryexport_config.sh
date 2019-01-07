#!/bin/bash

#<<tels_inbound_repositoryexport_config.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 19/07/2018  Simon Marsh     v01
#
# Description:
#   File handler script to receive a custom-formatted file and load to DB
#
# Invoked By: LND Autoloader based on the mapping of file-type to file handler
#   script name.
#
# Command Line: tels_inbound_repositoryexport_config.sh <inbound filename without path>
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################
target_archive_dir=$Rep_Export_targets_archive
target_badfiles_dir=$Rep_Export_targets_badfiles
processing_business_unit=$buname

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################
filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript]"
echo "[CallScript]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript]"

echo "[CallScript] Current FileHandler path: " $filehandlername
echo "[CallScript] Current FileHandler: " $filehandler
echo "[CallScript] $tenantid_uc Supplied Inbound file name : " $filename
echo "[CallScript] Current SourceFileType: " $sourcetype
echo "[CallScript] $tenantid_uc INBOUND filetype: " $filetype
echo "[CallScript] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

###################################################################################################
#Exit the process, if the workflow not found for filetype;

if [ "$inboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[WorkflowNotFound] Script not found for filetype=$filetype, exiting..."
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

###################################################################################################
# Call the Utility Function to log the start of an inbound file process

LoggingProcess $filehandler $filename $stagetablename $batchname
processretcode=$?
if [ $processretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi
  
echo "[CallScript] Source & File Type is: $srcfiletype"

###############################################################################################
# create an Informatica parameter file to be used by every Workflow called by this script  
cd $infasrcdir

if [ $srcfiletype = "TELS_REPOSITORYEXPORTCONFIG" ]; then
    parameterfile="${tenantid_uc}_"$filetype"_parm.txt"
	ErrorFileName1="${tenantid_uc}_"$filetype"_Error_"$timestamp".txt"
fi

hdr1="[Global]"
g_var1="$""PMWorkflowLogDir"
g_var2="$""PMSessionLogDir"
g_var3="$""PMCacheDir"
g_var4="$""PMBadFileDir"
g_var5="$""PMSourceFileDir"
g_var6="$""PMTargetFileDir"
g_extuser="$""Paramextuser"
g_extpwd="$""Paramextpwd"
var1="$""$""filename"
var2="$""$""prestage_tablename"
var3="$""InputFileName"

cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$filename
$var2=$stagetablename
$var3=$filename
EOA

export parameterfile
echo "[CallScript] Parameter file $parameterfile generated and moved to $infasrcdir. "
echo ""
cat $parameterfile
echo ""

###############################################################################################
#Executing Workflow
#ExecuteWorkflow $infa_foldername $inboundwfname $filehandler $filename $stagetablename $filereccount
ExecuteWorkflow $foldername $inboundwfname $filehandler $filename $stagetablename $filereccount

wfretcode=$?
if [ $wfretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

echo "[CallScript] Summarising run"
sh $tntscriptsdir/$datasummary $filehandler $filename " " " " $ErrorFileName1 $processing_business_unit

echo "[CallScript]"
echo "[CallScript]  === [$timestamp]::END:: $filehandler ] ==="
exit $wfretcode
