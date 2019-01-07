#!/bin/bash

#<<tels_outbound_ccg_tools_auto.sh>>

#-------------------------------------------------------------------------------
# Date        Author                Version   Comments
#-------------------------------------------------------------------------------
# 06/09/2018  Simon Marsh			v1.0
# 
# Description:
#   File handler script to run ccg extracts, called from CRON
#
# Invoked By: CRON Job automation to invoke everyday at 10PM
#   Name: N/A
#   Parameters: Not required
#
# Command Line: sh tels_outbound_ccg_tools_auto.sh
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# TO DO : LOCAL VARAIBLES
target_archive_dir=$CCG_Tools_targets_archive
target_badfiles_dir=$CCG_Tools_targets_badfiles
filesrc="CCG"
filetypelist="PARTNER,COMMISSIONQUOTA,DEALERTRANSLATION,USERTABLE,PAYPERIOD,POSTPAYBATCH,PREPAYBATCH"

filehandlername="tels_outbound_ccg_tools_auto.sh"
filehandler=`echo $filehandlername | cut -d "/" -f6`
log=${tenantid_uc}"_CCG_TOOLS_AUTO_"${timestamp}.log
logfile=$logfolder/$log
tmplog="tmp_"${log}
tmplogfile=$logfolder/$tmplog
filereccount=0

echo "[CallScript-OutboundCCGToolsAuto]  === [$timestamp]:: START:: $filehandler ]==="   | tee -a $logfile
echo "[CallScript-OutboundCCGToolsAuto]"  | tee -a $logfile
echo "[CallScript-OutboundCCGToolsAuto] Current FileHandler path: " $filehandlername  | tee -a $logfile
echo "[CallScript-OutboundCCGToolsAuto] Current FileHandler: "$filehandler  | tee -a $logfile

#Send an alert mail, process started
SendMail $logfile "ALERT" "$srcfiletype" "ALERT: CCG Extracts Auto Started"

targetcount=""
targetfilename=""
		
################################################################################
#Loop for each CCG extract
for i in $(echo $filetypelist | sed "s/,/ /g")
do
	#FunctionCall: Read typemap config file and get required parameters
	filetype=$i
	ReadParameters $filesrc $filetype
	retcode=$?
	
	if [ "$filesrc" = "" -a "$filetype" = "" ]; then
		echo "[CallScript-OutboundCCGToolsAuto] Invalid input arguments, exiting process." | tee -a $tmplogfile
		exit 1
	fi
	
	period_name=`sqlplus -s $lpdb_username/$lpdb_password <<!
	set heading off feedback off verify off
	set serveroutput on size 100000
	declare
	  l_period_name varchar2(4000);
	begin
	  SELECT PERIOD_NAME INTO l_period_name FROM TELS_PERIOD WHERE STARTDATE <= SYSDATE AND ENDDATE > SYSDATE;
	  dbms_output.put_line(l_period_name);
	end;
	/
!`

	################################################################################
	# Period Override
	period_name="AUGW5-FY19"
	
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
	
	echo "[CallScript-OutboundCCGToolsAuto]  === [$timestamp]:: START:: $filehandler ]==="   | tee -a $tmplogfile
	echo "[CallScript-OutboundCCGToolsAuto]"  | tee -a $tmplogfile
	echo "[CallScript-OutboundCCGToolsAuto] Current SourceFileType:" $srcfiletype  | tee -a $tmplogfile
	echo "[CallScript-OutboundCCGToolsAuto] $tenantid_uc Outbound filename: " $OutputFileName1  | tee -a $tmplogfile
	echo "[CallScript-OutboundCCGToolsAuto] Period determined as: " $period_name  | tee -a $tmplogfile
	echo "[CallScript-OutboundCCGToolsAuto]"  | tee -a $tmplogfile

	################################################################################
	#Exit the process, if the workflow not found for filetype;
	if [ "$outboundwfname" = "" -o "$wftype" = "" ]; then
		echo "[CallScript-OutboundCCGToolsAuto] Workflow not found for filetype=$filetype, exiting..."  | tee -a $tmplogfile
		exit 1
	fi

	################################################################################
	# Call the Utility Function to log the start of an outbound file process
	LoggingProcess $filehandler $srcfiletype $stagetablename $batchname
	processretcode=$?
	if [ $processretcode -ne 0 ]; then
		exit 1
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
	echo ""

	###############################################################################################
	#Executing Workflow
	echo "[CallScript-OutboundCCGToolsAuto] Executing Outbound workflow : $outboundwfname"  | tee -a $tmplogfile
	ExecuteWorkflow $foldername $outboundwfname $filehandler $srcfiletype $stagetablename $filereccount
	wfretcode=$?

	if [ $wfretcode -ne 0 ]; then
		echo "[CallScript-OutboundCCGToolsAuto] Error executing Outbound workflow [$outboundwfname], please check Workflow log for more details."  | tee -a $tmplogfile
		echo "wfret=1" > $tempdir/wfreturncode.txt
		exit 1
	else 
		echo "[CallScript-OutboundCCGToolsAuto] Outbound workflow [$outboundwfname] completed succesfully..."  | tee -a $tmplogfile
	fi

	###############################################################################################
	# This will Check the file size and moves non-empty files to AppServer
	echo "[CallScript-OutboundCCGToolsAuto] Calling Utility function to check size and move files to AppServer."  | tee -a $tmplogfile

	if [ $srcfiletype = "CCG_DEALERTRANSLATION" -o $srcfiletype = "CCG_PARTNER" -o $srcfiletype = "CCG_COMMISSIONQUOTA" -o $srcfiletype = "CCG_USERTABLE" -o $srcfiletype = "CCG_PAYPERIOD" -o $srcfiletype = "CCG_POSTPAYBATCH" -o $srcfiletype = "CCG_PREPAYBATCH" ]; then
		cd $infatgtdir

		if [ "$OutputFileName1" != "" ]; then
			filereccount1=`cat $infatgtdir/$OutputFileName1 | sed '1d' | wc -l | awk  '{print $1}'` # Outbound file record count - Excluding file header
			#filereccount1=`wc -l $infatgtdir/$OutputFileName1 | awk  '{print $1}'` # Outbound file record count - Including file header
			
			echo "[CallScript-OutboundCCGToolsAuto] Record count in Output file (excluding file header) : $filereccount1"  | tee -a $tmplogfile
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

		echo "[CallScript-OutboundCCGToolsAuto] Target & Error file summary start ..."  | tee -a $tmplogfile
		sh $tntscriptsdir/$datasummary $filehandler "<Automatic Run "$timestamp">" $targetfilename $targetcount $ErrorFileName1 $buname
		#tels_datasummary_start.sh     <filehandler>, <filename>,				 <tgtfilename1>, 	<tgtcount>, <errfilename>, <filesrc>
		echo "[CallScript-OutboundCCGToolsAuto] Target & Error file Summary Completed .."  | tee -a $tmplogfile

		if [ "$targetcount" -gt 1 ]; then
			echo "[CallScript-OutboundCCGToolsAuto] Files are ready to move to dropbox server "  | tee -a $tmplogfile
			MoveFilesToOutbound $infatgtdir $OutputFileName1 $CCG_Tools_targets_archive 
			retcode=$?
			rm -rf $infatgtdir/$OutputFileName1
		else 
		   echo "[CallScript-OutboundCCGToolsAuto] Outbound file is empty, exiting process."  | tee -a $tmplogfile
		   rm -f $infatgtdir/$OutputFileName1
		   retcode=1
		fi
	fi

	if [ "$retcode" -eq 0 ] ; then
		echo "[CallScript-OutboundCCGToolsAuto] $retcode - Script execution completed succesfully."   | tee -a $tmplogfile
		echo "[CallScript-OutboundCCGToolsAuto] Archiving the files after successful execution."  | tee -a $tmplogfile
		echo "[CallScript-OutboundCCGToolsAuto] Sending SUCCESS mail, with log."  | tee -a $tmplogfile
		ErrorCount $filesrc $srcfiletype
		SendMail $tmplogfile "SUCCESS" "$srcfiletype" "SUCCESS: CCG Extracts Auto"  | tee -a $tmplogfile
	else
		echo "[CallScript-OutboundCCGToolsAuto] $retcode - Error in executing script, check Log Files for more information."  | tee -a $tmplogfile
		echo "[CallScript-OutboundCCGToolsAuto] Sending ERROR mail, with log."   | tee -a $tmplogfile
		SendMail $tmplogfile "ERROR" "$srcfiletype" "ERROR: CCG Extracts Auto"  | tee -a $tmplogfile
		exit $retcode
	fi
	  
	cat $tmplogfile > $logfile
	cat /dev/null > $tmplogfile
done

rm -f $tmplogfile 

echo "[CallScript-OutboundCCGToolsAuto]"  | tee -a $logfile
echo "[CallScript-OutboundCCGToolsAuto]  === [$timestamp]::END:: $filehandler ] ==="  | tee -a $logfile

exit $wfretcode
