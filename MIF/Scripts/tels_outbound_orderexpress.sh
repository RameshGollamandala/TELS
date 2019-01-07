#!/bin/bash

#<<tels_outbound_orderexpress.sh>>

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
# Command Line: tels_outbound_orderexpress.sh <Trigger File Name>
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
processing_business_unit="Indirect_AU"

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-OutboundOEPayConfirm]"
echo "[CallScript-OutboundOEPayConfirm]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OutboundOEPayConfirm]"

echo "[CallScript-OutboundOEPayConfirm] Current FileHandler path: " $filehandlername
echo "[CallScript-OutboundOEPayConfirm] Current FileHandler: " $filehandler
echo "[CallScript-OutboundOEPayConfirm] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OutboundOEPayConfirm] Current SourceFileType: " $sourcetype
echo "[CallScript-OutboundOEPayConfirm] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OutboundOEPayConfirm] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

parm=`cat $inboundfolder/$filename`
period_name=`echo $parm | awk '{print $1}'`
echo "[CallScript-OutboundOEPayConfirm] Period [$period_name] found in parameter file"

################################################################################
#Exit the process, if the workflow not found for filetype;
if [ "$outboundwfname" = "" -o "$wftype" = "" ]; then
    echo "[WorkflowNotFound] Script not found for filetype=$filetype, exiting..."
    echo "wfret=1" > $tempdir/wfreturncode.txt
    exit 1
fi

#Loop from here
periodname_str="'"$period_name"'"
filelist=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
declare
  l_filelist varchar2(4000);
begin
  SELECT concafilename INTO l_filelist
  FROM(
	  SELECT STRING_AGG(FILENAME) concafilename, PERIOD_NAME 
	  FROM( SELECT distinct fat.FILENAME, tper.PERIOD_NAME 
			FROM TELS_INBOUND_FILE_ATTRIBUTES fat 
			JOIN TELS_PERIOD tper 
			  ON tper.PERIOD_NAME = $periodname_str AND tper.STARTDATE <= TO_DATE(fat.BATCHPROCESSDATE,'DD/MM/YYYY HH24:MI:SS') AND tper.ENDDATE > TO_DATE(fat.BATCHPROCESSDATE,'DD/MM/YYYY HH24:MI:SS') 
			WHERE EXISTS (SELECT 1 FROM TELS_CORE_INBOUND_FILE_RUN ifr WHERE ifr.BATCHNAME = fat.FILENAME AND ifr.FILEHANDLERNAME = 'tels_inbound_orderexpress.sh') 
			ORDER BY fat.FILENAME ASC)
	  GROUP BY PERIOD_NAME
  );
  dbms_output.put_line(l_filelist);
end;
/
!`	

file_list=${filelist//$'\n'/}

################################################################################
#Loop for each inbound file
for i in $(echo $file_list | sed "s/,/ /g")
do 
    if [ $i = "declare*ERROR" ]; then
		SendMail " " "ERROR" $filename $filename" - There are no MIF files for period "$period_name
		exit 1
	fi
	
    echo "*** Now processing file $i"
	fileseq=`echo $i | cut -d "_" -f4`
	
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
	parameterfile="tels_outbound_orderexpress_mif_parm.txt"
	cat /dev/null > $parameterfile
		
	if [ $srcfiletype = "ORDEREXPRESS_PAYCONFIRM" ]; then
		OutputFileName1="SKYCOMM_"$custinst_uc"_ORDEREXPRESS_"$fileseq"_PAYCONFIRM_"$timestamp"_sin1xfer.dat"
	fi

	ErrorFileName1="SKYCOMM_ORDEREXPRESS_"$custinst_uc"_"$fileseq"_PayConfirm_Error_"$timestamp".txt"

	echo "[CallScript-OutboundOEPayConfirm] Output File Name: $OutputFileName1"
		
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
	var3="$""$""filename"

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
	$var3=$i
	EOA

	export parameterfile
	echo "[CallScript-OutboundOEPayConfirm] Parameter file $parameterfile generated and moved to $infasrcdir. "
	echo "[CallScript-OutboundOEPayConfirm] Parameters:"
	echo ""
	cat $parameterfile

	#cp $parameterfile "/apps/Callidus/tels/temp/_Simon/"

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
	echo "[CallScript-OutboundOEPayConfirm] Calling Utility function to check size and move files to AppServer."

	if [ $srcfiletype = "ORDEREXPRESS_PAYCONFIRM" ]; then
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
		MoveFilesToOutbound $infatgtdir $OutputFileName1 $target_archive_dir 
		
		rm -rf $infatgtdir/$OutputFileName1
	fi
done
	
echo "[CallScript-OutboundOEPayConfirm]"
echo "[CallScript-OutboundOEPayConfirm]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode