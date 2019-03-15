#!/bin/bash

#<<tels_utilityfunctions.sh>>

#-------------------------------------------------------------------------------
# Date        Author  Version
#-------------------------------------------------------------------------------
# 01/12/2017  Daniel  v00
#
# Description : Custom Functions
#
# Invoked by  : Can be invoked by any shell script in Landing Pad
#
# Required    : use  ". /apps/Callidus/tels/integrator/tels_utilityfunctions.sh"
#               line in the script that uses any of the below functions.
#
# Command Line: function_name <arguments as required by definition>
#
# Functions   :
#   DatafileCount ()
#   MoveFilesToAppServer () -- Required
#   MoveFilesToOutbound ()
#   ReadParameters () -- Required
#   ExecuteWorkflow () -- Required
#   RecordCount () -- Required
#   LoggingProcess () -- Required
#   DependencyChecker () -- Required
#   DependencySourceChecker ()
#   TargetDependencyChecker () -- Required
#   ErrorCount () -- Required
#   targetrecordcount ()
#   targetfilecount ()
#   MailHeader () -- Required
#   MailFooter () -- Required
#   SendMail () -- Required
#   CleanInboundFolder () -- Required
#   CheckFileGrowth () -- Required
#   CheckChecksum () -- Required
#   CheckCksum_org ()
#   CleanorgInboundfolder ()
#   ParPosProc ()
#   MergeErrorFile () -- Required
#   MergeInvestigationFile ()
#
################################################################################

# Import Environment Variables

. /home/callidus/.bash_profile
. /apps/Callidus/tels/integrator/tels_setenv_variables.sh

################################################################################
# Function: Check Outbound extract file size and move non-empty files to AppServer.
################################################################################
MoveFilesToAppServer ()
{

    startfolder=`pwd`
    tgtfolder=$1
    ob_filename=$2
    archfolder=$3
    filetype=$4
    filetype1=$5
    filereccount=0

    cd $tgtfolder
    chmod 775 $tgtfolder/$ob_filename

    filereccount=`wc -lwc $tgtfolder/$ob_filename | awk '{print$1}' | tail -1 | head -1`

    if [ $tgtfolder = $infatgtinbound ]; then
        Appfolder=$outboundfolder
        targetsystem="APPSERVER"
    elif [ $tgtfolder = $infatgtoutbound ]; then
        Appfolder=$lndoutboundfolder
        targetsystem="LNDDROPBOX"
    elif [ $tgtfolder = $infatgtinboundplain ]; then
        Appfolder=$outboundfolder
        targetsystem="APPSERVERPLAINTEXT"
    fi

    if [ $filereccount -ne 0 ]; then
        gzoutputFile=$ob_filename".gz"
        zpoutputfile=$ob_filename".zip"
        gpgoutputFile=$gzoutputFile".gpg"
        echo "[CallFunc] Zipping File : $ob_filename"
        cp $ob_filename $ob_filename".orig"
        zip -r $ob_filename".zip" $ob_filename
        gzip $ob_filename
        mv $ob_filename".orig" $ob_filename
        gpg -r B8D82B1A -e $ob_filename".gz"
    #    gpg -r $gpgcodemap -e $ob_filename".gz"
        
	   if [ $targetsystem = "LNDDROPBOX" ]; then
            echo "[CallFunc] Moving all Zipped files to Landing server Archive folder ($archfolder)."
            cd $infatgtoutbound
            filerecordsErr=`wc -lwc $infatgtoutbound/$ob_filename | awk '{print $1}'`
            echo "Target record count :$errfilereccount "
            if [ $filerecordsErr -gt 1 ]; then
                cp $tgtfolder/$ob_filename $Appfolder
                cp -r $tgtfolder/$zpoutputfile $archfolder
            fi
        fi
        if [ $targetsystem = "APPSERVER" ]; then
            echo "[CallFunc] Moving all Zipped files to Landing server Archive folder ($Appfolder)."
#            if [ "$filetype" = "TXSTA" -a "$filetype1" = "TXTA" ]; then
            if [ "$filetype" = "TXSTAG" ]; then
#                cp $tgtfolder/$gpgoutputFile $dependencycheck
                cp $tgtfolder/$gzoutputFile $dependencycheck
                cp -r $tgtfolder/$gzoutputFile $archfolder
            else
                cp -r $tgtfolder/$gzoutputFile $archfolder
#                cp $tgtfolder/$gpgoutputFile $Appfolder
                cp $tgtfolder/$gzoutputFile $Appfolder
            fi
        fi
        if [ $targetsystem = "APPSERVERPLAINTEXT" ]; then
            echo "[CallFunc] Moving all plaintext files to Landing server Archive folder ($Appfolder)."
            cp -r $tgtfolder/$ob_filename $archfolder
            cp $tgtfolder/$ob_filename $Appfolder
        fi
    else
        #echo "[CallFunc] $ob_filename file is empty. Not transferring empty file"
        echo "[CallFunc] $ob_filename file is empty."
    fi

    echo "[CallFunc] Removing All files from $tgtfolder folder."
    rm -f $tgtfolder/$ob_filename*
    rm -f $tgtfolder/$gzoutputFile

    cd $startfolder

}

################################################################################
# Function: Check Outbound extract file size and move files to Landing Pad
#   Dropbox Outbound folder
################################################################################
MoveFilesToOutbound ()
{

  target_dir=$1
  outbound_file=$2
  archive_dir=$3

  echo "[Call Function MoveFilesToOutbound - Start]"

  start_dir=`pwd`

  record_count=0

  cd $target_dir

  chmod 775 $target_dir/$outbound_file

  record_count=`wc -lwc $target_dir/$outbound_file | awk '{print$1}' | tail -1 | head -1`

  outbound_dir=$lndoutboundfolder

  echo "  Copying files to Landing Pad outbound folder ($outbound_dir)"

  cp $target_dir/$outbound_file $outbound_dir

  echo "  Outbound file record count: $record_count"

  echo "  Copying files to Landing Pad archive folder ($archive_dir)"

  cp -r $target_dir/$outbound_file $archive_dir

  echo "  Removing files from Landing Pad target folder ($target_dir)"

  rm -f $target_dir/$outbound_file*

  cd $start_dir

  echo "[Call Function MoveFilesToOutbound - End]"

}

################################################################################
# Function : set the variables by reading configure files and export them.
#################################################################################
ReadParameters()
{

    sourcetype=$1
    filetype=$2

    chmod 777 $tntscriptsdir/$typemap_conf

    echo "[Autoloader] Reading Typemap data for $sourcetype $filetype"

    srcfiletype=${sourcetype}"_"${filetype}

    executescript=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f3`
    inboundwfname=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f4`
    outboundwfname=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f5`
    stagetablename=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f6`
    wftype=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f7`
    wftype1=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f8`
    Dependency=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f9`
    headerflag=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f10`
    flag=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f11`
    NumPartitions=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f12`
    foldername=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f13`
    buname=`cat $tntscriptsdir/$typemap_conf | grep "$sourcetype|$filetype|" | cut -d "|" -f14`

    echo "[Autoloader] Received filetype      : $filetype"
    echo "[Autoloader] Source type            : $sourcetype"
    echo "[Autoloader] Script to be Executed  : $executescript"
    echo "[Autoloader] Inbound Workflow name  : $inboundwfname"
    echo "[Autoloader] Outbound Workflow name : $outboundwfname"
    echo "[Autoloader] Stageable name         : $stagetablename"
    echo "[Autoloader] Workflow type [wftype] : $wftype"
    echo "[Autoloader] Workflow type [wftype1]: $wftype1"
    echo "[Autoloader] File Dependency        : $Dependency"
    echo "[Autoloader] Concatenation flag(1/0): $headerflag"
    echo "[Autoloader] Concatenation flag(Y/N): $flag"
    echo "[Autoloader] File Partitions(16/5/0): $NumPartitions"
    echo "[Autoloader] FolderName of the Workflow: $foldername"
    echo "[Autoloader] BusinessUnitName for archiving: $buname"
    echo "[Autoloader] "

    #Export all the above variables so that they are accessible in other scripts.
    export filetype
    export sourcetype
    export srcfiletype
    export executescript
    export inboundwfname
    export outboundwfname
    export stagetablename
    export wftype
    export wftype1
    export Dependency
    export headerflag
    export flag
    export NumPartitions
    export foldername
    export buname

}

###############################################################################################
# Function : Execute Workflow, Return Success/Error code and update datafilesummary table
################################################################################
ExecuteWorkflow()
{

foldername=$1
workflowname=$2
filehandler=$3
filename=$4
stagetablename=$5
filereccount=$6

runparamfile="$infasrcdir/$parameterfile"
pid=`ps | grep "bash" | awk '{print$1}' | tail -1 | head -1`
instancename=$tenantid_uc"_"$timestamp"_"$pid

echo "[CallFunc-ExecuteWorkflow] Workflow [$workflowname] execution started at $timestamp."
pmcmd startworkflow -sv $service -d $domain -u $infa_username -p $infa_password -f $foldername -paramfile $runparamfile -wait -rin $instancename $workflowname
v_pmcmdreturncode=$?

if [ $v_pmcmdreturncode -ne 0 ]; then
    echo "[CallFunc-ExecuteWorkflow] $v_pmcmdreturncode - Error in [$workflowname] Load, check Workflow Log."
    sh $tntscriptsdir/$inboundfilerun_end $filehandler $filename $v_pmcmdreturncode
    echo "wfret=$v_pmcmdreturncode" > $tempdir/wfreturncode.txt
    sh $tntscriptsdir/$datafilesummary_end $filehandler $filename $stagetablename $filename $v_pmcmdreturncode $filereccount
    return $v_pmcmdreturncode
elif [ $workflowname = "" ]; then
    echo "[CallFunc-ExecuteWorkflow] $workflowname - Workflow is not defined for Control file."
    echo "wfret=0" > $tempdir/wfreturncode.txt
else
    echo "wfret=0" > $tempdir/wfreturncode.txt
    echo "[CallFunc-ExecuteWorkflow]"
    echo "[CallFunc-ExecuteWorkflow] Workflow $workflowname with run instance name [$instancename] Completed with return code [$v_pmcmdreturncode]."
    echo "[CallFunc-ExecuteWorkflow]"
    sh $tntscriptsdir/$inboundfilerun_end $filehandler $filename $v_pmcmdreturncode
    ibrun=$?
    sh $tntscriptsdir/$datafilesummary_end $filehandler $filename $stagetablename $filename $v_pmcmdreturncode $filereccount
    sumrum=$?
    if [ "$ibrun" = 0 -a "$sumrum" = 0 ]; then
        result=0
    else
        result=1
    fi
    return $result
fi

}

###############################################################################################
# Function : Count and Return the number of records in the input file & Error File
################################################################################
RecordCount ()
{

    sourcetype=$1
    filetype=$2

    filerecords=0
    filesize=0
    errorrecords=0
    headerflagcheck=$headerflag

    cd $infasrcdir

    chmod 777 $infasrcdir/*$filetype*

    datafilename=`find $infasrcdir -name "$sourcetype"_"$filetype*" -type f -exec basename \{} \; | sort -n | head -1 | tail -1`

    if [ "$datafilename" != "" ]; then
        if [ $headerflagcheck = "1" ]; then
            filerecords1=`sed 1d $infasrcdir/$sourcetype"_"$filetype* | wc -lwc | awk '{print $1}'`
            filerecords=`echo $filerecords1 | tail -1 | head -1`
            filesize1=`wc -lwc $infasrcdir/$sourcetype"_"$filetype* | awk '{print $3}'`
            filesize=`echo $filesize1 | tail -1 | head -1`
            filesizeKB=`echo "scale=2; $filesize/1024/1024" | bc -l`
            filesizeKB="$filesizeKB"" M"
        else
            filerecords1=`wc -lwc $infasrcdir/$sourcetype"_"$filetype* | awk '{print $1}'`
            filerecords=`echo $filerecords1 | tail -1 | head -1`
            filesize1=`wc -lwc $infasrcdir/$sourcetype"_"$filetype* | awk '{print $3}'`
            filesize=`echo $filesize1 | tail -1 | head -1`
            filesizeKB=`echo "scale=2; $filesize/1024/1024" | bc -l`
            filesizeKB="$filesizeKB"" M"
        fi
    fi

    echo "[Autoloader] File Records     : $filerecords"
    echo "[Autoloader] File Size        : $filesizeKB"
    echo "[Autoloader] Header Flag Check: $headerflagcheck"

    export filerecords
    export filesizeKB
    export headerflagcheck

}

###############################################################################################
# Function : Log the name of the inbound/outbound file being processed.
################################################################################
LoggingProcess ()
{

    filehandler=$1
    filename=$2
    stagetablename=$3
    batchname=$4

    sh $tntscriptsdir/$inboundfilerun_start $filehandler $filename
    processretcode=$?
    if [ $processretcode != 0 ]; then
        echo "[CallFunc] $processretcode - Error logging to ${tenantid}_inbound_file_run [${tntscriptsdir}/${inboundfilerun_start} ${filehandler} ${filename}]"
        echo "wfret=1" > $tempdir/wfreturncode.txt
    fi

    sh $tntscriptsdir/$datafilesummary_start $filehandler $filename $stagetablename $batchname
    summaryretcode=$?
    if [ $summaryretcode != 0 ]; then
        echo "[CallFunc] $summaryretcode - Error logging to ${tenantid}_data_file_summary  [${tntscriptsdir}/${datafilesummary_start} ${filehandler} ${filename} ${stagetablename} ${batchname}]"
        echo "wfret=1" > $tempdir/wfreturncode.txt
    fi

    if [ "$processretcode" = 0 -a "$summaryretcode" = 0 ]; then
        result=0
    else
        result=1
    fi

    return $result

}

###############################################################################################
# Function : Check for any Dependencies based on filetype
################################################################################
DependencyChecker()
{

    sourcetype=$1
    filetype=$2

    filename=`find $inboundfolder -name "*$sourcetype_$filetype*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`

    basefilename=`echo $filename | awk -F\. '{print $1}'`

    if [ "$filename" = "" ]; then
        echo "[Autoloader] There are no $filetype files in Inbound folder."
        exit 0
    fi

    cat /dev/null > $tempdir/dependency_list.txt

    if [ "$Dependency" != "none" ]; then
        echo $Dependency | cut -d "," -f1 >> $tempdir/dependency_list.txt
        echo $Dependency | cut -d "," -f2 >> $tempdir/dependency_list.txt
        while read type
        do
            datafilename1=`find $archivefolder -name "*$type*$filedate*" -type f -exec basename \{} \; | sort -n | head -1 | tail -1`
            if [ "$datafilename1" != "" ]; then
                echo "[Autoloader] $filetype : $datafilename1 dependent file processed successfully."
                echo "[Autoloader]" $datafilename1
                echo "dpcode=0" > $tempdir/dependency_code.txt
            else
                echo "[Autoloader] $filetype : $type dependent file has to be processed."
                echo "dpcode=1" > $tempdir/dependency_code.txt
            fi
        done < $tempdir/dependency_list.txt
    else
        echo "dpcode=2" > $tempdir/dependency_code.txt
    fi

}

###############################################################################################
# Function : Check for any Target Dependencies based on filetype
#################################################################################
TargetDependencyChecker ()
{

    filetype=$1
    filetype1=$2
    archfolder=$3
    badfolder=$4

    cd $dependencycheck

    filename=`find $dependencycheck -name "*_${filetype}_*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`

    basefilename=`echo $filename | cut -d "_" -f2`

    echo "TargetDependencyChecker: $filename"
    echo "TargetDependencyChecker Basefilename: $basefilename"

    if [ "$basefilename" = "TXSTAG" ]; then
        filename1=`find $dependencycheck -name "*_TXTA_*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`
        basefilename1=`echo $filename1 | cut -d "_" -f2`
        echo "TargetDependencyChecker: $filename1"
        echo "TargetDependencyChecker Basefilename1: $basefilename1"
    else
        filename1=`find $dependencycheck -name "*$filetype1*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`
        basefilename1=`echo $filename1 | cut -d "_" -f2`
        echo "TargetDependencyChecker: $filename1"
        echo "TargetDependencyChecker Basefilename1: $basefilename1"
    fi

    if [ "$basefilename" = "TXSTAG" ]; then
        filename2=`find $dependencycheck -name "*_TXTG_*" -type f -exec basename \{} \; | sort -n | head -2 | tail -1`
        basefilename2=`echo $filename2 | cut -d "_" -f2`
        echo "TargetDependencyChecker: $filename2"
        echo "TargetDependencyChecker Basefilename2: $basefilename2"
    fi

    if [ "$basefilename" = "TXSTAG" -a "$basefilename1" = "TXTA" -a "$basefilename2" = "TXTG" ]; then
        echo "[Autoloader] dependency on the $tgtfilename files are found $tgtfolder folder."
        mv $filename $outboundfolder
        mv $filename1 $outboundfolder
        mv $filename2 $outboundfolder
        echo "File moved to appserver $filename $outboundfolder"
        echo "File moved to appserver $filename1 $outboundfolder"
        echo "File moved to appserver $filename2 $outboundfolder"
        cat /dev/null > $tempdir/trnreturncode.txt
        echo 0 > $tempdir/trnreturncode.txt
    elif [ "$basefilename" = "TXSTA" -a "$basefilename1" = "TXTA" ]; then
        echo "[Autoloader] dependency on the $tgtfilename files are found $tgtfolder folder."
        mv $filename $outboundfolder
        mv $filename1 $outboundfolder
        echo "File moved to appserver $filename $outboundfolder"
        echo "File moved to appserver $filename1 $outboundfolder"
        cat /dev/null > $tempdir/trnreturncode.txt
        echo 0 > $tempdir/trnreturncode.txt
    elif [ "$basefilename" = "" -a "$basefilename1" = "" ]; then
        echo "No files in the DependencyChecker working directory. Skipping this process."
    elif [ "$basefilename" = "TXSTA" -o "$basefilename1" = "" ]; then
        mv *$filename* $badfolder
        mv *$filename1* $badfolder
        echo "File $filename moved to $badfolder"
        cat /dev/null > $tempdir/trnreturncode.txt
        echo 1 > $tempdir/trnreturncode.txt
    elif [ "$basefilename" = "" -o "$basefilename1" = "TXTA" ]; then
        mv *$filename1* $badfolder
        mv *$filename* $badfolder
        echo "File $filename moved to $badfolder"
        cat /dev/null > $tempdir/trnreturncode.txt
        echo 1 > $tempdir/trnreturncode.txt
    fi

}

