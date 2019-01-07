#!/bin/bash

#<<tels_outbound_ccg_tools.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 28/05/2018  Simon Marsh    v00
#
# Description:
#   File handler script to generate extract to the CCG Tools
#
# Invoked By: Trigger File
#   Name: CCG_DEALERTRANSLATION_<DEV|TST|UAT|PRD>.txt
#   Parameters: None
#
# Command Line: tels_outbound_ccg_tools.sh <Trigger File Name>
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################

target_archive_dir=$CCG_Tools_targets_archive
target_badfiles_dir=$CCG_Tools_targets_badfiles
processing_business_unit="PCA"

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-OutboundCCGTools]"
echo "[CallScript-OutboundCCGTools]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OutboundCCGTools]"

echo "[CallScript-OutboundCCGTools] Current FileHandler path: " $filehandlername
echo "[CallScript-OutboundCCGTools] Current FileHandler: " $filehandler
echo "[CallScript-OutboundCCGTools] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OutboundCCGTools] Current SourceFileType: " $sourcetype
echo "[CallScript-OutboundCCGTools] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OutboundCCGTools] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

parm=`cat $inboundfolder/$filename`
period_name=`echo $parm | awk '{print $1}'`
echo "[CallScript-OutboundCCGTools] Period [$period_name] found in parameter file"

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
# create an Informatica parameter file to be used by every Workflow called by this script  
cd $infasrcdir
parameterfile="tels_outbound_ccg_tools_parm.txt"
	
if [ $srcfiletype = "CCG_DEALERTRANSLATION" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Dealer_Translation_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_PARTNER" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Partner_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_COMMISSIONQUOTA" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Commission_Quota_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_USERTABLE" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_User_Table_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_PAYPERIOD" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Pay_Period_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_POSTPAYBATCH" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Post_Paybatch_Extract_$timestamp.dat"
elif [ $srcfiletype = "CCG_PREPAYBATCH" ]; then
	OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Pre_Paybatch_Extract_$timestamp.dat"
fi

ErrorFileName1="SKYCOMM_CCG_"$custinst_uc"_CCGTOOLS_Error_"$timestamp".txt"

echo "[CallScript-OutboundCCGTools] Output File Name: $OutputFileName1"
	
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
var2="$""OutputFileName1"

cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtdir
$var1=$period_name
$var2=$OutputFileName1
EOA

export parameterfile
echo "[CallScript-OutboundCCGTools] Parameter file $parameterfile generated and moved to $infasrcdir. "
echo "[CallScript-OutboundCCGTools] Parameters:"
echo ""
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

###############################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.
echo "[CallScript-OutboundCCGTools] Calling Utility function to check size and move files to AppServer."

if [ $srcfiletype = "CCG_DEALERTRANSLATION" -o $srcfiletype = "CCG_PARTNER" -o $srcfiletype = "CCG_COMMISSIONQUOTA" -o $srcfiletype = "CCG_USERTABLE" -o $srcfiletype = "CCG_PAYPERIOD" -o $srcfiletype = "CCG_POSTPAYBATCH" -o $srcfiletype = "CCG_PREPAYBATCH" ]; then
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
	
    echo "  Target & Error file summary start ..."
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount $ErrorFileName1 $processing_business_unit
    echo "  Target & Error file Summary Completed .."
	echo "$OutputFileName1 Files are ready to move to dropbox server "
	MoveFilesToOutbound $infatgtdir $OutputFileName1 $CCG_Tools_targets_archive 
	
	rm -rf $infatgtdir/$OutputFileName1
fi

echo "[CallScript-OutboundCCGTools]"
echo "[CallScript-OutboundCCGTools]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode