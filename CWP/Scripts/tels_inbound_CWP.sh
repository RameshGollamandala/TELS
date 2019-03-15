#!/bin/bash

#<<tels_inbound_CWP.sh>>

#-------------------------------------------------------------------------------
# Date        Author                 Version  Comments
#-------------------------------------------------------------------------------
# 04/01/2019  Ramesh Gollamandala    v0.0     Development and deployment
#
# Description:
#   File handler script to process Inbound CWP objects feed files
#
# Invoked By: Autoloader script upon receiving CWP inbound file
#   Name: xx
#   Parameters: None
#
# Command Line: xx
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################

processing_business_unit="Indirect_AU"
source_archive_dir=$PCA_sources_archive
source_badfiles_dir=$PCA_sources_badfiles

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-CWP]"
echo "[CallScript-CWP]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-CWP]"

echo "[CallScript-CWP] Current FileHandler path: " $filehandlername
echo "[CallScript-CWP] Current FileHandler: " $filehandler
echo "[CallScript-CWP] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-CWP] Current SourceFileType: " $sourcetype
echo "[CallScript-CWP] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-CWP] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

################################################################################
#Exit the process, if the workflow not found for filetype;
if [ "$inboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[WorkflowNotFound] Script not found for filetype=$filetype, exiting..."
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

################################################################################
# Call the Utility Function to log the start of an inbound file process
LoggingProcess $filehandler $filename $stagetablename $batchname
processretcode=$?
if [ $processretcode -ne 0 ]; then
	echo "wfret=1" > $tempdir/wfreturncode.txt
	exit 1
fi

echo "[CallScript] Checking to see if we have processed this file before..."
filename_str="'$filename'"
file_processdate=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
declare
  l_file_processdate varchar2(4000);
begin
  SELECT MAX(BATCHPROCESSDATE) PROCESSDATE INTO l_file_processdate FROM TELS_INBOUND_FILE_ATTRIBUTES WHERE FILENAME = $filename_str;
  dbms_output.put_line(l_file_processdate);
end;
/
!`	

if [ "$file_processdate" = "" ]; then
  echo "[CallScript]     No, First time"
else
  echo "[CallScript]     Yes. Processed on $file_processdate, Exiting"
  SendMail " " "ERROR" $filename $filename" has already been processed before on "$file_processdate
  exit 1
fi

################################################################################
# create an Informatica parameter file to be used by every Workflow called by this script  
cd $infasrcdir
parameterfile="TELS_INBOUND_CWP_parm.txt"
#cat /dev/null > $parameterfile
	
echo "[CallScript-CWP] Inbound File Name: $filename"
	
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
var2="$""InputFileName"
var3="$""$""prestage_tablename"

cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$filename
$var2=$filename
$var3=$stagetablename
EOA

export $parameterfile
echo "[CallScript-CWP] Parameter file $parameterfile generated and moved to $infasrcdir. "
echo "[CallScript-CWP] Parameters:"
echo ""
cat $parameterfile

###############################################################################################
#Executing Inbound Workflow
ExecuteWorkflow $foldername $inboundwfname $filehandler $filename $stagetablename $filereccount
wfretcode=$?
if [ $wfretcode -ne 0 ]; then
	echo "wfret=1" > $tempdir/wfreturncode.txt
	sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount " " $processing_business_unit
	exit 1
else 
   echo "wfret=0" > $tempdir/wfreturncode.txt
fi
	
echo "[CallScript-CWP]"
echo "[CallScript-CWP]  === [$timestamp]::END:: $filehandler ] ==="

sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount " " $processing_business_unit

exit $wfretcode