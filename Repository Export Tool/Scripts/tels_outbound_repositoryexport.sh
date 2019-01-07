#!/bin/bash

#<<tels_outbound_repositoryexport.sh>>

#-------------------------------------------------------------------------------
# Date        Author          Version  Comments
#-------------------------------------------------------------------------------
# 10/09/2018  Simon Marsh    v00
#
# Description:
#   File handler script to generate extract of repository tables
#
# Invoked By: Trigger File
#   Name: TELS_REPOSITORYEXPORT_TIMESTAMP.txt
#   Parameters: None
#
# Command Line: tels_outbound_repositoryexport.sh <Trigger File Name>
#
################################################################################

set -x

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

#############################################
# LOCAL VARAIBLES [MODIFY ME]               #
#############################################

target_archive_dir=$Rep_Export_targets_archive
target_badfiles_dir=$Rep_Export_targets_badfiles
processing_business_unit=$buname

#####################################################################
# PROGRAM BEGIN                                                     #
#####################################################################

filename=$1
batchname=$1
filehandlername=$0
filehandler=`echo $filehandlername | cut -d "/" -f6`

echo "[CallScript-OutboundRepExport]"
echo "[CallScript-OutboundRepExport]  === [$timestamp]:: START:: $filehandler ]===" 
echo "[CallScript-OutboundRepExport]"

echo "[CallScript-OutboundRepExport] Current FileHandler path: " $filehandlername
echo "[CallScript-OutboundRepExport] Current FileHandler: " $filehandler
echo "[CallScript-OutboundRepExport] $tenantid_uc Supplied Outbound file name : " $filename
echo "[CallScript-OutboundRepExport] Current SourceFileType: " $sourcetype
echo "[CallScript-OutboundRepExport] $tenantid_uc Outbound filetype: " $filetype
echo "[CallScript-OutboundRepExport] [$filename] received from $tenantid_uc, and it has [ $filerecords ] records."

parm=`cat $inboundfolder/$filename`
period_name=`echo $parm | awk '{print $1}'`

if [ "$period_name" = "" ]; then 												#If the period is blank, the script is automatically called so determine the period
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
	table_schedule="'d'" 														#schedule is daily
	echo "[CallScript-OutboundRepExport] Period [$period_name] determined from query, schedule [$table_schedule]"
else																			#If period is read from trigger it is a manual extract
	last_char=`echo $period_name | grep -o '.$'`
	if [ $last_char = "+" ]; then
		table_schedule="'a','d'" 												#When we get a plus after the period name, schedule is daily and adhoc
		new_period=${period_name%\+}
		period_name=$new_period
	else
		table_schedule="'d'" 													#No plus, schedule is daily
	fi	
	echo "[CallScript-OutboundRepExport] Period [$period_name] found in parameter file, schedule [$table_schedule]"
fi

period_name_str="'$period_name'"												#Convert the period name into the periodseq
period_seq=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
declare
  l_period_name varchar2(4000);
  l_period_seq varchar2(4000);
begin
  l_period_name:=$period_name_str;
  l_period_seq:='0';
  SELECT TO_CHAR(PERIODSEQ) INTO l_period_seq FROM CS_PERIOD@TC_LINK WHERE REMOVEDATE = TO_DATE('01012200','DDMMYYYY') AND TENANTID = 'TELS' AND NAME = $period_name_str;
  dbms_output.put_line(l_period_seq);
end;
/
!`
period_start=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
declare
  l_period_name varchar2(4000);
  l_period_start varchar2(4000);
begin
  l_period_name:=$period_name_str;
  l_period_start:='0';
  SELECT TO_CHAR(STARTDATE, 'DD-MON-YYYY') INTO l_period_start FROM CS_PERIOD@TC_LINK WHERE REMOVEDATE = TO_DATE('01012200','DDMMYYYY') AND TENANTID = 'TELS' AND NAME = $period_name_str;
  dbms_output.put_line(l_period_start);
end;
/
!`
period_end=`sqlplus -s $lpdb_username/$lpdb_password <<!
set heading off feedback off verify off
set serveroutput on size 100000
declare
  l_period_name varchar2(4000);
  l_period_end varchar2(4000);
begin
  l_period_name:=$period_name_str;
  l_period_end:='0';
  SELECT TO_CHAR(ENDDATE, 'DD-MON-YYYY') INTO l_period_end FROM CS_PERIOD@TC_LINK WHERE REMOVEDATE = TO_DATE('01012200','DDMMYYYY') AND TENANTID = 'TELS' AND NAME = $period_name_str;
  dbms_output.put_line(l_period_end);
end;
/
!`
echo "[CallScript-OutboundRepExport] Periodseq [$period_seq], Periodstart [$period_start], Periodend [$period_end] determined from query"

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

