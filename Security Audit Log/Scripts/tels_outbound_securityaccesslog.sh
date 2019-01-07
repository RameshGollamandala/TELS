#!/bin/bash

#<<tels_outbound_securityaccesslog.sh>>

#-------------------------------------------------------------------------------
# Date        Author                Version   Comments
#-------------------------------------------------------------------------------
# 08/04/2018  Ramesh Gollamandala   v1.0
# 30/07/2018  Simon Marsh			v2.0
# 
# Description:
#   File handler script to generate Security auditlog outbound file.
#
# Invoked By: CRON Job automation to invoke for every one hour
#   Name: N/A
#   Parameters: Not required
#
# Command Line: sh tels_outbound_securityaccesslog.sh
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# TO DO : LOCAL VARAIBLES
target_archive_dir=$Audit_Log_targets_archive
#target_badfiles_dir=$PCA_targets_badfiles
#filesrc=$1
#filetype=$2

filehandlername="tels_outbound_securityaccesslog.sh"
filesrc="TELS"
filetype="AUDITTRIG"

filehandler=`echo $filehandlername | cut -d "/" -f6`
log=${tenantid_uc}"_"${filetype}"_"${timestamp}.log
logfile=$logfolder/$log
filereccount=0

v_StartWindow=`date +%Y%m%d_%H -d "-1 Hour"`"0000"
v_EndWindow=`date +%Y%m%d_%H`"0000"
#v_StartWindow="20180601_000000"
#v_EndWindow="20180627_235959"
#OutputFileName1="SKYCOMM_SECURITYACCESSLOG_"${v_StartWindow}"_"${custinst_uc}".txt"

envtag=""
if [ ${custinst_uc} = "PRD" ]; then
  envtag=""
elif [ ${custinst_uc} = "UAT" ]; then
  envtag="PAA_"
else
  envtag=${custinst_uc}"_"
fi
OutputFileName1="TELS_"$envtag"AUDITLOG_"${v_StartWindow}".txt"

if [ "$filesrc" = "" -a "$filetype" = "" ]; then
    echo "[CallScript-OutboundAuditfile] Invalid input arguments, exiting process." | tee -a $logfile
	exit 1
fi

#FunctionCall: Read typemap config file and get required parameters
ReadParameters $filesrc $filetype
retcode=$?

echo "[CallScript-OutboundAuditfile]  === [$timestamp]:: START:: $filehandler ]==="   | tee -a $logfile
echo "[CallScript-OutboundAuditfile]"  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] Current FileHandler path: " $filehandlername  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] Current FileHandler: "$filehandler  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] Current SourceFileType:" $srcfiletype  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] $tenantid_uc Outbound filename: " $OutputFileName1  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] Security Access logging Window Start: $v_StartWindow"  | tee -a $logfile
echo "[CallScript-OutboundAuditfile] Security Access logging Window End: $v_EndWindow"  | tee -a $logfile
echo "[CallScript-OutboundAuditfile]"  | tee -a $logfile

