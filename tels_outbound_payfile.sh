#!/bin/bash

#<<tels_outbound_payfile.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 12/03/2018  Andrew Mills    v00
#
# Description:
#   File handler script to generate an outbound Payfile file.
#
# Invoked By: Trigger File
#   Name: TELS_PAYFILETRIG_<DEV|TST|UAT|PRD>.txt
#   Parameters: Period Name
#
# Command Line: tels_outbound_payfile.sh <Trigger File Name>
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
processing_business_unit="PCA"

#####################################################################
# PROGRAM BEGIN                                                     #
# --- MAY STILL REQUIRE CUSTOMISATION (SEARCH FOR 'TODO' TAGS) ---  #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-OutboundPayfile]"
echo "[CallScript-OutboundPayfile]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OutboundPayfile]"

echo "[CallScript-OutboundPayfile] Current FileHandler path: " $filehandlername
echo "[CallScript-OutboundPayfile] Current FileHandler: " $filehandler
echo "[CallScript-OutboundPayfile] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OutboundPayfile] Current SourceFileType: " $sourcetype
echo "[CallScript-OutboundPayfile] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OutboundPayfile] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

parm=`cat $inboundfolder/$filename`
period_name=`echo $parm | awk '{print $1}'`
last_char=`echo $period_name | grep -o '.$'`
if [ $last_char = "+" ]; then
    delta_only=0
	new_period=${period_name%\+}
	period_name=$new_period
else
    delta_only=1
fi

echo "[CallScript-OutboundPayfile] Period $period_name will be run for delta_only=$delta_only"

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

if [ $srcfiletype = "TELS_PAYFILETRIG" ]; then
    parameterfile="tels_outbound_payfile_parm.txt"
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
var2="$""$""delta_only"

cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$period_name
$var2=$delta_only
EOA

export parameterfile

echo "[CallScript-OutboundPayfile] Parameter file $parameterfile generated and moved to $infasrcdir. "

cat $parameterfile

###############################################################################################
#Executing Workflow
#ExecuteWorkflow $infa_foldername $outboundwfname $filehandler $filename $stagetablename $filereccount

ExecuteWorkflow $foldername $outboundwfname $filehandler $filename $stagetablename $filereccount
wfretcode=$?
if [ $wfretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

###################################################################################################
# Generate Output ODI file-names  based on the srcfiletype from SFX
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

echo "[CallScript-OutboundPayfile] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "TELS_PAYFILETRIG" ]; then
  curr_dir=`pwd`
  cd $infatgtdir
  OutputFileName1=$(ls -1 cm01* | head -1)
  cd $curr_dir
  echo "[CallScript-OutboundPayfile] Output File Name: $OutputFileName1"
fi

# [TODO] If there are any other output files, add them here (use a conditional IF block on the $srcfiletype if it applies only to a subset of file types)

###############################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.

echo "[CallScript-OutboundPayfile] Calling Utility function to check size and move files to AppServer."

# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

if [ $srcfiletype = "TELS_PAYFILETRIG" ]; then
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
#        rm -rf $OutputFileName1
    fi
    echo " Files are ready to move to dropbox server "
    echo " Target & Error file summary start ..."
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount " " $processing_business_unit
    echo "Target & Error file Summary Completed .."
    if [ "$OutputFileName1" != "" ]; then
        mv $OutputFileName1 $infatgtoutbound
        echo "$OutputFileName1 Files are ready to move to apps server "
        MoveFilesToOutbound $infatgtoutbound $OutputFileName1 $target_archive_dir $wftype $wftype1
    fi
fi

echo "[CallScript-OutboundPayfile]"
echo "[CallScript-OutboundPayfile]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode
