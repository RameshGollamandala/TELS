#!/bin/bash

#<<tels_outbound_pcs.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 14/03/2018  Andrew Mills    v00
#
# Description:
#   File handler script to generate an outbound Partner Commission Statement
#   file.
#
# Invoked By: Trigger File
#   Name: TELS_PCSTRIG_<DEV|TST|UAT|PRD>.txt
#   Parameters: Period Name
#
# Command Line: tels_outbound_pcs.sh <Trigger File Name>
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

echo "[CallScript-OutboundPCS]"
echo "[CallScript-OutboundPCS]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OutboundPCS]"

echo "[CallScript-OutboundPCS] Current FileHandler path: " $filehandlername
echo "[CallScript-OutboundPCS] Current FileHandler: " $filehandler
echo "[CallScript-OutboundPCS] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OutboundPCS] Current SourceFileType: " $sourcetype
echo "[CallScript-OutboundPCS] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OutboundPCS] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

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

if [ $srcfiletype = "TELS_PCSTRIG" ]; then
    parameterfile="tels_outbound_pcs_parm.txt"
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

echo "[CallScript-OutboundPCS] Parameter file $parameterfile generated and moved to $infasrcdir. "

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

echo "[CallScript-OutboundPCS] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "TELS_PCSTRIG" ]; then
  curr_dir=`pwd`
  cd $infatgtdir
  OutputFileName_base=$(ls -1 CCB-COMM_SENDPARTNERCOMMISSIONDATA_*.ctl | head -1 | cut -d "." -f1)
  OutputFileName1=${OutputFileName_base}".ctl"
  OutputFileName2=${OutputFileName_base}".dat"
  OutputFileName3=${OutputFileName_base}".eot"
  #OutputFileName1=$(ls -1 CCB-COMM_SENDPARTNERCOMMISSIONDATA_*.ctl | head -1)
  #OutputFileName2=$(ls -1 CCB-COMM_SENDPARTNERCOMMISSIONDATA_*.dat | head -1)
  #OutputFileName3=$(ls -1 CCB-COMM_SENDPARTNERCOMMISSIONDATA_*.eot | head -1)
  cd $curr_dir
  echo "[CallScript-OutboundPCS] Output File Name - Header: $OutputFileName1"
  echo "[CallScript-OutboundPCS] Output File Name - Detail: $OutputFileName2"
  echo "[CallScript-OutboundPCS] Output File Name - Footer: $OutputFileName3"
fi

# [TODO] If there are any other output files, add them here (use a conditional IF block on the $srcfiletype if it applies only to a subset of file types)

###############################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.

echo "[CallScript-OutboundPCS] Calling Utility function to check size and move files to AppServer."

# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

if [ $srcfiletype = "TELS_PCSTRIG" ]; then
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
    if [ "$OutputFileName2" != "" ]; then
        filereccount2=`wc -l $infatgtdir/$OutputFileName2 | awk  '{print $1}'`
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount2
        else
            targetcount=$targetcount","$filereccount2
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName2
        else
            targetfilename=$targetfilename","$OutputFileName2
        fi
    fi
    if [ "$OutputFileName3" != "" ]; then
        filereccount3=`wc -l $infatgtdir/$OutputFileName3 | awk  '{print $1}'`
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount3
        else
            targetcount=$targetcount","$filereccount3
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName3
        else
            targetfilename=$targetfilename","$OutputFileName3
        fi
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
    if [ "$OutputFileName2" != "" ]; then
        mv $OutputFileName2 $infatgtoutbound
        echo "$OutputFileName2 Files are ready to move to apps server "
        MoveFilesToOutbound $infatgtoutbound $OutputFileName2 $target_archive_dir $wftype $wftype1
    fi
    if [ "$OutputFileName3" != "" ]; then
        mv $OutputFileName3 $infatgtoutbound
        echo "$OutputFileName3 Files are ready to move to apps server "
        MoveFilesToOutbound $infatgtoutbound $OutputFileName3 $target_archive_dir $wftype $wftype1
    fi
fi

echo "[CallScript-OutboundPCS]"
echo "[CallScript-OutboundPCS]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode
