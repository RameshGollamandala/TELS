#!/bin/bash

#<<tels_autoloader.sh>>

#-------------------------------------------------------------------------------
# Date        Author               Version  Comments
#-------------------------------------------------------------------------------
# 01/12/2017  Daniel Harsojo       v00
# 05/12/2017  Andrew Mills         v01
# 14/02/2019  Ramesh Gollamandala  v02      Add file extension(s):: .txt, .csv
#
# Description:
#   On-Demand Integrator (ODI) script for processing files in Landing Pad
#   inbound folder.
#
# Command line: sh tels_autoloader.sh
#   Scheduled to run every minute
#
################################################################################

# Import Environment Variables
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh
. /apps/Callidus/tels/integrator/tels_utility_functions.sh

filename=`find $inboundfolder -name "*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`
basefilename=`echo $filename | awk -F\. '{print $1}' | tail -1 | head -1`
fileext=`echo $filename | awk -F\. '{print $2}' | tail -1 | head -1`
filesrc=`echo $filename | cut -d "_" -f1`
if [ "$filesrc" = "CCB-COMM" ];  then
  filetype=`echo $filename | cut -d "_" -f3`
else
  filetype=`echo $filename | cut -d "_" -f2`
fi
srcfiletype=${filesrc}"_"${filetype}

if [ "$filename" = "" ]; then
    exit
fi

autoloaderlog=$logfolder/autoloader.log

log=${tenantid_uc}"_"${srcfiletype}"_"${timestamp}.log
logfile=$logfolder/$log

# In case any other file is being processed, EXIT

if [ -s $workdir/lock.out ]; then
  lockedfiletype=`cat $workdir/lock.out | tail -1 | head -1`
  echo "=== [ $timestamp :: START :: "$0" ] ===" | tee -a $autoloaderlog
  echo "[Autoloader] $timestamp : Currently '$lockedfiletype' file is being processed" | tee -a $autoloaderlog
  exit 1
else
  echo "=== [ $timestamp :: START :: "$0" ] ===" | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Autoloader invoked."   | tee -a $autoloaderlog $logfile
  echo "[Autoloader] File name: "$filename  | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Didn't detect another datafile being processed - OK to continue..." | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Creating lock on $filesrc $filetype" | tee -a $autoloaderlog $logfile
  touch $workdir/lock.out
  echo "$filesrc $filetype" > $workdir/lock.out
fi

#FunctionCall: To get filename parameters like filedate
# Mo doesn't know where this is defined...
# filenameProperties $filename

# Pre-checking the typemap config file, to make sure Valid file received

filetype_config=`cat $tntscriptsdir/$typemap_conf | grep "$filesrc|$filetype|" | cut -d "|" -f2`
if [ "$filetype_config" != "$filetype" ]; then
  echo "[CheckTypemap] Processing file: $filename"  | tee -a $autoloaderlog $logfile
  echo "[CheckTypemap] Invalid file, File Type: $filesrc $filetype is not recognised. Please check file naming convention and reload file." | tee -a $autoloaderlog $logfile
  echo "[CheckTypemap] filetype_config: |$filetype_config| filetype: |$filetype| filename: |$filename|" | tee -a $autoloaderlog $logfile
  CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
  SendMail $logfile "ERROR" $filename "Invalid Filename: $filename"
  exit
fi

#FunctionCall: to check file growth
CheckFileGrowth $filename | tee -a $autoloaderlog $logfile
inputfilestatus=$?
if [ $inputfilestatus != 0 ] ; then
  echo "[Autoloader] File is not stable, still loading..." | tee -a $autoloaderlog $logfile
  exit
fi

#FunctionCall: Read typemap config file and get required parameters
ReadParameters $filesrc $filetype

#FunctionCall: check for any dependencies
DependencyChecker $filesrc $filetype | tee -a $autoloaderlog $logfile
Depreturn=`cat $tempdir/dependency_code.txt | cut -d "=" -f2`
if [ $Depreturn = 0 ] ; then
  echo "[Autoloader] ($Depreturn) : All dependent file for $filesrc $filetype were processed" | tee -a $autoloaderlog $logfile
  rm -f $tempdir/dependency*
elif [ $Depreturn = 2 ] ; then
  echo "[Autoloader] ($Depreturn) : $filesrc $filetype : Don't have any dependencies" | tee -a $autoloaderlog $logfile
  rm -f $tempdir/dependency*
else
  echo "[Autoloader] ($Depreturn) : Dependent files for $filesrc $filetype yet to be processed, so exiting" | tee -a $autoloaderlog $logfile
  CleanInboundFolder $Depreturn $basefilename | tee -a $autoloaderlog $logfile
  SendMail $logfile "ERROR" $filename "Dependent files for $filesrc $filetype yet to be processed, so exiting"
  exit
fi

# New change need to add in order to accomdate the CTL,DAT file format
# Checking if concatenation of individual files required or not.
if [ "$flag" = "Y" ]; then
  #echo "[Autoloader] Calling [ $concatenate ] script" | tee -a $autoloaderlog $logfile
  # TODO - When creating concatenate script, include check for source type and file type !!! SM: Code seems never to have been built!!!
  sh $tntscriptsdir/$concatenate $filetype | tee -a $autoloaderlog $logfile
  shret=$?
  return=`cat $tempdir/returncode.txt | cut -d "=" -f2`
  #echo "[Autoloader] Concatenation script return code : $return" | tee -a $autoloaderlog $logfile
  if [ $return != 0 -o $shret != 0 ]; then
    echo "[Autoloader] $filetype files are still Loading into $inboundfolder folder, Please wait until all $NumPartitions $filetype files received." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] [$timestamp]: Autoloader Exit."
    SendMail $logfile "EXIT" "$filename" "'$filetype' files are still Loading to Inbound folder"
    rm -f $workdir/lock*
    rm -f $tempdir/returncode.txt
    exit
  fi
fi

inboundfilename1=`find $inboundfolder -name "*$filesrc_$filetype*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`
if [ "$inboundfilename1" = "" ]; then
  sleep 60
  echo "[CheckDataFile] No files found in inbound folder, exiting..."
  SendMail $logfile "ERROR" "$inboundfilename1" "No $filesrc $filetype files found in Inbound folder"
  exit
fi

basefilename=`echo $inboundfilename1 | awk -F\. '{print $1}' | tail -1 | head -1`
fileext=`echo $inboundfilename1 | awk -F\. '{print $2}' | tail -1 | head -1`

#Process File according to file extension.
case "$inboundfilename1" in
  *.aud)
    echo "[CheckDataFile] Audit File Found, and is of '$filesrc $filetype' type." | tee -a $autoloaderlog $logfile
    echo "[CheckDataFile] Audit File: $inboundfilename1" | tee -a $autoloaderlog $logfile
	
	datafilename=`find $inboundfolder -name "*$filesrc_$filetype*" -type f -exec basename \{} \; | sort -n | head -1 | tail -1`
    
	#inboundfilename="$basefilename".dat
    #v02:14-Feb-2019
	case "$inboundfilename1" in
	  *.txt.gz.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".txt
	    ;;
	  *.txt.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".txt
	    ;;
	  *.csv.gz.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".csv
		;;
	  *.csv.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".csv
		;;
	  *.dat.gz.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".dat
		;;
	  *.dat.aud)
	     echo "file extension - $fileext"
		 inboundfilename="$basefilename".dat
        ;;
    esac
	
	#FunctionCall: To validate Audit file
    CheckChecksum $inboundfilename1 $datafilename
    sizematch=$?
    if [ $sizematch != 0 ] ; then
      echo "[Autoloader] Invalid Audit file, exiting." | tee -a $autoloaderlog $logfile
      CleanInboundFolder $sizematch $basefilename | tee -a $autoloaderlog $logfile
      SendMail $logfile "ERROR" "$inboundfilename1" "Invalid Audit file received "
      exit
    fi
	
	#Unzip data files
    if [ -f $inboundfolder/$basefilename.dat.gz ]; then
      gunzip $inboundfolder/$basefilename.dat.gz
    elif [ -f $inboundfolder/$basefilename.txt.gz ]; then
      gunzip $inboundfolder/$basefilename.txt.gz
	elif [ -f $inboundfolder/$basefilename.csv.gz ]; then
      gunzip $inboundfolder/$basefilename.csv.gz
	fi
    
	if [ -f $inboundfolder/$inboundfilename ]; then
      echo "[CheckDataFile] Found Data File : $inboundfilename" | tee -a $autoloaderlog $logfile
    else
      echo "[CheckDataFile] Data File : $inboundfilename not found in: $inboundfolder" | tee -a $autoloaderlog $logfile
      echo "[Autoloader] Terminating Autoloader execution" | tee -a $autoloaderlog $logfile
      #sleep 60
      CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
      SendMail $logfile "ERROR" "$inboundfilename1" "Data file not found in Inbound folder"
      exit 1
    fi
    ;;
  *.dat.gz)
    echo "[CheckDataFile] Zipped Data File Found" | tee -a $autoloaderlog $logfile
    echo "[CheckDataFile] GZip file: $inboundfilename1" | tee -a $autoloaderlog $logfile
    gunzip $inboundfolder/$inboundfilename1
    #inboundfilename="$basefilename".txt
    inboundfilename="$basefilename".dat
    if [ -f $inboundfolder/$inboundfilename ]; then
      echo "[CheckDataFile] Found Data File: $inboundfilename" | tee -a $autoloaderlog $logfile
    else
      echo "[CheckDataFile] Data File : $inboundfilename not found in: $inboundfolder" | tee -a $autoloaderlog $logfile
      echo "[Autoloader] Terminating Autoloader execution" | tee -a $autoloaderlog $logfile
      CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
      SendMail $logfile "ERROR" "$inboundfilename1" "Data file not found in Inbound folder"
      exit 1
    fi
    ;;
  *.dat)
    echo "[CheckDataFile] Data File Found" | tee -a $autoloaderlog $logfile
    inboundfilename=$inboundfilename1
    echo "[CheckDataFile] Found Data File: $inboundfilename" | tee -a $autoloaderlog $logfile
    ;;
  *.txt)
    echo "[CheckDataFile] Trigger File Found" | tee -a $autoloaderlog $logfile
    inboundfilename=$inboundfilename1
    echo "[CheckDataFile] Found Trigger File: $inboundfilename" | tee -a $autoloaderlog $logfile
    ;;