if [ $srcfiletype = "TELS_REPOSITORYEXPORT" ]; then
																				#Read the config table to determine which things to export
	export_list=`sqlplus -s $lpdb_username/$lpdb_password <<!
	set heading off feedback off verify off
	set serveroutput on size 100000
	SET LINESIZE 32767
	SET TRIMSPOOL ON
	SET TRIMOUT ON
	SET WRAP OFF
	declare
	  l_export_list varchar2(4000);
	  l_table_schedule varchar2(50);
	begin
	  l_table_schedule:=$table_schedule;
	  SELECT LISTAGG(TABLE_NAME,',') WITHIN GROUP (ORDER BY TABLE_NAME) table_list INTO l_export_list FROM TELS_REPOSITORYEXPORT_CONFIG WHERE EXPORT_SCHEDULE IN(l_table_schedule);
	  dbms_output.put_line(l_export_list);
	end;
	/
	!`
	
	table_list=${export_list//$'\n'/}											#Remove any newline chars
	echo "[CallScript-OutboundRepExport] Tables that will be exported: $table_list"

	################################################################################
	#Loop for each extract
	for i in $(echo $table_list | sed "s/,/ /g")								#Loop over the table list at commas
	do
		l_intable="'""${i//$'\n'/}""'"											#Strip out any newline chars from table name and wrap in quotes then read the column list for each table

		column_list=`sqlplus -s $lpdb_username/$lpdb_password <<!
			set heading off feedback off verify off
			set serveroutput on size 100000
			SET LINESIZE 32767
			SET TRIMSPOOL ON
			SET TRIMOUT ON
			SET WRAP OFF
			declare
			l_table varchar2(4000);
			l_column_list varchar2(4000);
			begin
			l_table:=$l_intable;
			SELECT COLUMN_LIST INTO l_column_list FROM TELS_REPOSITORYEXPORT_CONFIG WHERE TABLE_NAME=$l_intable AND EXPORT_SCHEDULE IN($table_schedule);
			dbms_output.put_line(l_column_list);
			end;
			/
			!`
	
		concat_col_list=$(printf '%s\n' "$column_list" | sed -e "s/,/||'|'||/g") #Format the column list to replace commas with pipe concatenation to retreive a single row of data
		concat_colname_list="'"$(printf '%s\n' "$column_list" | sed -e "s/,/'||'|'||'/g")"'" #Format the column name list to replace commas with pipe concatenation to retreive a single row for the header
																				#Retrieve the optional db link to access the TC repository
		db_link=`sqlplus -s $lpdb_username/$lpdb_password <<!
			set heading off feedback off verify off
			set serveroutput on size 100000
			SET LINESIZE 32767
			SET TRIMSPOOL ON
			SET TRIMOUT ON
			SET WRAP OFF
			declare
			l_table varchar2(4000);
			l_db_link varchar2(4000);
			begin
			l_table:=$l_intable;
			SELECT DB_LINK INTO l_db_link FROM TELS_REPOSITORYEXPORT_CONFIG WHERE TABLE_NAME=$l_intable AND EXPORT_SCHEDULE IN($table_schedule);
			dbms_output.put_line(l_db_link);
			end;
			/
			!`
																				#Read the filter condition for the table
		table_filter=`sqlplus -s $lpdb_username/$lpdb_password <<!
			set heading off feedback off verify off
			set serveroutput on size 100000
			SET LINESIZE 32767
			SET TRIMSPOOL ON
			SET TRIMOUT ON
			SET WRAP OFF
			declare
			l_table varchar2(4000);
			l_table_filter varchar2(4000);
			begin
			l_table:=$l_intable;
			SELECT TABLE_FILTER INTO l_table_filter FROM TELS_REPOSITORYEXPORT_CONFIG WHERE TABLE_NAME=$l_intable AND EXPORT_SCHEDULE IN($table_schedule);
			dbms_output.put_line(l_table_filter);
			end;
			/
			!`
	  
		################################################################################
		# create an Informatica parameter file to be used by every Workflow called by this script  
		cd $infasrcdir
		parameterfile="TELS_REPOSITORYEXPORT_parm.txt"
		cat /dev/null > $parameterfile											#Empty the param file
		
		OutputFileName1="SKYCOMM_CCG_"$custinst_uc"_Repository_Export_"$period_name"_"$i"_"$timestamp".dat"
		ErrorFileName1="SKYCOMM_CCG_"$custinst_uc"_Repository_Export_"$period_name"_Error_"$timestamp".txt"
		table_filter="${table_filter//'$period_name'/$period_name}"		#Perform variable substitution for period name
		table_filter="${table_filter//'$period_start'/$period_start}"	#Perform variable substitution for periodstart
		table_filter="${table_filter//'$period_end'/$period_end}"		#Perform variable substitution for periodend
		table_filter="${table_filter//'$period_seq'/$period_seq}"		#Perform variable substitution for periodseq
		
		header_SQL="SELECT $concat_colname_list ALL_COLUMNS FROM DUAL"
		extract_SQL="SELECT $concat_col_list ALL_COLUMNS FROM $i$db_link $table_filter"
			
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
		var3="$""$""extract_SQL"
		var4="$""$""header_SQL"

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
		$var3=$extract_SQL
		$var4=$header_SQL
		EOA

		export parameterfile
		echo "[CallScript-OutboundRepExport] Parameter file $parameterfile generated and moved to $infasrcdir. "
		echo "[CallScript-OutboundRepExport] Parameters:"
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
		echo "[CallScript-OutboundRepExport] Calling Utility function to check size and move files to AppServer."

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

		echo "[CallScript-OutboundRepExport] Target & Error file summary start ..."
		sh $tntscriptsdir/$datasummary $filehandler $filename $targetfilename $targetcount $ErrorFileName1 $processing_business_unit
		echo "[CallScript-OutboundRepExport] Target & Error file Summary Completed .."
			
		echo "[CallScript-OutboundRepExport] $OutputFileName1 is being moved to $target_archive_dir"
		echo "$OutputFileName1 Files are ready to move to apps server "
		MoveFilesToOutbound $infatgtdir $OutputFileName1 $Rep_Export_targets_archive
		
		rm -f $infatgtdir/$OutputFileName1
	done
fi

echo "[CallScript-OutboundRepExport]"
echo "[CallScript-OutboundRepExport]  === [$timestamp]::END:: $filehandler ] ==="

exit $wfretcode