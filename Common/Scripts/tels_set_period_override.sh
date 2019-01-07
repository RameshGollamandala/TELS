#!/bin/bash

#<<tels_set_period_override.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 15/03/2018  Andrew Mills    v00
#
# Description:
#   File handler script to set the override period for the PPE load.
#
# Invoked By: Trigger File
#   Name: TELS_SETPERIOD_<DEV|TST|UAT|PRD>.txt
#   Parameters: Period Name
#
# Command Line: tels_set_period_override.sh <Trigger File Name>
#
################################################################################

set -x

# Import Environment Variables

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################

target_archive_dir=$PCA_targets_archive
target_badfiles_dir=$PCA_targets_badfiles

#####################################################################
# PROGRAM BEGIN                                                     #
# --- MAY STILL REQUIRE CUSTOMISATION (SEARCH FOR 'TODO' TAGS) ---  #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-SetPeriod]"
echo "[CallScript-SetPeriod]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-SetPeriod]"

echo "[CallScript-SetPeriod] Current FileHandler path: " $filehandlername
echo "[CallScript-SetPeriod] Current FileHandler: " $filehandler
echo "[CallScript-SetPeriod] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-SetPeriod] Current SourceFileType: " $sourcetype
echo "[CallScript-SetPeriod] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-SetPeriod] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

parm=`cat $inboundfolder/$filename`

period_name=`echo $parm | awk '{print $1}'`

################################################################################
#Exit the process, if the workflow not found for filetype;

if [ "$outboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[WorkflowNotFound] Script not found for filetype=$filetype, exiting..."
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

################################################################################
# Call the Utility Function to log the start of an outbound file process

LoggingProcess $filehandler $filename $stagetablename $batchname
processretcode=$?
if [ $processretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi
  
################################################################################
# create an Informatica parameter file to be used by every Workflow called by
# this script  
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

cd $infasrcdir

if [ $srcfiletype = "TELS_SETPERIOD" ]; then
    parameterfile="tels_set_period_override_parm.txt"
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
var1="$""$""period_name"

cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$period_name
EOA

export parameterfile

echo "[CallScript-SetPeriod] Parameter file $parameterfile generated and moved to $infasrcdir. "

cat $parameterfile

################################################################################
# Executing Workflow
# ExecuteWorkflow $infa_foldername $outboundwfname $filehandler $filename
#   $stagetablename $filereccount

ExecuteWorkflow $foldername $outboundwfname $filehandler $filename $stagetablename $filereccount
wfretcode=$?
if [ $wfretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

################################################################################
# Generate Output ODI file-names  based on the srcfiletype from SFX
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

echo "[CallScript-SetPeriod] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "TELS_SETPERIOD" ]; then
  curr_dir=`pwd`
  cd $infatgtdir
  OutputFileName1=$(ls -1 tels_set_period_override.out | head -1)
  cd $curr_dir
  echo "[CallScript-SetPeriod] Output File Name: $OutputFileName1"
fi

################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.

echo "[CallScript-SetPeriod] Calling utility function to check size and move files"

# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

if [ $srcfiletype = "TELS_SETPERIOD" ]; then
    cd $infatgtdir
    targetcount=""
    targetfilename=""
    if [ "$OutputFileName1" != "" ]; then
        filereccount1=`wc -l $infatgtdir/$OutputFileName1 | awk  '{print $1}'`
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount1
        else
            targetcount=$targetcount","$filereccount1
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName1
        else
            targetfilename=$targetfilename","$OutputFileName1
        fi
    fi
    echo "File Summary Start"
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount " " $buname
    echo "File Summary Completed"
    if [ "$OutputFileName1" != "" ]; then
      rm -f $OutputFileName1
    fi
fi

echo "[CallScript-SetPeriod]"
echo "[CallScript-SetPeriod]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode
