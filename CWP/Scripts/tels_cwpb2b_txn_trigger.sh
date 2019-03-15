#!/bin/bash

#<<tels_cwpb2b_txn_trigger.sh>>

#-------------------------------------------------------------------------------
# Date        Author                 Version  Comments
#-------------------------------------------------------------------------------
# 01-Feb-2019  Ramesh Gollamandala   v.1.0     Development and deployment
#
# Description:
#   File handler script to trigger CWP ODI Txn generation process.
#
# Invoked By: Autoloader script upon receiving CWP ODI Trigger file
#   Name: xx
#   Parameters: None
#
# Command Line: tels_cwpb2b_txn_trigger.sh
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
processing_business_unit="Indirect_AU"
cnt_cwpobject=15
cnt_cwpfiles=0
triggerfiletype="CWPB2B"

log=${tenantid_uc}"_"CWPB2BTrigger"_"${timestamp}.log
logfile=$logfolder/$log

cat /dev/null > $logfile

#####################################################################
# PROGRAM BEGIN                                                     #
# --- MAY STILL REQUIRE CUSTOMISATION (SEARCH FOR 'TODO' TAGS) ---  #
#####################################################################

filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CWPB2B-Trigger]" > $logfile
echo "[CWPB2B-Trigger]  === [$timestamp]:: START:: $filehandler ]===" >> $logfile
echo "[CWPB2B-Trigger]" >> $logfile

echo "[CWPB2B-Trigger] CWP B2B ODI Trigger scheduled script started at: $timestamp " >> $logfile

#date_yyyymmdd="20190211"
date_yyyymmdd=`date +%Y%m%d`
v_Todaydate=$date_yyyymmdd


### The below logic is converted to function
##filecnt=`sqlplus -s $lpdb_username/$lpdb_password@$lpdb_connstring<<EOF
##set pagesize 0 feedback off verify off heading off echo off;
##select trim(nvl((select count(*) from TELS_CORE_DATA_FILE_SUMMARY
##where 1 = 1 
##and filehandlername = 'tels_inbound_CWP.sh' 
##and filename like 'DATAHUB_%20190211%.txt'),0)) cnt from dual;
##EOF`

### Function to get the CWP inbound files processed today
Get_CWP_filecount()
{
cnt_cwpfiles=`sqlplus -s $lpdb_username/$lpdb_password <<!

set pagesize 0 feedback off verify off heading off echo off;
select trim(nvl((select count(*) from TELS_CORE_DATA_FILE_SUMMARY
where 1 = 1 
AND filehandlername = 'tels_inbound_CWP.sh' 
AND NVL(RETURNCODE,3) = 0
AND NVL(ERRORCOUNT,3) = 0
and filename like 'DATAHUB_%${date_yyyymmdd}%.txt'),0)) cnt from dual;

!`
}


### Function to get the CWP ProductLines inbound file processed today. to pass on it to Trigger file
Get_PLines_filename()
{
PL_filename=`sqlplus -s $lpdb_username/$lpdb_password <<!

set pagesize 0 feedback off verify off heading off echo off;
select trim(filename) from TELS_CORE_DATA_FILE_SUMMARY
where 1 = 1 
AND filehandlername = 'tels_inbound_CWP.sh' 
AND NVL(RETURNCODE,3) = 0
AND NVL(ERRORCOUNT,3) = 0
AND filename like 'DATAHUB_PRODUCTLINES_%${date_yyyymmdd}%.txt';

!`
}


###Function calls
Get_CWP_filecount

Get_PLines_filename

echo "[CWPB2B-Trigger] Today DataHub CWP files count: $cnt_cwpfiles" >> $logfile
echo "[CWPB2B-Trigger] ProductLines fileName: $PL_filename" >> $logfile
echo "[CWPB2B-Trigger] " >> $logfile

if [ $cnt_cwpfiles -eq $cnt_cwpobject -a "$PL_filename" != '' ] ; then
     echo "[CWPB2B-Trigger] All $cnt_cwpobject files loaded today, so creating the CWPB2B Txn process trigger file"  >> $logfile
	 
	 #sample filename: TELS_CWPB2B_DEV_20190207_020600.txt
     triggerfilename=$tenantid_uc"_"$triggerfiletype"_"$custinst_uc"_"$filetimestamp".txt"

     cd $inboundfolder
     touch $inboundfolder/$triggerfilename
     echo $PL_filename > $inboundfolder/$triggerfilename
     cksum $triggerfilename > $inboundfolder/$triggerfilename".aud"
     
	 status=$?
	 if [ $status -eq 0 ] ; then
	     echo "[CWPB2B-Trigger] Trigger file created" >> $logfile
		 echo "[CWPB2B-Trigger] Exiting script - SUCCESS."
		 SendMail $logfile "SUCCESS" "CWPB2B_ODI_Trigger" "[$timestamp] CWPB2B ODI Trigger file generated"
	 else 
	    echo "[CWPB2B-Trigger] Error creating trigger file, please check" >> $logfile
		echo "[CWPB2B-Trigger] Exiting script - ERROR."
		SendMail $logfile "ERROR" "CWPB2B_ODI_Trigger" "[$timestamp] CWPB2B ODI Trigger file not generated"
		exit $status
     fi
elif [ $cnt_cwpfiles -gt 0 -a $cnt_cwpfiles -lt $cnt_cwpobject ] ; then
     echo "[CWPB2B-Trigger] Couldn't initiate CWP B2B ODI Txn process, since all $cnt_cwpobject files not received from DataHub or not successfully loaded into SkyComm" >> $logfile
	 echo "[CWPB2B-Trigger] Exiting script - ERROR."
	 SendMail $logfile "ERROR" "CWPB2B_ODI_Trigger" "[$timestamp] All 15 CWP files not loaded"
	 exit 1
else
	 echo "[CWPB2B-Trigger] Today, no CWP files received from DataHub, so no need to trigger CWP B2B ODI Txn process, Exiting... " >> $logfile
	 echo "[CWPB2B-Trigger] Exiting script - ERROR."
	 SendMail $logfile "WARNING" "CWPB2B_ODI_Trigger" "[$timestamp] No CWP files received from DataHub today"
	 exit 1
fi

exit 0