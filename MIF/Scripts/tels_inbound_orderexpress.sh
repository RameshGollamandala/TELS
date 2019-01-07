#!/bin/bash

#<<tels_inbound_orderexpress.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 19/07/2018  Simon Marsh     v01
#
# Description:
#   File handler script to receive a custom-formatted file and convert to 
#   standard ODI transaction files.
#
# Invoked By: LND Autoloader based on the mapping of file-type to file handler
#   script name.
#
# Command Line: tels_inbound_orderexpress.sh <inbound filename without path>
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################
target_archive_dir=$OrderExpress_targets_archive
target_badfiles_dir=$OrderExpress_targets_badfiles

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
 #SELECT Count(*) COUNT INTO l_file_count FROM TELS_INBOUND_FILE_ATTRIBUTES WHERE FILENAME = $filename_str;

if [ "$file_processdate" = "" ]; then
  echo "[CallScript]     No, First time"
else
  echo "[CallScript]     Yes. Processed on $file_processdate, Exiting"
  SendMail " " "ERROR" $filename $filename" has already been processed before on "$file_processdate
  exit 1
fi
  
###################################################################################################
# Generate Output ODI file-names  based on the srcfiletype from SFX
echo "[CallScript] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "ORDEREXPRESS_MIF" ]; then
    OutputFileName1=$tenantid_uc"_TXSTAG_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp".txt"
	OutputFileName2=$tenantid_uc"_TXTA_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp".txt"
	OutputFileName3=$tenantid_uc"_TXTG_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp".txt"
fi

OutputFileName4=$tenantid_uc"_ERROR_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp".txt"

echo "[CallScript] Generated output file name 1: $OutputFileName1"
echo "[CallScript] Generated output file name 2: $OutputFileName2"
echo "[CallScript] Generated output file name 3: $OutputFileName3"
echo "[CallScript] Generated error file name 1: $OutputFileName4"

###############################################################################################
# create an Informatica parameter file to be used by every Workflow called by this script  
cd $infasrcdir

if [ $srcfiletype = "ORDEREXPRESS_MIF" ]; then
    parameterfile="${tenantid_uc}_"$srcfiletype"_parm.txt"
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
var4="$""OutputFileName1"
var5="$""OutputFileName2"
var6="$""OutputFileName3"
var7="$""OutputFileName4"

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
$var4=$OutputFileName1
$var5=$OutputFileName2
$var6=$OutputFileName3
$var7=$OutputFileName4

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

# cp $infasrcdir/$parameterfile "/apps/Callidus/tels/temp/_Simon/"

# ###############################################################################################
# # This (Call)will Check the file size and moves non-empty files to AppServer.
echo "[CallScript] Calling Utility function to check size and move files to AppServer."

if [ $srcfiletype = "ORDEREXPRESS_MIF" ]; then
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
        #rm -rf $OutputFileName1
    fi
    if [ "$OutputFileName2" != "" ]; then
        filereccount2=`wc -l $infatgtdir/$OutputFileName2 | awk  '{print $1}' `
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
        #rm -rf $OutputFileName2
    fi
    if [ "$OutputFileName3" != "" ]; then
        filereccount3=`wc -l $infatgtdir/$OutputFileName3 | awk  '{print $1}' `
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
        #rm -rf $OutputFileName3
    fi
	
	#### ERROR file
    if [ "$OutputFileName4" != "" ]; then
        filereccount4=`wc -l $infatgtdir/$OutputFileName4 | awk  '{print $1}' `
		echo "<b><font size="3" color="red">$OutputFileName4 contains $filereccount4 records</font></b>"
        MergeErrorFile $OutputFileName4
        #rm -rf $OutputFileName4
    fi
	
	if [ -z "$targetcount" ]; then
		targetcount="0"
	fi
	
    echo " Files are ready to move to apps server "
    echo " Target & Error file summary start ..."
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount $OutputFileName4 $buname
 
    echo "Target & Error file Summary Completed .."   
    if [ "$OutputFileName1" != "" ]; then
        mv $OutputFileName1 $infatgtinbound
        echo "$OutputFileName1 Files are ready to move to apps server "
        MoveFilesToAppServer $infatgtinbound $OutputFileName1 $target_archive_dir $wftype $wftype1
    fi
    if [ "$OutputFileName2" != "" ]; then
        mv $OutputFileName2 $infatgtinbound
        echo "$OutputFileName2 Files are ready to move to Drop Box server "
        MoveFilesToAppServer $infatgtinbound $OutputFileName2 $target_archive_dir $wftype $wftype1
    fi
    if [ "$OutputFileName3" != "" ]; then
        mv $OutputFileName3 $infatgtinbound
        echo "$OutputFileName3 Files are ready to move to Drop Box server "
        MoveFilesToAppServer $infatgtinbound $OutputFileName3 $target_archive_dir $wftype $wftype1
    fi
	if [ "$OutputFileName4" != "" ]; then
        mv $OutputFileName4 $infatgtoutbound
        echo "$OutputFileName4 Files are ready to move to Drop Box server "
        MoveFilesToAppServer $infatgtoutbound $OutputFileName4 $target_badfiles_dir
    fi
    TargetDependencyChecker $wftype $wftype1 $target_archive_dir $target_badfiles_dir
fi

echo "[CallScript]"
echo "[CallScript]  === [$timestamp]::END:: $filehandler ] ==="
exit $wfretcode
