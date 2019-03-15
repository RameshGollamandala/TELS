#!/bin/bash

#<<tels_cwpb2b_txn_process.sh>>

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
# Command Line: tels_cwpb2b_txn_process.sh <triggerfilename>
#
################################################################################

set -x

# Import Environment Variables

. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#TODO -  Read arguments - if no arguments then exit here with error message

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################

target_archive_dir=$PCA_targets_archive
target_badfiles_dir=$PCA_targets_badfiles
processing_business_unit="Indirect_AU"
Transaction_EventTypeId="B2B_Product_Line"

### Customize the ProductName after further communication from Brad; <As of 12-Feb-2019>
Transaction_ProductName="Commissions B2B Main Plain"

PL_batchname=""
#####################################################################
# PROGRAM BEGIN                                                     #
# --- MAY STILL REQUIRE CUSTOMISATION (SEARCH FOR 'TODO' TAGS) ---  #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript]"
echo "[CallScript]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript]"

echo "[CallScript] Current FileHandler path: " $filehandlername
echo "[CallScript] $tenantid_uc Supplied Inbound file name : " $filename
echo "[CallScript] Current SourceFileType: " $sourcetype
echo "[CallScript] $tenantid_uc INBOUND filetype: " $filetype
echo "[CallScript] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

PL_batchname=`cat $inboundfolder/$filename | tail -1 | head -1`

echo "[CallScript] Today's DataHub ProductLines filename: " $PL_batchname

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
  
###################################################################################################
# Generate Output ODI file-names  based on the srcfiletype from SFX
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

echo "[CallScript] Source & File Type is: $srcfiletype"
if [ $srcfiletype = "TELS_CWPB2B" ]; then
    if [ $wftype = "TXSTAG" ]; then
        OutputFileName1=$tenantid_uc"_TXSTAG_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName2=$tenantid_uc"_TXTA_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName3=$tenantid_uc"_TXTG_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName4=$tenantid_uc"_ERROR_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
    elif [ $wftype = "TXSTA" ]; then
        OutputFileName1=$tenantid_uc"_TXSTA_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName2=$tenantid_uc"_TXTA_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName3=$tenantid_uc"_DUMMY_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
        OutputFileName4=$tenantid_uc"_ERROR_"$custinst_uc"_"$buname"_"$srcfiletype"_"$timestamp
    fi
    echo "[CallScript] Generated output file name 1: $OutputFileName1"
    echo "[CallScript] Generated output file name 2: $OutputFileName2"
    echo "[CallScript] Generated output file name 3: $OutputFileName3"
    echo "[CallScript] Generated output file name 4: $OutputFileName4"
elif [ "$wftype" != "" ]; then
    OutputFile1=$tenantid_uc"_"$wftype"_"$custinst_uc"_"$filetype"_"$timestamp".txt"
    echo "[CallScript] Output file name: $OutputFile1"
fi

###############################################################################################
# create an Informatica parameter file to be used by every Workflow called by this script  
# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

cd $infasrcdir

#TELS_CWP_ODI_param.txt
if [ $srcfiletype = "TELS_CWPB2B" ]; then
    parameterfile="${tenantid_uc}_CWP_ODI_param.txt"
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
var2="$""InputFileName"
var3="$""OutputFileName1"
var4="$""OutputFileName2"
var5="$""OutputFileName3"
var6="$""OutputFileName4"
var7="$""$""Txn_EventTypeId"
var8="$""$""Txn_ProductName"
var9="$""$""ProdLine_filename"


cat > $parameterfile <<-EOA
$hdr1
$g_var1=$infaworkflowdir
$g_var2=$infasessiondir
$g_var3=$infacachedir
$g_var4=$infabadfiledir
$g_var5=$infasrcdir
$g_var6=$infatgtinbound
$var1=$filename
$var2=$filename
$var3=$OutputFileName1
$var4=$OutputFileName2
$var5=$OutputFileName3
$var6=$OutputFileName4
$var7=$Transaction_EventTypeId
$var8=$Transaction_ProductName
$var9=$PL_batchname

EOA

export parameterfile

echo "[CallScript] Parameter file $parameterfile generated and moved to $infasrcdir. "

cat $parameterfile


###############################################################################################
#Executing Workflow
#ExecuteWorkflow $infa_foldername $inboundwfname $filehandler $filename $stagetablename $filereccount

ExecuteWorkflow $foldername $inboundwfname $filehandler $filename $stagetablename $filereccount
wfretcode=$?
if [ $wfretcode -ne 0 ]; then
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

###############################################################################################
# This (Call)will Check the file size and moves non-empty files to AppServer.

echo "[CallScript] Calling Utility function to check size and move files to AppServer."

# [TODO] CUSTOMISE THIS SECTION TO MEET YOUR IMPLEMENTATION REQUIREMENTS

if [ $srcfiletype = "TELS_CWPB2B" ]; then
    cd $infatgtinbound
    targetcount=""
    targetfilename=""
    # CompensationDate Check and update in the target file name for each source for TXST/TXSTA files
    if [ "$wftype" = "TXST" -o "$wftype" = "TXSTA" -o "$wftype" = "TXSTAG" ]; then
        perl -ne 'print if ($.==1);' $OutputFileName1 > temp.txt
        perl -wnlp -e 's/\t/,/g;' temp.txt > temp1.txt
        comp=`cat temp1.txt | sort -n | head -2 | tail -1 | cut -d "," -f14`
        compdate=`echo "_"$comp | tr -d '//'`
        echo "[CallScript] Compensation Date: $compdate"
    fi
    if [ "$OutputFileName1" != "" ]; then
        cp $OutputFileName1 $OutputFileName1$compdate".txt"
        filereccount1=`wc -l $infatgtinbound/$OutputFileName1 | awk  '{print $1}'`
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount1
        else
            targetcount=$targetcount","$filereccount1
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName1$compdate".txt"
        else
            targetfilename=$targetfilename","$OutputFileName1$compdate".txt"
        fi
        rm -rf $OutputFileName1
    fi
    if [ "$OutputFileName2" != "" ]; then
        cp $OutputFileName2 $OutputFileName2$compdate".txt"
        filereccount2=`wc -l $infatgtinbound/$OutputFileName2 | awk  '{print $1}' `
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount2
        else
            targetcount=$targetcount","$filereccount2
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName2$compdate".txt"
        else
            targetfilename=$targetfilename","$OutputFileName2$compdate".txt"
        fi
        rm -rf $OutputFileName2
    fi
    if [ "$OutputFileName3" != "" ]; then
        cp $OutputFileName3 $OutputFileName3$compdate".txt"
        filereccount3=`wc -l $infatgtinbound/$OutputFileName3 | awk  '{print $1}' `
        if [ -z "$targetcount" ]; then
            targetcount=$filereccount3
        else
            targetcount=$targetcount","$filereccount3
        fi
        if [ -z "$targetfilename" ]; then
            targetfilename=$OutputFileName3$compdate".txt"
        else
            targetfilename=$targetfilename","$OutputFileName3$compdate".txt"
        fi
        rm -rf $OutputFileName3
    fi
    #### ERROR file
    if [ "$OutputFileName4" != "" ]; then
        cp $OutputFileName4 $OutputFileName4$compdate".txt"
        filereccount4=`wc -l $infatgtinbound/$OutputFileName4 | awk  '{print $1}' `
        MergeErrorFile $OutputFileName4$compdate".txt"
        rm -rf $OutputFileName4
    fi
    echo " Files are ready to move to apps server "
    echo " Target & Error file summary start ..."
    sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount $OutputFileName4$compdate".txt" $processing_business_unit
    echo "Target & Error file Summary Completed .."   

     if [ "$OutputFileName1" != "" ]; then
         echo "$OutputFileName1$compdate.txt file is ready to move to Application server "
         MoveFilesToAppServer $infatgtinbound $OutputFileName1$compdate".txt" $target_archive_dir $wftype $wftype1
     fi
     if [ "$OutputFileName2" != "" ]; then
         echo "$OutputFileName2$compdate.txt file is ready to move to Application server "
         MoveFilesToAppServer $infatgtinbound $OutputFileName2$compdate".txt" $target_archive_dir $wftype $wftype1
     fi
     if [ "$OutputFileName3" != "" ]; then
         echo "$OutputFileName3$compdate.txt file is ready to move to Application server "
         MoveFilesToAppServer $infatgtinbound $OutputFileName3$compdate".txt" $target_archive_dir $wftype $wftype1
     fi
     if [ "$OutputFileName4" != "" ]; then
         mv $OutputFileName4 $infatgtoutbound
         echo "$OutputFileName4 file are ready to move to Drop Box server "
         MoveFilesToAppServer $infatgtoutbound $OutputFileName4 $target_badfiles_dir
     fi
	TargetDependencyChecker $wftype $wftype1 $target_archive_dir $target_badfiles_dir
fi

echo "[CallScript]"
echo "[CallScript]  === [$timestamp]::END:: $filehandler ] ==="

exit 0