esac

if [ "$inboundfilename" = "" ]; then
  sleep 60
  echo "[CallScript] No data file found in inbound folder, exiting..." | tee -a $autoloaderlog $logfile
  SendMail $logfile "ERROR" "$inboundfilename1" "$filesrc $filetype : Data file not found"
  CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
  exit
fi

#Send an alert mail, file received
SendMail $logfile "ALERT" "$inboundfilename" "$inboundfilename Received"

echo "[CheckDataFile] $timestamp - Started processing file: [$inboundfilename]" | tee -a $autoloaderlog $logfile
echo "[CheckDataFile] Processing: $inboundfilename" | tee -a $autoloaderlog $logfile

chmod 777 $inboundfolder/$inboundfilename $inboundfolder/$inboundfilename1

echo "[CheckDataType] File Type = [$filesrc $filetype] Action = [$executescript] Dependencies = [none]" | tee -a $autoloaderlog $logfile
echo "[CheckDataType] "
echo "[CheckDataType] filename      = $inboundfilename"
echo "[CheckDataType] filetype      = $filesrc $filetype"
echo "[CheckDataType] Executescript = $executescript"
echo "[CheckDataType] ErrorCount    = $errfilereccount"
echo "[CheckDataType] "

if [ "$executescript" = "" ]; then
  echo "[CheckDataType] Script not found for filetype=filesrc $filetype, exiting..." | tee -a $autoloaderlog $logfile
  CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
  (
    echo "To: $(cat $tntscriptsdir/$email_conf)"
    echo "Subject: LND-ERROR: $tenantid_uc [$custinst_uc] --> Cannot find data file type[] in config file"
    echo "Content-Type: text/html"
    echo
    echo -e "ERROR: Cannot find data file type[ $filesrc $filetype ] in config file.\nDatafile = $inboundfilename"
  ) | sendmail -t
  #    ( echo -e "ERROR: Cannot find data file type[ $filesrc $filetype ] in config file.\nDatafile = $inboundfilename" ) | mailx -s "LND-ERROR: $tenantid_uc [$custinst_uc] --> Cannot find data file type[] in config file" `cat $tntscriptsdir/$email_conf`
  exit