################################################################################
#Exit the process, if the workflow not found for filetype;
if [ "$outboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[CallScript-OutboundAuditfile] Workflow not found for filetype=$filetype, exiting..."  | tee -a $logfile
    exit 1
fi

#Send an alert mail, file received
#if [  "$retcode" = 0 ] ; then 
#    SendMail $logfile "ALERT" "$srcfiletype" "Security Access Logging Started"
#fi 

################################################################################
# Call the Utility Function to log the start of an outbound file process
LoggingProcess $filehandler $srcfiletype $stagetablename $batchname
processretcode=$?
if [ $processretcode -ne 0 ]; then
    exit 1
fi
  
################################################################################
# create an Informatica parameter file 
cd $infasrcdir

if [ $srcfiletype = "TELS_AUDITTRIG" ]; then
    parameterfile="tels_outbound_securityauditlog_parm.txt"
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
var1="$""outputfilename"
var2="$""$""p_StartTime"
var3="$""$""p_EndTime"

cat > $parameterfile <<-EOA
$header
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$OutputFileName1
$var2=$v_StartWindow
$var3=$v_EndWindow
EOA

export parameterfile
echo "[CallScript-OutboundAuditfile] Parameter file $parameterfile generated and moved to $infasrcdir. "  | tee -a $logfile
cat $parameterfile  | tee -a $logfile
echo ""

###############################################################################################
#Executing Workflow
echo "[CallScript-OutboundAuditfile] Executing Outbound workflow : $outboundwfname"  | tee -a $logfile
ExecuteWorkflow $foldername $outboundwfname $filehandler $srcfiletype $stagetablename $filereccount
wfretcode=$?

if [ $wfretcode -ne 0 ]; then
	echo "[CallScript-OutboundAuditfile] Error executing Outbound workflow [$outboundwfname], please check Workflow log for more details."  | tee -a $logfile
    echo "wfret=1" > $tempdir/wfreturncode.txt
	exit 1
else 
    echo "[CallScript-OutboundAuditfile] Outbound workflow [$outboundwfname] completed succesfully..."  | tee -a $logfile
fi

###############################################################################################
# This will Check the file size and moves non-empty files to AppServer
echo "[CallScript-OutboundAuditfile] Calling Utility function to check size and move files to AppServer."  | tee -a $logfile

if [ $srcfiletype = "TELS_AUDITTRIG" ]; then
    cd $infatgtdir
    targetcount=""
    targetfilename=""
    if [ "$OutputFileName1" != "" ]; then
		filereccount1=`cat $infatgtdir/$OutputFileName1 | sed '1d' | wc -l | awk  '{print $1}'` # Outbound file record count - Excluding file header
		#filereccount1=`wc -l $infatgtdir/$OutputFileName1 | awk  '{print $1}'` # Outbound file record count - Including file header
		
		echo "[CallScript-OutboundAuditfile] Record count in Output file (excluding file header) : $filereccount1"  | tee -a $logfile
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount1
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName1
        fi
    fi

    echo "[CallScript-OutboundAuditfile] Target & Error file summary start ..."  | tee -a $logfile
	sh $tntscriptsdir/$datasummary $filehandler $srcfiletype $targetfilename $targetcount " " $buname
    echo "[CallScript-OutboundAuditfile] Target & Error file Summary Completed .."  | tee -a $logfile

	if [ "$targetcount" -gt 1 ]; then
        mv $OutputFileName1 $infatgtoutbound
        echo "[CallScript-OutboundAuditfile] Files are ready to move to dropbox server "  | tee -a $logfile
        MoveFilesToOutbound $infatgtoutbound $OutputFileName1 $target_archive_dir $wftype $wftype1
		retcode=$?
#	else #Commenting out; if there are no log events then an empty file is legitimate
#	   echo "[CallScript-OutboundAuditfile] Outbound file is empty, exiting process."  | tee -a $logfile
#	   rm -f $infatgtdir/$OutputFileName1*
#	   retcode=1
	fi
fi

if [ "$retcode" -eq 0 ] ; then
    echo "[CallScript-OutboundAuditfile] $retcode - Script execution completed succesfully."   | tee -a $logfile
    echo "[CallScript-OutboundAuditfile] Archiving the files after successful execution."  | tee -a $logfile
    #echo "[CallScript-OutboundAuditfile] Sending SUCCESS mail, with log."  | tee -a $logfile
	ErrorCount $filesrc $srcfiletype
    #SendMail $logfile "SUCCESS" "$srcfiletype" "SUCCESS: Security Audit log process"  | tee -a $logfile #Dont send an email; this script runs every hour!
else
    echo "[CallScript-OutboundAuditfile] $retcode - Error in executing script, check Log Files for more information."  | tee -a $logfile
    echo "[CallScript-OutboundAuditfile] Sending ERROR mail, with log."   | tee -a $logfile
    SendMail $logfile "ERROR" "$srcfiletype" "ERROR: Security Audit log process"  | tee -a $logfile
    exit $retcode
fi

rm -f $infatgtdir/$OutputFileName1

echo "[CallScript-OutboundAuditfile]"  | tee -a $logfile
echo "[CallScript-OutboundAuditfile]  === [$timestamp]::END:: $filehandler ] ==="  | tee -a $logfile

exit $wfretcode