###############################################################################################
# Function : Check Outbound extract file and write error count.
################################################################################
ErrorCount ()
{

    filesrc=$1
    filename=$2

	echo "[Error Count] filesrc=[$filesrc] filename=[$filename]"
	
    tgtfilereccount1=0
    tgtfilereccount2=0
    errfilereccount=0
    tgtfilename1=""
    tgtfilename2=""
    errfilename=""

    #### Archving Target File,Error count

    l_insfilesrc="'""$filesrc""'"
    l_insbatchname="'""$filename""'"

    tgtfilereccount1=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(4000);
        l_batchname varchar2(4000);
        l_errorcount varchar2(4000);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select to_char(nvl(targetrecordcount_1,0)) into l_errorcount from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_errorcount);
        end;
        /
!`

    tgtfilereccount2=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(255);
        l_batchname varchar2(255);
        l_errorcount varchar2(255);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select nvl(targetrecordcount_2,0) into l_errorcount from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_errorcount);
        end;
        /
!`

    errfilereccount=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(255);
        l_batchname varchar2(255);
        l_errorcount varchar2(255);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select nvl(errorcount,0) into l_errorcount from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_errorcount);
        end;
        /
!`

    errfilename=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(255);
        l_batchname varchar2(255);
        l_errorfilename varchar2(255);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select nvl(errorfilename,'null') into l_errorfilename from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_errorfilename);
        end;
        /
!`

    tgtfilename1=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(1000);
        l_batchname varchar2(1000);
        l_targetfilename varchar2(4000);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select nvl(targetfilename_1,'null') into l_targetfilename from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_targetfilename);
        end;
        /
!`

    tgtfilename2=`sqlplus -s $lpdb_username/$lpdb_password <<!
        set heading off feedback off verify off
        set serveroutput on size 100000
        declare
        l_filesrc varchar2(1000);
        l_batchname varchar2(1000);
        l_targetfilename varchar2(4000);
        begin
        l_batchname:=$l_insbatchname;
        l_filesrc:=$l_insfilesrc;
        select nvl(targetfilename_2,'null') into l_targetfilename from TELS_CORE_DATA_SUMMARY where sourcefilename=$l_insbatchname;
        dbms_output.put_line(l_targetfilename);
        end;
        /