else
  echo "[CheckDataType] Script Identified: ($tntscriptsdir/$executescript)" | tee -a $autoloaderlog $logfile
  echo "[MoveDataFile] Moving data file [$inboundfilename] to Informatica SrcFiles dir:" | tee -a $autoloaderlog $logfile
  echo "[MoveDataFile] $infasrcdir" | tee -a $autoloaderlog $logfile
  cp $inboundfolder/$inboundfilename $infasrcdir
  echo "[MoveDataFile] Looking for [$infasrcdir/$inboundfilename]" | tee -a $autoloaderlog $logfile
  cd $infasrcdir
  if [ ! -f $infasrcdir/$inboundfilename ]; then
    echo "[MoveDataFile] Error - File not Found in Informatica Source Directory - $inboundfilename" | tee -a $autoloaderlog $logfile
    CleanInboundFolder 1 $basefilename | tee -a $autoloaderlog $logfile
    SendMail $logfile "ERROR" "$inboundfilename" "Data File not Found in Informatica Source Directory"
    exit 1
  fi
  echo "[MoveDataFile] Found moved data file: $inboundfilename" | tee -a $autoloaderlog $logfile
  echo "[MoveDataFile]" `ls -ltr $inboundfilename` | tee -a $autoloaderlog $logfile
  #Get file size and number of records
  RecordCount $filesrc $filetype
  cd $tntscriptsdir
  echo "[Autoloader] Executing script: $executescript"
  echo "[Autoloader] Executing: $executescript for $inboundfilename" | tee -a $autoloaderlog $logfile
  #Executing identified script;
  chmod 777 $tntscriptsdir/$executescript
  $tntscriptsdir/$executescript $inboundfilename | tee -a $autoloaderlog $logfile
  retcode=$?
  #Capture Script execution and Workflow return code
  if [ -f $tempdir/wfreturncode.txt ]; then
    return=`cat $tempdir/wfreturncode.txt | cut -d "=" -f2`
  else
    return=1
  fi
  #check the ErrorCount from the TELS_CORE_DATA_SUMMARY table.
  # #Target Error Count
  l_insbatchname="'""$inboundfilename""'"
  errfilereccount=`sqlplus -s $lpdb_username/$lpdb_password <<!
    set heading off feedback off verify off
    set serveroutput on size 100000
    declare
    l_batchname varchar2(1000);
    l_errorcount varchar2(255);
    begin
    l_batchname:=$l_insbatchname;
    select nvl(errorcount,0) into l_errorcount from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
    dbms_output.put_line(l_errorcount);
    end;
    /
!`
  echo "[Autoloader] Transaction Empty OD Files"
  if [ -f $tempdir/trnreturncode.txt ]; then
    trn_return=`cat $tempdir/trnreturncode.txt | awk '{print $1}'`
  else
    trn_return=0
  fi
  echo "[Autoloader] " | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Execute Command return code [$retcode]" | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Script execution return code [$return]" | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Script execution return Error code [$errfilereccount]" | tee -a $autoloaderlog $logfile
  echo "[Autoloader] Script execution return Error code [$trn_return]" | tee -a $autoloaderlog $logfile
  echo "[Autoloader] " | tee -a $autoloaderlog $logfile
  if [ "$retcode" = 0 -a "$return" = 0 -a "$errfilereccount" = 0 -a "$trn_return" = 0 ] ; then
    echo "[Autoloader] $return - Script '$executescript' execution completed succesfully." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] $errfilereccount - Script '$executescript' execution completed succesfully." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] $trn_return - Script '$executescript' execution completed succesfully." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] Archiving the files after successful execution." | tee -a $autoloaderlog $logfile
    CleanInboundFolder $return $basefilename | tee -a $autoloaderlog $logfile
    ErrorCount $sourcetype $inboundfilename
    echo "[Autoloader] Autoloader Process SUCCESS : [$inboundfilename]" | tee -a $autoloaderlog $logfile
    echo "[SuccessMail] Sending Autoloader SUCCESS mail, with log." | tee -a $autoloaderlog $logfile
    SendMail $logfile "SUCCESS" "$inboundfilename" "$inboundfilename"
  elif [ "$retcode" = 0 -a "$return" = 0 -a "$errfilereccount" != 0 -o "$errfilereccount" = 0 -a  "$trn_return" = 1 ] ; then
    echo "[Autoloader] $return - Script '$executescript' execution completed succesfully." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] $errfilereccount - Script '$executescript' execution completed with Warnings." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] $trn_return - Script '$executescript' execution completed with Warnings." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] Archiving the files after successful execution." | tee -a $autoloaderlog $logfile
    CleanInboundFolder $return $basefilename | tee -a $autoloaderlog $logfile
    ErrorCount $sourcetype $inboundfilename
    echo "[Autoloader] Autoloader Process Completed with WARNINGS: [$inboundfilename]" | tee -a $autoloaderlog $logfile
    echo "[WarningMail] Sending Autoloader WARNING mail, with log." | tee -a $autoloaderlog $logfile
    echo "[WarningMail] Sending WARNING mail as Informatica Process completed with Errors, with log." | tee -a $autoloaderlog $logfile
    SendMail $logfile "WARNING" "$inboundfilename" "$inboundfilename"
  else
    echo "[Autoloader] $return - Error in executing script '$executescript', check Log Files for more information." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] $errfilereccount - Error's in executing script '$executescript', check Log Files for more information." | tee -a $autoloaderlog $logfile
    echo "[Autoloader] Execution failed, Moving files to badfiles folder..." | tee -a $autoloaderlog $logfile
    CleanInboundFolder $return $basefilename | tee -a $autoloaderlog $logfile
    echo "[Autoloader] Autoloader Process FAILED : [$inboundfilename]" | tee -a $autoloaderlog $logfile
    echo "[FailureMail] Sending Autoloader ERROR mail, with log." | tee -a $autoloaderlog $logfile
    SendMail $logfile "ERROR" "$inboundfilename" "$inboundfilename"
    exit $return
  fi
fi

echo "===[$timestamp::END::"$0" ]===" | tee -a $autoloaderlog $logfile
