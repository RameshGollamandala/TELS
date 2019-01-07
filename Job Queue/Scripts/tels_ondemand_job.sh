#!/bin/bash

#<<tels_ondemand_job.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 21/05/2018  Andrew Mills    v00
#
# Description:
#   File handler script to run On-Demand Jobs and initiate extracts
#
# Invoked By: Trigger File
#   Name: TELS_JOB_<environment (DEV|TST|UAT|PRD)>_<date (YYYYMMDD)>_<id (alpha, plus '-')>.txt
#   Parameters: Each line is one line from an ODJB file
#
# Command Line: tels_ondemand_job.sh <Trigger File Name>
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

echo "[CallScript-OnDemandJob]"
echo "[CallScript-OnDemandJob]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OnDemandJob]"

echo "[CallScript-OnDemandJob] Current FileHandler path: " $filehandlername
echo "[CallScript-OnDemandJob] Current FileHandler: " $filehandler
echo "[CallScript-OnDemandJob] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OnDemandJob] Current SourceFileType: " $sourcetype
echo "[CallScript-OnDemandJob] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OnDemandJob] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

basefile=`echo $filename | cut -d "." -f1`
echo "[CallScript-OnDemandJob] base file: [$basefile]"
cat $infasrcdir/$filename
echo "[CallScript-OnDemandJob] input: [$infasrcdir][$filename]"

unset i

(( i = 0 ))

while IFS='' read -r line || [[ -n "$line" ]]; do
  (( i += 1 ))
  if (( i == 1 )); then
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" > $infatgtdir/$basefile".xml"
    echo "<ONDEMAND_JOB VERSION=\"5.2\" LOCALE=\"en_US\" ORDER_BY_JOBSET=\"true\">" >> $infatgtdir/$basefile".xml"
    echo "<IMPORT_JOBSET TC_CONNECTION_NAME=\"default\" ENVIRONMENT=\"TST\" USERNAME=\"Administrator\" PASSWORD=\"Administrator\" CALENDAR=\"AU Fiscal Calendar Weekly\" STOP_ON_ERROR_FLAG=\"false\">" >> $infatgtdir/$basefile".xml"
  fi
  echo "[CallScript-OnDemandJob] output: [$infatgtdir/$basefile.xml]"
  echo "<PIPELINE_RUN "$line"/>" >> $infatgtdir/$basefile".xml"
done < $infasrcdir/$filename

if (( i > 0 )); then
    echo "</IMPORT_JOBSET>" >> $infatgtdir/$basefile".xml"
    echo "</ONDEMAND_JOB>" >> $infatgtdir/$basefile".xml"
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
# Generate Output ODI file-names  based on the srcfiletype from SFX
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

echo "[CallScript-OnDemandJob] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "TELS_JOB" ]; then
  curr_dir=`pwd`
  cd $infatgtdir
  OutputFileName1=$(ls -1 TELS_JOB_*.xml | head -1)
  cd $curr_dir
  echo "[CallScript-OnDemandJob] Output File Name: $OutputFileName1"
fi

################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.

echo "[CallScript-OnDemandJob] Calling utility function to check size and move files"

# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

if [ $srcfiletype = "TELS_JOB" ]; then
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
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount " " $processing_business_unit
    echo "File Summary Completed"
    if [ "$OutputFileName1" != "" ]; then
        mv $OutputFileName1 $infatgtinboundplain
        echo "$OutputFileName1 Files are ready to move to apps server "
        MoveFilesToOutbound $infatgtinboundplain $OutputFileName1 $target_archive_dir $wftype $wftype1
    fi
fi

echo "[CallScript-OnDemandJob]"
echo "[CallScript-OnDemandJob]  === [$timestamp]::END:: $filehandler ] ==="

exit 0