!`

    cd $infasrcdir
    cat /dev/null > $infasrcdir/ODITARGET

    count1=0
    count2=0

    IFS=","

    for i in $tgtfilename1
    do
        if [ `echo $i | grep -c "_OB_" ` -gt 0 ]; then
            count1=`expr $count1 + 1`
        else
            echo "<tr>" >> ODITARGET
            echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black">" >> ODITARGET
            echo "$i" >> ODITARGET
            echo "</span></td>" >> ODITARGET
            count1=`expr $count1 + 1`
            for j in $tgtfilereccount1
            do
                count2=`expr $count2 + 1`
                if [ $count1 = $count2 ]; then
                    echo "<td>" >> ODITARGET
                    echo "$j" >> ODITARGET
                    echo "</td>" >> ODITARGET
                    perl -e print "<br/>" >> ODITARGET
                    count2=0
                    break
                fi
            done
            echo "</tr>" >> ODITARGET
        fi
    done

    tgt=`cat $infasrcdir/ODITARGET`

    cd $infasrcdir
    cat /dev/null > $infasrcdir/ODITARGET_OB

    count1=0
    count2=0

    IFS=","

    for i in $tgtfilename1
    do
        if [ `echo $i | grep -c "_OB_" ` = 0 ]; then
            count1=`expr $count1 + 1`
        else
            echo "<tr>" >> ODITARGET_OB
            echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black">" >> ODITARGET_OB
            echo "$i" >> ODITARGET_OB
            echo "</span></td>" >> ODITARGET_OB
            count1=`expr $count1 + 1`
            for j in $tgtfilereccount1
            do
                count2=`expr $count2 + 1`
                if [ $count1 = $count2 ] ; then
                    echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:red">" >> ODITARGET_OB
                    echo "$j" >> ODITARGET_OB
                    echo "</td>" >> ODITARGET_OB
                    perl -e print "<br/>"  >> ODITARGET_OB
                    count2=0
                    break
                fi
            done
            echo "</tr>" >> ODITARGET_OB
        fi
    done

    tgtob=`cat $infasrcdir/ODITARGET_OB`
    tgtcheck=`wc -l $infasrcdir/ODITARGET_OB | awk  '{print $1}'`

    export tgtfilereccount1
    export tgtfilereccount2
    export errfilereccount
    export errfilename
    export tgtfilename1
    export tgtfilename2
    export tgt
    export tgtcnt
    export tgtob

}

###############################################################################################
# Function : Send mail in HTML format : Header
#################################################################################
MailHeader ()
{

filename="$1"
ProcessingResult="$2"
echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<title>sample HTML Mail Document</title>"
echo "<style>p {color:Royalblue} body {background-color:white}</style>"
echo "</head>"
echo "<body>"
echo "<hr width="100%" align=left>"
echo "<span style=font-size:10.0pt;font-family:"Arial"><b>"$tenantid_uc"-LND Data Processing Results</b></span>"
echo "<hr width="100%" align=left>"
echo "<table border = 0 cellpadding = 1>"
echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> Processing data for: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial"><b>"$tenantid_uc"</b></span></td> </tr>"
echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> Instance: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial">"$custinst_uc"</span></td> </tr>"
echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> DATAFILE: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial"><b>"$filename"</b></span></td></tr>"
echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> Start Time: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial">"$starttime"</span></td></tr>"
if [ "$ProcessingResult" = "SUCCESS" -o "$ProcessingResult" = "ERROR" -o "$ProcessingResult" = "WARNING" -a  $filetype != "ADJUSTMENT"  ] ; then
     echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> End Time: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial">`date +%m/%d/%Y-%H:%M:%S`</span></td></tr>"
     echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> SIZE: </span></td> <td><span style=font-size:8.0pt;font-family:"Arial">"$filesizeKB"</span></td></tr>"
     echo "<tr><td><span style=font-size:8.0pt;font-family:"Arial"> RECORDS: </span></td><td><span style=font-size:8.0pt;font-family:"Arial">"$filerecords"</span></td></tr>"
fi
echo "</table>"
echo "<hr width="100%" align=left>"
echo "<table border=1>"
echo "<tr>"
if [ "$ProcessingResult" = "SUCCESS" ] ; then
     echo "<td><span style=font-size:10.0pt;font-family:"Arial";"color:black"><b>Processing Results</b></span></td><td><span style=font-size:8.0pt;font-family:"Arial";"color:darkgreen"><b>"$ProcessingResult"</b></span></td></tr>"
elif [ "$ProcessingResult" = "WARNING" ] ; then
     echo "<td><span style=font-size:10.0pt;font-family:"Arial";"color:black"><b>Processing Results</b></span></td><td><span style=font-size:8.0pt;font-family:"Arial";"color:orange"><b>"$ProcessingResult"</b></span></td></tr>"
else
     echo "<td><span style=font-size:10.0pt;font-family:"Arial";"color:black"><b>Processing Results</b></span></td>"
     echo "<td><span style=font-size:10.0pt;font-family:"Arial";"color:red"><b>$ProcessingResult</b></span></td>"
fi
echo "</tr>"
  echo "</table>"
echo "<hr width="100%" align=left>"
  if [ "$ProcessingResult" = "SUCCESS" -o "$ProcessingResult" = "WARNING" ] ; then
     echo "<table border=1>"
     echo "<tr>"
echo "<td colspan="2" bgcolor="DEB887"><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>File Processing Summary</b></span></td>"
echo "</tr>"
echo "<tr bgcolor="cyan">"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>Error FileName (fromLandingPad)</b></span></td>"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>FileCount</b></span></td>"
echo "</tr>"
echo "<tr>"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black">$errfilename</span></td>"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:red">$errfilereccount</span></td>"
echo "</tr>"
echo "<tr bgcolor="cyan">"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>Target FileName</b></span></td>"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>FileCount</b></span></td>"
echo "</tr>"
echo $tgt;
if [ "$tgtcheck" != "0" ] ; then
echo "<tr bgcolor="cyan">"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>Files For Business (fromLandingPad)</b></span></td>"
echo "<td><span style=font-size:8.0pt;font-family:"Arial";"color:black"><b>FileCount</b></span></td>"
echo "</tr>"
echo $tgtob;
else
echo "<tr>"
echo "</tr>"
fi
echo "</table>"
fi
   echo "<hr width="50%" align=left>"
echo "<table border=1 cellpadding=1>"
echo "<tr>"
echo "<td><span style='font-size:8.0pt;font-family:"Arial";color:#7777cc'>"
echo "<hr width="100%" align=left>"
echo "<span style=font-size:10.0pt;font-family:"Arial"><b>"Output from this autoloader utility:"</b></span>"
echo "<hr width="100%" align=left>"
echo "<pre>"

}

###############################################################################################
# Function : Send mail in HTML format : Footer
###############################################################################################
MailFooter ()
{
	echo "</pre>"
	echo "</td>"
	echo "</tr>"
	echo "</table>"
	echo "<hr width="100%" align=left>"
	echo "</body>"
	echo "</html>"
}

###############################################################################################
# Function : Send mail in HTML format : Main function
###############################################################################################
SendMail ()
{
    templogfile="$1"
    mailtype="$2"
    filename="$3"
    description="$4"

    Mailbody="$tempdir/mail_body.txt"
    SUBJECT="LND-$mailtype: $tenantid_uc [$custinst_uc] --> $description"

    cat /dev/null > $Mailbody

    MailHeader $filename $mailtype >> $Mailbody
    cat $templogfile >> $Mailbody
    MailFooter >> $Mailbody

    chmod 777 $Mailbody

#    mutt -e 'set content_type=text/html' -s "$SUBJECT" `cat $tntscriptsdir/$email_conf` <$Mailbody

    (
        echo "To: $(cat $tntscriptsdir/$email_conf)"
        echo "Subject: ${SUBJECT}"
        echo "Content-Type: text/html"
        echo
        cat $Mailbody
    ) | sendmail -t
}

######################################################################################################
# Function : During the execution upon SUCCESS or FAILURE at any stage, copy and remove Inbound files.
#        and output the archival locations for both Inbound and Target files
###############################################################################################
CleanInboundFolder ()
{
    status=$1
    file="$2"
    filetype1=`echo "$file" | cut -d "_" -f2`

    echo "[Autoloader] --- Business Unit Name = $buname ---"

    cd $inboundfolder

    #Identify where to move files Source Archiving

    if [ $status = 0 ]; then
#        if [ "$buname" = "PCA" ] ; then
            cp $inboundfolder/$file* $PCA_sources_archive
            echo "[Autoloader] Copying '$filetype1' files to $PCA_sources_archive"
#        fi
    else
#        if [ "$buname" = "PCA" ] ; then
            cp $inboundfolder/$file* $PCA_sources_badfiles
            echo "[Autoloader] Copying '$filetype1' files to $PCA_sources_badfiles"
#        fi
    fi

    # Move files

    rm -f $inboundfolder/$file*
    echo "[Autoloader] Removing Temporary files."
    rm -f $workdir/lock.out
    rm -f $tempdir/returncode.txt
    rm -f $tempdir/wfreturncode.txt
    rm -f $tempdir/trnreturncode.txt
    rm -f $tempdir/dependency*
    rm -f $infasrcdir/*$filetype*
    rm -f $infasrcdir/field_validation.txt
}

###############################################################################################
# Function : check if file completely loaded or not.
###############################################################################################
CheckFileGrowth ()
{
    inputfile="$1"

    cd $inboundfolder

    cksumold=`cksum $inboundfolder/$inputfile | awk '{print $2}' | tail -1 | head -1`
    sleep 5
    cksumnew=`cksum $inboundfolder/$inputfile | awk '{print $2}' | tail -1 | head -1`

    if [ $cksumold = $cksumnew ] ; then
        fileLoadstatus=0
    else
        fileLoadstatus=1
    fi

    return $fileLoadstatus
}

###############################################################################################
# Function : To verify Audit file and data file .
###############################################################################################
CheckChecksum ()
{
    auditfile="$1"
    datafile="$2"

    cksumDatafile=`cksum $inboundfolder/$datafile | awk '{print $2}' | tail -1 | head -1`
    cksumAuditfile=`cat $inboundfolder/$auditfile | awk '{print $2}' | tail -1 | head -1`

    #echo "[CheckChecksum] Data file size: $cksumDatafile"
    #echo "[CheckChecksum] File size in auditfile: $cksumAuditfile"

    if [ $cksumDatafile = $cksumAuditfile ]; then
        filestatus=0
    else
        # try cleaning the file
        cksumDatafile=`$tntscriptsdir/clean_text.pl $inboundfolder/$datafile | cksum | awk '{print $2}' | tail -1 | head -1`
        if [ $cksumDatafile = $cksumAuditfile ] ; then
            $tntscriptsdir/clean_text.pl $inboundfolder/$datafile > ~/test.cleaning
            filestatus=0
        else
            filestatus=1
        fi
    fi

    return $filestatus
}

###############################################################################################
#
###############################################################################################
MergeErrorFile()
{

    filename_mer=$1
    cd $infatgtdir
    filecount_mer=`wc -l $infatgtdir/$filename_mer | awk  '{print $1}' `
    if [ $filecount_mer -gt 0 ]; then
        /bin/echo "FILENAME\tRECORDNUMBER\tTABLENAME\tFIELDNAME\tRECORDKEY\tERRORMESSAGE\tFILERUNDATE" > temp
        cat $filename_mer >> temp
        mv temp $filename_mer
#    else
#        $filename_mer
    fi

}

#####
#####
##### Not confirmed required for TELS below here #####
#####
#####

#######################################################################################################
# Function : Count the No.of Data files received in Inbound folder for corresponding filetype supplied
#

DatafileCount () {

filetype="$1"
cd $inboundfolder

datafilename=`find $inboundfolder -name "*$filetype*" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `

case "$datafilename" in
*.dat.gz)
        echo "[FileCount ] Data file is GZipped file."
        dcount=`ls -ltr $inboundfolder/*$filetype*.dat.gz | wc -l | awk '{print $1}' |tail -1 |head -1`;;
*.dat)
        echo "[FileCount ] Data file is Text file."
        dcount=`ls -ltr $inboundfolder/*$filetype*.dat| wc -l | awk '{print $1}' |tail -1|head -1`;;

*.csv.gz)
        echo "[FileCount ] Data file is GZipped file."
        dcount=`ls -ltr $inboundfolder/*$filetype*.csv.gz | wc -l | awk '{print $1}' |tail -1 |head -1`;;
*.csv)
        echo "[FileCount ] Data file is Text file."
        dcount=`ls -ltr $inboundfolder/*$filetype*.csv| wc -l | awk '{print $1}' |tail -1|head -1`;;
esac

return $dcount
}

###############################################################################################
# Function : Check for any Dependencies based on filetype
#
DependencySourceChecker()
{
sourcetype=$1
filetype=$2
filename=`find $inboundfolder -name "*$sourcetype_$filetype*" -type f -exec basename \{} \;| sort -n | head -2|tail -1 `
basefilename=`echo $filename|awk -F\. '{print $1}' `

if [ "$filename" = "" ]; then
     echo "[Autoloader] There are no $filetype files in Inbound folder."
     exit 0
fi

cat /dev/null > $tempdir/dependency_list.txt

if [ "$Dependency" != "none" ]; then
     echo $Dependency | cut -d "," -f1 >> $tempdir/dependency_list.txt
     echo $Dependency | cut -d "," -f2 >> $tempdir/dependency_list.txt

     while read type
     do
         datafilename1=`find $archivefolder -name "*$type*$filedate*" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `
         if [ "$datafilename1" != "" ]; then
             echo "[Autoloader] $filetype : $datafilename1 dependent file processed Successfully. "
             echo "[Autoloader]" $datafilename1
             echo "dpcode=0" > $tempdir/dependency_code.txt
         else
             echo "[Autoloader] $filetype : $type dependent file has to be processed "
             echo "dpcode=1" > $tempdir/dependency_code.txt
           fi
     done < $tempdir/dependency_list.txt
else
            echo "dpcode=2" > $tempdir/dependency_code.txt
   fi
}

targetrecordcount()
{
    targettype=$1
    #filetype=$2
    targetfilerecords=0
    errorrecords=0

    cd $infatgtdir
    chmod 777 $infatgtdir/*$targettype*

    #datafilename=`find /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/ -name "targettype*" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `
    datafilename=`find $infatgtdir -name "$targettype*" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `

if [ "$datafilename" != "" ]; then
     filerecords1=`wc -lwc $infatgtdir/$targettype* |awk '{print $1}'`
     targetfilerecords=`echo $filerecords1|tail -1|head -1`

     #filesize1=`wc -lwc $infasrcdir/$sourcetype"_"$filetype* |awk '{print $3}'`
     #filesize=`echo $filesize1|tail -1|head -1`

    #filesizeKB=`echo "scale=2; $filesize/1024/1024" |bc -l`
     #filesizeKB="$filesizeKB"" M"

fi
    echo "[Autoloader] File Records   : $filerecords"
    #echo "[Autoloader] File Size      : $filesizeKB"


export targetfilerecords
#export filesizeKB
}


targetfilecount()
{
    targetfile=$1
    targetfilerecords=0
    errorrecords=0

    cd $infatgtdir
    chmod 775 $infatgtdir/$targetfile

    #datafilename=`find /apps/Informatica/PowerCenter10.1.1/server/infa_shared/TgtFiles/ -name "targettype*" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `
    datafilename=`find $infatgtdir -name "$targetfile" -type f -exec basename \{} \;| sort -n |head -1|tail -1 `

if [ "$datafilename" != "" ]; then
     filerecords2=`wc -lwc $infatgtdir/$targetfile |awk '{print $1}'`
     targetfilerecords1=`echo $filerecords2|tail -1|head -1`
        if [ "$targetfilerecords1" = 0 ]; then
          rm $targetfile
        fi

fi
    echo "[Autoloader] File Records   : $filerecords"
    #echo "[Autoloader] File Size      : $filesizeKB"


export targetfilerecords1
}

###############################################################################################
# Function : To verify Audit file and data file .
#
CheckCksum_org ()
{

auditfile="$1"
datafile="$2"
cksumDatafile=`cksum $org_inbound/$datafile |awk '{print $2}' |tail -1|head -1`
cksumAuditfile=`cat $org_inbound/$auditfile |awk '{print $2}' |tail -1|head -1`

#echo "[CheckChecksum] Data file size: $cksumDatafile"
#echo "[CheckChecksum] File size in auditfile: $cksumAuditfile"

  if [ $cksumDatafile = $cksumAuditfile ] ; then
     filestatus=0
  else
     # try cleaning the file
     cksumDatafile=`$tntscriptsdir/clean_text.pl $org_inbound/$datafile | cksum | awk '{print $2}' |tail -1|head -1`
     if [ $cksumDatafile = $cksumAuditfile ] ; then
        $tntscriptsdir/clean_text.pl $org_inbound/$datafile > ~/test.cleaning
         filestatus=0
     else
        filestatus=1
     fi
  fi

return $filestatus
}

######################################################################################################
# Function : During the execution upon SUCCESS or FAILURE at any stage, copy and remove Inbound files.
#
CleanorgInboundfolder ()
{

status=$1
file="$2"

#buname=`echo "$file" | cut -d "_" -f1`
filetype1=`echo "$file" | cut -d "_" -f2`

cd $org_inbound

 #Identify where to move files Source Archiving
  if [ $status = 0 ]; then
      Destinationfolder=$archivefolder
      if [ "$buname" = "PEX" ] ; then
      cp $org_inbound/$file* $PEXarchive
      elif [ "$buname" = "CSD" ] ; then
       cp $org_inbound/$file* $CSDarchive
     elif [ "$buname" = "TW" ] ; then
      cp $org_inbound/$file* $TWarchive
      elif [ "$buname" = "GCC" ] ; then
      cp $org_inbound/$file* $GCCarchive
       elif [ "$buname" = "GESA" ] ; then
      cp $org_inbound/$file* $GESAarchive
      elif [ "$buname" = "GESI" ] ; then
      cp $org_inbound/$file* $GESIarchive
      elif [ "$buname" = "TCW" ] ; then
       cp $org_inbound/$file* $TCWarchive
      elif [ "$buname" = "T007" ] ; then
       cp $org_inbound/$file* $T007archive
             elif [ "$buname" = "BTS" ] ; then
       cp $org_inbound/$file* $BTSarchive
  fi
 else
     Destinationfolder=$badfilesfolder
     if [ "$buname" = "PEX" ] ; then
       cp $org_inbound/$file* $PEXbadfiles
      elif [ "$buname" = "CSD" ] ; then
       cp $org_inbound/$file* $CSDbadfiles
      elif [ "$buname" = "TW" ] ; then
       cp $org_inbound/$file* $TWbadfiles
      elif [ "$buname" = "GCC" ] ; then
       cp $org_inbound/$file* $GCCbadfiles
       elif [ "$buname" = "GESA" ] ; then
       cp $org_inbound/$file* $GESAbadfiles
        elif [ "$buname" = "GESI" ] ; then
       cp $org_inbound/$file* $GESIbadfiles
       elif [ "$buname" = "TCW" ] ; then
       cp $org_inbound/$file* $TCWbadfiles
       elif [ "$buname" = "T007" ] ; then
       cp $org_inbound/$file* $T007badfiles
              elif [ "$buname" = "BTS" ] ; then
       cp $org_inbound/$file* $BTSbadfiles
  fi
 fi

#Source Archiving
#Archiving & Rejecting the PEX & LEAVE Source files and update the message in the LND  Mails
if [ $status = 0 -a "$buname" = "PEX" ] ; then
echo "[Autoloader] Copying '$filetype' files to $PEXarchive."
elif [ $status != 0 -a "$buname" = "PEX" ] ; then
echo "[Autoloader] Copying '$filetype' files to $PEXbadfiles."
fi

#Archiving & Rejecting the CSD Source files and update the message in the LND  Mails
if [ $status = 0 -a "$buname" = "CSD" ] ; then
echo "[Autoloader] Copying '$filetype' files to $CSDarchive."
elif [ $status != 0 -a "$buname" = "CSD" ] ; then
echo "[Autoloader] Copying '$filetype' files to $CSDbadfiles."
fi

#Archiving & Rejecting the TW Source files and update the message in the LND  Mails
if [ $status = 0 -a "$buname" = "TW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TWarchive."
elif [ $status != 0 -a "$buname" = "TW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TWbadfiles."
fi

#Archiving & Rejecting the GCC Source files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GCC" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GCCarchive."
elif [ $status != 0 -a "$buname" = "GCC" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GCCbadfiles."
fi

#Archiving & Rejecting the GCC Source files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GESA" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESAarchive."
elif [ $status != 0 -a "$buname" = "GESA" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESAbadfiles."
fi

#Archiving & Rejecting the GESI Source files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GESI" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESIarchive."
elif [ $status != 0 -a "$buname" = "GESI" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESIbadfiles."
fi

#Archiving & Rejecting the GCC Source files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "TCW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TCWarchive."
elif [ $status != 0 -a "$buname" = "TCW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TCWbadfiles."
fi

#Archiving & Rejecting the TB-T007 Source files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "T007" ] ; then
echo "[Autoloader] Copying '$filetype' files to $T007archive."
elif [ $status != 0 -a "$buname" = "T007" ] ; then
echo "[Autoloader] Copying '$filetype' files to $T007badfiles."
fi


#Target Archiving
#Archiving & Rejecting the PEX Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "PEX" ] ; then
echo "[Autoloader] Copying '$filetype' files to $PEXTGTarchive."
elif [ $status != 0 -a "$buname" = "PEX" ] ; then
echo "[Autoloader] Copying '$filetype' files to $PEXTGTbadfiles."
fi

#Archiving & Rejecting the CSD Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "CSD" ] ; then
echo "[Autoloader] Copying '$filetype' files to $CSTGTDarchive."
elif [ $status != 0 -a "$buname" = "CSD" ] ; then
echo "[Autoloader] Copying '$filetype' files to $CSDTGTbadfiles."
fi

#Archiving & Rejecting the GCC Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GCC" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GCCTGTarchive."
elif [ $status != 0 -a "$buname" = "GCC" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GCCTGTbadfiles."
fi

#Archiving & Rejecting the TW Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "TW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TWTGTarchive."
elif [ $status != 0 -a "$buname" = "TW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TWTGTbadfiles."
fi

#Archiving & Rejecting the GESA Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GESA" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESATGTarchive."
elif [ $status != 0 -a "$buname" = "GESA" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESATGTbadfiles."
fi

#Archiving & Rejecting the GESI Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "GESI" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESITGTarchive."
elif [ $status != 0 -a "$buname" = "GESI" ] ; then
echo "[Autoloader] Copying '$filetype' files to $GESITGTbadfiles."
fi

#Archiving & Rejecting the TCW Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "TCW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TCWTGTarchive."
elif [ $status != 0 -a "$buname" = "TCW" ] ; then
echo "[Autoloader] Copying '$filetype' files to $TCWTGTbadfiles."
fi

#Archiving & Rejecting the T007 Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "T007" ] ; then
echo "[Autoloader] Copying '$filetype' files to $T007TGTarchive."
elif [ $status != 0 -a "$buname" = "T007" ] ; then
echo "[Autoloader] Copying '$filetype' files to $T007TGTbadfiles."
fi

#Archiving & Rejecting the BTS Target files and update the message in the LND Mails
if [ $status = 0 -a "$buname" = "BTS" ] ; then
echo "[Autoloader] Copying '$filetype' files to $BTSTGTarchive."
elif [ $status != 0 -a "$buname" = "BTS" ] ; then
echo "[Autoloader] Copying '$filetype' files to $BTSTGTbadfiles."
fi

#Move files
    #cp $inboundfolder/$file* $Destinationfolder
    rm -f $org_inbound/$file*

echo "[Autoloader] Removing Temporary files."
    rm -f $workdir/lock_org.out
    rm -f $tempdir/returncode.txt
    #rm -f $tempdir/wfreturncode.txt
    rm -f $tempdir/dependency*
    rm -f $infasrcdir/*$filetype*
    rm -f $infasrcdir/field_validation.txt
}

ParPosProc()
{
	trigproc=$1

	echo "Trigger tels_PARTICIPANT_POSITION Store procedure:$trigproc"
	#if [ "$trigproc" = '' -o "$trigproc" = 0 ] ; then
	if [ "$trigproc" = 0 ] ; then
	echo "tels_PARTICIPANT_POSITION procedure refresh is not Enabled ."
	#exit 225
	else
	echo "Calling tels_PARTICIPANT_POSITION Proc"
	`sqlplus -s $dbtrnusername@$dbconnstring/$dbtrnpassword <<EOF>$infatgtdir/tels_par_pos_refresh.log
	set serveroutput on size 100000;
	execute tels_all_Participant_position;
	exit SQL.SQLCODE;
	EOF`
	errcd1=$?
	cat $infatgtdir/tels_par_pos_refresh.log
	if [ $errcd1 != 0 ]; then
	echo error in tels_all_Participant_position Proc,process exited with error code $errcd1
	exit $errcd1
	fi
	echo "tels_PARTICIPANT_POSITION  procedure successfully completed."
	fi
}

MergeInvestigationFile()
{
	filename_mer1=$1
	cd $infatgtdir
	filecount_mer1=`wc -l $infatgtdir/$filename_mer1 | awk  '{print $1}' `
	 if [ $filecount_mer1 -gt 0 ]; then
	/bin/echo "FILENAME\tEMPLOYEE_ID\tEFFECTIVE_DATE\tFIRSTNAME\tLASTNAME\tWORK_CODE\tPLAN_ELIGIBILITY\tPLAN_NAME\tORG_UNIT_NUMBER\tDESCRIPTOR\tBU" > temp1
	cat $filename_mer1 >> temp1
	mv temp1 $filename_mer1
	else
	$filename_mer1
	fi
}
